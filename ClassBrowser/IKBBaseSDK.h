//See COPYING for licence details.

#import <Foundation/Foundation.h>

@interface IKBBaseSDK : NSObject

@property (readonly) NSString *displayName;		// e.g. "OS X 10.9"
@property (readonly) NSString *path;			// "macosx10.9.sdk"
@property (readonly) NSString *version;			// "10.9"
@property (readonly) NSUInteger versionMajor;	// 10
@property (readonly) NSUInteger versionMinor;	// 9

- (instancetype)initWithDisplayName:(NSString *)displayName path:(NSString *)path version:(NSString *)version;

@end
