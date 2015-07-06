//See COPYING for licence details.

#import "IKBInspectorDataSource.h"

#import <objc/runtime.h>

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
