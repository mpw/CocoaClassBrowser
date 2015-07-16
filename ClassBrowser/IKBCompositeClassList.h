//See COPYING for licence details.

#import <Foundation/Foundation.h>

#import "IKBClassList_Protocol.h"

@interface IKBCompositeClassList : NSObject <IKBClassList>

+ (instancetype)compositeOfClassLists:(NSArray *)classLists;

@end
