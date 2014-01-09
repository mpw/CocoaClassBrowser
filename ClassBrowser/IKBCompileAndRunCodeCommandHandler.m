//
//  IKBCompileAndRunCodeCommandHandler.m
//  ClassBrowser
//
//  Created by Graham Lee on 09/01/2014.
//  Copyright (c) 2014 Project Isambard. All rights reserved.
//

#import "IKBCompileAndRunCodeCommandHandler.h"
#import "IKBCodeRunner.h"
#import "IKBCompileAndRunCodeCommand.h"

@implementation IKBCompileAndRunCodeCommandHandler

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.codeRunner = [IKBCodeRunner new];
    }
    return self;
}

- (BOOL)canHandleCommand:(id<IKBCommand>)command
{
    return [command isKindOfClass:[IKBCompileAndRunCodeCommand class]];
}

- (void)executeCommand:(IKBCompileAndRunCodeCommand *)command
{
    [self.codeRunner doIt:command.source completion:command.completion];
}

@end
