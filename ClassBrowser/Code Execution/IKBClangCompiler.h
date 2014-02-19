//See COPYING for licence details.

#import <Foundation/Foundation.h>
#include <string>

@class IKBLLVMBitcodeModule;

@interface IKBClangCompiler : NSObject

- (IKBLLVMBitcodeModule *)bitcodeForSource:(NSString *)source compilerArguments:(NSArray *)compilerArguments compilerTranscript:(std::string&)diagnostic_output error:(NSError *__autoreleasing*)error;

@end