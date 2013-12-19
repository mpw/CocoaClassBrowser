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
}

- (void)testTheViewIsATextViewThatAutoresizesToItsParent
{
    XCTAssertTrue([_view isKindOfClass:[NSTextView class]]);
    XCTAssertEqual([_view autoresizingMask], (NSUInteger)(NSViewWidthSizable | NSViewHeightSizable | NSViewMaxYMargin));
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
    _vc.textView.textStorage.attributedString = [[NSAttributedString alloc] initWithString:@"Hello, world"];
    [_vc.textView setSelectedRange:(NSRange){.location = 0, .length = 5}];
    [_vc printIt:self];
    XCTAssertEqualObjects(runner.ranSource, @"Hello");
}
@end
