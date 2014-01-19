//
//  IKBCompilerDefaultsTests.m
//  ClassBrowser
//
//  Created by Éric Trépanier on 2014-01-19.
//  Copyright (c) 2014 Project Isambard. All rights reserved.
//

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "IKBCompilerDefaults_ClassExtension.h"
#import "IKBBaseSDK.h"

@interface FakeBaseSDKProvider : NSObject <IKBBaseSDKProvider>
{
	NSArray *_baseSDKs;
}
@end

@implementation FakeBaseSDKProvider

- (id)init
{
    self = [super init];
    if (self) {
        _baseSDKs = @[[[IKBBaseSDK alloc] initWithDisplayName:@"OS X 10.7" path:@"MacOSX10.7.sdk" version:@"10.7"],
                      [[IKBBaseSDK alloc] initWithDisplayName:@"OS X 10.8" path:@"MacOSX10.8.sdk" version:@"10.8"],
                      [[IKBBaseSDK alloc] initWithDisplayName:@"OS X 10.9" path:@"MacOSX10.9.sdk" version:@"10.9"]];
    }
    return self;
}

- (NSUInteger)numberOfBaseSDKs
{
    return _baseSDKs.count;
}

- (IKBBaseSDK *)baseSDKForIndex:(NSUInteger)index
{
    return _baseSDKs[index];
}

@end

@interface CompilerDefaultsTests : XCTestCase

@end

@implementation CompilerDefaultsTests
{
    IKBCompilerDefaults *_compilerDefaults;
}

- (void)setUp
{
    _compilerDefaults = [IKBCompilerDefaults new];
    _compilerDefaults.baseSDKsProvider = [FakeBaseSDKProvider new];
    _compilerDefaults.userDefaults = [OCMockObject niceMockForClass:[NSUserDefaults class]];
}

- (void)testDefaultsAreRegistered
{
    id mockUserDefaults = [OCMockObject mockForClass:[NSUserDefaults class]];
    [[mockUserDefaults expect] registerDefaults:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [obj[IKBCurrentBaseSDKVersionKey] isEqualToString:@"10.9"];
    }]];
    XCTAssertNoThrow(_compilerDefaults.userDefaults = mockUserDefaults);
    XCTAssertNoThrow([mockUserDefaults verify]);
}

- (void)testBaseSDKsIsPopulated
{
    XCTAssertEqual(_compilerDefaults.baseSDKs.count, (NSUInteger)3);
    XCTAssertEqualObjects([_compilerDefaults.baseSDKs[0] displayName], @"OS X 10.7");
    XCTAssertEqualObjects([_compilerDefaults.baseSDKs[1] displayName], @"OS X 10.8");
    XCTAssertEqualObjects([_compilerDefaults.baseSDKs[2] displayName], @"OS X 10.9");
}

- (void)testCurrentBaseSDKVersionUserDefaultIsQueriedWhenCurrentBaseSDKIsRetrieved
{
    id mockUserDefaults = _compilerDefaults.userDefaults;
    [[[mockUserDefaults expect] andReturn:@"10.9"] stringForKey:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [obj isEqualToString:IKBCurrentBaseSDKVersionKey];
    }]];
    IKBBaseSDK *baseSDK = nil;
    XCTAssertNoThrow(baseSDK = _compilerDefaults.currentBaseSDK);
    XCTAssertNoThrow([mockUserDefaults verify]);
    XCTAssertEqualObjects(baseSDK, [_compilerDefaults.baseSDKs lastObject]);
}

- (void)testCurrentBaseSDKVersionUserDefaultIsUpdatedWhenCurrentBaseSDKIsChanged
{
    id mockUserDefaults = _compilerDefaults.userDefaults;
    [[mockUserDefaults expect] setObject:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [obj isEqualToString:@"10.7"];
    }] forKey:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [obj isEqualToString:IKBCurrentBaseSDKVersionKey];
    }]];
    [[mockUserDefaults expect] synchronize];
    IKBBaseSDK *baseSDK = [_compilerDefaults.baseSDKsProvider baseSDKForIndex:0];
    XCTAssertNoThrow(_compilerDefaults.currentBaseSDK = baseSDK);
    XCTAssertNoThrow([mockUserDefaults verify]);
}

- (void)testCurrentBaseSDKVersionUserDefaultIsRemovedWhenCurrentBaseSDKIsSetToNil
{
    id mockUserDefaults = _compilerDefaults.userDefaults;
    [[mockUserDefaults expect] removeObjectForKey:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [obj isEqualToString:IKBCurrentBaseSDKVersionKey];
    }]];
    [[mockUserDefaults expect] synchronize];
    XCTAssertNoThrow(_compilerDefaults.currentBaseSDK = nil);
    XCTAssertNoThrow([mockUserDefaults verify]);
}

@end
