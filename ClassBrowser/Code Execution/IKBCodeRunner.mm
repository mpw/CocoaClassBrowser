//
//  IKBCodeRunner.m
//  ClassBrowser
//
//  Created by Graham Lee on 12/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import "IKBCodeRunner.h"

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
#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/ExecutionEngine/JIT.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/Host.h"
#include "llvm/Support/ManagedStatic.h"
#include "llvm/Support/Path.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/raw_ostream.h"

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

static const NSString *objcMainWrapper = @"#import <Cocoa/Cocoa.h>\n"
@"int main()\n"
@"{\n"
@"@autoreleasepool {\n"
@"%@\n"
@"}}\n";

- (id)doIt:(NSString *)objectiveCSource error:(NSError *__autoreleasing *)error
{
    NSString *mainProgram = [NSString stringWithFormat:(NSString *)objcMainWrapper,objectiveCSource];
    int returnValue = [self resultOfRunningSource:mainProgram error:error];
    return @(returnValue);
}

- (NSArray *)compilerArguments
{
    return @[@"-fsyntax-only"];
}

- (int)resultOfRunningSource:(NSString *)source error:(NSError *__autoreleasing *)error
{
    const char * fileTemplate = "/tmp/IKBCodeRunner.XXXXXX";
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
    std::string diagnostic_output;
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
    // yes, I'm ignoring the arguments for now
    Args.push_back("-fsyntax-only");
    Args.push_back("-x");
    Args.push_back("objective-c");
    Args.push_back("-isysroot");
    //we should find the SDK_ROOT from a preference (and maybe use xcode-select's path)
    Args.push_back("/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk");
    //not sure why this isn't picked up, but again it should be discovered
    Args.push_back("-I");
    Args.push_back("/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/5.0/include");
    Args.push_back("-fobjc-arc");
    Args.push_back("-framework");
    Args.push_back("Cocoa");
    Args.push_back("-c");
    Args.push_back([sourcePath UTF8String]);
    OwningPtr<Compilation> C(driver.BuildCompilation(Args));
    if (!C)
    {
        if (error)
        {
            NSString *description = @(diagnostic_output.c_str());
            *error = [NSError errorWithDomain:IKBCompilerErrorDomain code:IKBCompilerErrorBadArguments userInfo: @{NSLocalizedDescriptionKey : description}];
        }
        return 0;
    }
    // we should now be able to extract the list of jobs from that
    const driver::JobList &Jobs = C->getJobs();
    if (!canUseCompilerJobs(Jobs, diagnostics))
    {
        if (error)
        {
            NSString *description = @(diagnostic_output.c_str());
            *error = [NSError errorWithDomain:IKBCompilerErrorDomain code:IKBCompilerErrorNoClangJob userInfo: @{NSLocalizedDescriptionKey : description}];
        }
        return 0;
    }
    //and pull the clang invocation from the list of jobs
    driver::Command *command = cast<driver::Command>(*Jobs.begin());
    if (llvm::StringRef(command->getCreator().getName()) != "clang") {
        diagnostics.Report(diag::err_fe_expected_clang_command);
        if (error)
        {
            *error = [NSError errorWithDomain:IKBCompilerErrorDomain code:IKBCompilerErrorNotAClangInvocation userInfo: @{NSLocalizedDescriptionKey : @(diagnostic_output.c_str())}];
        }
        return 0;
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
            *error = [NSError errorWithDomain:IKBCompilerErrorDomain code:IKBCompilerErrorCouldNotReportUnderlyingErrors userInfo: @{NSLocalizedDescriptionKey : @(diagnostic_output.c_str())}];
        }
        return 0;
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
            *error = [NSError errorWithDomain:IKBCompilerErrorDomain code:IKBCompilerErrorInSourceCode userInfo: @{NSLocalizedDescriptionKey : @(diagnostic_output.c_str())}];
        }
        return 0;
    }
    llvm::Module *mod = Act->takeModule();

    llvm::InitializeNativeTarget();
    std::string Error;
    OwningPtr<llvm::ExecutionEngine> EE(llvm::ExecutionEngine::createJIT(mod, &Error));
    if (!EE) {
        llvm::errs() << "unable to make execution engine: " << Error << "\n";
        return -1;
    }
    
    llvm::Function *EntryFn = mod->getFunction("main");
    if (!EntryFn) {
        llvm::errs() << "'main' function not found in module.\n";
        return 255;
    }
    
    // FIXME: Support passing arguments.
    std::vector<std::string> jitArguments;
    jitArguments.push_back(mod->getModuleIdentifier());
    
    int result = EE->runFunctionAsMain(EntryFn, jitArguments, nullptr);
    return result;
}

@end

NSString *IKBCompilerErrorDomain = @"IKBCompilerErrorDomain";