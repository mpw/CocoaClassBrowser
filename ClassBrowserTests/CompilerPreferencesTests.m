//See COPYING for licence details.

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "IKBCompilerPreferences_ClassExtension.h"
#import "IKBBaseSDK.h"

@interface CompilerPreferencesTests : XCTestCase

@end

@implementation CompilerPreferencesTests
{
    IKBCompilerPreferences *_compilerPreferences;
    NSArray *_testBaseSDKs;
}

- (void)setUp
{
    _testBaseSDKs = @[[[IKBBaseSDK alloc] initWithDisplayName:@"OS X 10.7" path:@"MacOSX10.7.sdk" version:@"10.7"],
                      [[IKBBaseSDK alloc] initWithDisplayName:@"OS X 10.8" path:@"MacOSX10.8.sdk" version:@"10.8"],
                      [[IKBBaseSDK alloc] initWithDisplayName:@"OS X 10.9" path:@"MacOSX10.9.sdk" version:@"10.9"]];
    _compilerPreferences = [IKBCompilerPreferences new];
    _compilerPreferences.baseSDKs = _testBaseSDKs;
    _compilerPreferences.userDefaults = [OCMockObject niceMockForClass:[NSUserDefaults class]];
}

/**
 * Tests that the latest available base SDK version is registered in the user defaults.
 */
- (void)testDefaultsAreRegistered
{
    id mockUserDefaults = [OCMockObject niceMockForClass:[NSUserDefaults class]];
    [[mockUserDefaults expect] registerDefaults:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [obj[IKBPreferredBaseSDKVersionKey] isEqualToString:@"10.9"];
    }]];
    XCTAssertNoThrow(_compilerPreferences.userDefaults = mockUserDefaults);
    XCTAssertNoThrow([mockUserDefaults verify]);
}

/**
 * Tests that the list of available base SDKs can be retrieved.
 */
- (void)testBaseSDKsIsPopulated
{
    XCTAssertEqual(_compilerPreferences.baseSDKs.count, (NSUInteger)3);
    XCTAssertEqualObjects([_compilerPreferences.baseSDKs[0] displayName], @"OS X 10.7");
    XCTAssertEqualObjects([_compilerPreferences.baseSDKs[1] displayName], @"OS X 10.8");
    XCTAssertEqualObjects([_compilerPreferences.baseSDKs[2] displayName], @"OS X 10.9");
}

/**
 * Tests that asking for the preferred base SDK causes the preferred base SDK version
 * to be retrieved from the user defaults.
 */
- (void)testPreferredBaseSDKVersionUserDefaultIsQueriedWhenPreferredBaseSDKIsRetrieved
{
    id mockUserDefaults = _compilerPreferences.userDefaults;
    [[[mockUserDefaults expect] andReturn:@"10.9"] stringForKey:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [obj isEqualToString:IKBPreferredBaseSDKVersionKey];
    }]];
    IKBBaseSDK *baseSDK = nil;
    XCTAssertNoThrow(baseSDK = _compilerPreferences.preferredBaseSDK);
    XCTAssertNoThrow([mockUserDefaults verify]);
    XCTAssertEqualObjects(baseSDK, [_compilerPreferences.baseSDKs lastObject]);
}

/**
 * Tests that setting the preferred base SDK to a version other than the latest
 * causes the new preferred base SDK version to be saved to the user defaults.
 */
- (void)testPreferredBaseSDKVersionUserDefaultIsUpdatedWhenPreferredBaseSDKIsChanged
{
    id mockUserDefaults = _compilerPreferences.userDefaults;
    [[mockUserDefaults expect] setObject:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [obj isEqualToString:@"10.7"];
    }] forKey:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [obj isEqualToString:IKBPreferredBaseSDKVersionKey];
    }]];
    [[mockUserDefaults expect] synchronize];
    IKBBaseSDK *baseSDK = [_compilerPreferences.baseSDKs firstObject];
    XCTAssertNoThrow(_compilerPreferences.preferredBaseSDK = baseSDK);
    XCTAssertNoThrow([mockUserDefaults verify]);
}

/**
 * Tests that setting the preferred base SDK to the latest available version
 * causes the new preferred base SDK version to be removed from the user defaults.
 */
- (void)testPreferredBaseSDKVersionUserDefaultIsRemovedWhenPreferredBaseSDKIsSetToLatest
{
    id mockUserDefaults = _compilerPreferences.userDefaults;
    [[mockUserDefaults expect] removeObjectForKey:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [obj isEqualToString:IKBPreferredBaseSDKVersionKey];
    }]];
    [[mockUserDefaults expect] synchronize];
    IKBBaseSDK *baseSDK = [_compilerPreferences.baseSDKs lastObject];
    XCTAssertNoThrow(_compilerPreferences.preferredBaseSDK = baseSDK);
    XCTAssertNoThrow([mockUserDefaults verify]);
}

/**
 * Tests that setting the preferred base SDK to nil causes the new preferred base
 * SDK version to be removed from the user defaults.
 */
- (void)testPreferredBaseSDKVersionUserDefaultIsRemovedWhenPreferredBaseSDKIsSetToNil
{
    id mockUserDefaults = _compilerPreferences.userDefaults;
    [[mockUserDefaults expect] removeObjectForKey:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [obj isEqualToString:IKBPreferredBaseSDKVersionKey];
    }]];
    [[mockUserDefaults expect] synchronize];
    XCTAssertNoThrow(_compilerPreferences.preferredBaseSDK = nil);
    XCTAssertNoThrow([mockUserDefaults verify]);
}

@end
