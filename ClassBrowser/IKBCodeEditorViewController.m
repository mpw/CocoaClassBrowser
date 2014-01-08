//See COPYING for licence details.

#import "IKBCodeEditorViewController.h"
#import "IKBCodeRunner.h"
#import "IKBCompilerTranscriptWindowController.h"
#import "IKBViewControllerOwnedView.h"

@interface IKBCodeEditorViewController ()

@property (nonatomic, weak, readwrite) NSTextView *textView;

@end

@implementation IKBCodeEditorViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.codeRunner = [IKBCodeRunner new];
        self.transcriptWindowController = [[IKBCompilerTranscriptWindowController alloc] initWithWindowNibName:NSStringFromClass([IKBCompilerTranscriptWindowController class])];
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

    CGFloat fontSize = [NSFont systemFontSize];
    NSFont *font = [NSFont userFixedPitchFontOfSize:fontSize];
    textView.font = font;

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
    [self.codeRunner doIt:source completion:^(id returnValue, NSString *compilerTranscript, NSError *error){
        [self updateSourceViewWithResult:returnValue ofSourceInRange:textRange compilerOutput:compilerTranscript error:error];
    }];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    return ([self.textView selectedRange].length > 0);
}

- (void)updateSourceViewWithResult:(id)returnValue ofSourceInRange:(NSRange)textRange compilerOutput:(NSString *)transcript error:(NSError *)error
{
    NSString *formattedResult = [NSString stringWithFormat:@"%@", returnValue?:[error localizedDescription]];
    [self.textView.textStorage insertAttributedString:[[NSAttributedString alloc] initWithString:formattedResult]
                                              atIndex:textRange.location + textRange.length];
    NSWindow *transcriptWindow = self.transcriptWindowController.window;
    if (transcript.length > 0) {
        self.transcriptWindowController.transcriptText = transcript;
        [transcriptWindow orderFront:self];
    } else {
        [transcriptWindow orderOut:self];
    }

}
@end
