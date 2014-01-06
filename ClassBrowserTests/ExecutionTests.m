//
//  ExecutionTests.m
//  ClassBrowser
//
//  Created by Graham Lee on 12/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "IKBCodeRunner.h"
#import "IKBXcodeClangArgumentBuilder.h"
#import "HumbleCompilerArgumentBuilder.h"

@interface ExecutionTests : XCTestCase

@end

@implementation ExecutionTests
{
    IKBCodeRunner *_runner;
}

- (void)setUp
{
    _runner = [[IKBCodeRunner alloc] initWithCompilerArgumentBuilder:[HumbleCompilerArgumentBuilder new]];
}

- (void)testICanRunHelloWorld
{
    NSString *source = @"#include <stdio.h>\nint main(){printf(\"Hello, world!\\n\");}";
    [_runner runSource:source completion:^(id result, NSString *compilerTranscript, NSError *error) {
        XCTAssertNil(error, @"I wanted the compiler to work but this happened: %@", error);
        XCTAssertEqualObjects(result, @0, @"An unexpected value (%@) was returned.", result);
    }];
}

- (void)testICanUseAFoundationFunction
{
    NSString *source = @"NSLog(@\"Hello, world!\"); return 1;";
    [_runner doIt:source completion:^(id result, NSString *compilerTranscript, NSError *error) {
        XCTAssertEqualObjects(result, @(1), @"Transcript: %@\nError: %@", compilerTranscript, error);
    }];
}

- (void)testICanUseAnObject
{
    NSString *source = @"SEL newSelector = sel_registerName(\"new\"); id obj = objc_msgSend(objc_getClass(\"NSObject\"), newSelector); obj = nil; return 2;";
    [_runner doIt:source completion:^(id result, NSString *compilerTranscript, NSError *error) {
        XCTAssertEqualObjects(result, @(2), @"Transcript: %@\nError: %@", compilerTranscript, error);
    }];
}

- (void)testDefaultCompilerArgumentBuilderIsForClangAndXcode
{
    IKBCodeRunner *runner = [IKBCodeRunner new];
    id <IKBCompilerArgumentBuilder> builder = runner.compilerArgumentBuilder;
    XCTAssertEqualObjects([builder class], [IKBXcodeClangArgumentBuilder class]);
}

@end
