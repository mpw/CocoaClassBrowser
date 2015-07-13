//See COPYING for licence details.

#import "IKBMethodSignatureSheetController.h"
#import "IKBMethodSignatureSheetController_ClassExtension.h"
#import "IKBObjectiveCMethod.h"


@implementation IKBMethodSignatureSheetController
{

}

- (IKBObjectiveCMethod *)method
{
    return nil;
}

- (void)setClass:(NSString *)classForNewMethod
{

}

- (void)reset
{

}

- (void)createMethod:(id)sender
{
    
}

- (void)cancel:(id)sender
{
    NSWindow *presentingWindow = [self.window sheetParent];
    [presentingWindow endSheet:self.window returnCode:NSModalResponseCancel];
}

- (BOOL)isValidSignature
{
    return ([self.signatureText canBeConvertedToEncoding:NSASCIIStringEncoding] &&
            ([self.signatureText hasPrefix:@"-"] || [self.signatureText hasPrefix:@"+"]) &&
            !([self.signatureText hasSuffix:@":"]));
}

- (void)controlTextDidChange:(NSNotification *)note
{
    _signatureText = [[note object] stringValue];
    BOOL valid = [self isValidSignature];
    self.createMethodButton.enabled = valid;
    self.problemLabel.hidden = valid;
}

@end