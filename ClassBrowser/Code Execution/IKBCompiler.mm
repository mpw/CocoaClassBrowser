//
//  IKBCompiler.m
//  ClassBrowser
//
//  Created by Graham Lee on 12/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import "IKBCompiler.h"

@implementation IKBCompiler

+ (instancetype)compilerWithArguments:(NSArray *)arguments error:(NSError *__autoreleasing *)error
{
    if (![arguments count])
    {
        if (error)
        {
            *error = [NSError errorWithDomain:IKBCompilerErrorDomain code:IKBCompilerErrorBadArguments userInfo:nil];
        }
        return nil;
    }
    return [self new];
}

@end

NSString *IKBCompilerErrorDomain = @"IKBCompilerErrorDomain";