//
//  IKBClassBrowserWindowController.m
//  ClassBrowser
//
//  Created by Graham Lee on 10/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import "IKBClassBrowserWindowController.h"
#import "IKBClassBrowserWindowController_ClassExtension.h"

#import "IKBClassBrowserSource.h"
#import "IKBClassList.h"
#import "IKBCodeRunner.h"

@implementation IKBClassBrowserWindowController
{
    IKBCodeRunner *_runner;
}

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
    
    _runner = [[IKBCodeRunner alloc] init];
    
    NSMenu *menu = [self.codeText menu];
    [menu addItem:self.doItItem];
}

- (IBAction)browserSelectionDidChange:(NSBrowser *)sender
{
    NSInteger column = [sender selectedColumn];
    NSInteger row = [sender selectedRowInColumn:column];
    [self.browserSource browser:sender didSelectRow:row inColumn:column];
}

- (IBAction)printIt:(id)sender
{
    NSRange textRange = [self.codeText selectedRange];
    NSString *source = [self.codeText.textStorage.string substringWithRange:textRange];
    NSError *error = nil;
    id returnValue = [_runner doIt:source error:&error];
    //work out how this error will propagate back up
    [self.codeText.textStorage insertAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", returnValue]] atIndex:textRange.location + textRange.length];
}

@end
