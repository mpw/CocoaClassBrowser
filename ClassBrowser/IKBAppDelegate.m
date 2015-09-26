//See COPYING for licence details.

#import "IKBAppDelegate.h"
#import "IKBClassBrowserWindowController.h"
#import "IKBCommandBus.h"
#import "IKBCompileAndRunCodeCommandHandler.h"
#import "IKBInspectorProvider.h"
#import "IKBPreferencesWindowController.h"
#import "IKBSourceRepository.h"

@interface IKBAppDelegate ()

@property (nonatomic, strong) IKBClassBrowserWindowController *windowController;
@property (nonatomic, strong) IKBPreferencesWindowController *preferencesWindowController;

@end

@implementation IKBAppDelegate

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.commandBus = [IKBCommandBus applicationCommandBus];
		self.repository = [IKBSourceRepository new];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.windowController = [[IKBClassBrowserWindowController alloc] initWithWindowNibName:@"IKBClassBrowserWindowController"];
    self.windowController.inspectorProvider = [IKBInspectorProvider new];
	self.windowController.repository = self.repository;
    [self.windowController.window makeKeyAndOrderFront:self];
    [self.commandBus registerCommandHandler:[IKBCompileAndRunCodeCommandHandler new]];
}

- (IBAction)showPreferences:(id)sender
{
	if (!self.preferencesWindowController) {
		self.preferencesWindowController = [IKBPreferencesWindowController new];
	}
	[self.preferencesWindowController.window makeKeyAndOrderFront:self];
}

@end
