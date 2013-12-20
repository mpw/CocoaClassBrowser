//
//  IKBCodeEditorViewController.m
//  ClassBrowser
//
//  Created by Graham Lee on 18/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import "IKBCodeEditorViewController.h"
#import "IKBCodeRunner.h"

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
    }
    return self;
}

- (void)loadView
{
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame: NSMakeRect(0, 0, 100, 100)];
    scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable | NSViewMaxYMargin;

    NSTextView *textView = [[NSTextView alloc] initWithFrame:scrollView.contentView.bounds];
    textView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [textView setAutomaticDashSubstitutionEnabled:NO];
    [textView setAutomaticQuoteSubstitutionEnabled:NO];
    [textView setAutomaticSpellingCorrectionEnabled:NO];
    [textView setAutomaticTextReplacementEnabled:NO];
    
    NSMenuItem *printItItem = [[NSMenuItem alloc] initWithTitle:@"Print It" action:@selector(printIt:) keyEquivalent:@""];
    [textView.menu addItem:printItItem];
    self.textView = textView;
    [scrollView.contentView addSubview:textView];
    scrollView.contentView.documentView = textView;
    
    self.view = scrollView;
}

- (void)printIt:(id)sender
{
    NSRange textRange = [self.textView selectedRange];
    NSString *source = [self.textView.textStorage.string substringWithRange:textRange];
    NSError *error = nil;
    __unused id returnValue = [self.codeRunner doIt:source error:&error];
    //work out how this error will propagate back up
    [self.textView.textStorage insertAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", returnValue]] atIndex:textRange.location + textRange.length];
}

@end
