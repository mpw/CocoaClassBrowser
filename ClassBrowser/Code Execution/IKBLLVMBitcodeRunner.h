//See COPYING for licence details.

#import <Foundation/Foundation.h>
#include <string>

@class IKBLLVMBitcodeModule;

@interface IKBLLVMBitcodeRunner : NSObject

- (id)objectByRunningFunctionWithName:(NSString *)name inModule:(IKBLLVMBitcodeModule *)compiledBitcode compilerTranscript:(std::string&)diagnostic_output error:(NSError *__autoreleasing*)error;

@end