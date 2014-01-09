//See COPYING for licence details.

#import "IKBAppDelegate.h"
#import "IKBClassBrowserWindowController.h"
#import "IKBCommandBus.h"
#import "IKBCompileAndRunCodeCommandHandler.h"

@interface IKBAppDelegate ()

@property (nonatomic, strong) IKBClassBrowserWindowController *windowController;

@end

@implementation IKBAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.windowController = [[IKBClassBrowserWindowController alloc] initWithWindowNibName:@"IKBClassBrowserWindowController"];
    [self.windowController.window makeKeyAndOrderFront:self];
    [self.commandBus registerCommandHandler:[IKBCompileAndRunCodeCommandHandler new]];
}

@end
