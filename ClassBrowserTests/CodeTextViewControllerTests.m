//
//  CodeTextViewControllerTests.m
//  ClassBrowser
//
//  Created by Graham Lee on 18/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "IKBCodeEditorViewController.h"
#import "FakeCodeRunner.h"

@interface CodeTextViewControllerTests : XCTestCase

@end

@implementation CodeTextViewControllerTests
{
    IKBCodeEditorViewController *_vc;
    NSView *_view;
}

- (void)setUp
{
    _vc = [IKBCodeEditorViewController new];
    _view = [_vc view];
    _vc.textView.textStorage.attributedString = [[NSAttributedString alloc] initWithString:@"Hello, world"];
    [_vc.textView setSelectedRange:(NSRange){.location = 0, .length = 5}];
}

- (void)testTheViewIsAScrollViewThatAutoresizesToItsParent
{
    XCTAssertTrue([_view isKindOfClass:[NSScrollView class]]);
    XCTAssertEqual([_view autoresizingMask], (NSUInteger)(NSViewWidthSizable | NSViewHeightSizable | NSViewMaxYMargin));
}

- (void)testTheViewControllerClipViewHasATextViewAsItsDocument
{
    XCTAssertNotNil([_vc textView]);
    NSScrollView *scrollView = (NSScrollView *)_vc.view;
    XCTAssertEqualObjects(_vc.textView.superview, scrollView.contentView);
    XCTAssertEqualObjects(scrollView.contentView.documentView, _vc.textView);
}

- (void)testThatWhenTheViewIsReadyTheControllerHasACodeRunner
{
    XCTAssertNotNil(_vc.codeRunner);
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
    FakeCodeRunner *runner = [FakeCodeRunner new];
    _vc.codeRunner = (IKBCodeRunner *)runner;
    [_vc printIt:self];
    XCTAssertEqualObjects(runner.ranSource, @"Hello");
}

- (void)testPrintItPlacesTheResultAfterTheCompiledSource
{
    FakeCodeRunner *runner = [FakeCodeRunner new];
    runner.runResult = @"PASS";
    _vc.codeRunner = (IKBCodeRunner *)runner;
    [_vc printIt:self];
    NSRange resultRange = [_vc.textView.textStorage.string rangeOfString:@"PASS"];
    XCTAssertEqual(resultRange.location, (NSUInteger)5);
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
