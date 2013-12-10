//
//  IKBClassBrowserSource.h
//  ClassBrowser
//
//  Created by Graham Lee on 10/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IKBClassList.h"

@interface IKBClassBrowserSource : NSObject <NSBrowserDelegate>

- (instancetype)initWithClassList:(id <IKBClassList>)list;

@end
