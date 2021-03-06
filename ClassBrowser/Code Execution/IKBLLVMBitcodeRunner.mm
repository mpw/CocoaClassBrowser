//See COPYING for licence details.

#import "IKBLLVMBitcodeRunner.h"
#import "IKBLLVMBitcodeModule.h"
#import "IKBCodeRunner.h"

#import "ClangUndefs.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wconversion"
#include "clang/Basic/DiagnosticOptions.h"
#include "clang/CodeGen/CodeGenAction.h"
#include "clang/Driver/Compilation.h"
#include "clang/Frontend/CompilerInvocation.h"
#include "clang/Driver/Driver.h"
#include "clang/Driver/Tool.h"
#include "clang/Frontend/CompilerInstance.h"
#include "clang/Frontend/CompilerInvocation.h"
#include "clang/Frontend/FrontendDiagnostic.h"
#include "clang/Frontend/TextDiagnosticPrinter.h"
#include "llvm/Bitcode/BitstreamReader.h"
#include "llvm/Bitcode/ReaderWriter.h"
#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/ExecutionEngine/GenericValue.h"
#include "llvm/ExecutionEngine/MCJIT.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/TypeBuilder.h"
#include "llvm/IR/Verifier.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/Host.h"
#include "llvm/Support/ManagedStatic.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/Path.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/raw_ostream.h"
#pragma clang diagnostic pop

#import <objc/runtime.h>

using namespace clang;
using namespace clang::driver;

@interface IKBExecutionEngine : NSObject

- (instancetype)initWithEngine:(llvm::ExecutionEngine *)engine;

@end

@implementation IKBExecutionEngine
{
    std::unique_ptr<llvm::ExecutionEngine>_engine;
}

- (instancetype)initWithEngine:(llvm::ExecutionEngine *)engine
{
    self = [super init];
    if (self) {
        _engine = std::unique_ptr<llvm::ExecutionEngine>(engine);
    }
    return self;
}

@end

@implementation IKBLLVMBitcodeRunner

- (NSString *)localizedDescriptionForJITErrorWithCode:(NSInteger)code
{
    id errorCode = @(code);
    NSDictionary *map = @{@(IKBCodeRunnerErrorCouldNotConstructRuntime): NSLocalizedString(@"LLVM could not create an execution environment.", @"Error on not building a JIT"),
            @(IKBCodeRunnerErrorCouldNotFindFunctionToRun): NSLocalizedString(@"LLVM could not find the main() function.", @"Error on not finding the function to run"),
            @(IKBCodeRunnerErrorCouldNotLoadModule): NSLocalizedString(@"LLVM could not read the bitcode module.", @"Error on failing to read an LLVM module"),
            @(IKBCodeRunnerErrorModuleFailedVerification): NSLocalizedString(@"LLVM could not verify the bitcode module.", @"Error on failing to verify an LLVM module"),
    };

    return map[errorCode]?:[NSString stringWithFormat:@"An unknown llvm JIT error (code %@) occurred.", errorCode];
}


- (NSError *)JITErrorWithCode:(NSInteger)code diagnosticOutput:(std::string&)diagnostic_output errorText:(std::string&)llvmError
{
    llvm::errs() << llvmError << "\n";
    NSString *failureReason = @(llvmError.c_str());
    NSString *errorDescription = [self localizedDescriptionForJITErrorWithCode:code];
    NSError *error = [NSError errorWithDomain:IKBCodeRunnerErrorDomain code:code userInfo: @{NSLocalizedDescriptionKey : errorDescription,
            NSLocalizedFailureReasonErrorKey : failureReason}];
    return error;
}

