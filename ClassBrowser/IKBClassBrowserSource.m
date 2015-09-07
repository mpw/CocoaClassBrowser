//See COPYING for licence details.

#import "IKBClassBrowserSource.h"
#import "IKBRuntimeClassList.h"
#import "IKBMethodSignatureSheetController.h"

typedef NS_ENUM(NSInteger, IKBClassBrowserColumn) {
    IKBClassBrowserColumnClassGroup = 0,
    IKBClassBrowserColumnClass = 1,
    IKBClassBrowserColumnProtocol = 2,
    IKBClassBrowserColumnMethod = 3,
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
        case IKBClassBrowserColumnProtocol:
            return [_classList countOfProtocols];
            break;
        case IKBClassBrowserColumnMethod:
            return [_classList countOfMethods];
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
        case IKBClassBrowserColumnProtocol:
        {
            NSString *protocolName = [_classList objectInProtocolsAtIndex:row];
            [cell setStringValue:protocolName];
            break;
        }
        case IKBClassBrowserColumnMethod:
        {
            NSString *methodName = [_classList objectInMethodsAtIndex:row];
            [cell setStringValue:methodName];
            [cell setLeaf:YES];
        }
        default:
            break;
    }
}

- (void)browser:(NSBrowser *)browser didSelectRow:(NSInteger)row inColumn:(NSInteger)column
{
    switch (column) {
        case IKBClassBrowserColumnClassGroup:
            [self selectClassGroupAtIndex:row];
            break;
        case IKBClassBrowserColumnClass:
            [self selectClassAtIndex:row];
            break;
        case IKBClassBrowserColumnProtocol:
            [self selectProtocolAtIndex:row];
            break;
        case IKBClassBrowserColumnMethod:
            return;
            break;
        default:
            break;
    }
    [browser reloadColumn:column + 1];
}

- (void)selectClassGroupAtIndex:(NSInteger)index
{
  [_classList selectClassGroupAtIndex:index];
}

- (void)selectClassAtIndex:(NSInteger)index
{
  [_classList selectClassAtIndex:index];
}

- (void)selectProtocolAtIndex:(NSInteger)index
{
  [_classList selectProtocolAtIndex:index];
}

@end
