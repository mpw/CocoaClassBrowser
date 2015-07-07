//See COPYING for licence details.

#import "IKBInspectorWindowController.h"

@interface IKBInspectorWindowController ()

@end

@implementation IKBInspectorWindowController
{
    id _representedObject;
}

- representedObject { return _representedObject; }

- (void)setRepresentedObject:representedObject
{
    _representedObject = representedObject;
    self.window.title = [representedObject description]?:@"nil";
}

@end
