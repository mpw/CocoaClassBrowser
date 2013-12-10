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
{
    id <IKBClassList> list;
}

- (void)setUp
{
    list = [IKBClassList new];
}

- (void)testClassGroupsAreNamedAfterBinaryImages
{
    NSArray *classGroups = [list allClassGroups];
    XCTAssertTrue([classGroups containsObject:@"Foundation"]);
}

- (void)testClassGroupsAreOrderedAlphabetically
{
    NSArray *classGroups = [list allClassGroups];
    NSUInteger foundationIndex = [classGroups indexOfObject:@"Foundation"];
    NSUInteger appkitIndex = [classGroups indexOfObject:@"AppKit"];
    XCTAssertTrue(appkitIndex < foundationIndex);
}

@end
