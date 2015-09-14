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

#pragma mark - Unimplemented protocol methods

- (NSArray *)classesInGroup:(NSString *)group
{
    return nil;
}

- (NSUInteger)countOfClassesInGroup:(NSString *)group
{
    return NSNotFound;
}

- (NSString *)classInGroup:(NSString *)group atIndex:(NSUInteger)index
{
    return nil;
}

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

- (NSArray *)methodsInProtocol:(NSString *)protocolName ofClass:(NSString *)className
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
