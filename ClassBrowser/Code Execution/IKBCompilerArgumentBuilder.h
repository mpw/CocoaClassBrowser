//
//  IKBCompilerArgumentBuilder.h
//  ClassBrowser
//
//  Created by Graham Lee on 06/01/2014.
//  Copyright (c) 2014 Project Isambard. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^IKBCompilerArgumentCompletion)(NSArray *arguments, NSError *error);

@protocol IKBCompilerArgumentBuilder <NSObject>

- (void)constructCompilerArgumentsWithCompletion:(IKBCompilerArgumentCompletion)completion;

@end
