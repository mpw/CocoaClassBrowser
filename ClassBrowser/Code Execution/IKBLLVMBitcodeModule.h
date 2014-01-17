//See COPYING for licence details.

#import <Foundation/Foundation.h>


@interface IKBLLVMBitcodeModule : NSObject

@property (nonatomic, readonly) NSString *moduleIdentifier;
@property (nonatomic, readonly) const char *bitcode;
@property (nonatomic, readonly) NSUInteger bitcodeLength;

- (instancetype)initWithIdentifier:(NSString *)identifier data:(NSData *)bitcodeData;

@end