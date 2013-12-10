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
    NSArray *_classGroups;
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
        for (int i = 0; i < numberOfClasses; i++)
        {
            Class ThisClass = classes[i];
            const char *imgName = class_getImageName(ThisClass);
            NSString *imageName = imgName ? [@(imgName) lastPathComponent] : @"Uncategorized";
            [groups addObject:imageName];
        }
        _classGroups = [[[groups allObjects] sortedArrayUsingSelector:@selector(compare:)] retain];
    }
    return self;
}

- (void)dealloc
{
    [_classGroups release];
    [super dealloc];
}

- (NSUInteger)countOfClassGroups
{
    return [_classGroups count];
}

- (NSString *)objectInClassGroupsAtIndex:(NSUInteger)index
{
    return _classGroups[index];
}

- (NSArray *)allClassGroups
{
    return [[_classGroups retain] autorelease];
}

- (NSUInteger)countOfClasses
{
    return 0;
}

- (void)selectClassGroupAtIndex:(NSInteger)index
{
    
}

@end
