//See COPYING for licence details.

#import "IKBBaseSDK.h"

@implementation IKBBaseSDK

- (instancetype)initWithDisplayName:(NSString *)displayName path:(NSString *)path version:(NSString *)version
{
    self = [super init];
    if (self) {
        _displayName = [displayName copy];
        _path = [path copy];
        _version = [version copy];
        _versionMajor = [[_version componentsSeparatedByString:@"."][0] longLongValue];
        _versionMinor = [[_version componentsSeparatedByString:@"."][1] longLongValue];
    }
    return self;
}

- (NSString *)description
{
    return self.displayName;
}

- (NSUInteger)hash
{
    return [self.version hash];
}

- (BOOL)isEqual:(id)object
{
    BOOL isEqual = NO;
    if ([object isKindOfClass:[self class]]) {
        IKBBaseSDK *baseSDK = object;
        if ([self.displayName isEqualToString:baseSDK.displayName] &&
            [self.path isEqualToString:baseSDK.path] &&
            [self.version isEqualToString:baseSDK.version]) {
            isEqual = YES;
        }
    }
    return isEqual;
}

@end
