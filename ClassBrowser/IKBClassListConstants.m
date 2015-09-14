//See COPYING for licence details.

#import <Foundation/Foundation.h>
#import "IKBClassList_Protocol.h"

NSString const *IKBProtocolAllMethods = @"--all--";
NSString const *IKBProtocolUncategorizedMethods = @"uncategorized";

NSArray *IKBSortedMethodList(NSArray *unsorted)
{
    return [unsorted sortedArrayUsingComparator:^(NSString *name1, NSString *name2){
        //class methods first
        NSString *initial1 = [name1 substringToIndex:1];
        NSString *initial2 = [name2 substringToIndex:1];
        if ([initial1 isEqualToString:@"+"] && [initial2 isEqualToString:@"-"])
        {
            return NSOrderedAscending;
        }
        else if ([initial2 isEqualToString:@"+"] && [initial1 isEqualToString:@"-"])
        {
            return NSOrderedDescending;
        }
        return [name1 compare:name2];
    }];
}