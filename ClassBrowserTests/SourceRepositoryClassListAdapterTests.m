//See COPYING for licence details.

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "IKBObjectiveCClass.h"
#import "IKBSourceRepositoryClassList.h"
#import "IKBSourceRepository.h"

@interface SourceRepositoryClassListAdapterTests : XCTestCase

@end

@implementation SourceRepositoryClassListAdapterTests
{
    IKBSourceRepositoryClassList *_classList;
    IKBSourceRepository *_repository;
}

- (void)setUp
{
    _repository = [IKBSourceRepository new];
    _classList = [[IKBSourceRepositoryClassList alloc] initWithRepository:_repository];
}

- (void)testEmptyRepositoryHasNoClassGroups
{
    XCTAssertEqual([_classList countOfClassGroups], 0);
    XCTAssertEqualObjects([_classList allClassGroups], @[]);
}

- (void)testRepositoryWithCustomClassHasAClassGroupForIt
{
    IKBObjectiveCClass *aClass = [[IKBObjectiveCClass alloc] initWithName:@"IKBFictionalClass" superclass:@"NSObject"];
    [_repository addClass:aClass];
    XCTAssertEqual([_classList countOfClassGroups], 1);
    XCTAssertEqualObjects([_classList objectInClassGroupsAtIndex:0], @"Custom Classes");
}

- (void)testRepositoryClassesAreOrderedAlphabetically
{
    IKBObjectiveCClass *aClass = [[IKBObjectiveCClass alloc] initWithName:@"BFictionalClass" superclass:@"NSObject"];
    [_repository addClass:aClass];
    IKBObjectiveCClass *anotherClass = [[IKBObjectiveCClass alloc] initWithName:@"AFictionalClass" superclass:@"NSObject"];
    [_repository addClass:anotherClass];
    NSString *group = @"Custom Classes";
    XCTAssertEqual([_classList countOfClassesInGroup:group], 2);
    XCTAssertEqualObjects([_classList classInGroup:group atIndex:0], @"AFictionalClass");
    XCTAssertEqualObjects([_classList classInGroup:group atIndex:1], @"BFictionalClass");
}

@end
