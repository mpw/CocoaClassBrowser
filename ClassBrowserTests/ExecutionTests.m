//See COPYING for licence details.

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
    NSString *source = @"id obj = [NSObject new]; obj = nil; return 2;";
    [_runner doIt:source completion:^(id result, NSString *compilerTranscript, NSError *error) {
        XCTAssertEqualObjects(result, @(2), @"Transcript: %@\nError: %@", compilerTranscript, error);
    }];
}


- (void)testICanUseNormalMessagingSyntax
{
    NSString *source = @"NSDate *d = [NSDate dateWithTimeIntervalSinceReferenceDate:68000];\n\
    NSTimeInterval ticks = [d timeIntervalSinceReferenceDate];\n\
    return ticks;";

    /* When we get this wrong, Foundation actually calls abort(). */
    [_runner doIt:source completion:^(id result, NSString *compilerTranscript, NSError *error) {
        XCTAssertEqualObjects(result, @(68000), @"Transcript: %@\nError: %@", compilerTranscript, error);
    }];
}

- (void)testDefaultCompilerArgumentBuilderIsForClangAndXcode
{
    IKBCodeRunner *runner = [IKBCodeRunner new];
    id <IKBCompilerArgumentBuilder> builder = runner.compilerArgumentBuilder;
    XCTAssertEqualObjects([builder class], [IKBXcodeClangArgumentBuilder class]);
}

@end
