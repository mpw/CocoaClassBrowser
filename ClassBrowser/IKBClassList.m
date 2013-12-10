//
//  IKBClassList.m
//  ClassBrowser
//
//  Created by Graham Lee on 10/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import "IKBClassList.h"
#import <objc/runtime.h>

@implementation IKBClassList
{
    NSDictionary *_classesByGroup;
    NSArray *_selectedGroup;
    Class _selectedClass;
    NSArray *_protocolList;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        int numberOfClasses = objc_getClassList(NULL, 0);
        __unsafe_unretained Class *classes = malloc(sizeof(Class) * numberOfClasses);
        numberOfClasses = objc_getClassList(classes, numberOfClasses);
        
        NSMutableSet *groups = [NSMutableSet set];
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
        _classesByGroup = [classesByGroup copy];
        [self sortClassesInGroups];
    }
    return self;
}

- (void)dealloc
{
    [_classesByGroup release];
    [_protocolList release];
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

@end

NSString const *IKBProtocolAllMethods = @"--all--";
NSString const *IKBProtocolUncategorizedMethods = @"uncategorized";