- (id)objectByRunningFunctionWithName:(NSString *)name inModule:(IKBLLVMBitcodeModule *)compiledBitcode compilerTranscript:(std::string&)diagnostic_output error:(NSError *__autoreleasing*)error
{
    std::string moduleName([compiledBitcode.moduleIdentifier UTF8String]);
    llvm::LLVMContext context;

    llvm::StringRef bitcodeBytes = llvm::StringRef(compiledBitcode.bitcode, compiledBitcode.bitcodeLength);
    std::unique_ptr<llvm::MemoryBuffer> memBuffer = llvm::MemoryBuffer::getMemBuffer(bitcodeBytes, moduleName, false);
    llvm::ErrorOr<std::unique_ptr<llvm::Module>> parseResult = llvm::parseBitcodeFile(memBuffer.get()->getMemBufferRef(),
                                                  context);

    if (parseResult.getError().value() != 0)
    {
        std::string llvmError("unable to read bitcode module: ");
        llvmError += parseResult.getError().message();
        if (error)
        {
            *error = [self JITErrorWithCode:IKBCodeRunnerErrorCouldNotLoadModule
                           diagnosticOutput:diagnostic_output
                                  errorText:llvmError];
        }
        return nil;
    }

    LLVMLinkInMCJIT();
    llvm::InitializeNativeTargetAsmPrinter();
    llvm::InitializeNativeTargetAsmParser();
    llvm::InitializeNativeTarget();
    std::string Error;
    auto module = std::move(parseResult.get());

    
    llvm::Function *EntryFn = module->getFunction([name UTF8String]);
    if (!EntryFn)
    {
        std::string llvmError("'doItMain()' function not found in module.");
        if (error)
        {
            *error = [self JITErrorWithCode:IKBCodeRunnerErrorCouldNotFindFunctionToRun
                           diagnosticOutput:diagnostic_output
                                  errorText:llvmError];
        }
        return nil;
    }
    
    [self.class fixupSelectorsInModule:module];
    
    llvm::raw_string_ostream ostream(Error);
    if (llvm::verifyModule(*module, &ostream))
    {
        /* If verification fails, we would crash during execution. */
        if (error)
        {
            ostream.flush();
            *error = [self JITErrorWithCode:IKBCodeRunnerErrorModuleFailedVerification
                           diagnosticOutput:diagnostic_output
                                  errorText:Error];
        }
        return nil;
    }

    std::string EngineBuildError;
    std::unique_ptr<llvm::ExecutionEngine> EE(llvm::EngineBuilder(std::move(module)).setErrorStr(&EngineBuildError).create());
    if (!EE)
    {
        std::string llvmError("unable to make execution engine: ");
        llvmError += EngineBuildError;
        if (error)
        {
            *error = [self JITErrorWithCode:IKBCodeRunnerErrorCouldNotConstructRuntime
                           diagnosticOutput:diagnostic_output
                                  errorText:llvmError];
        }
        return nil;
    }

    EE->finalizeObject();
    
    llvm::ArrayRef<llvm::GenericValue> functionArguments;
    llvm::GenericValue result = EE->runFunction(EntryFn, functionArguments);
    id returnedObject = (__bridge id)GVTOP(result);
    
    IKBExecutionEngine *engineOwner = [[IKBExecutionEngine alloc] initWithEngine:EE.release()];
    objc_setAssociatedObject(returnedObject, "ExecutionEngine", engineOwner, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return returnedObject;
}

/** Returns true if \p GV is a reference to a selector. */
bool
isSelectorReference(const llvm::GlobalValue &GV)
{
    /* We're looking for something like:
     *  @"\01L_OBJC_SELECTOR_REFERENCES_" = internal externally_initialized
     *    global i8* getelementptr inbounds
     *    ([5 x i8]* @"\01L_OBJC_METH_VAR_NAME_", i32 0, i32 0),
     *    section "__DATA, __objc_selrefs, literal_pointers, no_dead_strip"
     *
     * Rather than checking the name, we look at the section the value has been
     * placed in.
     */
    const std::string &Section = GV.getSection();
    bool IsSelRef = (Section.find("__objc_selrefs") != std::string::npos);
    return IsSelRef;
}

/** Replaces all references to selectors with references to
 *  sel_getUid(selector).
 *
 *  This avoids the "does not match selector known to Objective C runtime"
 *  exception encountered without this level of indirection. */
+ (void)fixupSelectorsInModule:(std::unique_ptr<llvm::Module>&)Module
{
#define FIXUP_DEBUG (0)
#if FIXUP_DEBUG
    fprintf(stderr, "\n\n[[MODULE BEFORE:\n");
    Module->dump();
    fprintf(stderr, "\nEND MODULE BEFORE]]\n");
#endif  // FIXUP_DEBUG

    llvm::FunctionType *CharPtrToCharPtrType = llvm::TypeBuilder<
    llvm::types::i<8>*(llvm::types::i<8>*),
    true>::get(Module->getContext());
    llvm::Constant *SelGetName = Module->getOrInsertFunction(
            "sel_getName", CharPtrToCharPtrType);
    llvm::Constant *SelGetUid = Module->getOrInsertFunction(
            "sel_getUid", CharPtrToCharPtrType);

    llvm::Module::GlobalListType& Globals = Module->getGlobalList();
    for (llvm::Module::GlobalListType::iterator
                 I = Globals.begin(), E = Globals.end(); I != E; ++I) {
        llvm::GlobalValue &GV = *I;
        if (!isSelectorReference(GV)) continue;

        /*
         for each use of GV:
             generate name = sel_getName("selector")
             generate sel_getUid(name) instruction
             for each user of the original use's value:
                 make it use the sel_getUid call result instead
                 (use Value::replaceAllUsesWith)
         */
        for (llvm::Value::use_iterator I = GV.use_begin(), E = GV.use_end();
             I != E; ++I) {
            llvm::LoadInst *Selector = dyn_cast<llvm::LoadInst>(I->getUser());
            if (!Selector) continue;

            llvm::CallInst *SelGetNameCall = llvm::CallInst::Create(
                    SelGetName, Selector, "selector_name");
            llvm::CallInst *SelGetUidCall = llvm::CallInst::Create(
                    SelGetUid, SelGetNameCall, "registered_selector");

            Selector->replaceAllUsesWith(SelGetUidCall);

            /* Our sel_getName() was also a user, so it's now using itself as
             * its first argument. Fix that. */
            SelGetNameCall->setArgOperand(0, Selector);

            /* Patch the new call instructions into the basic block. */
            llvm::BasicBlock *BB = Selector->getParent();
            llvm::BasicBlock::InstListType &InstList = BB->getInstList();
            InstList.insertAfter(Selector, SelGetNameCall);
            InstList.insertAfter(SelGetNameCall, SelGetUidCall);
        }
    }

#if FIXUP_DEBUG
    fprintf(stderr,"\n\n[[MODULE AFTER:\n");
    Module->dump();
    fprintf(stderr,"\nEND MODULE AFTER]]\n");
#endif  // FIXUP_DEBUG
}

@end
