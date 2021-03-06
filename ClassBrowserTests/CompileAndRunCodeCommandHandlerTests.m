//See COPYING for licence details.

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "XCTest+Async.h"

#import "IKBCodeRunner.h"
#import "IKBCommandHandler.h"
#import "IKBCompileAndRunCodeCommand.h"
#import "IKBCompileAndRunCodeCommandHandler.h"

@interface HumbleCodeRunner : IKBCodeRunner
@end

@implementation HumbleCodeRunner

- (void)doIt:(NSString *)objectiveCSource completion:(IKBCodeRunnerCompletionHandler)completion {
    completion(nil, nil, nil);
}

@end

@interface CompileAndRunCodeCommandHandlerTests : XCTestCase
{
    IKBCompileAndRunCodeCommandHandler *_handler;
    IKBCompileAndRunCodeCommand *_command;
}

@end

@implementation CompileAndRunCodeCommandHandlerTests

- (void)setUp
{
    _handler = [IKBCompileAndRunCodeCommandHandler new];
    _command = [IKBCompileAndRunCodeCommand new];
    _command.source = @"Test Source";
    _command.completion = ^(id result, NSString *transcript, NSError *error) {
        
    };
}

- (void)testTheHandlerWillAcceptCompileAndRunSourceCommands
{
    XCTAssertTrue([_handler canHandleCommand:_command]);
}

- (void)testHandlerDoesNotAcceptAnyOldCommand
{
    XCTAssertFalse([_handler canHandleCommand:(id)@"Not the expected command"]);
}

- (void)testExecutionInvolvesRunningTheCode
{
    id mockRunner = [OCMockObject mockForClass:[IKBCodeRunner class]];
    [[mockRunner expect] doIt:_command.source completion:OCMOCK_ANY];
    _handler.codeRunner = mockRunner;
    [_handler executeCommand:_command];
    [mockRunner verify];
}

- (void)testHandlerHasARunnerByDefault
{
    XCTAssertTrue([_handler.codeRunner isKindOfClass:[IKBCodeRunner class]]);
}

- (void)testCompletionBlockRunsOnMainThread
{
    ASYNC_TEST_START;
    __block BOOL didRunOnMainThread = NO;
    _command.completion = ^(id result, NSString *transcript, NSError *error) {
        didRunOnMainThread = [NSThread isMainThread];
        ASYNC_TEST_DONE;
    };
    _handler.codeRunner = [HumbleCodeRunner new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_handler executeCommand:_command];
    });
    ASYNC_TEST_END;
    XCTAssertTrue(didRunOnMainThread);
}
@end
