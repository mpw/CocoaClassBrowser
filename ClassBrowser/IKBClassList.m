//See COPYING for licence details.

#import "IKBClassList.h"
#import <objc/runtime.h>

@implementation IKBClassList
{
    NSDictionary *_classesByGroup;
    NSArray *_selectedGroup;
    Class _selectedClass;
    NSArray *_protocolList;
    NSString *_selectedProtocol;
    NSArray *_methodList;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        int numberOfClasses = objc_getClassList(NULL, 0);
        __unsafe_unretained Class *classes = malloc(sizeof(Class) * numberOfClasses);
        numberOfClasses = objc_getClassList(classes, numberOfClasses);
        
        NSMutableDictionary *classesByGroup = [NSMutableDictionary dictionary];
        for (int i = 0; i < numberOfClasses; i++)
        {
            Class ThisClass = classes[i];
            const char *imgName = class_getImageName(ThisClass);
            NSString *imageName = imgName ? [@(imgName) lastPathComponent] : @"Uncategorized";
            NSMutableArray *classesInGroup = classesByGroup[imageName];
            if (classesInGroup)
            {
                [classesInGroup addObject:NSStringFromClass(ThisClass)];
            }
            else
            {
                classesInGroup = [NSMutableArray arrayWithObject:NSStringFromClass(ThisClass)];
                classesByGroup[imageName] = classesInGroup;
            }
        }
        free(classes);
        _classesByGroup = [classesByGroup copy];
        [self sortClassesInGroups];
    }
    return self;
}

- (void)dealloc
{
    [_classesByGroup release];
    [_protocolList release];
    [_methodList release];
    [_selectedProtocol release];
    [super dealloc];
}

- (NSUInteger)countOfClassGroups
{
    return [[self allClassGroups] count];
}

- (NSString *)objectInClassGroupsAtIndex:(NSUInteger)index
{
    return [self allClassGroups][index];
}

