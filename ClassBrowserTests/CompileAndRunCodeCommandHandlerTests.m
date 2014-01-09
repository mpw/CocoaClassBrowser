//
//  CompileAndRunSourceCommandHandlerTests.m
//  ClassBrowser
//
//  Created by Graham Lee on 09/01/2014.
//  Copyright (c) 2014 Project Isambard. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "XCTest+Async.h"

#import "IKBCodeRunner.h"
#import "IKBCommandHandler.h"
#import "IKBCompileAndRunCodeCommand.h"

@interface IKBCompileAndRunCodeCommandHandler : NSObject <IKBCommandHandler>

@property (nonatomic, strong) IKBCodeRunner *codeRunner;

@end

@implementation IKBCompileAndRunCodeCommandHandler

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.codeRunner = [IKBCodeRunner new];
    }
    return self;
}

- (BOOL)canHandleCommand:(id<IKBCommand>)command
{
    return [command isKindOfClass:[IKBCompileAndRunCodeCommand class]];
}

- (void)executeCommand:(IKBCompileAndRunCodeCommand *)command
{
    [self.codeRunner doIt:command.source completion:command.completion];
}

@end

@interface HumbleCodeRunner : IKBCodeRunner
@end

@implementation HumbleCodeRunner

- (void)doIt:(NSString *)objectiveCSource completion:(IKBCodeRunnerCompletionHandler)completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        completion(nil, nil, nil);
    });
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
    [[mockRunner expect] doIt:_command.source completion:_command.completion];
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
    _command.completion = ^(id result, NSString *transcript, NSError *error) {
        XCTAssertTrue([NSThread isMainThread]);
        ASYNC_TEST_DONE;
    };
    _handler.codeRunner = [HumbleCodeRunner new];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_handler executeCommand:_command];
    });
    ASYNC_TEST_END;
}
@end
