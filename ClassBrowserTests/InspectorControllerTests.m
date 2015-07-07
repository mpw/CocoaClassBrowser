//See COPYING for licence details.

#import <Cocoa/Cocoa.h>
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

#import "IKBInspectorWindowController.h"

@interface InspectorControllerTests : XCTestCase

@end

@implementation InspectorControllerTests
{
    id _window;
    IKBInspectorWindowController *_controller;
}

- (void)setUp
{
    _window = [OCMockObject niceMockForClass:[NSWindow class]];
    _controller = [[IKBInspectorWindowController alloc] initWithWindow:_window];
}
- (void)testInspectorWindowTitleRepresentsInspectedObjectDescription
{
    [[_window expect] setTitle:@"test"];
    [_controller setRepresentedObject:@"test"];
    [_window verify];
}

- (void)testInspectorWindowTitleCanRepresentNilObject
{
    [[_window expect] setTitle:@"nil"];
    [_controller setRepresentedObject:nil];
    [_window verify];
}

@end
