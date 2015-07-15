//See COPYING for licence details.

#import "IKBSourceRepositoryClassList.h"
#import "IKBSourceRepository.h"

@implementation IKBSourceRepositoryClassList
{
    IKBSourceRepository *_repository;
}

- (instancetype)initWithRepository:(IKBSourceRepository *)repository
{
    self = [super init];
    if (self) {
        _repository = repository;
    }
    return self;
}

- (BOOL)repositoryHasClasses
{
    return [[_repository allClasses] count] != 0;
}

- (NSUInteger)countOfClassGroups
{
    return [self repositoryHasClasses] ? 1 : 0;
}

- (NSArray *)allClassGroups
{
    NSArray *groups = @[];
    if ([self repositoryHasClasses]) {
        groups = [groups arrayByAddingObject:@"Custom Classes"];
    }
    return groups;
}

- (NSString *)objectInClassGroupsAtIndex:(NSUInteger)index
{
    return [self allClassGroups][index];
}

@end
