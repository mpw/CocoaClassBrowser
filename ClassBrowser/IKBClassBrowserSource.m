//
//  IKBClassBrowserSource.m
//  ClassBrowser
//
//  Created by Graham Lee on 10/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import "IKBClassBrowserSource.h"
#import "IKBClassList.h"

typedef NS_ENUM(NSInteger, IKBClassBrowserColumn) {
    IKBClassBrowserColumnClassGroup = 0,
    IKBClassBrowserColumnClass = 1,
};

@implementation IKBClassBrowserSource
{
    id <IKBClassList> _classList;
}

- (instancetype)initWithClassList:(id)list
{
    self = [super init];
    if (self)
    {
        _classList = list;
    }
    return self;
}

- (NSInteger)browser:(NSBrowser *)sender numberOfRowsInColumn:(NSInteger)column
{
    switch (column) {
        case IKBClassBrowserColumnClassGroup:
            return [_classList countOfClassGroups];
            break;
        case IKBClassBrowserColumnClass:
            return [_classList countOfClasses];
            break;
        default:
            return 0;
            break;
    }
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(NSInteger)row column:(NSInteger)column
{
    [cell setLeaf:NO];
    switch (column) {
        case IKBClassBrowserColumnClassGroup:
        {
            NSString *groupName = [_classList objectInClassGroupsAtIndex:row];
            [cell setStringValue:groupName];
            break;
        }
        case IKBClassBrowserColumnClass:
        {
            NSString *className = [_classList objectInClassesAtIndex:row];
            [cell setStringValue:className];
            break;
        }
        default:
            break;
    }
}

- (void)browser:(NSBrowser *)browser didSelectRow:(NSInteger)row inColumn:(NSInteger)column
{
    switch (column) {
        case IKBClassBrowserColumnClassGroup:
            [_classList selectClassGroupAtIndex:row];
            break;
        case IKBClassBrowserColumnClass:
            [_classList selectClassAtIndex:row];
            break;
        default:
            break;
    }
    [browser reloadColumn:column + 1];
}

@end
