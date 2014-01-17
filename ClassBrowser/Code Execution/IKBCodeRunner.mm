//See COPYING for licence details.

#import "IKBCodeRunner.h"
#import "IKBClangCompiler.h"
#import "IKBLLVMBitcodeModule.h"
#import "IKBLLVMBitcodeRunner.h"
#import "IKBXcodeClangArgumentBuilder.h"

@implementation IKBCodeRunner
{
    IKBClangCompiler *_clang;
    IKBLLVMBitcodeRunner *_runner;
}

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
        _clang = [IKBClangCompiler new];
        _runner = [IKBLLVMBitcodeRunner new];
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

- (void)compileAndRunSource:(NSString *)source compilerArguments:(NSArray *)compilerArguments completion:(IKBCodeRunnerCompletionHandler)completion
{
    std::string diagnostic_output;
    NSError *compilerError = nil;

    IKBLLVMBitcodeModule *compiledBitcode = [_clang bitcodeForSource:source
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

    id result = [_runner objectByRunningFunctionWithName:@"doItMain"
                                                inModule:compiledBitcode
                                      compilerTranscript:diagnostic_output
                                                   error:&jitError];
    completion(result, @(diagnostic_output.c_str()), jitError);
}

@end

NSString *IKBCompilerErrorDomain = @"IKBCompilerErrorDomain";
NSString *IKBCodeRunnerErrorDomain = @"IKBCodeRunnerErrorDomain";