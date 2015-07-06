//See COPYING for licence details.

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

#import <objc/runtime.h>

@interface IKBInspectorDataSource : NSObject <NSTableViewDataSource>

+ (instancetype)inspectorWithObject:target;

@end

@implementation IKBInspectorDataSource
{
    id _inspectedObject;
    NSArray *_ivarNames;
}

+ (instancetype)inspectorWithObject:target
{
    IKBInspectorDataSource *source = [self new];
    [source configureForObject:target];
    return source;
}

- (void)configureForObject:target
{
    _inspectedObject = target;
    if (target == nil)
    {
        _ivarNames = [NSArray array];
        return;
    }
    unsigned int ivarCount;
    Ivar *ivars = class_copyIvarList([target class], &ivarCount);
    NSMutableArray *names = [[NSMutableArray alloc] initWithCapacity:ivarCount];
    for (unsigned int i = 0; i < ivarCount; i++) {
        const char *thisName = ivar_getName(ivars[i]);
        [names addObject:@(thisName)];
    }
    _ivarNames = [names copy];
    free(ivars);
    return;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [_ivarNames count];
}

- tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString *selectorName = [NSString stringWithFormat:@"objectValueFor%@AtRow:", [tableColumn identifier]];
    return [self performSelector:NSSelectorFromString(selectorName) withObject:@(row)];
}

- objectValueForNameAtRow:aRow
{
    NSInteger row = [aRow integerValue];
    return _ivarNames[row];
}

@end

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

- (void)testDataSourceHasNoRowsIfItIsInspectingNil
{
    IKBInspectorDataSource *source = [IKBInspectorDataSource inspectorWithObject:nil];
    XCTAssertEqual([source numberOfRowsInTableView:nil], 0);
}

@end
