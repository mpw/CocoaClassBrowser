//See COPYING for licence details.

#import "IKBLLVMBitcodeModule.h"


@implementation IKBLLVMBitcodeModule
{
    NSData *_bitcodeData;
}

- (instancetype)initWithIdentifier:(NSString *)identifier data:(NSData *)moduleData
{
    self = [super init];
    if (self)
    {
        _moduleIdentifier = [identifier copy];
        _bitcodeData = [moduleData copy];
    }
    return self;
}

- (const char *)bitcode
{
    return (const char *)(_bitcodeData.bytes);
}

- (NSUInteger)bitcodeLength
{
    return _bitcodeData.length;
}

@end