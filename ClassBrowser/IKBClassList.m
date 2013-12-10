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

- (void)sortClassesInGroups
{
    [_classesByGroup enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSMutableArray *value, BOOL *stop){
        [value sortUsingSelector:@selector(compare:)];
    }];
}
@end
