//
//  ClassBrowserTests.m
//  ClassBrowserTests
//
//  Created by Graham Lee on 10/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "IKBClassList.h"
#import "IKBClassBrowserSource.h"

#import "FakeClassList.h"

@interface FakeBrowserCell : NSObject

@property (nonatomic, strong) NSString *stringValue;
@property (nonatomic, assign, getter = isLeaf) BOOL leaf;

@end

@implementation FakeBrowserCell
@end

@interface ReloadWatcher : NSObject

@property (nonatomic, assign) NSInteger reloadedColumn;

@end

@implementation ReloadWatcher

- (void)reloadColumn:(NSInteger)column
{
    self.reloadedColumn = column;
}

@end

@interface ClassBrowserTests : XCTestCase

@end

@implementation ClassBrowserTests
{
    IKBClassBrowserSource *source;
    FakeClassList *list;
    FakeBrowserCell *cell;
}

- (void)setUp
{
    list = [FakeClassList new];
    list.classes = @{ @"Foundation" : @[@"NSObject", @"NSData", @"NSString"],
                      @"AppKit" : @[@"NSBrowser", @"NSCell", @"NSTableView", @"NSMatrix"],
                      @"Isambard" : @[@"IKBCommandBus"] };
    source = [[IKBClassBrowserSource alloc] initWithClassList:list];
    cell = [FakeBrowserCell new];
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
    [source browser:nil willDisplayCell:cell atRow:0 column:0];
    XCTAssertEqualObjects([cell stringValue], @"AppKit");
    [source browser:nil willDisplayCell:cell atRow:1 column:0];
    XCTAssertEqualObjects([cell stringValue], @"Foundation");
    [source browser:nil willDisplayCell:cell atRow:2 column:0];
    XCTAssertEqualObjects([cell stringValue], @"Isambard");
}

- (void)testColumnZeroCellsAreBranches
{
    [source browser:nil willDisplayCell:cell atRow:0 column:0];
    XCTAssertFalse([cell isLeaf]);
}

- (void)testBrowserCellSelectionResultsInChoosingAClassGroupInTheDataModel
{
    [source browser:nil didSelectRow:1 inColumn:0];
    XCTAssertEqualObjects(list.selectedClassGroup, @"Foundation");
}

- (void)testBrowserCellsInColumnOneAreNamedAfterTheClassesInTheSelectedGroup
{
    [source browser:nil didSelectRow:0 inColumn:0];
    XCTAssertEqual([source browser:nil numberOfRowsInColumn:1], (NSInteger)4);
    [source browser:nil willDisplayCell:cell atRow:2 column:1];
    XCTAssertEqualObjects([cell stringValue], @"NSTableView");
}

- (void)testSelectingClassGroupResultsInReloadingClassColumn
{
    ReloadWatcher *watcher = [ReloadWatcher new];
    [source browser:(NSBrowser *)watcher didSelectRow:1 inColumn:0];
    XCTAssertEqual(watcher.reloadedColumn, (NSInteger)1);
}

@end
