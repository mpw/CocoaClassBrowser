//See COPYING for licence details.

#import <Foundation/Foundation.h>

@class IKBBaseSDK;

@interface IKBCompilerDefaults : NSObject

@property (nonatomic, readonly) NSArray *baseSDKs;
@property (nonatomic, strong) IKBBaseSDK *currentBaseSDK;

@end
