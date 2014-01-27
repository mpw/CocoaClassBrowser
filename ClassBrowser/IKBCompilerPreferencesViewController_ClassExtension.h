//See COPYING for licence details.

#import "IKBCompilerPreferencesViewController.h"
#import "IKBCompilerPreferences.h"
#import "IKBXcodeSelectTaskRunner.h"

@interface IKBCompilerPreferencesViewController ()

/**
 * Normally, there is no need to publicly expose the baseSDKPopup outlet since
 * it's only accessed internally within IKBCompilerPreferencesViewController.
 *
 * For the purpose of unit testing however, we allow accessing it so that we
 * can verify that it contains the expected list of base SDK values.
 */
@property (weak) IBOutlet NSPopUpButton *baseSDKPopup;

/**
 * Normally, the IKBCompilerPreferences class instance is intialized
 * directly by IKBCompilerPreferencesViewController after the current
 * Xcode installation path is retrieved through the use of an
 * IKBXcodeSelectTaskRunner instance.
 *
 * For the purpose of unit testing however, we allow passing in a mock
 * IKBCompilerPreferences instance which will serve-up a known
 * 'fixed' list of base SDKs.
 */
@property (nonatomic, strong) IKBCompilerPreferences *compilerPreferences;

/**
 * Normally, the IKBXcodeSelectTaskRunner class instance is intialized
 * directly by IKBCompilerPreferencesViewController.
 *
 * For the purpose of unit testing however, we allow passing in a mock
 * IKBXcodeSelectTaskRunner instance which ensures that the unit tests are
 * not susceptible to failure due to a possible non-standard Xcode installation.
 */
@property (nonatomic, strong) IKBXcodeSelectTaskRunner *xcodeSelectTaskRunner;

/**
 * Normally, there is no need to publicly expose the errorDescription and
 * recoverySuggestion properties since they are only accessed internally
 * within IKBCompilerPreferencesViewController.
 *
 * For the purpose of unit testing however, we allow accessing them so that we
 * can verify that they contain the expected values if a missing Xcode
 * installation is simulated.
 */
@property (nonatomic, copy) NSString *errorDescription;
@property (nonatomic, copy) NSString *recoverySuggestion;

/**
 * Normally, there is no need to publicly expose the baseSDKPopupClicked: action
 * method since it's only called from within IKBCompilerPreferencesViewController.
 *
 * For the purpose of unit testing however, we allow calling it so that we
 * can trigger the expected pseudo-UI interactions with the view controller.
 */
- (IBAction)baseSDKPopupClicked:(id)sender;

@end
