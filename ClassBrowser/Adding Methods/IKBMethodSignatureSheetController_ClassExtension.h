//See COPYING for licence details.

#import "IKBMethodSignatureSheetController.h"

@interface IKBMethodSignatureSheetController () <NSTextFieldDelegate>

@property (weak) IBOutlet NSTextField *problemLabel;
@property (weak) IBOutlet NSTextField *signatureField;
@property (weak) IBOutlet NSButton *createMethodButton;
@property (strong, nonatomic) NSString *signatureText;
@property (assign, nonatomic, getter = isValidSignature) BOOL validSignature;

- (void)createMethod:(id)sender;
- (void)cancel:(id)sender;

@end
