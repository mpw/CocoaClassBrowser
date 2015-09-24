//See COPYING for licence details.

#import "IKBNameEntrySheetController.h"

@implementation IKBNameEntrySheetController

- (BOOL)isEntryValid
{
    NSAssert(NO, @"Subclass responsibility");
    return NO;
}

- (void)reset
{
    [self setClassName:nil];
    [self setTextEntered:nil];
}

- (void)cancel:(id)sender
{
    NSWindow *presentingWindow = [self.window sheetParent];
    [presentingWindow endSheet:self.window returnCode:NSModalResponseCancel];
}

- (void)createEntry:(id)sender
{
    NSAssert(NO, @"Subclass responsibility");
}

- (void)controlTextDidChange:(NSNotification *)note
{
    [self setTextEntered:[[note object] stringValue]];
    [self setControlState:[self isEntryValid]];
}

- (void)setControlState:(BOOL)entryValidity
{
    self.createEntryButton.enabled = entryValidity;
    self.problemLabel.hidden = entryValidity;
}

@end
