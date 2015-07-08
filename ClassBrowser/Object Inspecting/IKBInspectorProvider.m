//See COPYING for licence details.

#import "IKBInspectorProvider.h"
#import "IKBInspectorWindowController.h"

#import <objc/runtime.h>

@interface IKBInspectorProvider () <IKBInspectorWindowControllerDelegate>

@property (nonatomic, strong) IKBInspectorWindowController *nilInspector;

@end

@implementation IKBInspectorProvider

static const NSString *inspectorKey = @"IKBInspectorForObject";

- (IKBInspectorWindowController *)inspectorForObject:object
{
    IKBInspectorWindowController *controller = nil;
    if (!object) {
        if (!self.nilInspector) {
            self.nilInspector = [[IKBInspectorWindowController alloc] initWithWindowNibName:NSStringFromClass([IKBInspectorWindowController class])];
            self.nilInspector.representedObject = nil;
        }
        controller = self.nilInspector;
    } else {
        controller = objc_getAssociatedObject(object, (__bridge const void *)(inspectorKey));
        if (!controller) {
            controller = [[IKBInspectorWindowController alloc] initWithWindowNibName:NSStringFromClass([IKBInspectorWindowController class])];
            objc_setAssociatedObject(object, (__bridge const void *)inspectorKey, controller, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            controller.representedObject = object;
        }
    }
    controller.controllerDelegate = self;
    return controller;
}

- (IKBInspectorWindowController *)inspectorIfAvailableForObject:object
{
    if (!object) return self.nilInspector;
    return objc_getAssociatedObject(object, (__bridge const void *)inspectorKey);
}

- (void)inspectorWindowControllerWindowWillClose:(IKBInspectorWindowController *)controller
{
    id object = controller.representedObject;
    if (object == nil) {
        self.nilInspector = nil;
    } else {
        objc_setAssociatedObject(object, (__bridge const void *)inspectorKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@end
