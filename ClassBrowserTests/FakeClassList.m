//
//  FakeClassList.m
//  ClassBrowser
//
//  Created by Graham Lee on 10/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import "FakeClassList.h"

@implementation FakeClassList
{
    NSInteger _selectedGroup;
}

- (NSUInteger)countOfClassGroups
{
    return self.classGroups.count;
}

- (NSString *)objectInClassGroupsAtIndex:(NSUInteger)index
{
    return [self.classGroups objectAtIndex:index];
}

- (void)selectClassGroupAtIndex:(NSInteger)index
{
    _selectedGroup = index;
}

- (NSString *)selectedClassGroup
{
    return self.classGroups[_selectedGroup];
}

- (NSArray *)classGroups
{
    return [self.classes.allKeys sortedArrayUsingSelector:@selector(compare:)];
}

- (NSUInteger)countOfClasses
{
    return [self.classes[self.selectedClassGroup] count];
}

@end
