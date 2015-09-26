//See COPYING for licence details.

#import <Cocoa/Cocoa.h>

@class IKBObjectiveCMethod;

#import "IKBNameEntrySheetController.h"

@interface IKBMethodSignatureSheetController : IKBNameEntrySheetController

- (IKBObjectiveCMethod *)method;

@end