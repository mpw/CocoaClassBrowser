// See COPYING for license details.

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "IKBObjectiveCMethod.h"

@interface MethodTests : XCTestCase

@end

@implementation MethodTests
{
    IKBObjectiveCMethod *_method;
}

- (void)setUp
{
    _method = [IKBObjectiveCMethod new];
}

- (void)testNoArgumentInstanceMethodHasCanonicalNameWithoutReturnValue
{
    _method.declaration = @"-(id)count";
    XCTAssertEqualObjects(_method.canonicalName, @"-count");
}

- (void)testNoArgumentClassMethodHasCanonicalNameWithoutReturnValue
{
    _method.declaration = @"+(id)count";
    XCTAssertEqualObjects(_method.canonicalName, @"+count");
}

- (void)testOneArgumentInstanceMethodHasCanonicalNameWithoutReturnValueOrArgumentType
{
    _method.declaration = @"-(id)objectAtIndex:(NSInteger)index";
    XCTAssertEqualObjects(_method.canonicalName, @"-objectAtIndex:");
}

- (void)testSpacesInCommonPlacesAreConsideredInBuildingTheCanonicalName
{
    _method.declaration = @"- (char *)unicodeVersionOfString: (NSString *)string";
    XCTAssertEqualObjects(_method.canonicalName, @"-unicodeVersionOfString:");
}

- (void)testCrazyBlockSyntaxParenthesisDepthIsHonoured
{
    _method.declaration = @"+ (void)classMethodWithCompletion: ((id)(^)(id, NSError *))completion";
    XCTAssertEqualObjects(_method.canonicalName, @"+classMethodWithCompletion:");
}

- (void)testMethodWithMultipleParameters
{
    _method.declaration = @"+ (NSColor *)colorWithColorSpace:(NSColorSpace *)space components:(const CGFloat *)components count:(NSInteger)numberOfComponents";
    XCTAssertEqualObjects(_method.canonicalName, @"+colorWithColorSpace:components:count:");
}

@end
