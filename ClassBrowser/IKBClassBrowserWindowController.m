//See COPYING for licence details.

#import "IKBClassBrowserWindowController.h"
#import "IKBClassBrowserWindowController_ClassExtension.h"

#import "IKBClassBrowserSource.h"
#import "IKBRuntimeClassList.h"
#import "IKBCodeEditorViewController.h"
#import "IKBMethodSignatureSheetController.h"
#import "IKBNameEntrySheetController.h"

@implementation IKBClassBrowserWindowController

- (id)initWithWindowNibName:(NSString *)windowNibName
{
    self = [super initWithWindowNibName:windowNibName];
    if (self)
    {
        _addMethodSheet = [[IKBMethodSignatureSheetController alloc] initWithWindowNibName:NSStringFromClass([IKBNameEntrySheetController class])];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    IKBRuntimeClassList *classList = [IKBRuntimeClassList new];
    self.classList = classList;
    self.browserSource = [[IKBClassBrowserSource alloc] initWithClassList:classList];
    self.classBrowser.delegate = self.browserSource;
    [self.classBrowser reloadColumn:0];
    [self.classBrowser setTarget:self];
    [self.classBrowser setAction:@selector(browserSelectionDidChange:)];
    
    _codeEditorViewController = [IKBCodeEditorViewController new];
    _codeEditorViewController.inspectorProvider = self.inspectorProvider;
    NSView *editorView = self.codeEditorViewController.view;
    editorView.frame = (NSRect){ .origin = {0,0}, .size = {.width = 878, .height = 412 }};
    [self.window.contentView addSubview:editorView];
    
    [self.addMethodItem setEnabled:NO];
}

- (IBAction)browserSelectionDidChange:(NSBrowser *)sender
{
    NSInteger column = [sender selectedColumn];
    NSInteger row = [sender selectedRowInColumn:column];
    [self.addMethodItem setEnabled:(column > 0)];
    [self.browserSource browser:sender didSelectRow:row inColumn:column];
}

- (IBAction)addClass:(id)sender
{
    
}

- (IBAction)addMethod:(id)sender
{
    [self.addMethodSheet reset];
    NSString *selectedClassName = [self.browserSource selectedClass];
    [self.addMethodSheet setClassName:selectedClassName];
    [self.window beginSheet:self.addMethodSheet.window completionHandler:^(NSModalResponse returnCode) {
        [self addMethodSheetReturnedCode:returnCode];
    }];
}

- (void)addMethodSheetReturnedCode:(NSModalResponse)code
{
    if (code == NSModalResponseOK) {
        [self.codeEditorViewController setEditedMethod:self.addMethodSheet.method];
    }
}

@end
