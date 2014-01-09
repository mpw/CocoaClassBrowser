//
//  IKBCompileAndRunSourceCommand.h
//  ClassBrowser
//
//  Created by Graham Lee on 09/01/2014.
//  Copyright (c) 2014 Project Isambard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IKBCommand.h"

@interface IKBCompileAndRunCodeCommand : NSObject <IKBCommand>

@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) void(^completion)(NSString *source, NSString *compilerTranscript, NSError *error);

@end
