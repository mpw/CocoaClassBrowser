//See COPYING for licence details.

#import "IKBClassNameSheetController.h"
#import "IKBObjectiveCClass.h"

@interface IKBClassNameSheetController ()

@end

@implementation IKBClassNameSheetController

- (BOOL)isEntryValid
{
    return [self isValidClassName:self.textEntered];
}

- (BOOL)isValidClassName:(NSString *)proposedName
{
    //you might want to check whether the class already exists.
    if ([proposedName length] == 0) return NO;
    if ([proposedName rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location == 0) return 0;
    return [proposedName canBeConvertedToEncoding:NSASCIIStringEncoding];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.problemLabel.stringValue = NSLocalizedString(@"That is not a valid Objective-C class name.", @"Shown when trying to add an invalid ObjC class");
    self.createEntryButton.title = NSLocalizedString(@"Create Class", @"Button title for creating class");
}

- (NSString *)className
{
    return self.textEntered;
}

- (void)createEntry:(id)sender
{
    NSAssert([self isEntryValid], @"Only create a class when the class name is acceptable");
    self.createdClass = [[IKBObjectiveCClass alloc] initWithName:self.textEntered superclass:@"NSObject"];
    NSWindow *presentingWindow = [self.window sheetParent];
    [presentingWindow endSheet:self.window returnCode:NSModalResponseOK];
}

@end
