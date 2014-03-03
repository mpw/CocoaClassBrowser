//See COPYING for licence details.

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "IKBClassBrowserWindowController.h"
#import "IKBClassBrowserWindowController_ClassExtension.h"
#import "IKBCodeEditorViewController.h"
#import "IKBClassBrowserSource.h"
#import "FakeClassList.h"
#import "IKBMethodSignatureSheetController.h"
#import "IKBObjectiveCMethod.h"

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

- (id)mockTheAddMethodToolbarItem
{
    __unused NSWindow *windowLoadedByController = controller.window;
    id addMethodItem = [OCMockObject mockForClass:[NSToolbarItem class]];
    controller.addMethodItem = addMethodItem;
    return addMethodItem;
}

- (id)mockABrowserWithSelectedColumn:(NSInteger)column row:(NSInteger)row
{
    id sender = [OCMockObject niceMockForClass:[NSBrowser class]];
    [[[sender stub] andReturnValue:[NSNumber numberWithInteger:column]] selectedColumn];
    [[[sender stub] andReturnValue:[NSNumber numberWithInteger:row]] selectedRowInColumn:column];
    return sender;
}

- (void)testWithNothingSelectedICannotAddAMethod
{
    id addMethodItem = [self mockTheAddMethodToolbarItem];
    [[addMethodItem expect] setEnabled:NO];
    [controller windowDidLoad];
    [addMethodItem verify];
}

- (void)testWithAClassGroupSelectedICannotAddAMethod
{
    id addMethodItem = [self mockTheAddMethodToolbarItem];
    [[addMethodItem expect] setEnabled:NO];
    id sender = [self mockABrowserWithSelectedColumn:0 row:1];
    [controller browserSelectionDidChange:sender];
    [addMethodItem verify];
}

- (void)testWithAClassSelectedICanAddAMethod
{
    id addMethodItem = [self mockTheAddMethodToolbarItem];
    [[addMethodItem expect] setEnabled:YES];
    id sender = [self mockABrowserWithSelectedColumn:1 row:2];
    [controller browserSelectionDidChange:sender];
    [addMethodItem verify];
}

- (void)testWithAProtocolSelectedICanAddAMethod
{
    id addMethodItem = [self mockTheAddMethodToolbarItem];
    [[addMethodItem expect] setEnabled:YES];
    id sender = [self mockABrowserWithSelectedColumn:2 row:0];
    [controller browserSelectionDidChange:sender];
    [addMethodItem verify];
}

- (void)testWithAMethodSelectedICanAddAMethod
{
    id addMethodItem = [self mockTheAddMethodToolbarItem];
    [[addMethodItem expect] setEnabled:YES];
    id sender = [self mockABrowserWithSelectedColumn:3 row:7];
    [controller browserSelectionDidChange:sender];
    [addMethodItem verify];
}

- (void)testAddingAMethodPresentsASheetForSettingTheMethodSignature
{
    id window = [OCMockObject partialMockForObject:[controller window]];
    controller.window = window;
    [[window expect] beginSheet:OCMOCK_ANY completionHandler:OCMOCK_ANY];
    [controller addMethod:[controller addMethodItem]];
    [window verify];
}

- (void)testOKReturnFromSheetPassesTheMethodSignatureToTheCodeEditor
{
    id createdMethod = [IKBObjectiveCMethod new];

    id methodSignatureSheet = [OCMockObject mockForClass:[IKBMethodSignatureSheetController class]];
    controller.addMethodSheet = methodSignatureSheet;
    [[[methodSignatureSheet expect] andReturn:createdMethod] method];
    id codeEditor = [OCMockObject mockForClass:[IKBCodeEditorViewController class]];
    controller.codeEditorViewController = codeEditor;
    [[codeEditor expect] setEditedMethod:createdMethod];

    [controller addMethodSheetReturnedCode:NSModalResponseOK];

    [codeEditor verify];
    [methodSignatureSheet verify];
}

- (void)testCancelReturnFromSheetDoesNotPassAnythingToTheCodeEditor
{
    id codeEditor = [OCMockObject mockForClass:[IKBCodeEditorViewController class]];
    //use the fact that the mock is not nice and won't expect any methods
    controller.codeEditorViewController = codeEditor;

    [controller addMethodSheetReturnedCode:NSModalResponseCancel];
    [codeEditor verify];
}

- (void)testMethodSignatureSheetIsToldTheClassToAddTheMethodTo
{
    // first, select the Foundation category
    [classes selectClassGroupAtIndex:1];
    // then select the NSString class
    [classes selectClassAtIndex:2];
    controller.classList = classes;
    id methodSignatureSheet = [OCMockObject niceMockForClass:[IKBMethodSignatureSheetController class]];
    [[methodSignatureSheet expect] setClass:@"NSString"];
    controller.addMethodSheet = methodSignatureSheet;
    [controller addMethod:[controller addMethodItem]];
    [methodSignatureSheet verify];
}

- (void)testMethodSignatureSheetIsAskedToDiscardExistingStateOnPresentation
{
    id methodSignatureSheet = [OCMockObject niceMockForClass:[IKBMethodSignatureSheetController class]];
    [[methodSignatureSheet expect] reset];
    controller.addMethodSheet = methodSignatureSheet;
    [controller addMethod:[controller addMethodItem]];
    [methodSignatureSheet verify];
}

@end
