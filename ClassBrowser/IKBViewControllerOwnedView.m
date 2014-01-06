//See COPYING for licence details.

#import "IKBViewControllerOwnedView.h"

@implementation IKBViewControllerOwnedView

- (void)setViewController:(NSViewController *)newController
{
    if (_viewController)
    {
        NSResponder *controllerNextResponder = [_viewController nextResponder];
        [super setNextResponder:controllerNextResponder];
        [_viewController setNextResponder:nil];
    }
    
    _viewController = newController;
    
    if (newController)
    {
        NSResponder *ownNextResponder = [self nextResponder];
        [super setNextResponder: _viewController];
        [_viewController setNextResponder:ownNextResponder];
    }
}

- (void)setNextResponder:(NSResponder *)newNextResponder
{
    if (_viewController)
    {
        [_viewController setNextResponder:newNextResponder];
        return;
    }
    
    [super setNextResponder:newNextResponder];
}

@end
