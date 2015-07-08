//See COPYING for licence details.

#import <Cocoa/Cocoa.h>

@class IKBInspectorWindowController;

@protocol IKBInspectorWindowControllerDelegate <NSObject>

- (void)inspectorWindowControllerWindowWillClose:(IKBInspectorWindowController *)controller;

@end

@interface IKBInspectorWindowController : NSWindowController <NSWindowDelegate>

@property (nonatomic, weak) id <IKBInspectorWindowControllerDelegate> controllerDelegate;
@property (nonatomic, strong) id representedObject;

@end
