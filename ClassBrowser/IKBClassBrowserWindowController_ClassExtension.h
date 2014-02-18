//See COPYING for licence details.

#import "IKBClassBrowserWindowController.h"

@class IKBClassBrowserSource;
@class IKBCodeEditorViewController;
@protocol IKBClassList;

@interface IKBClassBrowserWindowController ()

@property (weak) IBOutlet NSBrowser *classBrowser;
@property (weak) IBOutlet NSToolbarItem *addMethodItem;

@property (nonatomic, strong) id <IKBClassList> classList;
@property (nonatomic, strong) IKBClassBrowserSource *browserSource;
@property (nonatomic, readonly) IKBCodeEditorViewController *codeEditorViewController;


- (IBAction)browserSelectionDidChange:(NSBrowser *)sender;

@end
