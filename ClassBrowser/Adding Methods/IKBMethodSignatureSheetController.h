//See COPYING for licence details.

#import <Cocoa/Cocoa.h>

@class IKBObjectiveCMethod;

@interface IKBMethodSignatureSheetController : NSWindowController

@property (nonatomic, copy) NSString *className;

- (IKBObjectiveCMethod *)method;
- (void)reset;

@end