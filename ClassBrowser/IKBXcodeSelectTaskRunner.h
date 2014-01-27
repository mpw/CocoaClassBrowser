//
//  IKBXcodeSelectTaskRunner.h
//  ClassBrowser
//
//  Created by Éric Trépanier on 2014-01-27.
//  Copyright (c) 2014 Project Isambard. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^IKBXcodeSelectTaskRunnerCompletion)(NSString *XcodePath, NSError *error);

@interface IKBXcodeSelectTaskRunner : NSObject

- (void)launchWithCompletion:(IKBXcodeSelectTaskRunnerCompletion)completion;

@end

extern NSString *IKBXcodeSelectTaskRunnerErrorDomain;

typedef NS_ENUM(NSInteger, IKBXcodeSelectTaskRunnerError) {
    IKBXcodeSelectTaskRunnerErrorCannotLocateXcode = 1,
};
