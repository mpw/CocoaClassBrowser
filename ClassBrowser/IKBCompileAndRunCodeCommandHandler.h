//See COPYING for licence details.

#import <Foundation/Foundation.h>
#import "IKBCommandHandler.h"

@class IKBCodeRunner;

@interface IKBCompileAndRunCodeCommandHandler : NSObject <IKBCommandHandler>

@property (nonatomic, strong) IKBCodeRunner *codeRunner;

@end
