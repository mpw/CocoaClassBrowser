//See COPYING for licence details.

#import <Foundation/Foundation.h>

typedef void(^IKBCompilerArgumentCompletion)(NSArray *arguments, NSError *error);

@protocol IKBCompilerArgumentBuilder <NSObject>

- (void)constructCompilerArgumentsWithCompletion:(IKBCompilerArgumentCompletion)completion;

@end
