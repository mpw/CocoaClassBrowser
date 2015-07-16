//See COPYING for licence details.

#import <XCTest/XCTest.h>
#import "IKBRuntimeClassList.h"
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

void selectSecondClassInBrowser(IKBClassBrowserSource *source, NSBrowser *browser)
{
    [source browser:browser didSelectRow:0 inColumn:0];
    [source browser:browser didSelectRow:1 inColumn:1];
}

void selectSecondProtocolForSecondClassInBrowser(IKBClassBrowserSource *source, NSBrowser *browser)
{
    selectSecondClassInBrowser(source, browser);
    [source browser:browser didSelectRow:1 inColumn:2];
}

@interface ClassBrowserTests : XCTestCase

@end

@implementation ClassBrowserTests
{
    IKBClassBrowserSource *source;
    FakeClassList *list;
    FakeBrowserCell *cell;
    ReloadWatcher *watcher;
}

- (void)setUp
{
    list = [FakeClassList new];
    list.classes = @{ @"Foundation" : @[@"NSObject", @"NSData", @"NSString"],
                      @"AppKit" : @[@"NSBrowser", @"NSCell", @"NSTableView", @"NSMatrix"],
                      @"Isambard" : @[@"IKBCommandBus"] };
    source = [[IKBClassBrowserSource alloc] initWithClassList:list];
    cell = [FakeBrowserCell new];
    watcher = [ReloadWatcher new];
    watcher.reloadedColumn = NSNotFound;
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
    [source browser:(NSBrowser *)watcher didSelectRow:1 inColumn:0];
    XCTAssertEqual(watcher.reloadedColumn, (NSInteger)1);
}

- (void)testColumnOneCellsAreBranches
{
    [source browser:nil didSelectRow:0 inColumn:0];
    [source browser:nil willDisplayCell:cell atRow:0 column:1];
    XCTAssertFalse([cell isLeaf]);
}

- (void)testSelectingACellInColumnOneResultsInColumnTwoBeingReloaded
{
    selectSecondClassInBrowser(source, (NSBrowser *)watcher);
    XCTAssertEqual(watcher.reloadedColumn, (NSInteger)2);
}

- (void)testSelectingClassInBrowserIsReflectedInDataModel
{
    selectSecondClassInBrowser(source, nil);
    XCTAssertEqualObjects(list.selectedClass, @"NSCell");
}

- (void)testProtocolsAreShownInTheThirdColumn
{
    //the test data is expressed in FakeClassList, but @"--all--" and @"uncategorized" are always present anyway.
    selectSecondClassInBrowser(source, nil);
    XCTAssertEqual([source browser:nil numberOfRowsInColumn:2], (NSInteger)3);
    [source browser:nil willDisplayCell:cell atRow:0 column:2];
    XCTAssertEqualObjects([cell stringValue], @"--all--");
    [source browser:nil willDisplayCell:cell atRow:1 column:2];
    XCTAssertEqualObjects([cell stringValue], @"uncategorized");
    [source browser:nil willDisplayCell:cell atRow:2 column:2];
    XCTAssertEqualObjects([cell stringValue], @"NSCopying");
    XCTAssertFalse([cell isLeaf]);
}

- (void)testSelectingProtocolInBrowserIsReflectedInDataModel
{
    selectSecondProtocolForSecondClassInBrowser(source, nil);
    XCTAssertEqualObjects(list.selectedProtocol, @"uncategorized");
}

- (void)testSelectingProtocolRefreshesMethodColumn
{
    selectSecondProtocolForSecondClassInBrowser(source, (NSBrowser *)watcher);
    XCTAssertEqual(watcher.reloadedColumn, (NSInteger)3);
}

- (void)testMethodsAreShownInTheFourthColumn
{
    //again, the data here is in FakeClassList.
    selectSecondProtocolForSecondClassInBrowser(source, nil);
    XCTAssertEqual([source browser:nil numberOfRowsInColumn:3], (NSInteger)2);
    [source browser:nil willDisplayCell:cell atRow:0 column:3];
    XCTAssertEqualObjects([cell stringValue], @"-copyWithZone:");
    XCTAssertTrue([cell isLeaf]);
}

- (void)testSelectingMethodDoesNotReloadAnything
{
    [source browser:(NSBrowser *)watcher didSelectRow:0 inColumn:3];
    XCTAssertEqual(watcher.reloadedColumn, (NSInteger)NSNotFound);
}
@end
