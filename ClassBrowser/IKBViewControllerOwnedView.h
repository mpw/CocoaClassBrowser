//
//  IKBViewControllerOwnedView.h
//  ClassBrowser
//
//  Created by Graham Lee on 02/01/2014.
//  Copyright (c) 2014 Project Isambard. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IKBViewControllerOwnedView : NSView

@property (nonatomic, weak) NSViewController *viewController;

@end
