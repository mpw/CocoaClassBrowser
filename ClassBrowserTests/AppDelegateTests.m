//See COPYING for licence details.

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "IKBAppDelegate.h"
#import "IKBCommandBus.h"
#import "IKBCompileAndRunCodeCommandHandler.h"

@interface AppDelegateTests : XCTestCase

@end

@implementation AppDelegateTests
{
    IKBAppDelegate *_appDelegate;
}

- (void)setUp
{
    _appDelegate = [IKBAppDelegate new];
}

- (void)testAppDelegateRegistersCommandHandlers
{
    id mockBus = [OCMockObject mockForClass:[IKBCommandBus class]];
    [[mockBus expect] registerCommandHandler:[OCMArg checkWithBlock:^(id handler){
        return [handler isKindOfClass:[IKBCompileAndRunCodeCommandHandler class]];
    }]];
    _appDelegate.commandBus = mockBus;

    [_appDelegate applicationDidFinishLaunching:nil];
    [mockBus verify];
}

- (void)testAppDelegateHasTheAppCommandBusByDefault
{
    XCTAssertEqualObjects(_appDelegate.commandBus, [IKBCommandBus applicationCommandBus]);
}

- (void)testAppDelegateHasASourceRepository
{
    XCTAssertNotNil(_appDelegate.repository);
}

@end
