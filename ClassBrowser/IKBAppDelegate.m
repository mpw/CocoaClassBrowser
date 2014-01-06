//See COPYING for licence details.

#import "IKBAppDelegate.h"
#import "IKBClassBrowserWindowController.h"

@interface IKBAppDelegate ()

@property (nonatomic, strong) IKBClassBrowserWindowController *windowController;

@end

@implementation IKBAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.windowController = [[IKBClassBrowserWindowController alloc] initWithWindowNibName:@"IKBClassBrowserWindowController"];
    [self.windowController.window makeKeyAndOrderFront:self];
}

@end
