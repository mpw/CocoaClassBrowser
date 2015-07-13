//See COPYING for licence details.

#import "IKBMethodSignatureSheetController.h"
#import "IKBMethodSignatureSheetController_ClassExtension.h"
#import "IKBObjectiveCMethod.h"


@implementation IKBMethodSignatureSheetController
{
    IKBObjectiveCMethod *_method;
}

- (IKBObjectiveCMethod *)method
{
    return _method;
}

- (void)reset
{
    _method = nil;
    _className = nil;
    _signatureText = nil;
}

- (void)createMethod:(id)sender
{
    NSAssert([self isValidSignature], @"I should only be called when the signature is valid");
    IKBObjectiveCMethod *method = [IKBObjectiveCMethod new];
    method.className = self.className;
    method.declaration = self.signatureText;
    method.body = @"{\n\n}\n";
    _method = method;
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