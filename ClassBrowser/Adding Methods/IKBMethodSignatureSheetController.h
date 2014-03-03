//See COPYING for licence details.

#import <Cocoa/Cocoa.h>

@class IKBObjectiveCMethod;

@interface IKBMethodSignatureSheetController : NSWindowController
- (IKBObjectiveCMethod *)method;
- (void)setClass:(NSString *)classForNewMethod;
@end