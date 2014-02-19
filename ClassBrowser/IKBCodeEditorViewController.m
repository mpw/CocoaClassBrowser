//See COPYING for licence details.

#import "IKBCodeEditorViewController.h"
#import "IKBCodeRunner.h"
#import "IKBCommandBus.h"
#import "IKBCompileAndRunCodeCommand.h"
#import "IKBCompilerTranscriptWindowController.h"
#import "IKBViewControllerOwnedView.h"
#import "IKBObjectiveCMethod.h"

@interface IKBCodeEditorViewController ()

@property (nonatomic, strong) NSFont *defaultFont;
@property (nonatomic, weak, readwrite) NSTextView *textView;

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
    self.textView = textView;
    [scrollView.contentView addSubview:textView];
    scrollView.contentView.documentView = textView;
    [view addSubview:scrollView];
    
    self.view = view;
}

#pragma mark - menu items

- (void)printIt:(id)sender
{
    NSRange textRange = [self.textView selectedRange];
    NSString *source = [self.textView.textStorage.string substringWithRange:textRange];
    IKBCompileAndRunCodeCommand *command = [IKBCompileAndRunCodeCommand new];
    command.source = source;
    command.completion = ^(id returnValue, NSString *compilerTranscript, NSError *error){
        [self updateSourceViewWithResult:returnValue ofSourceInRange:textRange compilerOutput:compilerTranscript error:error];
    };
    [self.commandBus execute:command];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    return ([self.textView selectedRange].length > 0);
}

- (void)updateSourceViewWithResult:(id)returnValue ofSourceInRange:(NSRange)textRange compilerOutput:(NSString *)transcript error:(NSError *)error
{
    NSString *formattedResult = [NSString stringWithFormat:@" %@", returnValue?:[error localizedDescription]];
    NSUInteger insertLocation = textRange.location + textRange.length;
    [self.textView insertText:formattedResult replacementRange:NSMakeRange(insertLocation, 0)];
    [self.textView setSelectedRange:NSMakeRange(insertLocation, [formattedResult length])];
    NSWindow *transcriptWindow = self.transcriptWindowController.window;
    if (transcript.length > 0) {
        self.transcriptWindowController.transcriptText = transcript;
        [transcriptWindow orderFront:self];
    } else {
        [transcriptWindow orderOut:self];
    }

}

- (void)setEditedMethod:(IKBObjectiveCMethod *)method
{

}

@end
