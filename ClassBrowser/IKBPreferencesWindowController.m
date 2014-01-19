//See COPYING for licence details.

#import "IKBPreferencesWindowController_ClassExtension.h"
#import "IKBCompilerPreferencesViewController.h"

@interface IKBPreferencesWindowController ()

@property (nonatomic, strong) NSMutableArray *viewControllers;

@end

@implementation IKBPreferencesWindowController

- (id)init
{
    self = [super initWithWindowNibName:NSStringFromClass([IKBPreferencesWindowController class])];
    if (self) {
        _viewControllers = [NSMutableArray new];
        NSViewController *vc = [IKBCompilerPreferencesViewController new];
        [_viewControllers addObject:vc];
    }
    return self;
}

- (void)windowDidLoad
{
    [self displayViewController:self.viewControllers[0]];
}

- (void)displayViewController:(NSViewController *)viewController
{
    NSWindow *window = self.contentView.window;
    BOOL ended = [window makeFirstResponder:window];
    if (!ended) {
        NSBeep();
        return;
    }
    NSView *view = viewController.view;
    self.contentView.contentView = view;
}

@end
