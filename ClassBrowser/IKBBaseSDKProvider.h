//See COPYING for licence details.

#import <Foundation/Foundation.h>

@class IKBBaseSDK;

@protocol IKBBaseSDKProvider <NSObject>

@required
- (NSUInteger)numberOfBaseSDKs;
- (IKBBaseSDK *)baseSDKForIndex:(NSUInteger)index;

@end
