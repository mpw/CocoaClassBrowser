//See COPYING for licence details.

#import <XCTest/XCTest.h>
#import "IKBPreferencesWindowController_ClassExtension.h"
#import "IKBCompilerPreferencesViewController.h"

@interface PreferencesWindowControllerTests : XCTestCase

@end

@implementation PreferencesWindowControllerTests
{
    IKBPreferencesWindowController *_controller;
}

- (void)setUp
{
    _controller = [IKBPreferencesWindowController new];
    __unused NSWindow *window = _controller.window;
}

- (void)testPreferenceWindowCanBeClosedAndReopened
{
    // Verify that the preferences window starts out initially hidden from view
    XCTAssertNotNil(_controller.window);
    XCTAssertFalse(_controller.window.isVisible);
    
    // Make the window appear and verify that it is visible
    [_controller.window makeKeyAndOrderFront:nil];
    XCTAssertNotNil(_controller.window);
    XCTAssertTrue(_controller.window.isVisible);
    
    // Close the window and verify that it's no longer visible
    [_controller.window performClose:self];
    XCTAssertFalse(_controller.window.isVisible);
    
    // Then make the window reappear and verify that it's still visible
    [_controller.window makeKeyAndOrderFront:nil];
    XCTAssertNotNil(_controller.window);
    XCTAssertTrue(_controller.window.isVisible);
}

- (void)testPreferenceWindowHasContentViewWithExpectedSubview
{
    XCTAssertNotNil(_controller.contentView);
    NSView *firstSubview = [_controller.contentView.subviews firstObject];
    XCTAssertEqualObjects([firstSubview identifier], NSStringFromClass([IKBCompilerPreferencesViewController class]));
}

@end
