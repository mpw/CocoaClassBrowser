//See COPYING for licence details.

#import "IKBCompilerPreferences.h"

extern NSString *IKBPreferredBaseSDKVersionKey;

@interface IKBCompilerPreferences ()

/**
 * Normally, the list of available base SDKs is retrieved from the SDKsPath
 * location that is provided when initializing the class instance.
 *
 * For the purpose of unit testing however, we allow passing in a known
 * 'fixed' list of base SDKs.
 */
@property (nonatomic, strong) NSArray *baseSDKs;

/**
 * Normally, the standardUserDefaults class initializer is used to manage
 * the NSUserDefaults related to compiler preferences.
 *
 * For the purpose of unit testing however, we allow passing in a mock
 * NSUserDefaults instance to test that the expected user defaults are
 * registered, queried, stored and removed as expected.
 *
 * Additionally, by using a mock NSUserDefaults instance, we ensure that the
 * execution of the unit tests suit does not interefere with any currently
 * existing user defaults.
 */
@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end
