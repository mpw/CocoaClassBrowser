//See COPYING for licence details.

#import <Foundation/Foundation.h>

typedef void(^IKBXcodeSelectTaskRunnerCompletion)(NSString *XcodePath, NSError *error);

@interface IKBXcodeSelectTaskRunner : NSObject

- (void)launchWithCompletion:(IKBXcodeSelectTaskRunnerCompletion)completion;

@end

extern NSString *IKBXcodeSelectTaskRunnerErrorDomain;

typedef NS_ENUM(NSInteger, IKBXcodeSelectTaskRunnerError) {
    IKBXcodeSelectTaskRunnerErrorCannotLocateXcode = 1,
};
