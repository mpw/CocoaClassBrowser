//
//  AppDelegateTests.m
//  ClassBrowser
//
//  Created by Graham Lee on 09/01/2014.
//  Copyright (c) 2014 Project Isambard. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "IKBAppDelegate.h"
#import "IKBCommandBus.h"
#import "IKBCompileAndRunCodeCommandHandler.h"

@interface AppDelegateTests : XCTestCase

@end

@implementation AppDelegateTests

- (void)testAppDelegateRegistersCommandHandlers
{
    IKBAppDelegate *appDelegate = [IKBAppDelegate new];
    id mockBus = [OCMockObject mockForClass:[IKBCommandBus class]];
    [[mockBus expect] registerCommandHandler:[OCMArg checkWithBlock:^(id handler){
        return [handler isKindOfClass:[IKBCompileAndRunCodeCommandHandler class]];
    }]];
    appDelegate.commandBus = mockBus;

    [appDelegate applicationDidFinishLaunching:nil];
    [mockBus verify];
}

@end
