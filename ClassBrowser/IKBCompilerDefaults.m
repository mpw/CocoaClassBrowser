//See COPYING for licence details.

#import "IKBCompilerDefaults_ClassExtension.h"
#import "IKBBaseSDK.h"
#import "IKBDefaultBaseSDKProvider.h"

NSString *IKBCurrentBaseSDKVersionKey = @"IKBCurrentBaseSDKVersion";

@interface IKBCompilerDefaults ()

@property (nonatomic, strong) NSArray *baseSDKs;

@end

@implementation IKBCompilerDefaults

- (id)init
{
    self = [super init];
    if (self) {
        _baseSDKsProvider = [IKBDefaultBaseSDKProvider new];
        _userDefaults = [NSUserDefaults standardUserDefaults];
        [self registerDefaults];
    }
    return self;
}

- (NSArray *)loadBaseSDKs
{
    NSMutableArray *baseSDKs = [NSMutableArray new];
    NSUInteger maxIndex = [self.baseSDKsProvider numberOfBaseSDKs];
    for (NSUInteger index = 0; index < maxIndex; index++) {
        [baseSDKs addObject:[self.baseSDKsProvider baseSDKForIndex:index]];
    }
    NSArray *sortedBaseSDKs = [baseSDKs sortedArrayWithOptions:0 usingComparator:^NSComparisonResult(id obj1, id obj2) {
        IKBBaseSDK *baseSDK1 = obj1, *baseSDK2 = obj2;
        NSComparisonResult result = NSOrderedAscending;
        if ((baseSDK1.versionMajor > baseSDK2.versionMajor) ||
            (baseSDK1.versionMajor == baseSDK2.versionMajor && baseSDK1.versionMinor > baseSDK2.versionMinor)) {
            result = NSOrderedDescending;
        }
        return result;
    }];
    return sortedBaseSDKs;
}

- (void)registerDefaults
{
    self.baseSDKs = [self loadBaseSDKs];
    IKBBaseSDK *defaultBaseSDK = [self.baseSDKs lastObject];
    NSDictionary *defaults = @{IKBCurrentBaseSDKVersionKey: defaultBaseSDK.version};
    [self.userDefaults registerDefaults:defaults];
}

- (IKBBaseSDK *)currentBaseSDK
{
    IKBBaseSDK *currentBaseSDK = nil;
    NSString *currentBaseSDKVersion = [_userDefaults stringForKey:IKBCurrentBaseSDKVersionKey];
    for (IKBBaseSDK *baseSDK in self.baseSDKs) {
        if ([baseSDK.version isEqualToString:currentBaseSDKVersion]) {
            currentBaseSDK = baseSDK;
            break;
        }
    }
    return currentBaseSDK;
}

- (void)setCurrentBaseSDK:(IKBBaseSDK *)currentBaseSDK
{
    BOOL foundCurrentBaseSDK = NO;
    for (IKBBaseSDK *baseSDK in self.baseSDKs) {
        if ([baseSDK.version isEqualToString:currentBaseSDK.version]) {
            foundCurrentBaseSDK = YES;
            break;
        }
    }
    if (foundCurrentBaseSDK) {
        [_userDefaults setObject:currentBaseSDK.version forKey:IKBCurrentBaseSDKVersionKey];
    } else {
        [_userDefaults removeObjectForKey:IKBCurrentBaseSDKVersionKey];
    }
    [_userDefaults synchronize];
}

- (void)setBaseSDKsProvider:(id<IKBBaseSDKProvider>)baseSDKsProvider
{
    _baseSDKsProvider = baseSDKsProvider;
    [self registerDefaults];
}

- (void)setUserDefaults:(NSUserDefaults *)userDefaults
{
    _userDefaults = userDefaults;
    [self registerDefaults];
}

@end
