//
//  IKBCompiler.m
//  ClassBrowser
//
//  Created by Graham Lee on 12/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import "IKBCompiler.h"
#include "clang/Basic/DiagnosticOptions.h"
#include "clang/Driver/Driver.h"
#include "clang/Frontend/TextDiagnosticPrinter.h"
#include "llvm/Support/Host.h"
#include "llvm/Support/raw_ostream.h"

using namespace clang;
using namespace clang::driver;

@implementation IKBCompiler
{
}

+ (instancetype)compilerWithArguments:(NSArray *)arguments error:(NSError *__autoreleasing *)error
{
    if (![arguments count])
    {
        if (error)
        {
            *error = [NSError errorWithDomain:IKBCompilerErrorDomain code:IKBCompilerErrorBadArguments userInfo:nil];
        }
        return nil;
    }
    return [[self alloc] initWithArguments:arguments error:error];
}

- (instancetype)initWithArguments:(NSArray *)arguments error:(NSError *__autoreleasing *)error
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
        DiagnosticsEngine diagnostics(diagnosticIDs, &*options, diagnosticClient);
        Driver driver(executable_name, llvm::sys::getProcessTriple(), "IKBCompiler", diagnostics);
        driver.setTitle("IKBCompiler");
        //I _think_ that all of the above could be statics, or could be in a singleton CompilerBuilder or something.
        
    }
    return self;
}

@end

NSString *IKBCompilerErrorDomain = @"IKBCompilerErrorDomain";