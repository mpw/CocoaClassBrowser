//
//  XcodeClangArgumentBuilderTests.m
//  ClassBrowser
//
//  Created by Graham Lee on 06/01/2014.
//  Copyright (c) 2014 Project Isambard. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Xcode-Async/XCTest+Async.h"

#import "IKBXcodeClangArgumentBuilder.h"

@interface XcodeClangArgumentBuilderTests : XCTestCase

@end

@implementation XcodeClangArgumentBuilderTests
{
    id <IKBCompilerArgumentBuilder> _argumentBuilder;
}

- (void)setUp
{
    _argumentBuilder = [IKBXcodeClangArgumentBuilder new];
}

- (void)testDefaultCompilerArgumentsSpecifySyntaxOnlyObjCArc
{
    ASYNC_TEST_START;
    [_argumentBuilder constructCompilerArgumentsWithCompletion:^(NSArray *arguments, NSError *error){
        XCTAssertTrue([arguments containsObject:@"-fsyntax-only"]);
        XCTAssertTrue([arguments containsObject:@"-fobjc-arc"]);
        NSInteger indexOfDashX = [arguments indexOfObject:@"-x"];
        NSInteger indexOfObjC = [arguments indexOfObject:@"objective-c"];
        XCTAssertNotEqual(indexOfDashX, NSNotFound);
        XCTAssertNotEqual(indexOfObjC, NSNotFound);
        XCTAssertEqual(indexOfObjC - indexOfDashX, (NSInteger)1);
        ASYNC_TEST_DONE;
    }];
    ASYNC_TEST_END;
}

@end
