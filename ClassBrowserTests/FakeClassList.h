//See COPYING for licence details.

#import <Foundation/Foundation.h>
#import "IKBRuntimeClassList.h"

@interface FakeClassList : NSObject <IKBClassList>

@property (nonatomic, strong) NSDictionary *classes;
@property (nonatomic, readonly) NSArray *classGroups;

- (void)setProtocols:(NSArray *)protocols forClass:(NSString *)className;
- (void)setMethods:(NSArray *)methods forProtocol:(NSString *)protocolName inClass:(NSString *)className;

@end
