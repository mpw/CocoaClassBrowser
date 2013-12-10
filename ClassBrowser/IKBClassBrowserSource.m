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
    NSString *groupName = [_classList objectInClassGroupsAtIndex:row];
    [cell setStringValue:groupName];
    [cell setLeaf:NO];
}

- (BOOL)browser:(NSBrowser *)sender selectRow:(NSInteger)row inColumn:(NSInteger)column
{
    [_classList selectClassGroupAtIndex:row];
    return YES;
}
@end
