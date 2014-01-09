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
    return YES;
}

- (void)executeCommand:(id<IKBCommand>)command
{
    
}

@end

@interface CompileAndRunCodeCommandHandlerTests : XCTestCase

@end

@implementation CompileAndRunCodeCommandHandlerTests

- (void)testTheHandlerWillAcceptCompileAndRunSourceCommands
{
    IKBCompileAndRunCodeCommand *command = [IKBCompileAndRunCodeCommand new];
    IKBCompileAndRunCodeCommandHandler *handler = [IKBCompileAndRunCodeCommandHandler new];
    XCTAssertTrue([handler canHandleCommand:command]);
}

@end
