//See COPYING for licence details.

#import "IKBClassBrowserWindowController.h"

@class IKBClassBrowserSource;
@class IKBCodeEditorViewController;
@protocol IKBClassList;
@class IKBMethodSignatureSheetController;

@interface IKBClassBrowserWindowController ()

@property (weak) IBOutlet NSBrowser *classBrowser;
@property (weak) IBOutlet NSToolbarItem *addMethodItem;

@property (nonatomic, strong) id <IKBClassList> classList;
@property (nonatomic, strong) IKBClassBrowserSource *browserSource;
@property (nonatomic, strong) IKBCodeEditorViewController *codeEditorViewController;
@property (nonatomic, strong) IKBMethodSignatureSheetController *addMethodSheet;

- (IBAction)browserSelectionDidChange:(NSBrowser *)sender;
- (IBAction)addClass:(id)sender;
- (IBAction)addMethod:(id)sender;

- (void)addMethodSheetReturnedCode:(NSModalResponse)code;

@end
