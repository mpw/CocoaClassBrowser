//See COPYING for licence details.

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "FakeClassList.h"
#import "IKBCompositeClassList.h"

@interface CompositeClassListTests : XCTestCase

@end

@implementation CompositeClassListTests
{
    FakeClassList *_list1, *_list2;
    IKBCompositeClassList *_classList;
}

- (void)setUp
{
    _list1 = [FakeClassList new];
    _list1.classes = @{ @"Foo" : @[@"IKBFoo", @"NSFoo", @"UIFoo"],
                        @"Bar" : @[@"MyBar", @"YourBar"] };
    [_list1 setProtocols:@[@"A", @"C"] forClass:@"MyBar"];
    [_list1 setMethods:@[@"-doAThing"] forProtocol:@"A" inClass:@"MyBar"];
    _list2 = [FakeClassList new];
    _list2.classes = @{ @"Bar" : @[@"TheirBar", @"MyBar"],
                        @"Baz" : @[@"WKBaz", @"MKBaz"] };
    [_list2 setProtocols:@[@"A", @"B", @"C"] forClass:@"MyBar"];
    [_list2 setMethods:@[@"-doAnotherThing"] forProtocol:@"A" inClass:@"MyBar"];
    _classList = [IKBCompositeClassList compositeOfClassLists: @[_list1, _list2]];
}

- (void)testClassGroupsAreCombinedAndMerged
{
    NSArray *classGroups = _classList.allClassGroups;
    NSArray *expectedClassGroups = @[@"Bar", @"Baz", @"Foo"];
    XCTAssertEqualObjects(classGroups, expectedClassGroups);
    XCTAssertEqual([_classList countOfClassGroups], 3);
    XCTAssertEqualObjects([_classList objectInClassGroupsAtIndex:0], @"Bar");
}

- (void)testClassesInAGroupAreCombinedAndMerged
{
    NSArray *classes = [_classList classesInGroup:@"Bar"];
    NSArray *expectedClasses = @[@"MyBar", @"TheirBar", @"YourBar"];
    XCTAssertEqualObjects(classes, expectedClasses);
}

- (void)testClassesInGroupAreCorrectWhenOneSublistLacksThatGroup
{
    NSArray *classes = [_classList classesInGroup:@"Foo"];
    NSArray *expectedClasses = @[@"IKBFoo", @"NSFoo", @"UIFoo"];
    XCTAssertEqualObjects(classes, expectedClasses);
}

- (void)testProtocolsForAGivenClassAreCombinedAndMerged
{
    NSArray *protocols = [_classList protocolsInClass:@"MyBar"];
    NSArray *expectedProtocols = @[@"--all--", @"uncategorized", @"A", @"B", @"C", @"NSCopying"];
    XCTAssertEqualObjects(protocols, expectedProtocols);
}

- (void)testMethodsForAProtocolInAClassAreCombinedAndMerged
{
    NSArray *methods = [_classList methodsInProtocol:@"A" ofClass:@"MyBar"];
    NSArray *expectedMethods = @[@"+alloc", @"-copyWithZone:", @"-doAThing", @"-doAnotherThing"];
    XCTAssertEqualObjects(methods, expectedMethods);
}
@end
