//See COPYING for licence details.

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "IKBCodeEditorViewController.h"
#import "IKBCodeEditorViewController_ClassExtension.h"
#import "IKBCommandBus.h"
#import "IKBCompileAndRunCodeCommand.h"
#import "IKBInspectorProvider.h"
#import "IKBInspectorWindowController.h"

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
    TranscriptController *_transcriptController;
    NSMenuItem *_printItItem;
    NSMenuItem *_inspectItItem;
    id _result;
}

- (void)setUp
{
    _vc = [IKBCodeEditorViewController new];
    _vc.inspectorProvider = [IKBInspectorProvider new];
    _view = [_vc view];
    [_vc.textView insertText:@"Hello, world"];
    [_vc.textView setSelectedRange:(NSRange){.location = 0, .length = 5}];
    _transcriptController = [TranscriptController new];
    _vc.transcriptWindowController = (id)_transcriptController;
    _printItItem = [[NSMenuItem alloc] initWithTitle:@"Print It"
                                              action:@selector(printIt:)
                                       keyEquivalent:@""];
    _inspectItItem = [[NSMenuItem alloc] initWithTitle:@"Inspect It"
                                                action:@selector(inspectIt:)
                                         keyEquivalent:@""];
    _result = @42;
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

- (void)testThatWhenTheViewIsReadyTheControllerHasACommandBus
{
    IKBCodeEditorViewController *viewController = [IKBCodeEditorViewController new];
    __unused NSView *view = viewController.view;
    XCTAssertEqualObjects(viewController.commandBus, [IKBCommandBus applicationCommandBus]);
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

- (void)testPrintItSchedulesACompileCommandContainingTheSourceCode
{
    id mockCommandBus = [OCMockObject mockForClass:[IKBCommandBus class]];
    [[mockCommandBus expect] execute:[OCMArg checkWithBlock:^(IKBCompileAndRunCodeCommand *command){
        return (BOOL)(command.completion != nil && [command.source isEqualToString:@"Hello"]);
    }]];
    _vc.commandBus = mockCommandBus;
    [_vc printIt:self];
    [mockCommandBus verify];
}

- (void)testPrintItCompletionPlacesTheResultAfterTheCompiledSourceWithPrependedSpace
{
    [_vc updateSourceViewWithResult:@"PASS" ofSourceInRange:_vc.textView.selectedRange compilerOutput:nil error:nil];
    NSRange resultRange = [_vc.textView.string rangeOfString:@"PASS"];
    XCTAssertEqual(resultRange.location, (NSUInteger)6);
}

- (void)testPrintItCompletionSelectsThePlacedResultAndThePrependedSpace
{
    [_vc updateSourceViewWithResult:@"PASS" ofSourceInRange:_vc.textView.selectedRange compilerOutput:nil error:nil];
    NSRange selectionRange = _vc.textView.selectedRange;
    XCTAssertEqual(selectionRange.location, (NSUInteger)5);
    XCTAssertEqual(selectionRange.length, (NSUInteger)5);
}

- (void)testPrintItCompletionPlacesTheErrorDescriptionAfterTheCompiledSourceOnFailureWithPrependedSpace
{
    NSError *buildError = [NSError errorWithDomain:@"IKBTestErrorDomain"
                                              code:99
                                          userInfo:@{ NSLocalizedDescriptionKey: @"Error Description" }];
    [_vc updateSourceViewWithResult:nil ofSourceInRange:_vc.textView.selectedRange compilerOutput:nil error:buildError];
    NSRange resultRange = [_vc.textView.string rangeOfString:[NSString stringWithFormat:@"%@", nil]];
    XCTAssertEqual(resultRange.location, NSNotFound);
    NSRange errorRange = [_vc.textView.string rangeOfString:@"Error Description"];
    XCTAssertEqual(errorRange.location, (NSUInteger)6);
}

- (void)testPrintItCompletionSelectsThePlacedErrorDescriptionAndThePrependedSpace
{
    NSError *buildError = [NSError errorWithDomain:@"IKBTestErrorDomain"
                                              code:99
                                          userInfo:@{ NSLocalizedDescriptionKey: @"Error Description" }];
    [_vc updateSourceViewWithResult:nil ofSourceInRange:_vc.textView.selectedRange compilerOutput:nil error:buildError];
    NSRange selectionRange = _vc.textView.selectedRange;
    XCTAssertEqual(selectionRange.location, (NSUInteger)5);
    XCTAssertEqual(selectionRange.length, (NSUInteger)18);
}

- (void)testPrintItResultUsesFixedWidthFont
{
    [_vc updateSourceViewWithResult:@"PASS" ofSourceInRange:_vc.textView.selectedRange compilerOutput:nil error:nil];
    NSRange attributesEffectiveRange = NSMakeRange(NSNotFound, 0);
    NSDictionary *attributes = [_vc.textView.textStorage attributesAtIndex:0 effectiveRange:&attributesEffectiveRange];
    XCTAssertTrue([[attributes allKeys] containsObject:NSFontAttributeName],
                  @"expected font attribute in result string");
    XCTAssertTrue([attributes[NSFontAttributeName] isFixedPitch],
                  @"expected %@ to be a fixed-pitch font", attributes[NSFontAttributeName]);
    XCTAssertEqual(attributesEffectiveRange.length, [_vc.textView.string length],
                   @"expected attributes' effective range to match length of result string");
}

- (void)testTextViewHasAMenuItemToExecuteCodeAndInspectTheResult
{
    NSMenu *menu = _vc.textView.menu;
    NSArray *titles = [menu.itemArray valueForKey:@"title"];
    XCTAssertTrue([titles containsObject:@"Inspect It"]);
    NSUInteger index = [titles indexOfObject:@"Inspect It"];
    NSMenuItem *inspectItItem = [menu.itemArray objectAtIndex:index];
    XCTAssertNil(inspectItItem.target);
    XCTAssertEqual(inspectItItem.action, @selector(inspectIt:));
}

- (void)testInspectItSchedulesACompileCommandContainingTheSourceCode
{
    id mockCommandBus = [OCMockObject mockForClass:[IKBCommandBus class]];
    [[mockCommandBus expect] execute:[OCMArg checkWithBlock:^(IKBCompileAndRunCodeCommand *command){
        return (BOOL)(command.completion != nil && [command.source isEqualToString:@"Hello"]);
    }]];
    _vc.commandBus = mockCommandBus;
    [_vc inspectIt:self];
    [mockCommandBus verify];
}

- (void)testInspectItCompletionShowsAnInspectorForTheResult
{
    [_vc inspectResult:_result compilerOutput:nil error:nil];
    IKBInspectorWindowController *controller = [_vc inspectorForObject:_result];
    XCTAssertNotNil(controller);
    XCTAssertTrue([controller.window isVisible]);
}

- (void)testClosingTheInspectorCausesTheControllerToDropIt
{
    [_vc inspectResult:_result compilerOutput:nil error:nil];
    IKBInspectorWindowController *theController = [_vc testAccessToCurrentInspectorForObject:_result];
    [theController.controllerDelegate inspectorWindowControllerWindowWillClose:theController];
    XCTAssertNil([_vc testAccessToCurrentInspectorForObject:_result]);
}

- (void)testInspectItShowsTheCompilerTranscriptIfItNeedsTo
{
    [_vc inspectResult:nil compilerOutput:@"Greetings, Programs!" error:nil];
    XCTAssertTrue([_transcriptController isWindowOrderedFront]);
}

- (void)testCompilerTranscriptControllerIsAvailableByDefault
{
    IKBCodeEditorViewController *viewController = [IKBCodeEditorViewController new];
    XCTAssertNotNil(viewController.transcriptWindowController);
}

- (void)testCompilerTranscriptIsShownWhenItHasSomethingToSay
{
    [_vc updateSourceViewWithResult:nil ofSourceInRange:_vc.textView.selectedRange compilerOutput:@"Danger Will Robinson" error:nil];
    XCTAssertTrue([_transcriptController isWindowOrderedFront]);
    XCTAssertEqualObjects(_transcriptController.transcriptText, @"Danger Will Robinson");
}

- (void)testCompilerTranscriptIsHiddenWhenItHasNothingToSay
{
    [_transcriptController.window orderFront:self];
    [_vc updateSourceViewWithResult:nil ofSourceInRange:_vc.textView.selectedRange compilerOutput:@"" error:nil];
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

- (void)testTextViewUsesFixedWidthFont
{
    NSFont *font = _vc.textView.typingAttributes[NSFontAttributeName];
    XCTAssertTrue([font isFixedPitch],
                  @"expected %@ to be a fixed-pitch font", font);
}

- (void)testPrintItMenuItemIsDisabledWhenNoTextIsSelected
{
    [_vc.textView setSelectedRange:NSMakeRange(0, 0)];
    XCTAssertFalse([_vc validateMenuItem:_printItItem]);
}

- (void)testPrintItMenuItemIsEnabledWhenTextIsSelected
{
    XCTAssertTrue([_vc validateMenuItem:_printItItem]);
}

- (void)testInspectItMenuItemIsDisabledWhenNoTextIsSelected
{
    [_vc.textView setSelectedRange:NSMakeRange(0, 0)];
    XCTAssertFalse([_vc validateMenuItem:_inspectItItem]);
}

- (void)testInspectItMenuItemIsEnabledWhenTextIsSelected
{
    XCTAssertTrue([_vc validateMenuItem:_inspectItItem]);
}

@end
