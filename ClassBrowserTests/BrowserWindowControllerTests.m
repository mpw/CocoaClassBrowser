//
//  BrowserWindowControllerTests.m
//  ClassBrowser
//
//  Created by Graham Lee on 10/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "IKBClassBrowserWindowController.h"
#import "IKBClassBrowserWindowController_ClassExtension.h"

@interface BrowserWindowControllerTests : XCTestCase

@end

@implementation BrowserWindowControllerTests

- (void)testBrowserHasADelegateAfterTheWindowWasLoaded
{
    IKBClassBrowserWindowController *controller = [[IKBClassBrowserWindowController alloc] initWithWindowNibName:@"IKBClassBrowserWindowController"];
    XCTAssertEqualObjects(controller.classBrowser.delegate, controller.browserSource);
}

@end
