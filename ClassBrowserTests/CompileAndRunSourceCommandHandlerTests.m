//
//  CompileAndRunSourceCommandHandlerTests.m
//  ClassBrowser
//
//  Created by Graham Lee on 09/01/2014.
//  Copyright (c) 2014 Project Isambard. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "IKBCommandHandler.h"
#import "IKBCompileAndRunSourceCommand.h"

@interface IKBCompileAndRunCodeCommandHandler : NSObject <IKBCommandHandler>

@end

@implementation IKBCompileAndRunCodeCommandHandler

- (BOOL)canHandleCommand:(id<IKBCommand>)command
{
    return YES;
}

- (void)executeCommand:(id<IKBCommand>)command
{
    
}

@end

@interface CompileAndRunSourceCommandHandlerTests : XCTestCase

@end

@implementation CompileAndRunSourceCommandHandlerTests

- (void)testTheHandlerWillAcceptCompileAndRunSourceCommands
{
    IKBCompileAndRunCodeCommand *command = [IKBCompileAndRunCodeCommand new];
    IKBCompileAndRunCodeCommandHandler *handler = [IKBCompileAndRunCodeCommandHandler new];
    XCTAssertTrue([handler canHandleCommand:command]);
}

@end
