//See COPYING for licence details.

#import "IKBXcodeClangArgumentBuilder.h"
#import "IKBXcodeSelectTaskRunner.h"
#import "IKBCompilerPreferences.h"

@implementation IKBXcodeClangArgumentBuilder

- (void)constructCompilerArgumentsWithCompletion:(IKBCompilerArgumentCompletion)completion
{
    [[IKBXcodeSelectTaskRunner new] launchWithCompletion:^(NSString *XcodePath, NSError *error) {
        if (XcodePath) {
            // the particular SDK to use should still be configurable
            NSString *SDKsPath = [XcodePath stringByAppendingPathComponent:@"Platforms/MacOSX.platform/Developer/SDKs"];
            NSString *SDKPath = [SDKsPath stringByAppendingPathComponent:[[[IKBCompilerPreferences alloc] initWithSDKsPath:SDKsPath] preferredBaseSDK].path];
            NSString *clangIncludePath = [XcodePath stringByAppendingPathComponent:@"Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/6.1.0/include"];
            NSArray *args = @[@"-fsyntax-only",
                              @"-x",
                              @"objective-c",
                              @"-isysroot",
                              SDKPath,
                              @"-I",
                              clangIncludePath,
                              @"-fobjc-arc",
                              @"-c"];
            completion(args, nil);
        } else {
            completion(nil, error);
        }
    }];
}

@end
