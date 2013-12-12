//
//  IKBCodeRunner.m
//  ClassBrowser
//
//  Created by Graham Lee on 12/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import "IKBCodeRunner.h"
#import "IKBCompiler.h"

@implementation IKBCodeRunner

- (id)doIt:(NSString *)objectiveCSource
{
    return nil;
}

- (NSArray *)compilerArguments
{
    return @[@"-fsyntax-only", @"-x", @"objective-c"];
}

- (IKBCompiler *)compilerWithArguments:(NSArray *)arguments error:(NSError *__autoreleasing *)error
{
    return [IKBCompiler compilerWithArguments:arguments error:error];
}

@end
