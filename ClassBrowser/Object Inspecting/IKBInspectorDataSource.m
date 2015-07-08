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
    Class theClass = object_getClass(target);
    NSMutableArray *classList = [[@[theClass] mutableCopy] autorelease];
    while ((theClass = class_getSuperclass(theClass)) != Nil) {
        [classList insertObject:theClass atIndex:0];
    }
    NSMutableArray *names = [NSMutableArray array];
    for (Class aClass in classList) {
        unsigned int ivarCount;
        Ivar *ivars = class_copyIvarList(aClass, &ivarCount);
        for (unsigned int i = 0; i < ivarCount; i++) {
            const char *thisName = ivar_getName(ivars[i]);
            [names addObject:@(thisName)];
        }
        free(ivars);
    }
    _ivarNames = [names copy];
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
        !strcmp(type, @encode(short)) ||
        !strcmp(type, @encode(long)) ||
        !strcmp(type, @encode(long long)) ||
        !strcmp(type, @encode(char))) {
        long long integerValue = (long long)value;
        return @(integerValue);
    } else if (!strcmp(type, @encode(unsigned int)) ||
               !strcmp(type, @encode(unsigned short)) ||
               !strcmp(type, @encode(unsigned long)) ||
               !strcmp(type, @encode(unsigned long long)) ||
               !strcmp(type, @encode(unsigned char)) ||
               !strcmp(type, @encode(_Bool)) ||
               !strncmp(type, "b", 1)) {
        unsigned long long unsignedValue = (unsigned long long)value;
        return @(unsignedValue);
    } else if (!strcmp(type, @encode(double))) {
        uintptr_t intValue = (uintptr_t)value;
        uintptr_t *intPtr = &intValue;
        double *doublePtr = (double *)intPtr;
        return @(*doublePtr);
    } else if (!strcmp(type, @encode(float))) {
        uintptr_t intValue = (uintptr_t)value;
        uintptr_t *intPtr = &intValue;
        float *floatPtr = (float *)intPtr;
        return @(*floatPtr);
    } else if (!strncmp(type, @encode(id), 1) ||
               !strncmp(type, @encode(Class), 1)) {
        return (id)value;
    } else if (!strcmp(type, @encode(char *))) {
        char *string = (char *)value;
        return @(string);
    } else {
        // everything remaining should be a compound type, with value being a pointer to it.
        return [NSValue valueWithBytes:value objCType:type];
    }
}

- (void)dealloc
{
    [_inspectedObject release];
    [_ivarNames release];
    [super dealloc];
}
@end
