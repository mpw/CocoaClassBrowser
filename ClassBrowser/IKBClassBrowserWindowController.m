//See COPYING for licence details.

#import "IKBClassBrowserWindowController.h"
#import "IKBClassBrowserWindowController_ClassExtension.h"

#import "IKBClassBrowserSource.h"
#import "IKBClassList.h"
#import "IKBCodeEditorViewController.h"

@implementation IKBClassBrowserWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    IKBClassList *classList = [IKBClassList new];
    self.classList = classList;
    self.browserSource = [[IKBClassBrowserSource alloc] initWithClassList:classList];
    self.classBrowser.delegate = self.browserSource;
    [self.classBrowser reloadColumn:0];
    [self.classBrowser setTarget:self];
    [self.classBrowser setAction:@selector(browserSelectionDidChange:)];
    
    _codeEditorViewController = [IKBCodeEditorViewController new];
    NSView *editorView = self.codeEditorViewController.view;
    editorView.frame = (NSRect){ .origin = {0,0}, .size = {.width = 878, .height = 412 }};
    [self.window.contentView addSubview:editorView];
    
    [self.addMethodItem setEnabled:NO];
}

- (IBAction)browserSelectionDidChange:(NSBrowser *)sender
{
    NSInteger column = [sender selectedColumn];
    NSInteger row = [sender selectedRowInColumn:column];
    [self.addMethodItem setEnabled:(column != 0)];
    [self.browserSource browser:sender didSelectRow:row inColumn:column];
}

- (IBAction)addMethod:(id)sender
{
    
}
@end
