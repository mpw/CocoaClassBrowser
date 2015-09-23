// See COPYING for license details.

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "IKBMethodSignatureSheetController.h"
#import "IKBMethodSignatureSheetController_ClassExtension.h"
#import "IKBObjectiveCMethod.h"

@interface NSString (IKBStringValue)

- (NSString *)stringValue;

@end

@implementation NSString (IKBStringValue)

- (NSString *)stringValue { return self; }

@end

@interface MethodSignatureSheetTests : XCTestCase

@end

@implementation MethodSignatureSheetTests
{
    IKBMethodSignatureSheetController *_controller;
    NSWindow *_window;
}

- (void)setUp
{
    _controller = [[IKBMethodSignatureSheetController alloc] initWithWindowNibName:NSStringFromClass([IKBMethodSignatureSheetController class])];
    _window = _controller.window;
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

- (void)testValidMethodSignatureMeansCreateButtonEnabledAndWarningHidden
{
    NSNotification *notification = [NSNotification notificationWithName:NSControlTintDidChangeNotification
                                                                 object:@"- (id)objectAtIndex:(NSInteger)index"];
    [_controller controlTextDidChange:notification];
    XCTAssertTrue([_controller.createMethodButton isEnabled]);
    XCTAssertTrue([_controller.problemLabel isHidden]);
}

- (void)testInvalidMethodSignatureMeansCreateButtonDisabledAndWarningShown
{
    NSNotification *notification = [NSNotification notificationWithName:NSControlTintDidChangeNotification
                                                                 object:@"- (id)objectAtIndex:"];
    [_controller controlTextDidChange:notification];
    XCTAssertFalse([_controller.createMethodButton isEnabled]);
    XCTAssertFalse([_controller.problemLabel isHidden]);
}

- (void)testMethodCreationResultsInAMethodWithTheSuppliedSignatureAndEmptyBodyOnTheExpectedClass
{
    _controller.signatureText = @"-(void)addObject:(id)anObject";
    [_controller setClassName:NSStringFromClass([NSObject class])];
    [_controller createMethod:_controller.createMethodButton];
    IKBObjectiveCMethod *method = _controller.method;
    XCTAssertNotNil(method);
    XCTAssertEqualObjects(method.className, NSStringFromClass([NSObject class]));
    XCTAssertEqualObjects(method.declaration, _controller.signatureText);
    XCTAssertEqualObjects(method.body, @"{\n\n}\n");
}

- (void)testResetMethodDiscardsExistingModelState
{
    _controller.signatureText = @"-(void)addObject:(id)anObject";
    [_controller setClassName:NSStringFromClass([NSArray class])];
    [_controller createMethod:_controller.createMethodButton];
    [_controller reset];
    XCTAssertNil(_controller.method);
    XCTAssertNil(_controller.signatureText);
    XCTAssertNil(_controller.className);
}

@end
