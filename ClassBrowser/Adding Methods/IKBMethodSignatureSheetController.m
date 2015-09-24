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

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.problemLabel.stringValue = NSLocalizedString(@"That is not a valid Objective-C method signature.", @"Shown when trying to add an invalid ObjC method");
    self.createEntryButton.stringValue = NSLocalizedString(@"Create Method", @"Button title for creating method");
}

- (void)reset
{
    [super reset];
    _method = nil;
}

- (void)createEntry:(id)sender
{
    NSAssert([self isEntryValid], @"I should only be called when the signature is valid");
    IKBObjectiveCMethod *method = [IKBObjectiveCMethod new];
    method.className = self.className;
    method.declaration = self.textEntered;
    method.body = @"{\n\n}\n";
    _method = method;
}

- (BOOL)isEntryValid
{
    return [self isValidSignature];
}

- (BOOL)isValidSignature
{
    return ([self.textEntered canBeConvertedToEncoding:NSASCIIStringEncoding] &&
            ([self.textEntered hasPrefix:@"-"] || [self.textEntered hasPrefix:@"+"]) &&
            !([self.textEntered hasSuffix:@":"]));
}

@end