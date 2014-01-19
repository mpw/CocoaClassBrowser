//
//  CompilerPreferencesViewControllerTests.m
//  ClassBrowser
//
//  Created by Éric Trépanier on 2014-01-17.
//  Copyright (c) 2014 Project Isambard. All rights reserved.
//

#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "IKBCompilerPreferencesViewController_ClassExtension.h"
#import "IKBBaseSDK.h"
#import "IKBCompilerDefaults.h"

@interface CompilerPreferencesViewControllerTests : XCTestCase

@end

@implementation CompilerPreferencesViewControllerTests
{
    IKBCompilerPreferencesViewController *_controller;
}

- (void)setUp
{
    _controller = [IKBCompilerPreferencesViewController new];
    id mockCompilerDefaults = [OCMockObject mockForClass:[IKBCompilerDefaults class]];
    NSArray *baseSDKs = @[[[IKBBaseSDK alloc] initWithDisplayName:@"OS X 10.7" path:@"MacOSX10.7.sdk" version:@"10.7"],
                          [[IKBBaseSDK alloc] initWithDisplayName:@"OS X 10.8" path:@"MacOSX10.8.sdk" version:@"10.8"],
                          [[IKBBaseSDK alloc] initWithDisplayName:@"OS X 10.9" path:@"MacOSX10.9.sdk" version:@"10.9"]];
    [[[mockCompilerDefaults expect] andReturn:baseSDKs] baseSDKs];
    [[[mockCompilerDefaults expect] andReturn:[baseSDKs lastObject]] currentBaseSDK];
    _controller.compilerDefaults = mockCompilerDefaults;
    __unused NSView *view = _controller.view;
    XCTAssertNoThrow([mockCompilerDefaults verify]);
}

- (void)testBaseSDKsPopupIsPopulated
{
    XCTAssertEqualObjects([_controller.baseSDKPopup itemTitleAtIndex:0], @"OS X 10.7");
    XCTAssertEqualObjects([_controller.baseSDKPopup itemTitleAtIndex:1], @"OS X 10.8");
    XCTAssertEqualObjects([_controller.baseSDKPopup itemTitleAtIndex:2], @"OS X 10.9");
}

- (void)testBaseSDKsPopupSelectionPopulatesBaseSDKPreferenceOption
{
    id mockCompilerDefaults = _controller.compilerDefaults;
    [[mockCompilerDefaults expect] setCurrentBaseSDK:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [[obj displayName] isEqualToString:@"OS X 10.7"];
    }]];
    [_controller.baseSDKPopup selectItemAtIndex:0];
    XCTAssertNoThrow([_controller baseSDKPopupClicked:nil]);
    XCTAssertNoThrow([mockCompilerDefaults verify]);
    
    [[mockCompilerDefaults expect] setCurrentBaseSDK:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [[obj displayName] isEqualToString:@"OS X 10.8"];
    }]];
    [_controller.baseSDKPopup selectItemAtIndex:1];
    XCTAssertNoThrow([_controller baseSDKPopupClicked:nil]);
    XCTAssertNoThrow([mockCompilerDefaults verify]);
    
    [[mockCompilerDefaults expect] setCurrentBaseSDK:[OCMArg checkWithBlock:^BOOL(id obj) {
        return [[obj displayName] isEqualToString:@"OS X 10.9"];
    }]];
    [_controller.baseSDKPopup selectItemAtIndex:2];
    XCTAssertNoThrow([_controller baseSDKPopupClicked:nil]);
    XCTAssertNoThrow([mockCompilerDefaults verify]);
}

@end
