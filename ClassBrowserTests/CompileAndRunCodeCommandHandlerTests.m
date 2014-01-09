//
//  CompileAndRunSourceCommandHandlerTests.m
//  ClassBrowser
//
//  Created by Graham Lee on 09/01/2014.
//  Copyright (c) 2014 Project Isambard. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "IKBCommandHandler.h"
#import "IKBCompileAndRunCodeCommand.h"

@interface IKBCompileAndRunCodeCommandHandler : NSObject <IKBCommandHandler>

@end

@implementation IKBCompileAndRunCodeCommandHandler

- (BOOL)canHandleCommand:(id<IKBCommand>)command
{
    return [command isKindOfClass:[IKBCompileAndRunCodeCommand class]];
}

- (void)executeCommand:(id<IKBCommand>)command
{
    
}

@end

@interface CompileAndRunCodeCommandHandlerTests : XCTestCase
{
    IKBCompileAndRunCodeCommandHandler *_handler;
}

@end

@implementation CompileAndRunCodeCommandHandlerTests

- (void)setUp
{
    _handler = [IKBCompileAndRunCodeCommandHandler new];
}

- (void)testTheHandlerWillAcceptCompileAndRunSourceCommands
{
    IKBCompileAndRunCodeCommand *command = [IKBCompileAndRunCodeCommand new];
    XCTAssertTrue([_handler canHandleCommand:command]);
}

- (void)testHandlerDoesNotAcceptAnyOldCommand
{
    XCTAssertFalse([_handler canHandleCommand:(id)@"Not the expected command"]);
}

@end
