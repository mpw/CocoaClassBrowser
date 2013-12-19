//
//  IKBCodeEditorViewController.m
//  ClassBrowser
//
//  Created by Graham Lee on 18/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import "IKBCodeEditorViewController.h"
#import "IKBCodeRunner.h"

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
    NSTextView *textView = [[NSTextView alloc] initWithFrame:(NSRect){0}];
    textView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable | NSViewMaxYMargin;
    
    NSMenuItem *printItItem = [[NSMenuItem alloc] initWithTitle:@"Print It" action:@selector(printIt:) keyEquivalent:@""];
    [textView.menu addItem:printItItem];
    self.view = textView;
}

- (NSTextView *)textView
{
    return (NSTextView *)self.view;
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
