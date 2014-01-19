//See COPYING for licence details.

#import "IKBCompilerPreferencesViewController.h"
#import "IKBCompilerDefaults.h"

@interface IKBCompilerPreferencesViewController ()

@property (weak) IBOutlet NSPopUpButton *baseSDKPopup;
@property (nonatomic, strong) IKBCompilerDefaults *compilerDefaults;

- (IBAction)baseSDKPopupClicked:(id)sender;

@end
