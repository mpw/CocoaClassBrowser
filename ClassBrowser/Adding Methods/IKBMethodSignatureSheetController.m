//See COPYING for licence details.

#import "IKBMethodSignatureSheetController.h"
#import "IKBMethodSignatureSheetController_ClassExtension.h"
#import "IKBObjectiveCMethod.h"


@implementation IKBMethodSignatureSheetController
{
    NSString *_class;
    IKBObjectiveCMethod *_method;
}

- (IKBObjectiveCMethod *)method
{
    return _method;
}

- (void)setClass:(NSString *)classForNewMethod
{
    _class = [classForNewMethod copy];
}

- (void)reset
{

}

- (void)createMethod:(id)sender
{
    NSAssert([self isValidSignature], @"I should only be called when the signature is valid");
    IKBObjectiveCMethod *method = [IKBObjectiveCMethod new];
    method.className = _class;
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