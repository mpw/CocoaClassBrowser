//
//  IKBCodeEditorViewController.h
//  ClassBrowser
//
//  Created by Graham Lee on 18/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class IKBCodeRunner;

@interface IKBCodeEditorViewController : NSViewController

@property (nonatomic, readonly) NSTextView *textView;
@property (nonatomic, strong) IKBCodeRunner *codeRunner;

- (void)printIt:(id)sender;

@end
