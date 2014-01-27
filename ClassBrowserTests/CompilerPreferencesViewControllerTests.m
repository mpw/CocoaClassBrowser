//See COPYING for licence details.

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "IKBCompilerPreferencesViewController_ClassExtension.h"
#import "IKBBaseSDK.h"
#import "IKBCompilerPreferences.h"
#import "IKBXcodeSelectTaskRunner.h"

@interface CompilerPreferencesViewControllerTests : XCTestCase

@end

@implementation CompilerPreferencesViewControllerTests
{
    IKBCompilerPreferencesViewController *_controller;
}

- (void)setUp
{
    _controller = [IKBCompilerPreferencesViewController new];
    id mockXcodeSelectTaskRunner = [OCMockObject mockForClass:[IKBXcodeSelectTaskRunner class]];
    [[mockXcodeSelectTaskRunner expect] launchWithCompletion:[OCMArg checkWithBlock:^BOOL(id obj) {
        IKBXcodeSelectTaskRunnerCompletion block = obj;
        block(@"fake-test-path-value", nil);
        return YES;
    }]];
    id mockCompilerPreferences = [OCMockObject mockForClass:[IKBCompilerPreferences class]];
    NSArray *baseSDKs = @[[[IKBBaseSDK alloc] initWithDisplayName:@"OS X 10.7" path:@"MacOSX10.7.sdk" version:@"10.7"],
                          [[IKBBaseSDK alloc] initWithDisplayName:@"OS X 10.8" path:@"MacOSX10.8.sdk" version:@"10.8"],
                          [[IKBBaseSDK alloc] initWithDisplayName:@"OS X 10.9" path:@"MacOSX10.9.sdk" version:@"10.9"]];
    [[[mockCompilerPreferences expect] andReturn:baseSDKs] baseSDKs];
    [[[mockCompilerPreferences expect] andReturn:[baseSDKs lastObject]] preferredBaseSDK];
    _controller.compilerPreferences = mockCompilerPreferences;
    _controller.xcodeSelectTaskRunner = mockXcodeSelectTaskRunner;
    __unused NSView *view = _controller.view;
    XCTAssertNoThrow([mockCompilerPreferences verify]);
}

- (void)testMissingXcodeInstallShowsErrorMessage
{
    _controller = [IKBCompilerPreferencesViewController new];
    id mockXcodeSelectTaskRunner = [OCMockObject mockForClass:[IKBXcodeSelectTaskRunner class]];
    [[mockXcodeSelectTaskRunner expect] launchWithCompletion:[OCMArg checkWithBlock:^BOOL(id obj) {
        IKBXcodeSelectTaskRunnerCompletion block = obj;
        NSDictionary *userInfo = @{
                                   NSLocalizedDescriptionKey : NSLocalizedString(@"Cannot find Xcode", @"Xcode not found description"),
                                   NSLocalizedFailureReasonErrorKey : NSLocalizedString(@"Xcode is not installed or its location is unknown", @"Xcode not found failure reason"),
                                   NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"Install Xcode and use xcode-select to configure its location", @"Xcode not found recovery suggestion"),
                                   };
        NSError *error = [NSError errorWithDomain:IKBXcodeSelectTaskRunnerErrorDomain
                                             code:IKBXcodeSelectTaskRunnerErrorCannotLocateXcode
                                         userInfo:userInfo];
        block(nil, error);
        return YES;
    }]];
    _controller.xcodeSelectTaskRunner = mockXcodeSelectTaskRunner;
    __unused NSView *view = _controller.view;
    XCTAssertEqualObjects(_controller.errorDescription, NSLocalizedString(@"Cannot find Xcode", @"Xcode not found description"));
    XCTAssertEqualObjects(_controller.recoverySuggestion, NSLocalizedString(@"Install Xcode and use xcode-select to configure its location", @"Xcode not found recovery suggestion"));
}

/**
 * Tests that baseSDKPopup control contains the list of available base SDKs.
 */
- (void)testBaseSDKsPopupIsPopulated
{
    XCTAssertEqualObjects([_controller.baseSDKPopup itemTitleAtIndex:0], @"OS X 10.7");
    XCTAssertEqualObjects([_controller.baseSDKPopup itemTitleAtIndex:1], @"OS X 10.8");
    XCTAssertEqualObjects([_controller.baseSDKPopup itemTitleAtIndex:2], @"OS X 10.9");
}

/**
 * Tests that selecting a new base SDK from the baseSDKPopup control causes
 * the compiler preferences to be updated accordingly.
 */
- (void)testBaseSDKsPopupSelectionPopulatesBaseSDKPreferenceOption
{
    id mockCompilerPreferences = _controller.compilerPreferences;
    [[mockCompilerPreferences expect] setPreferredBaseSDK:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [[obj displayName] isEqualToString:@"OS X 10.7"];
    }]];
    [_controller.baseSDKPopup selectItemAtIndex:0];
    XCTAssertNoThrow([_controller baseSDKPopupClicked:nil]);
    XCTAssertNoThrow([mockCompilerPreferences verify]);
    
    [[mockCompilerPreferences expect] setPreferredBaseSDK:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [[obj displayName] isEqualToString:@"OS X 10.8"];
    }]];
    [_controller.baseSDKPopup selectItemAtIndex:1];
    XCTAssertNoThrow([_controller baseSDKPopupClicked:nil]);
    XCTAssertNoThrow([mockCompilerPreferences verify]);
    
    [[mockCompilerPreferences expect] setPreferredBaseSDK:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [[obj displayName] isEqualToString:@"OS X 10.9"];
    }]];
    [_controller.baseSDKPopup selectItemAtIndex:2];
    XCTAssertNoThrow([_controller baseSDKPopupClicked:nil]);
    XCTAssertNoThrow([mockCompilerPreferences verify]);
}

@end
