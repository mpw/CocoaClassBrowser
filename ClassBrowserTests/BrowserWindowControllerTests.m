//
//  BrowserWindowControllerTests.m
//  ClassBrowser
//
//  Created by Graham Lee on 10/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "IKBClassBrowserWindowController.h"
#import "IKBClassBrowserWindowController_ClassExtension.h"
#import "IKBCodeEditorViewController.h"
#import "IKBClassBrowserSource.h"
#import "FakeClassList.h"

@interface FakeBrowser : NSBrowser

@property (nonatomic, assign) NSInteger selectedRow;
@property (nonatomic, assign) NSInteger selectedColumn;

@end

@implementation FakeBrowser

- (NSInteger)selectedRowInColumn:(NSInteger)column
{
    return self.selectedRow;
}

@end

@interface InspectableSource : IKBClassBrowserSource

@property (nonatomic, assign) NSInteger selectedRow;
@property (nonatomic, assign) NSInteger selectedColumn;
@property (nonatomic, strong) NSBrowser *actionedBrowser;

@end

@implementation InspectableSource

- (void)browser:(NSBrowser *)browser didSelectRow:(NSInteger)row inColumn:(NSInteger)column
{
    self.actionedBrowser = browser;
    self.selectedRow = row;
    self.selectedColumn = column;
}

@end

@interface BrowserWindowControllerTests : XCTestCase

@end

@implementation BrowserWindowControllerTests
{
    IKBClassBrowserWindowController *controller;
    FakeBrowser *browser;
    InspectableSource *source;
    FakeClassList *classes;
}

- (void)setUp
{
    controller = [[IKBClassBrowserWindowController alloc] initWithWindowNibName:@"IKBClassBrowserWindowController"];
    browser = [FakeBrowser new];
    controller.classBrowser = browser;
    classes = [FakeClassList new];
    classes.classes = @{ @"Foundation" : @[@"NSObject", @"NSData", @"NSString"],
                         @"AppKit" : @[@"NSBrowser", @"NSCell", @"NSTableView", @"NSMatrix"],
                         @"Isambard" : @[@"IKBCommandBus"] };
    source = [[InspectableSource alloc] initWithClassList:classes];
    controller.browserSource = source;
}

- (void)testBrowserHasADelegateAfterTheWindowWasLoaded
{
    [controller windowDidLoad];
    XCTAssertEqualObjects(controller.classBrowser.delegate, controller.browserSource);
    XCTAssertEqualObjects(controller.classBrowser.target, controller);
    XCTAssertEqual(controller.classBrowser.action, @selector(browserSelectionDidChange:));
}

- (void)testBrowserTellsSourceAboutSelectionInActionMethod
{
    browser.selectedColumn = 1;
    browser.selectedRow = 2;
    [controller browserSelectionDidChange:browser];
    XCTAssertEqualObjects(source.actionedBrowser, browser);
    XCTAssertEqual(source.selectedRow, browser.selectedRow);
    XCTAssertEqual(source.selectedColumn, browser.selectedColumn);
}

- (void)testCodeEditorVCLoadedAndViewAddedToWindow
{
    [controller windowDidLoad];
    XCTAssertNotNil(controller.codeEditorViewController);
    XCTAssertEqualObjects(controller.codeEditorViewController.view.superview, controller.window.contentView);
}

@end
