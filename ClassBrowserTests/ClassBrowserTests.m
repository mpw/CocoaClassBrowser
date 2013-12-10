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
- (NSString *)objectInClassGroupsAtIndex:(NSUInteger)index;

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

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(NSInteger)row column:(NSInteger)column
{
    NSString *groupName = [_classList objectInClassGroupsAtIndex:row];
    [cell setStringValue:groupName];
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

- (NSString *)objectInClassGroupsAtIndex:(NSUInteger)index
{
    return [self.classGroups objectAtIndex:index];
}

@end

@interface FakeBrowserCell : NSObject

@property (nonatomic, strong) NSString *stringValue;

@end

@implementation FakeBrowserCell
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
    list.classGroups = @[ @"Foundation", @"AppKit", @"Isambard" ];
    source = [[IKBClassBrowserSource alloc] initWithClassList:list];
}

- (void)testConformanceToBrowserDelegateProtocol
{
    XCTAssertTrue([source conformsToProtocol:@protocol(NSBrowserDelegate)]);
}

- (void)testColumnZeroHasOneRowForEveryClassGroup
{
    XCTAssertEqual([source browser:nil numberOfRowsInColumn:0], (NSInteger)3);
}

- (void)testColumnZeroCellsAreNamedAfterClassGroups
{
    FakeBrowserCell *cell = [FakeBrowserCell new];
    [source browser:nil willDisplayCell:cell atRow:0 column:0];
    XCTAssertEqualObjects([cell stringValue], @"Foundation");
    [source browser:nil willDisplayCell:cell atRow:1 column:0];
    XCTAssertEqualObjects([cell stringValue], @"AppKit");
    [source browser:nil willDisplayCell:cell atRow:2 column:0];
    XCTAssertEqualObjects([cell stringValue], @"Isambard");
}

@end
