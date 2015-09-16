//See COPYING for licence details.

#import "IKBSourceRepositoryClassList.h"
#import "IKBSourceRepository.h"

static NSString *IKBSourceRepositoryCustomClassesGroup = @"Custom Classes";

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
        groups = [groups arrayByAddingObject:IKBSourceRepositoryCustomClassesGroup];
    }
    return groups;
}

- (NSString *)objectInClassGroupsAtIndex:(NSUInteger)index
{
    return [self allClassGroups][index];
}

- (NSArray *)classesInGroup:(NSString *)group
{
    NSArray *classList = [group isEqualToString:IKBSourceRepositoryCustomClassesGroup]?[_repository allClasses]:nil;
    NSArray *namesList = [classList valueForKey:@"name"];
    return [namesList sortedArrayUsingSelector:@selector(compare:)];
}

- (NSUInteger)countOfClassesInGroup:(NSString *)group
{
    return [[self classesInGroup:group] count];
}

- (NSString *)classInGroup:(NSString *)group atIndex:(NSUInteger)index
{
    return [self classesInGroup:group][index];
}

- (NSArray *)protocolsInClass:(NSString *)className
{
    NSArray *allMethods = [_repository methodsForClassNamed:className];
    NSArray *allProtocols = [allMethods valueForKey:@"protocolName"];
    NSSet *uniqueProtocols = [NSSet setWithArray:allProtocols];
    NSArray *orderedProtocols = [[uniqueProtocols allObjects] sortedArrayUsingSelector:@selector(compare:)];
    NSArray *resultingProtocolList = [@[IKBProtocolAllMethods, IKBProtocolUncategorizedMethods] arrayByAddingObjectsFromArray:orderedProtocols];
    return resultingProtocolList;
}

- (NSUInteger)countOfProtocolsInClass:(NSString *)className
{
    return [[self protocolsInClass:className] count];
}

- (NSString *)protocolInClass:(NSString *)className atIndex:(NSUInteger)index
{
    return [self protocolsInClass:className][index];
}

#pragma mark - Unimplemented protocol methods

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
