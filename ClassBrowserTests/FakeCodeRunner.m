//
//  FakeCodeRunner.m
//  ClassBrowser
//
//  Created by Graham Lee on 18/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import "FakeCodeRunner.h"

@implementation FakeCodeRunner

- (void)doIt:(NSString *)objectiveCSource completion:(IKBCodeRunnerCompletionHandler)completion
{
    self.ranSource = objectiveCSource;
    completion(self.runResult, nil, nil);
}

@end
