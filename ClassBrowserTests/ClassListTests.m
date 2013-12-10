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

- (NSArray *)foundationClasses
{
    [list selectClassGroupAtIndex:foundationIndex];
    return [list classesInSelectedGroup];
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
    NSArray *foundationClasses = [self foundationClasses];
    XCTAssertTrue([foundationClasses containsObject:@"NSXMLParser"]);
    XCTAssertFalse([foundationClasses containsObject:@"NSCell"]);
}

- (void)testClassesInAGroupAreOrderedAlphabetically
{
    NSArray *foundationClasses = [self foundationClasses];
    NSUInteger xmlParserIndex = [foundationClasses indexOfObject:@"NSXMLParser"];
    NSUInteger conditionLockIndex = [foundationClasses indexOfObject:@"NSConditionLock"];
    XCTAssertTrue(conditionLockIndex < xmlParserIndex);
}

- (void)testSelectingAClassLetsYouInvestigateItsProtocols
{
    NSArray *foundationClasses = [self foundationClasses];
    NSUInteger conditionLockIndex = [foundationClasses indexOfObject:@"NSConditionLock"];
    [list selectClassAtIndex:conditionLockIndex];
    NSArray *protocols = [list protocolsInSelectedClass];
    XCTAssertEqualObjects(protocols[0], @"--all--");
    XCTAssertEqualObjects(protocols[1], @"uncategorized");
    XCTAssertEqualObjects(protocols[2], @"NSLocking");
}

@end
