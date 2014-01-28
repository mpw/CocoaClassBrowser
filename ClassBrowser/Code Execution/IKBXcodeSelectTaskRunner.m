//See COPYING for licence details.

#import "IKBXcodeSelectTaskRunner.h"

NSString *IKBXcodeSelectTaskRunnerErrorDomain = @"IKBXcodeSelectTaskRunnerErrorDomain";

@implementation IKBXcodeSelectTaskRunner

- (void)launchWithCompletion:(IKBXcodeSelectTaskRunnerCompletion)completion;
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
            completion(path, nil);
        } else {
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey : NSLocalizedString(@"Cannot find Xcode", @"Xcode not found description"),
                                       NSLocalizedFailureReasonErrorKey : NSLocalizedString(@"Xcode is not installed or its location is unknown", @"Xcode not found failure reason"),
                                       NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"Install Xcode and use xcode-select to configure its location", @"Xcode not found recovery suggestion"),
                                       };
            NSError *error = [NSError errorWithDomain:IKBXcodeSelectTaskRunnerErrorDomain
                                                 code:IKBXcodeSelectTaskRunnerErrorCannotLocateXcode
                                             userInfo:userInfo];
            completion(nil, error);
        }
    };
    [xcodeSelectTask launch];
}

@end
