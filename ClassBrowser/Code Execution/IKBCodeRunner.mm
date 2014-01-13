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
#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/ExecutionEngine/JIT.h"
#include "llvm/IR/Module.h"
#include "llvm/Analysis/Verifier.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/Host.h"
#include "llvm/Support/ManagedStatic.h"
#include "llvm/Support/Path.h"
#include "llvm/Support/TargetSelect.h"
#include "llvm/Support/raw_ostream.h"
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
@"int main()\n"
@"{\n"
@"@autoreleasepool {\n"
@"%@\n"
@"}}\n";

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

- (NSString *)localizedDescriptionForJITErrorWithCode:(NSInteger)code
{
    id errorCode = @(code);
    NSDictionary *map = @{@(IKBCodeRunnerErrorCouldNotConstructRuntime): NSLocalizedString(@"LLVM could not create an execution environment.", @"Error on not building a JIT"),
                          @(IKBCodeRunnerErrorCouldNotFindFunctionToRun): NSLocalizedString(@"LLVM could not find the main() function.", @"Error on not finding the function to run")};
    return map[errorCode]?:[NSString stringWithFormat:@"An unknown llvm JIT error (code %@) occurred.", errorCode];
}

- (void)reportCompileError:(NSInteger)code withCompilerOutput:(std::string&)output toCompletionHandler:(IKBCodeRunnerCompletionHandler)completion
{
    NSString *transcript = @(output.c_str());
    NSString *errorDescription = [self localizedDescriptionForCompileErrorWithCode:code];
    NSError *error = [NSError errorWithDomain:IKBCompilerErrorDomain code:code userInfo: @{NSLocalizedDescriptionKey : errorDescription}];
    completion(nil, transcript, error);
}

- (void)reportJITError:(NSInteger)code withCompilerOutput:(std::string&)output reportedError:(std::string&)errorText toCompletionHandler:(IKBCodeRunnerCompletionHandler)completion
{
    llvm::errs() << errorText << "\n";
    NSString *failureReason = @(errorText.c_str());
    NSString *errorDescription = [self localizedDescriptionForJITErrorWithCode:code];
    NSError *error = [NSError errorWithDomain:IKBCodeRunnerErrorDomain code:code userInfo: @{NSLocalizedDescriptionKey : errorDescription,
                                                                                             NSLocalizedFailureReasonErrorKey : failureReason}];
    completion(nil, @(output.c_str()), error);
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
    for(NSString *arg in compilerArguments)
    {
        Args.push_back([arg UTF8String]);
    }
    Args.push_back([sourcePath UTF8String]);
    OwningPtr<Compilation> C(driver.BuildCompilation(Args));
    if (!C)
    {
        [self reportCompileError:IKBCompilerErrorBadArguments withCompilerOutput:diagnostic_output toCompletionHandler:completion];
        return;
    }
    // we should now be able to extract the list of jobs from that
    const driver::JobList &Jobs = C->getJobs();
    if (!canUseCompilerJobs(Jobs, diagnostics))
    {
        [self reportCompileError:IKBCompilerErrorNoClangJob withCompilerOutput:diagnostic_output toCompletionHandler:completion];
        return;
    }
    //and pull the clang invocation from the list of jobs
    driver::Command *command = cast<driver::Command>(*Jobs.begin());
    if (llvm::StringRef(command->getCreator().getName()) != "clang") {
        diagnostics.Report(diag::err_fe_expected_clang_command);
        [self reportCompileError:IKBCompilerErrorNotAClangInvocation withCompilerOutput:diagnostic_output toCompletionHandler:completion];
        return;
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
        [self reportCompileError:IKBCompilerErrorCouldNotReportUnderlyingErrors withCompilerOutput:diagnostic_output toCompletionHandler:completion];
        return;
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
        [self reportCompileError:IKBCompilerErrorInSourceCode withCompilerOutput:diagnostic_output toCompletionHandler:completion];
        return;
    }
    llvm::Module *mod = Act->takeModule();

    llvm::InitializeNativeTarget();
    std::string Error;
    OwningPtr<llvm::ExecutionEngine> EE(llvm::ExecutionEngine::createJIT(mod, &Error));
    if (!EE) {
        std::string llvmError("unable to make execution engine: ");
        llvmError += Error;
        [self reportJITError:IKBCodeRunnerErrorCouldNotConstructRuntime withCompilerOutput:diagnostic_output reportedError:llvmError toCompletionHandler:completion];
        return;
    }

    llvm::Function *EntryFn = mod->getFunction("main");
    if (!EntryFn) {
        std::string llvmError("'main' function not found in module.");
        [self reportJITError:IKBCodeRunnerErrorCouldNotFindFunctionToRun withCompilerOutput:diagnostic_output reportedError:llvmError toCompletionHandler:completion];
        return;
    }

    std::string ErrorInfo;
    if (llvm::verifyModule(*mod, llvm::PrintMessageAction, &ErrorInfo)) {
        /* If verification fails, we would crash during execution. */
        [self
         reportCompileError:IKBCompilerErrorInSourceCode
         withCompilerOutput:ErrorInfo toCompletionHandler:completion];
        return;
    }

    // FIXME: Support passing arguments.
    std::vector<std::string> jitArguments;
    jitArguments.push_back(mod->getModuleIdentifier());

    int result = EE->runFunctionAsMain(EntryFn, jitArguments, nullptr);
    NSString *transcript = @(diagnostic_output.c_str());
    completion(@(result), transcript, nil);
}

@end

NSString *IKBCompilerErrorDomain = @"IKBCompilerErrorDomain";
NSString *IKBCodeRunnerErrorDomain = @"IKBCodeRunnerErrorDomain";