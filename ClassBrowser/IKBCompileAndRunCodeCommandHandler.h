//
//  IKBCompileAndRunCodeCommandHandler.h
//  ClassBrowser
//
//  Created by Graham Lee on 09/01/2014.
//  Copyright (c) 2014 Project Isambard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IKBCommandHandler.h"

@class IKBCodeRunner;

@interface IKBCompileAndRunCodeCommandHandler : NSObject <IKBCommandHandler>

@property (nonatomic, strong) IKBCodeRunner *codeRunner;

@end
