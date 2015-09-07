//See COPYING for licence details.

#import "IKBRuntimeClassList.h"
#import <objc/runtime.h>

@implementation IKBRuntimeClassList
{
    NSDictionary *_classesByGroup;
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

- (NSUInteger)countOfClassesInGroup:(NSString *)group
{
    return [_classesByGroup[group] count];
}

- (NSString *)classInGroup:(NSString *)group atIndex:(NSUInteger)index
{
    return _classesByGroup[group][index];
}

- (NSArray *)classesInGroup:(NSString *)group
{
    return [[_classesByGroup[group] retain] autorelease];
}

- (NSArray *)protocolsInClass:(NSString *)className
{
    return [self protocolListForClass:className];
}

- (NSUInteger)countOfProtocolsInClass:(NSString *)className
{
    return [[self protocolListForClass:className] count];
}

- (NSString *)protocolInClass:(NSString *)className atIndex:(NSUInteger)index
{
    return [self protocolListForClass:className][index];
}

- (NSUInteger)countOfMethodsInProtocol:(NSString *)protocolName ofClass:(NSString *)className
{
    return [[self methodListForProtocol:protocolName inClass:className] count];
}

- (NSString *)methodInProtocol:(NSString *)protocolName ofClass:(NSString *)className atIndex:(NSUInteger)index
{
    return [self methodListForProtocol:protocolName inClass:className][index];
}

- (void)sortClassesInGroups
{
    [_classesByGroup enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSMutableArray *value, BOOL *stop){
        [value sortUsingSelector:@selector(compare:)];
    }];
}

- (NSArray *)protocolListForClass:(NSString *)className
{
    unsigned int protocolCount;
    Protocol **list = class_copyProtocolList(NSClassFromString(className), &protocolCount);
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
    return fullList;
}

- (NSArray *)methodListForProtocol:(NSString *)protocolName inClass:(NSString *)className
{
    NSArray *appropriateMethods = nil;
    if ([protocolName isEqualToString:(id)IKBProtocolAllMethods])
    {
        appropriateMethods = [self listAllMethodsInClass:className];
    }
    else if ([protocolName isEqualToString:(id)IKBProtocolUncategorizedMethods])
    {
        appropriateMethods = [self listUncategorizedMethodsInClass:className];
    }
    else
    {
        appropriateMethods = [self listMethodsForProtocol:protocolName inClass:className];
    }
    return [self sortMethods:appropriateMethods];
}

- (NSArray *)listAllMethodsInClass:(NSString *)className
{
    unsigned int countOfClassMethods = 0;
    Class aClass = NSClassFromString(className);
    Method *classMethodList = class_copyMethodList(object_getClass(aClass), &countOfClassMethods);
    NSMutableArray *methodsInClass = [NSMutableArray array];
    for (unsigned int i = 0; i < countOfClassMethods; i++)
    {
        Method thisMethod = classMethodList[i];
        NSString *methodName = NSStringFromSelector(method_getName(thisMethod));
        [methodsInClass addObject:[NSString stringWithFormat:@"+%@",methodName]];
    }
    free(classMethodList);
    
    unsigned int countOfInstanceMethods = 0;
    Method *instanceMethodList = class_copyMethodList(aClass, &countOfInstanceMethods);
    for (unsigned int i = 0; i < countOfInstanceMethods; i++)
    {
        Method thisMethod = instanceMethodList[i];
        NSString *methodName = NSStringFromSelector(method_getName(thisMethod));
        [methodsInClass addObject:[NSString stringWithFormat:@"-%@",methodName]];
    }
    free(instanceMethodList);
    return methodsInClass;
}

- (NSArray *)listUncategorizedMethodsInClass:(NSString *)className
{
    NSArray *allMethods = [self listAllMethodsInClass:className];
    NSArray *allProtocols = [self protocolListForClass:className];
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
            NSArray *conformingMethods = [self methodsForProtocol:protocolName inClass:className];
            [mutableMethods removeObjectsInArray:conformingMethods];
        }
        return mutableMethods;
    }
    return nil;
}

- (NSArray *)methodsForProtocol:(NSString *)protocolName inClass:(NSString *)className
{
    NSMutableArray *methodsInProtocolAndClass = [NSMutableArray array];
    unsigned int countOfClassMethods = 0;
    Class aClass = NSClassFromString(className);
    Method *classMethodList = class_copyMethodList(object_getClass(aClass), &countOfClassMethods);
    NSMutableArray *methodsInClass = [NSMutableArray array];
    for (unsigned int i = 0; i < countOfClassMethods; i++)
    {
        Method thisMethod = classMethodList[i];
        NSString *methodName = NSStringFromSelector(method_getName(thisMethod));
        [methodsInClass addObject:methodName];
    }
    free(classMethodList);
    
    Protocol *protocol = NSProtocolFromString(protocolName);
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
    Method *instanceMethodList = class_copyMethodList(aClass, &countOfInstanceMethods);
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

- (NSArray *)listMethodsForProtocol:(NSString *)protocolName inClass:(NSString *)className
{
    return [self methodsForProtocol:protocolName inClass:className];
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
