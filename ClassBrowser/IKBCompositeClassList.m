//See COPYING for licence details.

#import "IKBCompositeClassList.h"

@implementation IKBCompositeClassList
{
    NSArray *_classLists;
}

+ (instancetype)compositeOfClassLists:(NSArray *)classLists
{
  IKBCompositeClassList *composite = [[self alloc] init];
  composite->_classLists = [classLists copy];
  return composite;
}

- (NSArray *)_mergedClassGroups
{
    NSMutableOrderedSet *groupsBuilder = [NSMutableOrderedSet orderedSet];
    [_classLists enumerateObjectsUsingBlock:^(id <IKBClassList>list, NSUInteger idx, BOOL *stop) {
        NSArray *groups = list.allClassGroups;
        [groupsBuilder addObjectsFromArray:groups];
    }];
    NSArray *combinedGroups = [groupsBuilder array];
    combinedGroups = [combinedGroups sortedArrayUsingSelector:@selector(compare:)];
    return combinedGroups;
}

- (NSArray *)allClassGroups
{
    return [self _mergedClassGroups];
}

- (NSUInteger)countOfClassGroups
{
    return [[self _mergedClassGroups] count];
}

- (NSString *)objectInClassGroupsAtIndex:(NSUInteger)index
{
    return [self _mergedClassGroups][index];
}

- (NSArray *)classesInGroup:(NSString *)group
{
    NSMutableOrderedSet *classesBuilder = [NSMutableOrderedSet orderedSet];
    [_classLists enumerateObjectsUsingBlock:^(id <IKBClassList>list, NSUInteger idx, BOOL *stop) {
        NSInteger index = [[list allClassGroups] indexOfObject:group];
        if (index != NSNotFound) {
            NSArray *classes = [list classesInGroup:group];
            [classesBuilder addObjectsFromArray:classes];
        }
    }];
    NSArray *combinedClassList = [classesBuilder array];
    combinedClassList = [combinedClassList sortedArrayUsingSelector:@selector(compare:)];
    return combinedClassList;
}

- (NSUInteger)countOfClassesInGroup:(NSString *)group
{
    return [[self classesInGroup:group] count];
}

- (NSString *)classInGroup:(NSString *)group atIndex:(NSUInteger)index
{
    return [self classesInGroup:group][index];
}

#pragma mark - Unimplemented protocol methods

- (NSArray *)protocolsInClass:(NSString *)className
{
    return nil;
}

- (NSUInteger)countOfProtocolsInClass:(NSString *)className
{
    return NSNotFound;
}

- (NSString *)protocolInClass:(NSString *)className atIndex:(NSUInteger)index
{
    return nil;
}

- (NSUInteger)countOfMethodsInProtocol:(NSString *)protocolName ofClass:(NSString *)className
{
    return NSNotFound;
}

- (NSString *)methodInProtocol:(NSString *)protocolName ofClass:(NSString *)className atIndex:(NSUInteger)index
{
    return nil;
}

@end
