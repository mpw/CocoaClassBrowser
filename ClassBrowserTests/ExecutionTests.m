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

- (void)testBuildingACompilerWithTheDefaultArgumentsResultsInAnObjectiveCCompilerFrontEnd
{
    NSError *compilerConstructionError = nil;
    IKBCompiler *compiler = [_runner compilerWithArguments:[_runner compilerArguments] error:&compilerConstructionError];
    XCTAssertNotNil(compiler, @"I wanted to make a compiler but instead I got %@", compilerConstructionError);
}

@end
