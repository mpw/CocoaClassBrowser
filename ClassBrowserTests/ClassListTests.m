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
    NSArray *classGroups;
    NSUInteger foundationIndex;
}

- (void)setUp
{
    list = [IKBClassList new];
    classGroups = [list allClassGroups];
    foundationIndex = [classGroups indexOfObject:@"Foundation"];
}

- (void)testClassGroupsAreNamedAfterBinaryImages
{
    XCTAssertTrue([classGroups containsObject:@"Foundation"]);
}

- (void)testClassGroupsAreOrderedAlphabetically
{
    NSUInteger appkitIndex = [classGroups indexOfObject:@"AppKit"];
    XCTAssertTrue(appkitIndex < foundationIndex);
}

- (void)testSelectingAClassGroupLetsYouInvestigateItsClasses
{
    [list selectClassGroupAtIndex:foundationIndex];
    NSArray *foundationClasses = [list classesInSelectedGroup];
    XCTAssertTrue([foundationClasses containsObject:@"NSXMLParser"]);
    XCTAssertFalse([foundationClasses containsObject:@"NSCell"]);
}

- (void)testClassesInAGroupAreOrderedAlphabetically
{
    [list selectClassGroupAtIndex:foundationIndex];
    NSArray *foundationClasses = [list classesInSelectedGroup];
    NSUInteger xmlParserIndex = [foundationClasses indexOfObject:@"NSXMLParser"];
    NSUInteger conditionLockIndex = [foundationClasses indexOfObject:@"NSConditionLock"];
    XCTAssertTrue(conditionLockIndex < xmlParserIndex);
}

@end
