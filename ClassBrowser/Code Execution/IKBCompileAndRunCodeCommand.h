//See COPYING for licence details.

#import <Foundation/Foundation.h>
#import "IKBCommand.h"
#import "IKBCodeRunner.h"

@interface IKBCompileAndRunCodeCommand : NSObject <IKBCommand>

@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) IKBCodeRunnerCompletionHandler completion;

@end
