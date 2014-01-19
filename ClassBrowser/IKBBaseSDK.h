//See COPYING for licence details.

#import <Foundation/Foundation.h>

@interface IKBBaseSDK : NSObject

@property (readonly) NSString *displayName;
@property (readonly) NSString *path;
@property (readonly) NSString *version;
@property (readonly) NSUInteger versionMajor;
@property (readonly) NSUInteger versionMinor;

- (instancetype)initWithDisplayName:(NSString *)displayName
                               path:(NSString *)path
                            version:(NSString *)version;

@end
