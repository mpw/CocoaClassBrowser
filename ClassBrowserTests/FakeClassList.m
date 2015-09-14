//See COPYING for licence details.

#import "FakeClassList.h"

@implementation FakeClassList
{
    NSArray *_protocols;
    NSArray *_methods;
    NSMutableDictionary *_protocolsInClasses;
    NSMutableDictionary *_methodsInProtocols;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _protocols = @[IKBProtocolAllMethods, IKBProtocolUncategorizedMethods, @"NSCopying"];
        _methods = @[ @"-copyWithZone:" , @"+alloc" ];
        _protocolsInClasses = [NSMutableDictionary dictionary];
        _methodsInProtocols = [NSMutableDictionary dictionary];
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
    return [_protocols arrayByAddingObjectsFromArray:_protocolsInClasses[className]];
}

- (NSUInteger)countOfProtocolsInClass:(NSString *)className
{
    return [[self protocolsInClass:className] count];
}

- (NSString *)protocolInClass:(NSString *)className atIndex:(NSUInteger)index
{
    return [self protocolsInClass:className][index];
}

- (NSString *)keyForProtocol:(NSString *)protocolName class:(NSString *)className
{
    return [protocolName stringByAppendingString:className];
}

- (NSArray *)methodsInProtocol:(NSString *)protocolName ofClass:(NSString *)className
{
    return [_methods arrayByAddingObjectsFromArray:_methodsInProtocols[[self keyForProtocol:protocolName class:className]]];
}

- (NSUInteger)countOfMethodsInProtocol:(NSString *)protocolName ofClass:(NSString *)className
{
    return [[self methodsInProtocol:protocolName ofClass:className] count];
}

- (NSString *)methodInProtocol:(NSString *)protocolName ofClass:(NSString *)className atIndex:(NSUInteger)index
{
    return [self methodsInProtocol:protocolName ofClass:className][index];
}

- (void)setProtocols:(NSArray *)protocols forClass:(NSString *)className
{
    _protocolsInClasses[className] = protocols;
}

- (void)setMethods:(NSArray *)methods forProtocol:(NSString *)protocolName inClass:(NSString *)className
{
    _methodsInProtocols[[self keyForProtocol:protocolName class:className]] = methods;
}
@end
