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

- (void)testICanUseAFoundationFunction
{
    NSString *source = @"NSLog(@\"Hello, world!\"); return nil;";
    [_runner doIt:source completion:^(id result, NSString *compilerTranscript, NSError *error) {
        XCTAssertNil(result, @"Transcript: %@\nError: %@", compilerTranscript, error);
    }];
}

- (void)testICanMakeAnObject
{
    NSString *source = @"id obj = [NSObject new]; return obj;";
    [_runner doIt:source completion:^(id result, NSString *compilerTranscript, NSError *error) {
        XCTAssertEqualObjects([result class], [NSObject class], @"Transcript: %@\nError: %@", compilerTranscript, error);
    }];
}

- (void)testTheExecutedCodeReturnsAnObjectiveCObject
{
    NSString *source = @"return [@\"Hello\" mutableCopy];";
    [_runner doIt:source completion:^(id result, NSString *compilerTranscript, NSError *error) {
        XCTAssertEqualObjects(result, @"Hello", @"Transcript:%@\nError: %@", compilerTranscript, error);
    }];
}

- (void)testICanUseNormalMessagingSyntax
{
    NSString *source = @"NSDate *d = [NSDate dateWithTimeIntervalSinceReferenceDate:68000];\n\
    NSTimeInterval ticks = [d timeIntervalSinceReferenceDate];\n\
    return @(ticks);";

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

- (void)testICanReturnALiteralNSString
{
    NSString *source = @"NSString *string = @\"Hello!\";"
    @"return string;";
    [_runner doIt:source completion:^(NSString *returnValue, NSString *compilerTranscript, NSError *error){
        XCTAssertEqualObjects(returnValue, @"Hello!", @"Transcript: %@\nError:%@", compilerTranscript, error);
    }];
}

- (void)testThereIsNoProblemRunningTheSourceInProblemReport26
{
    NSString *source = @"int theAnswer = 6 * 7;"
    @"return @(theAnswer);";
    [_runner doIt:source completion:^(NSNumber *result, NSString *compilerTranscript, NSError *error){
        XCTAssertEqual([result intValue], 42, @"Transcript: %@\nError:%@", compilerTranscript, error);
    }];
}
@end
