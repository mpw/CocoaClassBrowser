//
//  IKBCodeRunner.h
//  ClassBrowser
//
//  Created by Graham Lee on 12/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IKBCodeRunner : NSObject

- (id)doIt:(NSString *)objectiveCSource;
- (NSArray *)compilerArguments;
- (int)resultOfRunningSource:(NSString *)source error:(NSError **)error;

@end

extern NSString *IKBCompilerErrorDomain;
typedef NS_ENUM(NSInteger, IKBCompilerErrorCode) {
    IKBCompilerErrorBadArguments = 1,
    IKBCompilerErrorNoClangJob,
    IKBCompilerErrorNotAClangInvocation,
    IKBCompilerErrorCouldNotReportUnderlyingErrors,
    IKBCompilerErrorInSourceCode,
};