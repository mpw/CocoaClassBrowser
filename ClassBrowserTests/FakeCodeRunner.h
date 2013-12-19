//
//  FakeCodeRunner.h
//  ClassBrowser
//
//  Created by Graham Lee on 18/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FakeCodeRunner : NSObject

@property (nonatomic, copy) NSString *ranSource;
@property (nonatomic, strong) id runResult;

- (id)doIt:(NSString *)objectiveCSource error:(NSError **)error;

@end
