//See COPYING for licence details.

#import "IKBCodeRunner.h"
#import "IKBXcodeClangArgumentBuilder.h"

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
#include "llvm/ExecutionEngine/JIT.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/TypeBuilder.h"
#include "llvm/Analysis/Verifier.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/Host.h"
#include "llvm/Support/ManagedStatic.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/Path.h"
#include "llvm/Support/StreamableMemoryObject.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/raw_ostream.h"
#import "IKBLLVMBitcodeModule.h"
#pragma clang diagnostic pop

using namespace clang;
using namespace clang::driver;

BOOL canUseCompilerJobs (const driver::JobList& Jobs, DiagnosticsEngine &Diags)
{
    BOOL result = YES;
    if (Jobs.size() != 1 || !isa<driver::Command>(*Jobs.begin())) {
        SmallString<256> Msg;
        llvm::raw_svector_ostream OS(Msg);
        OS << "size: " << Jobs.size();
        Jobs.Print(OS, "; ", true);
        Diags.Report(diag::err_fe_expected_compiler_job) << OS.str();
        result = NO;
    }
    return result;
}

@implementation IKBCodeRunner

- (instancetype)init
{
    return [self initWithCompilerArgumentBuilder:[IKBXcodeClangArgumentBuilder new]];
}

- (instancetype)initWithCompilerArgumentBuilder:(id <IKBCompilerArgumentBuilder>)builder
{
    self = [super init];
    if (self)
    {
        _compilerArgumentBuilder = builder;
    }
    return self;
}

static const NSString *objcMainWrapper = @"#import <Cocoa/Cocoa.h>\n"
@"#import <objc/runtime.h>\n"
@"#import <objc/message.h>\n"
@"id doItMain()\n"
@"{\n"
@"%@\n"
@"}\n";

- (void)doIt:(NSString *)objectiveCSource completion:(IKBCodeRunnerCompletionHandler)completion
{
    NSString *mainProgram = [NSString stringWithFormat:(NSString *)objcMainWrapper,objectiveCSource];
    [self runSource:mainProgram completion:completion];
}

- (NSString *)localizedDescriptionForCompileErrorWithCode:(NSInteger)code
{
    id errorCode = @(code);
    NSDictionary *map = @{@(IKBCompilerErrorBadArguments): NSLocalizedString(@"The arguments passed to the compiler were not recognized.", @"Error message on bad compiler arguments"),
                          @(IKBCompilerErrorNoClangJob): NSLocalizedString(@"The compiler driver did not create a compiler front-end task.", @"Error message on no clang job"),
                          @(IKBCompilerErrorNotAClangInvocation): NSLocalizedString(@"The compiler driver created a front-end task that was not for the C front-end.", @"Error message on not a clang task"),
                          @(IKBCompilerErrorCouldNotReportUnderlyingErrors): NSLocalizedString(@"The compiler was cancelled because it would not be able to report further errors.", @"Error message on not being able to report underlying errors"),
                          @(IKBCompilerErrorInSourceCode): NSLocalizedString(@"An error in the source code stopped the compiler from producing output.", @"Error on compiler failure"),
                          };
    return map[errorCode]?:[NSString stringWithFormat:@"An unknown compiler error (code %@) occurred.", errorCode];
}

- (NSError *)compilerErrorWithCode:(NSInteger)code compilerOutput:(std::string&)output
{
    NSString *errorDescription = [self localizedDescriptionForCompileErrorWithCode:code];
    NSError *error = [NSError errorWithDomain:IKBCompilerErrorDomain code:code userInfo: @{NSLocalizedDescriptionKey : errorDescription}];
    return error;
}

- (void)runSource:(NSString *)source completion:(IKBCodeRunnerCompletionHandler)completion
{
    __weak typeof(self) weakSelf = self;
    [self.compilerArgumentBuilder constructCompilerArgumentsWithCompletion:^(NSArray *arguments, NSError *error){
        typeof(self) strongSelf = weakSelf;
        if (arguments) {
            [strongSelf compileAndRunSource:source compilerArguments:arguments completion:completion];
        } else {
            completion(nil, nil, error);
        }
    }];
}

