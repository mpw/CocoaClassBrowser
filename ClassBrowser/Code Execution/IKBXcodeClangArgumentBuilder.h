//See COPYING for licence details.

#import <Foundation/Foundation.h>
#import "IKBCompilerArgumentBuilder.h"

@interface IKBXcodeClangArgumentBuilder : NSObject <IKBCompilerArgumentBuilder>

@end

extern NSString *IKBXcodeClangArgumentBuilderErrorDomain;

typedef NS_ENUM(NSInteger, IKBXcodeClangArgumentBuilderError) {
    IKBXcodeClangArgumentBuilderErrorCannotLocateXcode = 1,
};
