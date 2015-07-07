//See COPYING for licence details.

#import "IKBInspectorDataSource.h"

#import <objc/runtime.h>

@implementation IKBInspectorDataSource
{
    NSArray *_ivarNames;
}

+ (instancetype)inspectorWithObject:target
{
    IKBInspectorDataSource *source = [self new];
    [source configureForObject:target];
    return [source autorelease];
}

- (void)configureForObject:target
{
    _inspectedObject = [target retain];
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
    [names release];
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

- objectValueForValueAtRow:aRow
{
    NSString *ivarName = _ivarNames[[aRow integerValue]];
    void *value = NULL;
    Ivar ivar = object_getInstanceVariable(_inspectedObject, [ivarName UTF8String], &value);
    const char *type = ivar_getTypeEncoding(ivar);
    if (!strcmp(type, @encode(int)) ||
        !strcmp(type, @encode(long long)) ||
        !strcmp(type, @encode(unsigned long long))) {
        int integerValue = (int)value;
        return @(integerValue);
    } else if (!strncmp(type, @encode(id), 1)) {
        return (id)value;
    } else {
        return @"Cannot display this ivar";
    }
}

- (void)dealloc
{
    [_inspectedObject release];
    [_ivarNames release];
    [super dealloc];
}
@end
