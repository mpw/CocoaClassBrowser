//See COPYING for licence details.

#import <Cocoa/Cocoa.h>

@interface IKBViewControllerOwnedView : NSView

@property (nonatomic, weak) NSViewController *viewController;

@end
