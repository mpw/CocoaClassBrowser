//
//  IKBViewControllerOwnedView.m
//  ClassBrowser
//
//  Created by Graham Lee on 02/01/2014.
//  Copyright (c) 2014 Project Isambard. All rights reserved.
//

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
