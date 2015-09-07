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
    _list2 = [FakeClassList new];
    _list2.classes = @{ @"Bar" : @[@"TheirBar", @"MyBar"],
                        @"Baz" : @[@"WKBaz", @"MKBaz"] };
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

@end
