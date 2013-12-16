//
//  IKBCompiler.m
//  ClassBrowser
//
//  Created by Graham Lee on 12/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import "IKBCompiler.h"
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
#include "llvm/Support/Host.h"
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

@implementation IKBCompiler
{
    std::string *diagnostic_output;
    DiagnosticsEngine *diagnostics;
    driver::Command *command;
    llvm::Module *module;
}

+ (instancetype)compilerWithFilename:(NSString *)path arguments:(NSArray *)arguments error:(NSError *__autoreleasing *)error;
{
    if (![arguments count])
    {
        if (error)
        {
            *error = [NSError errorWithDomain:IKBCompilerErrorDomain code:IKBCompilerErrorBadArguments userInfo:nil];
        }
        return nil;
    }
    return [[self alloc] initWithFilename:path arguments:arguments error:error];
}

- (instancetype)initWithFilename:(NSString *)path arguments:(NSArray *)arguments error:(NSError *__autoreleasing *)error
{
    self = [super init];
    if (self)
    {
        NSString *executableName = [[NSProcessInfo processInfo] processName];
        //in case you couldn't guess, this comes from an LLVM sample project.
        std::string executable_name([executableName UTF8String]);
        diagnostic_output = new std::string("");
        llvm::raw_string_ostream ostream(*diagnostic_output);
        IntrusiveRefCntPtr<DiagnosticOptions> options = new DiagnosticOptions;
        TextDiagnosticPrinter *diagnosticClient = new TextDiagnosticPrinter(ostream, &*options);
        IntrusiveRefCntPtr<DiagnosticIDs> diagnosticIDs(new DiagnosticIDs());
        diagnostics = new DiagnosticsEngine(diagnosticIDs, &*options, diagnosticClient);
        Driver driver(executable_name, llvm::sys::getProcessTriple(), "a.out", *diagnostics);
        driver.setTitle("clang");
        //I _think_ that all of the above could be statics, or could be in a singleton CompilerBuilder or something.
        // the trick is getting all of the ownership correct.
        SmallVector<const char *, 16> Args;
        // yes, I'm ignoring the arguments for now
        Args.push_back("-fsyntax-only");
        Args.push_back("-x");
        Args.push_back("objective-c");
        // next one should rely on some SDK_ROOT setting
        Args.push_back("-I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk/usr/include");
        Args.push_back("-c");
        Args.push_back([path UTF8String]);
        OwningPtr<Compilation> C(driver.BuildCompilation(Args));
        if (!C)
        {
            if (error)
            {
                NSString *description = @(diagnostic_output->c_str());
                *error = [NSError errorWithDomain:IKBCompilerErrorDomain code:IKBCompilerErrorBadArguments userInfo: @{NSLocalizedDescriptionKey : description}];
            }
            return nil;
        }
        // we should now be able to extract the list of jobs from that
        const driver::JobList &Jobs = C->getJobs();
        if (!canUseCompilerJobs(Jobs, *diagnostics))
        {
            if (error)
            {
                NSString *description = @(diagnostic_output->c_str());
                *error = [NSError errorWithDomain:IKBCompilerErrorDomain code:IKBCompilerErrorNoClangJob userInfo: @{NSLocalizedDescriptionKey : description}];
            }
            return nil;
        }
        //and pull the clang invocation from the list of jobs
        command = cast<driver::Command>(*Jobs.begin());
        if (llvm::StringRef(command->getCreator().getName()) != "clang") {
            diagnostics->Report(diag::err_fe_expected_clang_command);
            if (error)
            {
                *error = [NSError errorWithDomain:IKBCompilerErrorDomain code:IKBCompilerErrorNotAClangInvocation userInfo: @{NSLocalizedDescriptionKey : @(diagnostic_output->c_str())}];
            }
            return nil;
        }
        const driver::ArgStringList &CCArgs = command->getArguments();
        OwningPtr<CompilerInvocation> CI(new CompilerInvocation);
        CompilerInvocation::CreateFromArgs(*CI,
                                           const_cast<const char **>(CCArgs.data()),
                                           const_cast<const char **>(CCArgs.data()) +
                                           CCArgs.size(),
                                           *diagnostics);
        CompilerInstance Clang;
        Clang.setInvocation(CI.take());
        
        // Create the compilers actual diagnostics engine.
        Clang.createDiagnostics();
        if (!Clang.hasDiagnostics())
        {
            if (error)
            {
                *error = [NSError errorWithDomain:IKBCompilerErrorDomain code:IKBCompilerErrorCouldNotReportUnderlyingErrors userInfo: @{NSLocalizedDescriptionKey : @(diagnostic_output->c_str())}];
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
                *error = [NSError errorWithDomain:IKBCompilerErrorDomain code:IKBCompilerErrorInSourceCode userInfo: @{NSLocalizedDescriptionKey : @(diagnostic_output->c_str())}];
            }
            return nil;
        }
    }
    return self;
}

- (id)compile:(NSError *__autoreleasing *)error
{
    //it really looks like this is just going to return a module that was already compiled in -init….
    return @"";
}

- (void)dealloc
{
    delete diagnostics;
    delete diagnostic_output;
    command = nullptr;
}

@end

NSString *IKBCompilerErrorDomain = @"IKBCompilerErrorDomain";