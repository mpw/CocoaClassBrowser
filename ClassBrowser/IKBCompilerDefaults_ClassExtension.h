//See COPYING for licence details.

#import "IKBCompilerDefaults.h"
#import "IKBBaseSDKProvider.h"

extern NSString *IKBCurrentBaseSDKVersionKey;

@interface IKBCompilerDefaults ()

@property (nonatomic, strong) id <IKBBaseSDKProvider> baseSDKsProvider;
@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end
