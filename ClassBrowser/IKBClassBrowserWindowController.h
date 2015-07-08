//See COPYING for licence details.

#import <Cocoa/Cocoa.h>

@class IKBInspectorProvider;

@interface IKBClassBrowserWindowController : NSWindowController

@property (nonatomic, strong) IKBInspectorProvider *inspectorProvider;

@end
