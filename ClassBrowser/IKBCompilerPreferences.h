//See COPYING for licence details.

#import <Foundation/Foundation.h>
#import "IKBBaseSDK.h"

@interface IKBCompilerPreferences : NSObject

/**
 * For production use, the SDKsPath should point to the location of
 * available base SDKs provided within a valid Xcode installation (as
 * indicated by running the 'xcode-select -p' command line). Typically,
 * this would be 'XCODE_SELECT_PATH/Platforms/MacOSX.platform/Developer/SDKs/'.
 *
 * For the purpose of unit testing however, we allow the use the simple -init
 * initializer (no arguments), followed by a call to set a known 'fixed'
 * list of base SDKs (see the class extension header file for details).
 */
- (instancetype)initWithSDKsPath:(NSString *)SDKsPath;

/**
 * Returns a list of available IKBBaseSDK instances.
 */
@property (nonatomic, readonly) NSArray *baseSDKs;

/**
 * Retrieves or sets the currently preferred IKBBaseSDK.
 *
 * Should be one of the entries from the list of available IKBBaseSDK instances.
 */
@property (nonatomic, strong) IKBBaseSDK *preferredBaseSDK;

@end
