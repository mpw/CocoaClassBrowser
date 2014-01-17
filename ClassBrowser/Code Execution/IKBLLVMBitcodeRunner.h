//
// Created by Graham Lee on 16/01/2014.
// Copyright (c) 2014 Project Isambard. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <string>

@class IKBLLVMBitcodeModule;

@interface IKBLLVMBitcodeRunner : NSObject

- (id)objectByRunningFunctionWithName:(NSString *)name inModule:(IKBLLVMBitcodeModule *)compiledBitcode compilerTranscript:(std::string&)diagnostic_output error:(NSError *__autoreleasing*)error;

@end