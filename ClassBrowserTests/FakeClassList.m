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
    NSInteger _selectedClass;
    NSInteger _selectedProtocol;
    NSArray *_protocols;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _protocols = @[@"--all--", @"uncategorized", @"NSCopying"];
    }
    return self;
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

- (NSString *)objectInClassesAtIndex:(NSUInteger)index
{
    return self.classes[self.selectedClassGroup][index];
}

- (void)selectClassAtIndex:(NSInteger)index
{
    _selectedClass = index;
}

- (NSString *)selectedClass
{
    return self.classes[self.selectedClassGroup][_selectedClass];
}

- (NSUInteger)countOfProtocols
{
    return _protocols.count;
}

- (NSString *)objectInProtocolsAtIndex:(NSUInteger)index
{
    return _protocols[index];
}

- (void)selectProtocolAtIndex:(NSInteger)index
{
    _selectedProtocol = index;
}

- (NSString *)selectedProtocol
{
    return _protocols[_selectedProtocol];
}

@end
