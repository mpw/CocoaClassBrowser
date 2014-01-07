//See COPYING for licence details.

#import <XCTest/XCTest.h>
#import "IKBCompilerTranscriptWindowController.h"

@interface CompilerTranscriptTests : XCTestCase

@end

@implementation CompilerTranscriptTests
{
    IKBCompilerTranscriptWindowController *_controller;
}

- (void)setUp
{
    _controller = [[IKBCompilerTranscriptWindowController alloc] initWithWindowNibName:NSStringFromClass([IKBCompilerTranscriptWindowController class])];
    __unused NSWindow *window = _controller.window;
}

- (void)testTranscriptPropertySetsTextViewContent
{
    _controller.transcriptText = @"Test";
    XCTAssertEqualObjects(_controller.transcriptView.string, @"Test");
}

- (void)testTranscriptPropertyGetsValueFromTextView
{
    _controller.transcriptView.string = @"Test";
    XCTAssertEqualObjects(_controller.transcriptText, @"Test");
}

@end
