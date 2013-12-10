//
//  IKBAppDelegate.m
//  ClassBrowser
//
//  Created by Graham Lee on 10/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import "IKBAppDelegate.h"
#import "IKBClassBrowserWindowController.h"

@interface IKBAppDelegate ()

@property (nonatomic, strong) IKBClassBrowserWindowController *windowController;

@end

@implementation IKBAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.windowController = [[IKBClassBrowserWindowController alloc] initWithWindowNibName:@"IKBClassBrowserWindowController"];
    [self.windowController.window makeKeyAndOrderFront:self];
}

@end
