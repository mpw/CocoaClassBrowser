//See COPYING for licence details.

#import "IKBDefaultBaseSDKProvider.h"
#import "IKBBaseSDK.h"

@interface IKBDefaultBaseSDKProvider ()

@property (nonatomic, strong) NSArray *baseSDKs;

@end

@implementation IKBDefaultBaseSDKProvider

- (id)init
{
    self = [super init];
    if (self) {
        _baseSDKs = @[[[IKBBaseSDK alloc] initWithDisplayName:@"OS X 10.7" path:@"MacOSX10.7.sdk" version:@"10.7"],
                      [[IKBBaseSDK alloc] initWithDisplayName:@"OS X 10.8" path:@"MacOSX10.8.sdk" version:@"10.8"],
                      [[IKBBaseSDK alloc] initWithDisplayName:@"OS X 10.9" path:@"MacOSX10.9.sdk" version:@"10.9"]];
    }
    return self;
}

- (NSUInteger)numberOfBaseSDKs
{
    return self.baseSDKs.count;
}

- (IKBBaseSDK *)baseSDKForIndex:(NSUInteger)index
{
    return self.baseSDKs[index];
}

@end
