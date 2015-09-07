//See COPYING for licence details.

#import "FakeClassList.h"

@implementation FakeClassList
{
    NSArray *_protocols;
    NSArray *_methods;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _protocols = @[@"--all--", @"uncategorized", @"NSCopying"];
        _methods = @[ @"-copyWithZone:" , @"+alloc" ];
    }
    return self;
}

- (NSArray *)allClassGroups
{
    return self.classGroups;
}

- (NSUInteger)countOfClassGroups
{
    return self.classGroups.count;
}

- (NSString *)objectInClassGroupsAtIndex:(NSUInteger)index
{
    return [self.classGroups objectAtIndex:index];
}

- (NSArray *)classGroups
{
    return [self.classes.allKeys sortedArrayUsingSelector:@selector(compare:)];
}

- (NSUInteger)countOfClassesInGroup:(NSString *)group
{
    return [self.classes[group] count];
}

- (NSString *)classInGroup:(NSString *)group atIndex:(NSUInteger)index
{
    return self.classes[group][index];
}

- (NSArray *)classesInGroup:(NSString *)group
{
    return self.classes[group];
}

- (NSArray *)protocolsInClass:(NSString *)className
{
    return _protocols;
}

- (NSUInteger)countOfProtocolsInClass:(NSString *)className
{
    return _protocols.count;
}

- (NSString *)protocolInClass:(NSString *)className atIndex:(NSUInteger)index
{
    return _protocols[index];
}

- (NSUInteger)countOfMethodsInProtocol:(NSString *)protocolName ofClass:(NSString *)className
{
    return _methods.count;
}

- (NSString *)methodInProtocol:(NSString *)protocolName ofClass:(NSString *)className atIndex:(NSUInteger)index
{
    return _methods[index];
}

@end
