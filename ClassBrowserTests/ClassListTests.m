//
//  ClassListTests.m
//  ClassBrowser
//
//  Created by Graham Lee on 10/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "IKBClassList.h"


@interface ClassListTests : XCTestCase

@end

@implementation ClassListTests

- (void)testClassGroupsIncludeBinariesForUngroupedClasses
{
    IKBClassList *list = [IKBClassList new];
    BOOL hasFoundation = NO;
    for (NSUInteger i = 0; i < [list countOfClassGroups]; i++) {
        NSString *classGroup = [list objectInClassGroupsAtIndex:i];
        if ([classGroup isEqualToString:@"Foundation"])
        {
            hasFoundation = YES;
            break;
        }
    }
    XCTAssertTrue(hasFoundation);
}

@end
