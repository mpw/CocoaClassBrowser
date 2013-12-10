//
//  IKBAppDelegate.m
//  ClassBrowser
//
//  Created by Graham Lee on 10/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import "IKBAppDelegate.h"
#import "IKBClassBrowserSource.h"

// just for visual inspection during testing
#import "FakeClassList.h"

@interface IKBAppDelegate ()

@property (weak) IBOutlet NSBrowser *classBrowser;
@property (unsafe_unretained) IBOutlet NSTextView *codeText;
@property (nonatomic, strong) id <IKBClassList> classList;
@property (nonatomic, strong) IKBClassBrowserSource *browserSource;

@end

@implementation IKBAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // just for visual inspection during testing
    FakeClassList *classList = [FakeClassList new];
    classList.classes = @{ @"Foundation" : @[@"NSObject", @"NSData", @"NSString"],
                           @"AppKit" : @[@"NSBrowser", @"NSCell", @"NSTableView", @"NSMatrix"],
                           @"Isambard" : @[@"IKBCommandBus"] };
    self.classList = classList;
    self.browserSource = [[IKBClassBrowserSource alloc] initWithClassList:classList];
    self.classBrowser.delegate = self.browserSource;
    [self.classBrowser reloadColumn:0];
    [self.classBrowser setTarget:self];
    [self.classBrowser setAction:@selector(browserSelectionDidChange:)];
}

// this behaviour should be encapsulated in a window controller
- (IBAction)browserSelectionDidChange:(NSBrowser *)sender
{
    NSInteger column = [sender selectedColumn];
    NSInteger row = [sender selectedRowInColumn:column];
    [self.browserSource browser:sender didSelectRow:row inColumn:column];
}

@end
