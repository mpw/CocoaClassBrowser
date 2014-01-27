//See COPYING for licence details.

#import "IKBCompilerPreferences_ClassExtension.h"
#import "IKBBaseSDK.h"

NSString *IKBPreferredBaseSDKVersionKey = @"IKBPreferredBaseSDKVersion";

@interface IKBCompilerPreferences ()

@property (nonatomic, copy) NSString *SDKsPath;

@end

@implementation IKBCompilerPreferences

- (id)init
{
    self = [super init];
    if (self) {
        _userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (id)initWithSDKsPath:(NSString *)SDKsPath
{
    self = [self init];
    if (self) {
        _SDKsPath = SDKsPath;
    }
    return self;
}

@synthesize baseSDKs = _baseSDKs;

- (NSArray *)baseSDKs
{
    if (!_baseSDKs) {
        _baseSDKs = [self sortedBaseSDKsFromList:[self loadBaseSDKs]];
    }
	return _baseSDKs;
}

- (void)setBaseSDKs:(NSArray *)baseSDKs
{
    _baseSDKs = [self sortedBaseSDKsFromList:baseSDKs];
}

@synthesize preferredBaseSDK = _preferredBaseSDK;

- (IKBBaseSDK *)preferredBaseSDK
{
    if (!_preferredBaseSDK) {
        NSString *preferredBaseSDKVersion = [_userDefaults stringForKey:IKBPreferredBaseSDKVersionKey];
        for (IKBBaseSDK *baseSDK in self.baseSDKs) {
            if ([baseSDK.version isEqualToString:preferredBaseSDKVersion]) {
                _preferredBaseSDK = baseSDK;
                break;
            }
        }
		if (!_preferredBaseSDK) {
            _preferredBaseSDK = [self.baseSDKs lastObject];
        }
    }
    return _preferredBaseSDK;
}

- (void)setPreferredBaseSDK:(IKBBaseSDK *)preferredBaseSDK
{
    _preferredBaseSDK = preferredBaseSDK;
    BOOL foundPreferredBaseSDK = NO;
    BOOL isLatestBaseSDK = NO;
    for (IKBBaseSDK *baseSDK in self.baseSDKs) {
        if ([baseSDK.version isEqualToString:preferredBaseSDK.version]) {
            foundPreferredBaseSDK = YES;
            isLatestBaseSDK = [baseSDK isEqual:[self.baseSDKs lastObject]];
            break;
        }
    }
    if (foundPreferredBaseSDK && !isLatestBaseSDK) {
        [_userDefaults setObject:preferredBaseSDK.version forKey:IKBPreferredBaseSDKVersionKey];
    } else {
        [_userDefaults removeObjectForKey:IKBPreferredBaseSDKVersionKey];
    }
    [_userDefaults synchronize];
}

- (void)setUserDefaults:(NSUserDefaults *)userDefaults
{
    _userDefaults = userDefaults;
    self.baseSDKs = self.baseSDKs;
}

- (NSArray *)loadBaseSDKs
{
    NSMutableArray *baseSDKs = [NSMutableArray new];
    if ([self.SDKsPath length] > 0) {
        NSURL *SDKsURL = [NSURL fileURLWithPath:self.SDKsPath];
        NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtURL:SDKsURL includingPropertiesForKeys:@[NSURLPathKey] options:NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:nil];
        for (NSURL *SDKURL in dirEnum) {
            NSURL *SDKSettingsPlistURL = [SDKURL URLByAppendingPathComponent:@"SDKSettings.plist"];
            NSDictionary *SDKSettingsPlist = [NSDictionary dictionaryWithContentsOfURL:SDKSettingsPlistURL];
            if (SDKSettingsPlist) {
                NSString *sdkName = SDKSettingsPlist[@"DisplayName"];
                NSString *sdkPath = [SDKURL.path lastPathComponent];
                NSString *sdkVersion = SDKSettingsPlist[@"Version"];
                [baseSDKs addObject:[[IKBBaseSDK alloc] initWithDisplayName:sdkName path:sdkPath version:sdkVersion]];
            }
        }
        [baseSDKs sortUsingComparator:^NSComparisonResult(IKBBaseSDK *sdk1, IKBBaseSDK *sdk2) {
            return (sdk1.versionMajor > sdk2.versionMajor) || (sdk1.versionMajor == sdk2.versionMajor && sdk1.versionMinor > sdk2.versionMinor) ? NSOrderedDescending : NSOrderedAscending;
        }];
    }
    return [NSArray arrayWithArray:baseSDKs];
}

- (void)registerDefaultPreferredBaseSDKFromList:(NSArray *)baseSDKs
{
    NSArray *sortedBaseSDKs = [self sortedBaseSDKsFromList:baseSDKs];
    if (![_userDefaults stringForKey:IKBPreferredBaseSDKVersionKey] && [sortedBaseSDKs count] > 0) {
        IKBBaseSDK *preferredBaseSDK = [sortedBaseSDKs lastObject];
        [_userDefaults registerDefaults:@{IKBPreferredBaseSDKVersionKey: preferredBaseSDK.version}];
    }
}

- (NSArray *)sortedBaseSDKsFromList:(NSArray *)baseSDKs
{
    NSArray *sortedBaseSDKs = [baseSDKs sortedArrayUsingComparator:^NSComparisonResult(IKBBaseSDK *sdk1, IKBBaseSDK *sdk2) {
        return (sdk1.versionMajor > sdk2.versionMajor) || (sdk1.versionMajor == sdk2.versionMajor && sdk1.versionMinor > sdk2.versionMinor) ? NSOrderedDescending : NSOrderedAscending;
    }];
    if (![_userDefaults stringForKey:IKBPreferredBaseSDKVersionKey] && [sortedBaseSDKs count] > 0) {
        IKBBaseSDK *preferredBaseSDK = [sortedBaseSDKs lastObject];
        [_userDefaults registerDefaults:@{IKBPreferredBaseSDKVersionKey: preferredBaseSDK.version}];
    }
    return sortedBaseSDKs;
}

@end
