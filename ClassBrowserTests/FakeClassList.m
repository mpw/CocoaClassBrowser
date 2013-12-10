//
//  FakeClassList.m
//  ClassBrowser
//
//  Created by Graham Lee on 10/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import "FakeClassList.h"

@implementation FakeClassList

- (NSUInteger)countOfClassGroups
{
    return self.classGroups.count;
}

- (NSString *)objectInClassGroupsAtIndex:(NSUInteger)index
{
    return [self.classGroups objectAtIndex:index];
}

@end
