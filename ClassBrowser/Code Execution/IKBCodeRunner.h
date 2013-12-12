//
//  IKBCodeRunner.h
//  ClassBrowser
//
//  Created by Graham Lee on 12/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IKBCompiler;

@interface IKBCodeRunner : NSObject

- (id)doIt:(NSString *)objectiveCSource;
- (NSArray *)compilerArguments;
- (IKBCompiler *)compilerWithArguments:(NSArray *)arguments error:(NSError **)error;

@end
