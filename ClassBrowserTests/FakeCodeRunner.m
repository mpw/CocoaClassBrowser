//See COPYING for licence details.

#import "FakeCodeRunner.h"

@implementation FakeCodeRunner

- (void)doIt:(NSString *)objectiveCSource completion:(IKBCodeRunnerCompletionHandler)completion
{
    self.ranSource = objectiveCSource;
    completion(self.runResult, nil, nil);
}

@end
