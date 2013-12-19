//
//  FakeCodeRunner.m
//  ClassBrowser
//
//  Created by Graham Lee on 18/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import "FakeCodeRunner.h"

@implementation FakeCodeRunner

- (id)doIt:(NSString *)objectiveCSource error:(NSError **)error
{
    self.ranSource = objectiveCSource;
    return self.runResult;
}

@end
