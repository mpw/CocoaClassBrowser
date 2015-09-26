// See COPYING for license details.

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "IKBMethodSignatureSheetController.h"
#import "IKBMethodSignatureSheetController_ClassExtension.h"
#import "IKBNameEntrySheetController.h"
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
    _controller = [[IKBMethodSignatureSheetController alloc] initWithWindowNibName:NSStringFromClass([IKBNameEntrySheetController class])];
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
    _controller.textEntered = @"";
    XCTAssertFalse([_controller isValidSignature]);
}

- (void)testMethodsMustStartWithPlusOrMinus
{
    _controller.textEntered = @"^ (NSInteger)count";
    XCTAssertFalse([_controller isValidSignature]);
    _controller.textEntered = @"- (NSInteger)count";
    XCTAssertTrue([_controller isValidSignature]);
    _controller.textEntered = @"+ (NSInteger)count";
    XCTAssertTrue([_controller isValidSignature]);
}

- (void)testMethodsMustBeRepresentableInASCII
{
    _controller.textEntered = @"- (void)addObjéct:(id)objéct";
    XCTAssertFalse([_controller isValidSignature]);
}

- (void)testMethodSignaturesEndWithAColon
{
    _controller.textEntered = @"- (void)addObject:";
    XCTAssertFalse([_controller isValidSignature]);
}

- (void)testValidMethodSignatureMeansCreateButtonEnabledAndWarningHidden
{
    NSNotification *notification = [NSNotification notificationWithName:NSControlTintDidChangeNotification
                                                                 object:@"- (id)objectAtIndex:(NSInteger)index"];
    [_controller controlTextDidChange:notification];
    XCTAssertTrue([_controller.createEntryButton isEnabled]);
    XCTAssertTrue([_controller.problemLabel isHidden]);
}

- (void)testInvalidMethodSignatureMeansCreateButtonDisabledAndWarningShown
{
    NSNotification *notification = [NSNotification notificationWithName:NSControlTintDidChangeNotification
                                                                 object:@"- (id)objectAtIndex:"];
    [_controller controlTextDidChange:notification];
    XCTAssertFalse([_controller.createEntryButton isEnabled]);
    XCTAssertFalse([_controller.problemLabel isHidden]);
}

- (void)testMethodCreationResultsInAMethodWithTheSuppliedSignatureAndEmptyBodyOnTheExpectedClass
{
    _controller.textEntered = @"-(void)addObject:(id)anObject";
    [_controller setClassName:NSStringFromClass([NSObject class])];
    [_controller createEntry:_controller.createEntryButton];
    IKBObjectiveCMethod *method = _controller.method;
    XCTAssertNotNil(method);
    XCTAssertEqualObjects(method.className, NSStringFromClass([NSObject class]));
    XCTAssertEqualObjects(method.declaration, _controller.textEntered);
    XCTAssertEqualObjects(method.body, @"{\n\n}\n");
}

- (void)testResetMethodDiscardsExistingModelState
{
    _controller.textEntered = @"-(void)addObject:(id)anObject";
    [_controller setClassName:NSStringFromClass([NSArray class])];
    [_controller createEntry:_controller.createEntryButton];
    [_controller reset];
    XCTAssertNil(_controller.method);
    XCTAssertNil(_controller.textEntered);
    XCTAssertNil(_controller.className);
}

@end
