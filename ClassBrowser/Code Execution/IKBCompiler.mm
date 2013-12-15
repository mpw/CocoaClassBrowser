//
//  IKBCompiler.m
//  ClassBrowser
//
//  Created by Graham Lee on 12/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import "IKBCompiler.h"
#include "clang/Basic/DiagnosticOptions.h"
#include "clang/Driver/Compilation.h"
#include "clang/Driver/Driver.h"
#include "clang/Driver/Tool.h"
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
    DiagnosticsEngine *diagnostics;
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
        //in case you couldn't guess, this comes from an LLVM sample project.
        NSString *executableName = [[NSProcessInfo processInfo] processName];
        std::string executable_name([executableName UTF8String]);
        std::string diagnostic_output = "";
        llvm::raw_string_ostream ostream(diagnostic_output);
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
        Args.push_back("-c");
        Args.push_back([path UTF8String]);
        OwningPtr<Compilation> C(driver.BuildCompilation(Args));
        if (!C)
        {
            if (error)
            {
                NSString *description = @(diagnostic_output.c_str());
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
                NSString *description = @(diagnostic_output.c_str());
                *error = [NSError errorWithDomain:IKBCompilerErrorDomain code:IKBCompilerErrorNoClangJob userInfo: @{NSLocalizedDescriptionKey : description}];
            }
            return nil;
        }
        
       
    }
    return self;
}

- (void)dealloc
{
    delete diagnostics;
}

@end

NSString *IKBCompilerErrorDomain = @"IKBCompilerErrorDomain";