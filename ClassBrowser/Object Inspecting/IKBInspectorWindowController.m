//See COPYING for licence details.

#import "IKBInspectorWindowController.h"
#import "IKBInspectorWindowController_ClassExtension.h"

#import "IKBInspectorDataSource.h"

@implementation IKBInspectorWindowController
{
    id _representedObject;
}

- (void)setWindow:(NSWindow *)window
{
    window.delegate = self;
    [super setWindow:window];
}

- representedObject { return _representedObject; }

- (void)setRepresentedObject:representedObject
{
    _representedObject = representedObject;
    self.window.title = [representedObject description]?:@"nil";
    _dataSource = [IKBInspectorDataSource inspectorWithObject:representedObject];
    self.ivarTable.dataSource = _dataSource;
    [self.ivarTable reloadData];
}

- (void)windowWillClose:(NSNotification *)notification
{
    [self.controllerDelegate inspectorWindowControllerWindowWillClose:self];
}

@end
