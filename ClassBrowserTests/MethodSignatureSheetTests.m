// See COPYING for license details.

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "IKBMethodSignatureSheetController.h"
#import "IKBMethodSignatureSheetController_ClassExtension.h"

@interface MethodSignatureSheetTests : XCTestCase

@end

@implementation MethodSignatureSheetTests
{
    IKBMethodSignatureSheetController *_controller;
}

- (void)setUp
{
    _controller = [[IKBMethodSignatureSheetController alloc] initWithWindowNibName:NSStringFromClass([IKBMethodSignatureSheetController class])];
}

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

- (void)testEmptyMethodIsNotValid
{
    _controller.signatureText = @"";
    XCTAssertFalse([_controller isValidSignature]);
}

- (void)testMethodsMustStartWithPlusOrMinus
{
    _controller.signatureText = @"^ (NSInteger)count";
    XCTAssertFalse([_controller isValidSignature]);
    _controller.signatureText = @"- (NSInteger)count";
    XCTAssertTrue([_controller isValidSignature]);
    _controller.signatureText = @"+ (NSInteger)count";
    XCTAssertTrue([_controller isValidSignature]);
}

- (void)testMethodsMustBeRepresentableInASCII
{
    _controller.signatureText = @"- (void)addObjéct:(id)objéct";
    XCTAssertFalse([_controller isValidSignature]);
}

- (void)testMethodSignaturesEndWithAColon
{
    _controller.signatureText = @"- (void)addObject:";
    XCTAssertFalse([_controller isValidSignature]);
}
@end
