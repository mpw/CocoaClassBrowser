//See COPYING for licence details.

#import "FakeClassList.h"

@implementation FakeClassList
{
    NSInteger _selectedGroup;
    NSInteger _selectedClass;
    NSInteger _selectedProtocol;
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

- (void)selectClassGroupAtIndex:(NSInteger)index
{
    _selectedGroup = index;
}

- (NSString *)selectedClassGroup
{
    return self.classGroups[_selectedGroup];
}

- (NSArray *)classGroups
{
    return [self.classes.allKeys sortedArrayUsingSelector:@selector(compare:)];
}

- (NSUInteger)countOfClasses
{
    return [self.classes[self.selectedClassGroup] count];
}

- (NSString *)objectInClassesAtIndex:(NSUInteger)index
{
    return self.classes[self.selectedClassGroup][index];
}

- (NSArray *)classesInSelectedGroup
{
    return self.classes[self.selectedClassGroup];
}

- (void)selectClassAtIndex:(NSInteger)index
{
    _selectedClass = index;
}

- (NSString *)selectedClass
{
    return self.classes[self.selectedClassGroup][_selectedClass];
}

- (NSUInteger)countOfProtocols
{
    return _protocols.count;
}

- (NSString *)objectInProtocolsAtIndex:(NSUInteger)index
{
    return _protocols[index];
}

- (void)selectProtocolAtIndex:(NSInteger)index
{
    _selectedProtocol = index;
}

- (NSString *)selectedProtocol
{
    return _protocols[_selectedProtocol];
}

- (NSUInteger)countOfMethods
{
    return _methods.count;
}

- (NSString *)objectInMethodsAtIndex:(NSUInteger)index
{
    return _methods[index];
}

- (NSArray *)protocolsInSelectedClass
{
    return _protocols;
}

@end
