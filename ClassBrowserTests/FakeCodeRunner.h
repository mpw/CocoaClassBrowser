//See COPYING for licence details.

#import <Foundation/Foundation.h>
#import "IKBCodeRunner.h"

@interface FakeCodeRunner : NSObject

@property (nonatomic, copy) NSString *ranSource;
@property (nonatomic, copy) NSString *compilerTranscript;
@property (nonatomic, strong) id runResult;

- (void)doIt:(NSString *)objectiveCSource completion:(IKBCodeRunnerCompletionHandler)completion;

@end
