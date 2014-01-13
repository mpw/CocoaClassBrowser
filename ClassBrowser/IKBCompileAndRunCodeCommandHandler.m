//See COPYING for licence details.

#import "IKBCompileAndRunCodeCommandHandler.h"
#import "IKBCodeRunner.h"
#import "IKBCompileAndRunCodeCommand.h"

@implementation IKBCompileAndRunCodeCommandHandler

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.codeRunner = [IKBCodeRunner new];
    }
    return self;
}

- (BOOL)canHandleCommand:(id<IKBCommand>)command
{
    return [command isKindOfClass:[IKBCompileAndRunCodeCommand class]];
}

- (void)executeCommand:(IKBCompileAndRunCodeCommand *)command
{
    [self.codeRunner doIt:command.source completion:^(id result, NSString *transcript, NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
            command.completion(result, transcript, error);
        });
    }];
}

@end
