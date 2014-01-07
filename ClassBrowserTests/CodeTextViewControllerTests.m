//See COPYING for licence details.

#import <XCTest/XCTest.h>
#import "IKBCodeEditorViewController.h"
#import "FakeCodeRunner.h"

@interface TranscriptController : NSObject

@property (nonatomic, copy) NSString *transcriptText;
@property (nonatomic, assign, getter = isWindowOrderedFront) BOOL windowOrderedFront;

@end

@implementation TranscriptController

//capture messages to this controller's window, too
- (id)window { return self; }

- (void)orderFront:(id)sender
{
    self.windowOrderedFront = YES;
}

- (void)orderOut:(id)sender
{
    self.windowOrderedFront = NO;
}

@end

@interface CodeTextViewControllerTests : XCTestCase

@end

@implementation CodeTextViewControllerTests
{
    IKBCodeEditorViewController *_vc;
    NSView *_view;
    FakeCodeRunner *_runner;
    TranscriptController *_transcriptController;
}

- (void)setUp
{
    _vc = [IKBCodeEditorViewController new];
    _view = [_vc view];
    _vc.textView.textStorage.attributedString = [[NSAttributedString alloc] initWithString:@"Hello, world"];
    [_vc.textView setSelectedRange:(NSRange){.location = 0, .length = 5}];
    _runner = [FakeCodeRunner new];
    _vc.codeRunner = (id)_runner;
    _transcriptController = [TranscriptController new];
    _vc.transcriptWindowController = (id)_transcriptController;
}

- (void)testTheViewHasTheViewControllerAsItsNextResponder
{
    XCTAssertEqualObjects(_view.nextResponder, _vc);
}

- (void)testTheViewKeepsTheViewControllerAsItsNextResponder
{
    NSView *emptyView = [[NSView alloc] initWithFrame:NSZeroRect];
    [emptyView addSubview:_view];
    XCTAssertEqualObjects(_view.nextResponder, _vc);
}

- (void)testTheViewContainsAScrollViewThatAutoresizesToItsParent
{
    NSScrollView *subview = [[_view subviews] lastObject];
    XCTAssertTrue([subview isKindOfClass:[NSScrollView class]]);
    XCTAssertEqual([subview autoresizingMask], (NSUInteger)(NSViewWidthSizable | NSViewHeightSizable));
}

- (void)testTheViewControllerClipViewHasATextViewAsItsDocument
{
    XCTAssertNotNil([_vc textView]);
    NSScrollView *subview = [[_view subviews] lastObject];
    XCTAssertEqualObjects(_vc.textView.superview, subview.contentView);
    XCTAssertEqualObjects(subview.contentView.documentView, _vc.textView);
}

- (void)testThatWhenTheViewIsReadyTheControllerHasACodeRunner
{
    IKBCodeEditorViewController *viewController = [IKBCodeEditorViewController new];
    __unused NSView *view = viewController.view;
    XCTAssertNotNil(viewController.codeRunner);
}

- (void)testTextViewHasAMenuItemToExecuteCodeAndPrintTheResult
{
    NSMenu *menu = _vc.textView.menu;
    NSArray *titles = [menu.itemArray valueForKey:@"title"];
    XCTAssertTrue([titles containsObject:@"Print It"]);
    NSUInteger index = [titles indexOfObject:@"Print It"];
    NSMenuItem *printItItem = [menu.itemArray objectAtIndex:index];
    XCTAssertNil(printItItem.target);
    XCTAssertEqual(printItItem.action, @selector(printIt:));
}

- (void)testPrintItSendsTheTextSelectionToTheCodeRunner
{
    [_vc printIt:self];
    XCTAssertEqualObjects(_runner.ranSource, @"Hello");
}

- (void)testPrintItPlacesTheResultAfterTheCompiledSource
{
    _runner.runResult = @"PASS";
    [_vc printIt:self];
    NSRange resultRange = [_vc.textView.string rangeOfString:@"PASS"];
    XCTAssertEqual(resultRange.location, (NSUInteger)5);
}

- (void)testPrintItPlacesTheErrorDescriptionAfterTheCompiledSourceOnFailure
{
    _runner.runResult = nil;
    NSError *buildError = [NSError errorWithDomain:@"IKBTestErrorDomain"
                                              code:99
                                          userInfo:@{ NSLocalizedDescriptionKey: @"Error Description" }];
    _runner.error = buildError;
    [_vc printIt:self];
    NSRange resultRange = [_vc.textView.string rangeOfString:[NSString stringWithFormat:@"%@", nil]];
    XCTAssertEqual(resultRange.location, NSNotFound);
    NSRange errorRange = [_vc.textView.string rangeOfString:@"Error Description"];
    XCTAssertEqual(errorRange.location, (NSUInteger)5);
}

- (void)testCompilerTranscriptControllerIsAvailableByDefault
{
    IKBCodeEditorViewController *viewController = [IKBCodeEditorViewController new];
    XCTAssertNotNil(viewController.transcriptWindowController);
}

- (void)testCompilerTranscriptIsShownWhenItHasSomethingToSay
{
    _runner.compilerTranscript = @"Danger Will Robinson";
    [_vc printIt:self];
    XCTAssertTrue([_transcriptController isWindowOrderedFront]);
    XCTAssertEqualObjects(_transcriptController.transcriptText, @"Danger Will Robinson");
}

- (void)testCompilerTranscriptIsHiddenWhenItHasNothingToSay
{
    _runner.compilerTranscript = @"";
    [_transcriptController.window orderFront:self];
    [_vc printIt:self];
    XCTAssertFalse([_transcriptController isWindowOrderedFront]);
}

- (void)testTextViewDoesNotHaveRichTextOrAnyKindOfSubstitution
{
    NSTextView *textView = _vc.textView;
    XCTAssertFalse([textView isAutomaticDashSubstitutionEnabled]);
    XCTAssertFalse([textView isAutomaticQuoteSubstitutionEnabled]);
    XCTAssertFalse([textView isAutomaticSpellingCorrectionEnabled]);
    XCTAssertFalse([textView isAutomaticTextReplacementEnabled]);
}

@end