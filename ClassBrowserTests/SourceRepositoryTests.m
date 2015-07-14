// See COPYING for license details.

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "IKBSourceRepository.h"
#import "IKBObjectiveCMethod.h"

@interface SourceRepositoryTests : XCTestCase

@end

@implementation SourceRepositoryTests
{
    IKBSourceRepository *_repository;
}

- (void)setUp
{
    _repository = [IKBSourceRepository new];
}

- (void)testMethodCanBeAddedToTheRepository
{
    IKBObjectiveCMethod *method = [IKBObjectiveCMethod new];
    [_repository addMethod:method];
    XCTAssertTrue([[_repository allMethods] containsObject:method]);
}

- (void)testMethodsCanBeLookedUpByClass
{
    IKBObjectiveCMethod *method = [IKBObjectiveCMethod new];
    method.className = NSStringFromClass([NSNumber class]);
    IKBObjectiveCMethod *otherMethod = [IKBObjectiveCMethod new];
    otherMethod.className = NSStringFromClass([NSData class]);
    [_repository addMethod:method];
    NSArray *numberMethods = [_repository methodsForClassNamed:NSStringFromClass([NSNumber class])];
    XCTAssertTrue([numberMethods containsObject:method]);
    XCTAssertFalse([numberMethods containsObject:otherMethod]);
    NSArray *arrayMethods = [_repository methodsForClassNamed:NSStringFromClass([NSArray class])];
    XCTAssertEqual([arrayMethods count], 0);
}

- (void)testCodingRoundTrip
{
    IKBObjectiveCMethod *method = [IKBObjectiveCMethod new];
    method.className = @"IKBMyClass";
    method.declaration = @"- (void)doThing";
    method.body = @"{\n  [self doTheThing];\n}\n";
    [_repository addMethod:method];
    IKBSourceRepository *otherRepository = [NSKeyedUnarchiver unarchiveObjectWithData:
                                            [NSKeyedArchiver archivedDataWithRootObject:_repository]];
    XCTAssertEqualObjects(_repository.allMethods, otherRepository.allMethods);
}

@end
