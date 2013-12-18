//
//  ExecutionTests.m
//  ClassBrowser
//
//  Created by Graham Lee on 12/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "IKBCodeRunner.h"

@interface ExecutionTests : XCTestCase

@end

@implementation ExecutionTests
{
    IKBCodeRunner *_runner;
}

- (void)setUp
{
    _runner = [IKBCodeRunner new];
}

- (void)testDefaultCompilerArgumentsSpecifySyntaxOnly
{
    NSArray *arguments = [_runner compilerArguments];
    XCTAssertTrue([arguments containsObject:@"-fsyntax-only"]);
}

- (void)testICanRunHelloWorld
{
    NSString *source = @"#include <stdio.h>\nint main(){printf(\"Hello, world!\\n\");}";
    NSError *error = nil;
    int result = [_runner resultOfRunningSource:source error:&error];
    XCTAssertEqual(result, 0, @"I wanted the compiler to work but this happened: %@", error);
}

- (void)testICanUseAFoundationFunction
{
    NSString *source = @"NSLog(@\"Hello, world!\"); return 1;";
    NSError *error = nil;
    XCTAssertEqualObjects([_runner doIt:source error:&error], @(1), @"I wanted to run some Foundation code but got this: %@", error);
}

- (void)testICanUseAnObject
{
    NSString *source = @"SEL newSelector = sel_registerName(\"new\"); id obj = objc_msgSend(objc_getClass(\"NSObject\"), newSelector); obj = nil; return 2;";
    NSError *error = nil;
    XCTAssertEqualObjects([_runner doIt:source error:&error], @(2), @"I got this error: %@", error);
}
@end