- (IKBLLVMBitcodeModule *)bitcodeForSource:(NSString *)source compilerArguments:(NSArray *)compilerArguments compilerTranscript:(std::string&)diagnostic_output error:(NSError *__autoreleasing*)error
{
    NSString *temporaryPathTemplate = [NSTemporaryDirectory() stringByAppendingPathComponent:@"IKBCodeRunner.XXXXXX"];
    const char * fileTemplate = [temporaryPathTemplate fileSystemRepresentation];
    char *filename = static_cast<char *>(malloc(strlen(fileTemplate) + 1));
    strncpy(filename, fileTemplate, strlen(fileTemplate) + 1);
    int fd = mkstemp(filename);
    NSString *sourcePath = @(filename);
    free(filename);
    NSData *sourceData = [source dataUsingEncoding:NSUTF8StringEncoding];
    write(fd, [sourceData bytes], [sourceData length]);
    close(fd);

    NSString *executableName = [[NSProcessInfo processInfo] processName];
    //in case you couldn't guess, this comes from an LLVM sample project.
    std::string executable_name([executableName UTF8String]);
    llvm::raw_string_ostream ostream(diagnostic_output);
    IntrusiveRefCntPtr<DiagnosticOptions> options = new DiagnosticOptions;
    TextDiagnosticPrinter *diagnosticClient = new TextDiagnosticPrinter(ostream, &*options);
    IntrusiveRefCntPtr<DiagnosticIDs> diagnosticIDs(new DiagnosticIDs());
    DiagnosticsEngine diagnostics(diagnosticIDs, &*options, diagnosticClient);
    Driver driver(executable_name, llvm::sys::getProcessTriple(), "a.out", diagnostics);
    driver.setTitle("clang");
    //I _think_ that all of the above could be statics, or could be in a singleton CompilerBuilder or something.
    // the trick is getting all of the ownership correct.
    SmallVector<const char *, 16> Args;
    for(NSString *arg in compilerArguments)
    {
        Args.push_back([arg UTF8String]);
    }
    Args.push_back([sourcePath UTF8String]);
    OwningPtr<Compilation> C(driver.BuildCompilation(Args));
    if (!C)
    {
        if (error)
        {
            *error = [self compilerErrorWithCode:IKBCompilerErrorBadArguments compilerOutput:diagnostic_output];
        }
        return nil;
    }
    // we should now be able to extract the list of jobs from that
    const driver::JobList &Jobs = C->getJobs();
    if (!canUseCompilerJobs(Jobs, diagnostics))
    {
        if (error)
        {
            *error = [self compilerErrorWithCode:IKBCompilerErrorNoClangJob compilerOutput:diagnostic_output];
        }
        return nil;
    }
    //and pull the clang invocation from the list of jobs
    driver::Command *command = cast<driver::Command>(*Jobs.begin());
    if (llvm::StringRef(command->getCreator().getName()) != "clang") {
        diagnostics.Report(diag::err_fe_expected_clang_command);
        if (error)
        {
            *error = [self compilerErrorWithCode:IKBCompilerErrorNotAClangInvocation compilerOutput:diagnostic_output];
        }
        return nil;
    }
    const driver::ArgStringList &CCArgs = command->getArguments();
    OwningPtr<CompilerInvocation> CI(new CompilerInvocation);
    CompilerInvocation::CreateFromArgs(*CI,
                                       const_cast<const char **>(CCArgs.data()),
                                       const_cast<const char **>(CCArgs.data()) +
                                               CCArgs.size(),
                                       diagnostics);
    CompilerInstance Clang;
    Clang.setInvocation(CI.take());

    // Create the compilers actual diagnostics engine.
    Clang.createDiagnostics();
    if (!Clang.hasDiagnostics())
    {
        if (error)
        {
            *error = [self compilerErrorWithCode:IKBCompilerErrorCouldNotReportUnderlyingErrors compilerOutput:diagnostic_output];
        }
        return nil;
    }

    // Infer the builtin include path if unspecified.
    if (Clang.getHeaderSearchOpts().UseBuiltinIncludes &&
            Clang.getHeaderSearchOpts().ResourceDir.empty())
    {
        Clang.getHeaderSearchOpts().ResourceDir = [NSHomeDirectory() fileSystemRepresentation];
    }

    // Create and execute the frontend to generate an LLVM bitcode module.
    OwningPtr<CodeGenAction> Act(new EmitLLVMOnlyAction());
    if (!Clang.ExecuteAction(*Act))
    {
        if (error)
        {
            *error = [self compilerErrorWithCode:IKBCompilerErrorInSourceCode compilerOutput:diagnostic_output];
        }
        return nil;
    }
    llvm::Module *mod = Act->takeModule();
    std::string moduleName = mod->getModuleIdentifier();
    std::string bitcodeModule;
    llvm::raw_string_ostream bitcodeStream(bitcodeModule);
    llvm::WriteBitcodeToFile(mod, bitcodeStream);
    bitcodeStream.flush();

    IKBLLVMBitcodeModule *module = [[IKBLLVMBitcodeModule alloc] initWithIdentifier:@(moduleName.c_str())
                                                                               data:[[NSData alloc] initWithBytes:bitcodeModule.c_str()
                                                                                                           length:bitcodeModule.size()]];
    return module;
}

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
    std::string moduleReloadingError;
    llvm::LLVMContext context;

    llvm::StringRef bitcodeBytes = llvm::StringRef(compiledBitcode.bitcode, compiledBitcode.bitcodeLength);
    llvm::Module *module = llvm::ParseBitcodeFile(llvm::MemoryBuffer::getMemBuffer(bitcodeBytes, moduleName),
                                                  context,
                                                  &moduleReloadingError);

    if (module == nullptr)
    {
        std::string llvmError("unable to read bitcode module: ");
        llvmError += moduleReloadingError;
        if (error)
        {
            *error = [self JITErrorWithCode:IKBCodeRunnerErrorCouldNotLoadModule
                           diagnosticOutput:diagnostic_output
                                  errorText:llvmError];
        }
        return nil;
    }

    llvm::InitializeNativeTarget();
    std::string Error;
    OwningPtr<llvm::ExecutionEngine> EE(llvm::ExecutionEngine::createJIT(module, &Error));
    if (!EE)
    {
        std::string llvmError("unable to make execution engine: ");
        llvmError += Error;
        if (error)
        {
            *error = [self JITErrorWithCode:IKBCodeRunnerErrorCouldNotConstructRuntime
                           diagnosticOutput:diagnostic_output
                                  errorText:llvmError];
        }
        return nil;
    }

    llvm::Function *EntryFn = module->getFunction("doItMain");
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

    std::string ErrorInfo;
    if (llvm::verifyModule(*module, llvm::PrintMessageAction, &ErrorInfo))
    {
        /* If verification fails, we would crash during execution. */
        if (error)
        {
            *error = [self JITErrorWithCode:IKBCodeRunnerErrorModuleFailedVerification
                           diagnosticOutput:diagnostic_output
                                  errorText:ErrorInfo];
        }
        return nil;
    }

    // FIXME: Support passing arguments.
    std::vector<std::string> jitArguments;
    jitArguments.push_back(module->getModuleIdentifier());

    std::vector<llvm::GenericValue> functionArguments;
    llvm::GenericValue result = EE->runFunction(EntryFn, functionArguments);
    id returnedObject = (__bridge id)GVTOP(result);
    return returnedObject;
}

