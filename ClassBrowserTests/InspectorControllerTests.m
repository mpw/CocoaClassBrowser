//See COPYING for licence details.

#import <Cocoa/Cocoa.h>
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

#import "IKBInspectorWindowController.h"

@interface InspectorControllerTests : XCTestCase

@end

@implementation InspectorControllerTests

- (void)testInspectorWindowTitleRepresentsInspectedObjectDescription
{
    id window = [OCMockObject niceMockForClass:[NSWindow class]];
    [[window expect] setTitle:@"test"];
    IKBInspectorWindowController *controller = [[IKBInspectorWindowController alloc] initWithWindow:window];
    [controller setRepresentedObject:@"test"];
    [window verify];
}

@end
