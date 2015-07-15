//See COPYING for licence details.

#import <Foundation/Foundation.h>

#import "IKBClassList_Protocol.h"

@class IKBSourceRepository;

@interface IKBSourceRepositoryClassList : NSObject <IKBClassList>

- (instancetype)initWithRepository:(IKBSourceRepository *)repository;

@end