- (void)compileAndRunSource:(NSString *)source compilerArguments:(NSArray *)compilerArguments completion:(IKBCodeRunnerCompletionHandler)completion
{
    std::string diagnostic_output;
    NSError *compilerError = nil;

    IKBLLVMBitcodeModule *compiledBitcode = [self bitcodeForSource:source
                                                 compilerArguments:compilerArguments
                                                compilerTranscript:diagnostic_output
                                                             error:&compilerError];
    if (compiledBitcode == nil)
    {
        NSString *diagnosticText = @(diagnostic_output.c_str());
        completion(nil, diagnosticText, compilerError);
        return;
    }

    NSError *jitError = nil;

    id result = [self objectByRunningFunctionWithName:@"doItMain"
                                             inModule:compiledBitcode
                                   compilerTranscript:diagnostic_output
                                                error:&jitError];
    completion(result, @(diagnostic_output.c_str()), jitError);
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
+ (void)fixupSelectorsInModule:(llvm::Module *)Module
{
#define FIXUP_DEBUG (0)
#if FIXUP_DEBUG
    printf("\n\n[[MODULE BEFORE:\n");
    Module->dump();
    printf("\nEND MODULE BEFORE]]\n");
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
            llvm::LoadInst *Selector = dyn_cast<llvm::LoadInst>(*I);
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
    printf("\n\n[[MODULE AFTER:\n");
    Module->dump();
    printf("\nEND MODULE AFTER]]\n");
#endif  // FIXUP_DEBUG
}

@end

NSString *IKBCompilerErrorDomain = @"IKBCompilerErrorDomain";
NSString *IKBCodeRunnerErrorDomain = @"IKBCodeRunnerErrorDomain";