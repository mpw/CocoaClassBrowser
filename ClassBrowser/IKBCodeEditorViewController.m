//See COPYING for licence details.

#import "IKBCodeEditorViewController.h"
#import "IKBCodeRunner.h"
#import "IKBCommandBus.h"
#import "IKBCompileAndRunCodeCommand.h"
#import "IKBCompilerTranscriptWindowController.h"
#import "IKBInspectorProvider.h"
#import "IKBInspectorWindowController.h"
#import "IKBViewControllerOwnedView.h"
#import "IKBObjectiveCMethod.h"

@interface IKBCodeEditorViewController ()

@property (nonatomic, strong) NSFont *defaultFont;
@property (nonatomic, unsafe_unretained, readwrite) NSTextView *textView;

@end

@implementation IKBCodeEditorViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.transcriptWindowController = [[IKBCompilerTranscriptWindowController alloc] initWithWindowNibName:NSStringFromClass([IKBCompilerTranscriptWindowController class])];
        self.defaultFont = [NSFont userFixedPitchFontOfSize:[NSFont systemFontSize]];
        self.commandBus = [IKBCommandBus applicationCommandBus];
    }
    return self;
}

- (void)loadView
{
    NSRect initialRect = NSMakeRect(0, 0, 100, 100);
    IKBViewControllerOwnedView *view = [[IKBViewControllerOwnedView alloc] initWithFrame:initialRect];
    view.viewController = self;
    view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable | NSViewMaxYMargin;
    
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame: initialRect];
    scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;

    NSTextView *textView = [[NSTextView alloc] initWithFrame:scrollView.contentView.bounds];
    textView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [textView setAutomaticDashSubstitutionEnabled:NO];
    [textView setAutomaticQuoteSubstitutionEnabled:NO];
    [textView setAutomaticSpellingCorrectionEnabled:NO];
    [textView setAutomaticTextReplacementEnabled:NO];
    [textView setTypingAttributes:@{NSFontAttributeName: self.defaultFont}];
    
    NSMenuItem *printItItem = [[NSMenuItem alloc] initWithTitle:@"Print It" action:@selector(printIt:) keyEquivalent:@""];
    [textView.menu addItem:printItItem];
    NSMenuItem *inspectItItem = [[NSMenuItem alloc] initWithTitle:@"Inspect It" action:@selector(inspectIt:) keyEquivalent:@""];
    [textView.menu addItem:inspectItItem];

    self.textView = textView;
    [scrollView.contentView addSubview:textView];
    scrollView.contentView.documentView = textView;
    [view addSubview:scrollView];

    self.view = view;
}

#pragma mark - menu items

- (void)printIt:sender
{
    [self compileSelectedCodeWithCompletion:^(id returnValue, NSString *compilerTranscript, NSError *error) {
        [self updateSourceViewWithResult:returnValue ofSourceInRange:[self.textView selectedRange] compilerOutput:compilerTranscript error:error];
    }];
}

- (void)inspectIt:sender
{
    [self compileSelectedCodeWithCompletion:^(id returnValue, NSString *compilerTranscript, NSError *error) {
        [self inspectResult:returnValue compilerOutput:compilerTranscript error:error];
    }];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    return ([self.textView selectedRange].length > 0);
}

- (void)compileSelectedCodeWithCompletion:(void(^)(id,NSString *,NSError *))completion
{
    NSRange textRange = [self.textView selectedRange];
    NSString *source = [self.textView.textStorage.string substringWithRange:textRange];
    IKBCompileAndRunCodeCommand *command = [IKBCompileAndRunCodeCommand new];
    command.source = source;
    command.completion = completion;
    [self.commandBus execute:command];
}

- (void)updateCompilerTranscript:(NSString *)transcript
{
    NSWindow *transcriptWindow = self.transcriptWindowController.window;
    if (transcript.length > 0) {
        self.transcriptWindowController.transcriptText = transcript;
        [transcriptWindow orderFront:self];
    } else {
        [transcriptWindow orderOut:self];
    }
}

- (void)updateSourceViewWithResult:returnValue ofSourceInRange:(NSRange)textRange compilerOutput:(NSString *)transcript error:(NSError *)error
{
    NSString *formattedResult = [NSString stringWithFormat:@" %@", returnValue?:[error localizedDescription]];
    NSUInteger insertLocation = textRange.location + textRange.length;
    [self.textView insertText:formattedResult replacementRange:NSMakeRange(insertLocation, 0)];
    [self.textView setSelectedRange:NSMakeRange(insertLocation, [formattedResult length])];
    [self updateCompilerTranscript:transcript];
}

- (void)inspectResult:returnValue compilerOutput:(NSString *)compilerTranscript error:(NSError *)error
{
    /* Writing this method means accepting the possibility that the returnValue is nil but that this is desirable.
     * I'll follow the "if the result was nil then look at the error" approach, but rely on the error only being
     * non-nil in the case that the activity failed. "Looking at" the error in this case means inspecting it.
     */
    IKBInspectorWindowController *controller = [self inspectorForObject:returnValue?:error];
    [controller.window makeKeyAndOrderFront:self];
    [self updateCompilerTranscript:compilerTranscript];
}

- (void)setEditedMethod:(IKBObjectiveCMethod *)method
{

}

#pragma mark - Inspector shenanigans

- (IKBInspectorWindowController *)inspectorForObject:object
{
    return [self.inspectorProvider inspectorForObject:object];
}

- (IKBInspectorWindowController *)testAccessToCurrentInspectorForObject:object
{
    return [self.inspectorProvider inspectorIfAvailableForObject:object];
}

@end
