//See COPYING for licence details.

#import <Cocoa/Cocoa.h>

@class IKBInspectorProvider;
@class IKBSourceRepository;

@interface IKBClassBrowserWindowController : NSWindowController

@property (nonatomic, strong) IKBInspectorProvider *inspectorProvider;
@property (nonatomic, strong) IKBSourceRepository *repository;

@end
