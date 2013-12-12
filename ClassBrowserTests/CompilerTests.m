//
//  CompilerTests.m
//  ClassBrowser
//
//  Created by Graham Lee on 12/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "IKBCompiler.h"

@interface CompilerTests : XCTestCase

@end

@implementation CompilerTests

- (void)testNoArgumentsMeansNoCompiler
{
    NSError *constructionError = nil;
    XCTAssertNil([IKBCompiler compilerWithArguments:@[] error:&constructionError]);
    XCTAssertEqual(constructionError.code, IKBCompilerErrorBadArguments);
    XCTAssertEqualObjects(constructionError.domain, IKBCompilerErrorDomain);
}

- (void)testErrorCaseHandlesNullPointer
{
    XCTAssertNoThrow([IKBCompiler compilerWithArguments:@[] error:NULL]);
}

- (void)testCompilerCanBeBuiltWithArguments
{
    NSError *constructionError = nil;
    NSArray *arguments = @[ @"-fsyntax-only" ];
    XCTAssertNotNil([IKBCompiler compilerWithArguments:arguments error:&constructionError], @"I expected success but got this error: %@", constructionError);
}
@end
