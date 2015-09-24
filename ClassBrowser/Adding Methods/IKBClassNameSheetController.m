//See COPYING for licence details.

#import "IKBClassNameSheetController.h"

@interface IKBClassNameSheetController ()

@end

@implementation IKBClassNameSheetController

- (BOOL)isEntryValid
{
    return YES;
}

- (NSString *)className
{
    return self.textEntered;
}

@end
