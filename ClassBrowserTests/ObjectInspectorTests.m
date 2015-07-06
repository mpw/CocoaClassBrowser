//See COPYING for licence details.

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import "IKBInspectorDataSource.h"

@interface ObjectToInspect : NSObject

@property (nonatomic, retain) NSNumber *count;
@property (nonatomic, copy) NSString *name;

@end

@implementation ObjectToInspect
{
    int _x;
}

- (id)init
{
    self = [super init];
    if (!self) return nil;
    _x = 37;
    return self;
}

@end

@interface ObjectInspectorTests : XCTestCase

@end

@implementation ObjectInspectorTests
{
    IKBInspectorDataSource *_source;
    ObjectToInspect *_target;
}

- (void)setUp
{
    _target = [ObjectToInspect new];
    _target.count = @(3.14);
    _target.name = @"Test Object";
    _source = [IKBInspectorDataSource inspectorWithObject:_target];
}

- (void)testDataSourceHasOneRowForEachInstanceVariableInTheTarget
{
    XCTAssertEqual([_source numberOfRowsInTableView:nil], 3);
}

- (void)testObjectValuesInNameColumnAreInstanceVariableNames
{
    NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"Name"];
    id name_row0 = [_source tableView:nil objectValueForTableColumn:column row:0];
    XCTAssertEqualObjects(name_row0, @"_x");
    id name_row1 = [_source tableView:nil objectValueForTableColumn:column row:1];
    XCTAssertEqualObjects(name_row1, @"_count");
    id name_row2 = [_source tableView:nil objectValueForTableColumn:column row:2];
    XCTAssertEqualObjects(name_row2, @"_name");
}

- (void)testObjectValuesInValueColumnAreInstanceVariableValues
{
    NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"Value"];
    id value_row0 = [_source tableView:nil objectValueForTableColumn:column row:0];
    XCTAssertEqualObjects(value_row0, @(37));
    id value_row1 = [_source tableView:nil objectValueForTableColumn:column row:1];
    XCTAssertEqualObjects(value_row1, @(3.14));
}

- (void)testDataSourceHasNoRowsIfItIsInspectingNil
{
    IKBInspectorDataSource *source = [IKBInspectorDataSource inspectorWithObject:nil];
    XCTAssertEqual([source numberOfRowsInTableView:nil], 0);
}

@end
