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

@end