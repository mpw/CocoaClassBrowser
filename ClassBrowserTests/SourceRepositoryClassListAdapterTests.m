//See COPYING for licence details.

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "IKBObjectiveCClass.h"
#import "IKBObjectiveCMethod.h"
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

- (void)testRepositoryProtocolsAreOrderedAlphabetically
{
    [self addPopulatedClassToRepository];
    NSString *className = @"IKBThingDoer";
    XCTAssertEqual([_classList countOfProtocolsInClass:className], 4);
    XCTAssertEqualObjects([_classList protocolInClass:className atIndex:2], @"IKBThingDoing");
    XCTAssertEqualObjects([_classList protocolInClass:className atIndex:3], @"NSCopying");
}

- (void)addPopulatedClassToRepository
{
    IKBObjectiveCClass *aClass = [[IKBObjectiveCClass alloc] initWithName:@"IKBThingDoer" superclass:@"NSObject"];
    [_repository addClass:aClass];
    IKBObjectiveCMethod *aMethod = [IKBObjectiveCMethod new];
    aMethod.declaration = @"- (void)doTheThing";
    aMethod.protocolName = @"IKBThingDoing";
    aMethod.className = aClass.name;
    [_repository addMethod:aMethod];
    IKBObjectiveCMethod *anotherMethod = [IKBObjectiveCMethod new];
    anotherMethod.declaration = @"+ (id)classyThing";
    anotherMethod.protocolName = @"IKBThingDoing";
    anotherMethod.className = aClass.name;
    [_repository addMethod:anotherMethod];
    IKBObjectiveCMethod *yaMethod = [IKBObjectiveCMethod new];
    yaMethod.declaration = @"- (id)copyWithZone:(NSZone *)zone";
    yaMethod.protocolName = @"NSCopying";
    yaMethod.className = aClass.name;
    [_repository addMethod:yaMethod];
}
@end
