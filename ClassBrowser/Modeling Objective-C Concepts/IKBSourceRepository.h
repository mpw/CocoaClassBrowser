//See COPYING for licence details.

#import <Foundation/Foundation.h>

@class IKBObjectiveCMethod;

@interface IKBSourceRepository : NSObject <NSCoding>

- (void)addMethod:(IKBObjectiveCMethod *)method;
- (NSArray *)allMethods;
- (NSArray *)methodsForClassNamed:(NSString *)className;

@end
