//See COPYING for licence details.

#import <Foundation/Foundation.h>
#import "IKBClassList.h"

@interface FakeClassList : NSObject <IKBClassList>

@property (nonatomic, strong) NSDictionary *classes;
@property (nonatomic, readonly) NSArray *classGroups;
@property (nonatomic, readonly) NSString *selectedClassGroup;
@property (nonatomic, readonly) NSString *selectedClass;
@property (nonatomic, readonly) NSString *selectedProtocol;

@end
