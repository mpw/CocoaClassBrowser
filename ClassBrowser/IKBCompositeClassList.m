//See COPYING for licence details.

#import "IKBCompositeClassList.h"

@implementation IKBCompositeClassList
{
    NSArray *_classLists;
    NSString *_selectedClassGroup;
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

- (void)selectClassGroupAtIndex:(NSInteger)index
{
    _selectedClassGroup = [self objectInClassGroupsAtIndex:index];
}

- (NSArray *)classesInSelectedGroup
{
    NSMutableOrderedSet *classesBuilder = [NSMutableOrderedSet orderedSet];
    [_classLists enumerateObjectsUsingBlock:^(id <IKBClassList>list, NSUInteger idx, BOOL *stop) {
        NSInteger index = [[list allClassGroups] indexOfObject:_selectedClassGroup];
        if (index != NSNotFound) {
            [list selectClassGroupAtIndex:index];
            NSArray *classes = [list classesInSelectedGroup];
            [classesBuilder addObjectsFromArray:classes];
        }
    }];
    NSArray *combinedClassList = [classesBuilder array];
    combinedClassList = [combinedClassList sortedArrayUsingSelector:@selector(compare:)];
    return combinedClassList;
}

@end
