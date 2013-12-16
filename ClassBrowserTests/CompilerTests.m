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
{
    char *filename;
}

- (void)setUp
{
    const char * fileTemplate = "/tmp/test.XXXXXX";
    filename = malloc(strlen(fileTemplate) + 1);
    strncpy(filename, fileTemplate, strlen(fileTemplate) + 1);
    int fd = mkstemp(filename);
    const char *src = "#include <stdio.h>\nint main(){printf(\"Hello, world!\\n\");}";
    write(fd, src, strlen(src));
    close(fd);
}

- (void)tearDown
{
    unlink(filename);
}

- (void)testNoArgumentsMeansNoCompiler
{
    NSError *constructionError = nil;
    XCTAssertNil([IKBCompiler compilerWithFilename:@(filename) arguments:@[] error:&constructionError]);
    XCTAssertEqual(constructionError.code, IKBCompilerErrorBadArguments);
    XCTAssertEqualObjects(constructionError.domain, IKBCompilerErrorDomain);
}

- (void)testErrorCaseHandlesNullPointer
{
    XCTAssertNoThrow([IKBCompiler compilerWithFilename:@(filename) arguments:@[] error:NULL]);
}

- (void)testCompilerCanBeBuiltWithArguments
{
    NSString *path = @(filename);
    NSError *constructionError = nil;
    NSArray *arguments = @[ @"-fsyntax-only" ];
    XCTAssertNotNil([IKBCompiler compilerWithFilename:path arguments:arguments error:&constructionError], @"I expected success but got this error: %@", constructionError);
}

- (void)testCompilerCanRun
{
    NSString *path = @(filename);
    NSError *constructionError = nil;
    NSArray *arguments = @[ @"-fsyntax-only" ];
    IKBCompiler *compiler = [IKBCompiler compilerWithFilename:path arguments:arguments error:&constructionError];
    NSError *compilerError = nil;
    id module = [compiler compile:&compilerError];
    XCTAssertNotNil(module, @"I wanted to compile my module but I got this error: %@", compilerError);
}
@end
