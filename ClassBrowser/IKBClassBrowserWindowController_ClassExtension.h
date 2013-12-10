//
//  IKBClassBrowserWindowController_ClassExtension.h
//  ClassBrowser
//
//  Created by Graham Lee on 10/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import "IKBClassBrowserWindowController.h"

@class IKBClassBrowserSource;
@protocol IKBClassList;

@interface IKBClassBrowserWindowController ()

@property (weak) IBOutlet NSBrowser *classBrowser;
@property (unsafe_unretained) IBOutlet NSTextView *codeText;
@property (nonatomic, strong) id <IKBClassList> classList;
@property (nonatomic, strong) IKBClassBrowserSource *browserSource;

@end
