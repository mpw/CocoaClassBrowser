//
//  CodeTextViewControllerTests.m
//  ClassBrowser
//
//  Created by Graham Lee on 18/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface IKBCodeEditorViewController : NSViewController

@property (nonatomic, readonly) NSTextView *textView;
- (void)printIt:(id)sender;

@end

@implementation IKBCodeEditorViewController

- (void)loadView
{
    NSTextView *textView = [[NSTextView alloc] initWithFrame:(NSRect){0}];
    textView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable | NSViewMaxYMargin;
    
    NSMenuItem *printItItem = [[NSMenuItem alloc] initWithTitle:@"Print It" action:@selector(printIt:) keyEquivalent:@""];
    [textView.menu addItem:printItItem];
    self.view = textView;
}

- (NSTextView *)textView
{
    return (NSTextView *)self.view;
}

- (void)printIt:(id)sender
{
    
}

@end

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

@end
