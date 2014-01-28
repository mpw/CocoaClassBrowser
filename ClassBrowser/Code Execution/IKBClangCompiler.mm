//
// Created by Graham Lee on 16/01/2014.
// Copyright (c) 2014 Project Isambard. All rights reserved.
//

#import "IKBClangCompiler.h"
#import "IKBCodeRunner.h"
#import "IKBLLVMBitcodeModule.h"

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
#include "llvm/IR/Verifier.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/Host.h"
#include "llvm/Support/ManagedStatic.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/Path.h"
#include "llvm/Support/StreamableMemoryObject.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/raw_ostream.h"
#pragma clang diagnostic pop

using namespace clang;
using namespace clang::driver;

BOOL canUseCompilerJobs(const driver::JobList &Jobs, DiagnosticsEngine &Diags)
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

@implementation IKBClangCompiler

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


- (IKBLLVMBitcodeModule *)bitcodeForSource:(NSString *)source compilerArguments:(NSArray *)compilerArguments compilerTranscript:(std::string&)diagnostic_output error:(NSError *__autoreleasing*)error
{
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
    driver.setCheckInputsExist(false);
    //I _think_ that all of the above could be statics, or could be in a singleton CompilerBuilder or something.
    // the trick is getting all of the ownership correct.
    SmallVector<const char *, 16> Args;
    for(NSString *arg in compilerArguments)
    {
        Args.push_back([arg UTF8String]);
    }
    //this fake file name needs to exist for the compiler to function, but we'll never try to use it.
    NSString *fakeSourcePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"emptysource" ofType:nil];
    StringRef fakeFileName = [fakeSourcePath fileSystemRepresentation];
    Args.push_back([fakeSourcePath fileSystemRepresentation]);

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

    //create a virtual file with our content
    Clang.setInvocation(CI.take());
    Clang.createFileManager();
    Clang.createSourceManager(Clang.getFileManager());
    const FileEntry *mainFileEntry = Clang.getFileManager().getVirtualFile(fakeFileName, [source lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1, time(0));
    llvm::StringRef sourceString([source UTF8String]);
    llvm::MemoryBuffer* mainFile = llvm::MemoryBuffer::getMemBuffer(sourceString);
    Clang.getSourceManager().overrideFileContents(mainFileEntry, mainFile);

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
    llvm::SmallVector<char, 128> bitcodeModule;
    llvm::raw_svector_ostream bitcodeStream(bitcodeModule);
    llvm::WriteBitcodeToFile(mod, bitcodeStream);
    llvm::StringRef bitcodeString = bitcodeStream.str();
    
    IKBLLVMBitcodeModule *module = [[IKBLLVMBitcodeModule alloc] initWithIdentifier:@(moduleName.c_str())
                                                                               data:[[NSData alloc] initWithBytes:bitcodeString.data()
                                                                                                           length:bitcodeString.size()]];
    return module;
}
@end