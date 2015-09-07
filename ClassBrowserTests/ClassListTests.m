//See COPYING for licence details.

#import <XCTest/XCTest.h>
#import "IKBRuntimeClassList.h"
#import "FakeClassList.h"
#import "IKBAppDelegate.h"


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
    list = [IKBRuntimeClassList new];
    classGroups = [list allClassGroups];
    foundationIndex = [classGroups indexOfObject:@"Foundation"];
}

- (NSArray *)foundationClasses
{
    return [list classesInGroup:@"Foundation"];
}

- (NSArray *)protocolsForNSConditionLock
{
    return [list protocolsInClass:@"NSConditionLock"];
}

- (NSArray *)protocolsForIKBAppDelegate
{
    return [list protocolsInClass:@"IKBAppDelegate"];
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
    NSArray *protocols = [self protocolsForNSConditionLock];
    XCTAssertEqualObjects(protocols[0], @"--all--");
    XCTAssertEqualObjects(protocols[1], @"uncategorized");
    XCTAssertEqualObjects(protocols[2], @"NSLocking");
}

- (void)testSelectingAProtocolLetsYouInvestigateItsMethods
{
//    __unused NSArray *protocols = [self protocolsForNSConditionLock];
//    [list selectProtocolAtIndex:2];
//    XCTAssertEqual([list countOfMethods], (NSUInteger)2);
//    XCTAssertEqualObjects([list objectInMethodsAtIndex:0], @"-lock");
//    XCTAssertEqualObjects([list objectInMethodsAtIndex:1], @"-unlock");
}

- (void)testSelectingAllMethodsShowsAllMethods
{
//    __unused NSArray *protocols = [self protocolsForIKBAppDelegate];
//    [list selectProtocolAtIndex:0];
//    XCTAssertEqual([list countOfMethods], (NSUInteger)10);
//    XCTAssertEqualObjects([list objectInMethodsAtIndex:0], @"-.cxx_destruct");
//    XCTAssertEqualObjects([list objectInMethodsAtIndex:9], @"-windowController");
}

- (void)testSelectingUncategorizedMethodsLeavesOutMethodsInProtocols
{
//    __unused NSArray *protocols = [self protocolsForIKBAppDelegate];
//    [list selectProtocolAtIndex:1];
//    XCTAssertEqual([list countOfMethods], (NSUInteger)9);
}

@end