- (NSArray *)allClassGroups
{
    return [[_classesByGroup allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

- (NSUInteger)countOfClasses
{
    return [_selectedGroup count];
}

- (void)selectClassGroupAtIndex:(NSInteger)index
{
    NSString *selectedClassGroup = [self allClassGroups][index];
    _selectedGroup = _classesByGroup[selectedClassGroup];
}

- (NSString *)objectInClassesAtIndex:(NSUInteger)index
{
    return _selectedGroup[index];
}

- (NSArray *)classesInSelectedGroup
{
    return [[_selectedGroup retain] autorelease];
}

- (void)selectClassAtIndex:(NSInteger)index
{
    _selectedClass = NSClassFromString([self objectInClassesAtIndex:index]);
    [self createProtocolList];
}

- (Class)selectedClass
{
    return NSStringFromClass(_selectedClass);
}

- (NSArray *)protocolsInSelectedClass
{
    return [[_protocolList retain] autorelease];
}

- (NSUInteger)countOfProtocols
{
    return [_protocolList count];
}

- (NSString *)objectInProtocolsAtIndex:(NSUInteger)index
{
    return _protocolList[index];
}

- (void)selectProtocolAtIndex:(NSInteger)index
{
    [_selectedProtocol release];
    _selectedProtocol = [[self objectInProtocolsAtIndex:index] retain];
    [self createMethodList];
}

- (NSUInteger)countOfMethods
{
    return [_methodList count];
}

- (NSString *)objectInMethodsAtIndex:(NSUInteger)index
{
    return _methodList[index];
}

- (void)sortClassesInGroups
{
    [_classesByGroup enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSMutableArray *value, BOOL *stop){
        [value sortUsingSelector:@selector(compare:)];
    }];
}

- (void)createProtocolList
{
    [_protocolList release];
    _protocolList = nil;
    unsigned int protocolCount;
    Protocol **list = class_copyProtocolList(_selectedClass, &protocolCount);
    NSMutableArray *protocols = [NSMutableArray array];
    for (unsigned int i = 0; i < protocolCount; i++)
    {
        Protocol *protocol = list[i];
        NSString *protocolName = @(protocol_getName(protocol));
        [protocols addObject:protocolName];
    }
    free(list);
    [protocols sortUsingSelector:@selector(compare:)];
    NSArray *fullList = [@[IKBProtocolAllMethods, IKBProtocolUncategorizedMethods] arrayByAddingObjectsFromArray:protocols];
    _protocolList = [fullList retain];
}

- (void)createMethodList
{
    [_methodList release];
    _methodList = nil;
    NSArray *appropriateMethods = nil;
    if ([_selectedProtocol isEqualToString:(id)IKBProtocolAllMethods])
    {
        appropriateMethods = [self listAllMethods];
    }
    else if ([_selectedProtocol isEqualToString:(id)IKBProtocolUncategorizedMethods])
    {
        appropriateMethods = [self listUncategorizedMethods];
    }
    else
    {
        appropriateMethods = [self listMethodsInSelectedProtocol];
    }
    _methodList = [[self sortMethods:appropriateMethods] retain];
}

- (NSArray *)listAllMethods
{
    unsigned int countOfClassMethods = 0;
    Method *classMethodList = class_copyMethodList(object_getClass(_selectedClass), &countOfClassMethods);
    NSMutableArray *methodsInClass = [NSMutableArray array];
    for (unsigned int i = 0; i < countOfClassMethods; i++)
    {
        Method thisMethod = classMethodList[i];
        NSString *methodName = NSStringFromSelector(method_getName(thisMethod));
        [methodsInClass addObject:[NSString stringWithFormat:@"+%@",methodName]];
    }
    free(classMethodList);
    
    unsigned int countOfInstanceMethods = 0;
    Method *instanceMethodList = class_copyMethodList(_selectedClass, &countOfInstanceMethods);
    for (unsigned int i = 0; i < countOfInstanceMethods; i++)
    {
        Method thisMethod = instanceMethodList[i];
        NSString *methodName = NSStringFromSelector(method_getName(thisMethod));
        [methodsInClass addObject:[NSString stringWithFormat:@"-%@",methodName]];
    }
    free(instanceMethodList);
    return methodsInClass;
}

- (NSArray *)listUncategorizedMethods
{
    NSArray *allMethods = [self listAllMethods];
    NSArray *allProtocols = [self protocolsInSelectedClass];
    if ([allProtocols count] == 2)
    {
        return allMethods;
    }
    else
    {
        NSMutableArray *mutableMethods = [[allMethods mutableCopy] autorelease];
        NSArray *realProtocols = [allProtocols subarrayWithRange:NSMakeRange(2, [allProtocols count] - 2)];
        for (NSString *protocolName in realProtocols)
        {
            Protocol *protocol = NSProtocolFromString(protocolName);
            NSArray *conformingMethods = [self methodsInProtocol:protocol];
            [mutableMethods removeObjectsInArray:conformingMethods];
        }
        return mutableMethods;
    }
    return nil;
}

- (NSArray *)methodsInProtocol:(Protocol *)protocol
{
    NSMutableArray *methodsInProtocolAndClass = [NSMutableArray array];
    unsigned int countOfClassMethods = 0;
    Method *classMethodList = class_copyMethodList(object_getClass(_selectedClass), &countOfClassMethods);
    NSMutableArray *methodsInClass = [NSMutableArray array];
    for (unsigned int i = 0; i < countOfClassMethods; i++)
    {
        Method thisMethod = classMethodList[i];
        NSString *methodName = NSStringFromSelector(method_getName(thisMethod));
        [methodsInClass addObject:methodName];
    }
    free(classMethodList);
    
    //required class methods
    unsigned int countOfProtocolMethods = 0;
    struct objc_method_description *method_list = protocol_copyMethodDescriptionList(protocol, YES, NO, &countOfProtocolMethods);
    for (unsigned int i = 0; i < countOfProtocolMethods; i++)
    {
        struct objc_method_description thisMethod = method_list[i];
        NSString *methodName = NSStringFromSelector(thisMethod.name);
        if ([methodsInClass containsObject:methodName])
        {
            [methodsInProtocolAndClass addObject: [NSString stringWithFormat:@"+%@", methodName]];
        }
    }
    free(method_list);
    
    //optional class methods
    method_list = protocol_copyMethodDescriptionList(protocol, NO, NO, &countOfProtocolMethods);
    for (unsigned int i = 0; i < countOfProtocolMethods; i++)
    {
        struct objc_method_description thisMethod = method_list[i];
        NSString *methodName = NSStringFromSelector(thisMethod.name);
        if ([methodsInClass containsObject:methodName])
        {
            [methodsInProtocolAndClass addObject: [NSString stringWithFormat:@"+%@", methodName]];
        }
    }
    
    unsigned int countOfInstanceMethods = 0;
    Method *instanceMethodList = class_copyMethodList(_selectedClass, &countOfInstanceMethods);
    methodsInClass = [NSMutableArray array];
    for (unsigned int i = 0; i < countOfInstanceMethods; i++)
    {
        Method thisMethod = instanceMethodList[i];
        NSString *methodName = NSStringFromSelector(method_getName(thisMethod));
        [methodsInClass addObject:methodName];
        
    }
    free(instanceMethodList);
    
    //required instance methods
    method_list = protocol_copyMethodDescriptionList(protocol, YES, YES, &countOfProtocolMethods);
    for (unsigned int i = 0; i < countOfProtocolMethods; i++)
    {
        struct objc_method_description thisMethod = method_list[i];
        NSString *methodName = NSStringFromSelector(thisMethod.name);
        if ([methodsInClass containsObject:methodName])
        {
            [methodsInProtocolAndClass addObject: [NSString stringWithFormat:@"-%@", methodName]];
        }
    }
    free(method_list);
    
    //optional instance methods
    method_list = protocol_copyMethodDescriptionList(protocol, NO, YES, &countOfProtocolMethods);
    for (unsigned int i = 0; i < countOfProtocolMethods; i++)
    {
        struct objc_method_description thisMethod = method_list[i];
        NSString *methodName = NSStringFromSelector(thisMethod.name);
        if ([methodsInClass containsObject:methodName])
        {
            [methodsInProtocolAndClass addObject: [NSString stringWithFormat:@"-%@", methodName]];
        }
    }
    free(method_list);
    
    return methodsInProtocolAndClass;
}

- (NSArray *)listMethodsInSelectedProtocol
{
    Protocol *protocol = NSProtocolFromString(_selectedProtocol);
    return [self methodsInProtocol:protocol];
}

- (NSArray *)sortMethods:(NSArray *)unsorted
{
    return [unsorted sortedArrayUsingComparator:^(NSString *name1, NSString *name2){
        //class methods first
        NSString *initial1 = [name1 substringToIndex:1];
        NSString *initial2 = [name2 substringToIndex:1];
        if ([initial1 isEqualToString:@"+"] && [initial2 isEqualToString:@"-"])
        {
            return NSOrderedAscending;
        }
        else if ([initial2 isEqualToString:@"+"] && [initial1 isEqualToString:@"-"])
        {
            return NSOrderedDescending;
        }
        return [name1 compare:name2];
    }];
}

@end

NSString const *IKBProtocolAllMethods = @"--all--";
NSString const *IKBProtocolUncategorizedMethods = @"uncategorized";
