//
//  IKBCodeRunner.h
//  ClassBrowser
//
//  Created by Graham Lee on 12/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IKBCompilerArgumentBuilder;

typedef void(^IKBCodeRunnerCompletionHandler)(id returnValue, NSString *compilerTranscript, NSError *compilationError);

@interface IKBCodeRunner : NSObject

- (instancetype)initWithCompilerArgumentBuilder:(id <IKBCompilerArgumentBuilder>)builder;
- (void)doIt:(NSString *)objectiveCSource completion:(IKBCodeRunnerCompletionHandler)completion;
- (void)runSource:(NSString *)source completion:(IKBCodeRunnerCompletionHandler)completion;

@property (nonatomic, readonly) id <IKBCompilerArgumentBuilder> compilerArgumentBuilder;

@end

extern NSString *IKBCompilerErrorDomain;
typedef NS_ENUM(NSInteger, IKBCompilerErrorCode) {
    IKBCompilerErrorBadArguments = 1,
    IKBCompilerErrorNoClangJob,
    IKBCompilerErrorNotAClangInvocation,
    IKBCompilerErrorCouldNotReportUnderlyingErrors,
    IKBCompilerErrorInSourceCode,
};

extern NSString *IKBCodeRunnerErrorDomain;
typedef NS_ENUM(NSInteger, IKBCodeRunnerErrorCode) {
    IKBCodeRunnerErrorCouldNotConstructRuntime,
    IKBCodeRunnerErrorCouldNotFindFunctionToRun,
};