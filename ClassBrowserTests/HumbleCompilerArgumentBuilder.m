//See COPYING for licence details.

#import "HumbleCompilerArgumentBuilder.h"

#pragma message("This class hard-codes the location of Xcode, which is used in integration tests. If code execution tests fail, update the Xcode location here.")

@implementation HumbleCompilerArgumentBuilder

- (void)constructCompilerArgumentsWithCompletion:(IKBCompilerArgumentCompletion)completion
{
    completion(@[@"-fsyntax-only",
                 @"-x",
                 @"objective-c",
                 @"-isysroot",
                 // the particular SDK to use should still be configurable
                 @"/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk",
                 @"-I",
                 @"/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/5.0/include",
                 @"-fobjc-arc",
                 @"-c"], nil);
}

@end
