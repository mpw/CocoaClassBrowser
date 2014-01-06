//
//  IKBXcodeClangArgumentBuilder.m
//  ClassBrowser
//
//  Created by Graham Lee on 06/01/2014.
//  Copyright (c) 2014 Project Isambard. All rights reserved.
//

#import "IKBXcodeClangArgumentBuilder.h"

NSString *IKBXcodeClangArgumentBuilderErrorDomain = @"IKBXcodeClangArgumentBuilderErrorDomain";

@implementation IKBXcodeClangArgumentBuilder

- (void)constructCompilerArgumentsWithCompletion:(IKBCompilerArgumentCompletion)completion
{
    NSTask *xcodeSelectTask = [NSTask new];
    xcodeSelectTask.launchPath = @"/usr/bin/xcode-select";
    xcodeSelectTask.arguments = @[@"-p"];
    NSPipe *pipe = [NSPipe pipe];
    xcodeSelectTask.standardOutput = pipe;
    xcodeSelectTask.terminationHandler = ^(NSTask *task) {
        if (task.terminationStatus == 0) {
            NSFileHandle *standardOutput = [task.standardOutput fileHandleForReading];
            NSData *pathBytes = [standardOutput readDataToEndOfFile];
            NSString *path = [[[NSString alloc] initWithData:pathBytes encoding:NSUTF8StringEncoding] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            // the particular SDK to use should still be configurable
            NSString *SDKPath = [path stringByAppendingPathComponent:@"Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk"];
            NSString *clangIncludePath = [path stringByAppendingPathComponent:@"Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/5.0/include"];
            NSArray *args = @[@"-fsyntax-only",
                              @"-x",
                              @"objective-c",
                              @"-isysroot",
                              SDKPath,
                              @"-I",
                              clangIncludePath,
                              @"-fobjc-arc",
                              @"-framework",
                              @"Cocoa",
                              @"-c"];
            completion(args, nil);
        }
        else {
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey : NSLocalizedString(@"Cannot find Xcode", @"Xcode not found description"),
                                       NSLocalizedFailureReasonErrorKey : NSLocalizedString(@"Xcode is not installed or its location is unknown", @"Xcode not found failure reason"),
                                       NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"Install Xcode and use xcode-select to configure its location", @"Xcode not found recovery suggestion"),
                                       };
            NSError *error = [NSError errorWithDomain:IKBXcodeClangArgumentBuilderErrorDomain
                                                 code:IKBXcodeClangArgumentBuilderErrorCannotLocateXcode
                                             userInfo:userInfo];
            completion(nil, error);
        }
    };
    [xcodeSelectTask launch];
}

@end
