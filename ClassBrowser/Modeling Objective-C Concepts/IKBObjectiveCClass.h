//See COPYING for licence details.

#import <Foundation/Foundation.h>

@interface IKBObjectiveCClass : NSObject <NSCoding>

- (instancetype)initWithName:(NSString *)name superclass:(NSString *)superclass;

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *superclassName;

@end
