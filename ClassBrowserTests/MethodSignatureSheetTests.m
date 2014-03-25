// See COPYING for license details.

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "IKBMethodSignatureSheetController.h"
#import "IKBMethodSignatureSheetController_ClassExtension.h"

@interface MethodSignatureSheetTests : XCTestCase

@end

@implementation MethodSignatureSheetTests

- (void)testCancellingTheSignatureSpecificationCancelsTheSheet
{
    id sheetParent = [OCMockObject mockForClass:[NSWindow class]];
    id sheet = [OCMockObject niceMockForClass:[NSWindow class]];
    [[[sheet expect] andReturn:sheetParent] sheetParent];
    [[sheetParent expect] endSheet:sheet returnCode:NSModalResponseCancel];
    IKBMethodSignatureSheetController *controller = [[IKBMethodSignatureSheetController alloc] initWithWindow:sheet];
    [controller cancel:nil];
    [sheet verify];
    [sheetParent verify];
}

@end
