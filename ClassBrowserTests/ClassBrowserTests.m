//
//  ClassBrowserTests.m
//  ClassBrowserTests
//
//  Created by Graham Lee on 10/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import <XCTest/XCTest.h>

@protocol IKBClassList <NSObject>

- (NSUInteger)countOfClassGroups;

@end

@interface IKBClassBrowserSource : NSObject <NSBrowserDelegate>

- (instancetype)initWithClassList:(id <IKBClassList>)list;

@end

@implementation IKBClassBrowserSource
{
    id <IKBClassList> _classList;
}

- (instancetype)initWithClassList:(id)list
{
    self = [super init];
    if (self)
    {
        _classList = list;
    }
    return self;
}

- (NSInteger)browser:(NSBrowser *)sender numberOfRowsInColumn:(NSInteger)column
{
    return [_classList countOfClassGroups];
}

@end

@interface FakeClassList : NSObject <IKBClassList>

@property (nonatomic, strong) NSArray *classGroups;

@end

@implementation FakeClassList

- (NSUInteger)countOfClassGroups
{
    return self.classGroups.count;
}

@end

@interface ClassBrowserTests : XCTestCase

@end

@implementation ClassBrowserTests
{
    IKBClassBrowserSource *source;
    FakeClassList *list;
}

- (void)setUp
{
    list = [FakeClassList new];
    source = [[IKBClassBrowserSource alloc] initWithClassList:list];
}

- (void)testConformanceToBrowserDelegateProtocol
{
    XCTAssertTrue([source conformsToProtocol:@protocol(NSBrowserDelegate)]);
}

- (void)testColumnZeroHasOneRowForEveryClassGroup
{
    list.classGroups = @[ @"Foundation", @"AppKit", @"Isambard" ];
    XCTAssertEqual([source browser:nil numberOfRowsInColumn:0], (NSInteger)3);
}

@end
