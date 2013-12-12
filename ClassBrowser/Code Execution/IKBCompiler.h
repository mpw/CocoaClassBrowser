//
//  IKBCompiler.h
//  ClassBrowser
//
//  Created by Graham Lee on 12/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IKBCompiler : NSObject

+ (instancetype)compilerWithArguments:(NSArray *)arguments error:(NSError **)error;

@end

extern NSString *IKBCompilerErrorDomain;
typedef NS_ENUM(NSInteger, IKBCompilerErrorCode) {
    IKBCompilerErrorBadArguments = 1,
};