//See COPYING for licence details.

#import "IKBCompilerPreferencesViewController_ClassExtension.h"
#import "IKBXcodeSelectTaskRunner.h"

@interface IKBCompilerPreferencesViewController ()

@property (nonatomic, strong) NSArray *baseSDKs;
@property (strong) IBOutlet NSArrayController *baseSDKsArrayController;
@end

@implementation IKBCompilerPreferencesViewController

- (id)init
{
    self = [super initWithNibName:NSStringFromClass([IKBCompilerPreferencesViewController class]) bundle:nil];
    if (self) {
		_xcodeSelectTaskRunner = [IKBXcodeSelectTaskRunner new];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    __weak IKBCompilerPreferencesViewController *weakSelf = self;
    [self.xcodeSelectTaskRunner launchWithCompletion:^(NSString *XcodePath, NSError *error) {
        if (XcodePath) {
            NSString *SDKsPath = [XcodePath stringByAppendingPathComponent:@"Platforms/MacOSX.platform/Developer/SDKs"];
            IKBCompilerPreferences *compilerPreferences = weakSelf.compilerPreferences ? : [[IKBCompilerPreferences alloc] initWithSDKsPath:SDKsPath];
            weakSelf.baseSDKs = compilerPreferences.baseSDKs;
            weakSelf.baseSDKsArrayController.selectedObjects = @[compilerPreferences.preferredBaseSDK];
            weakSelf.compilerPreferences = compilerPreferences;
        } else if (error) {
            weakSelf.errorDescription = error.localizedDescription;
            weakSelf.recoverySuggestion = error.localizedRecoverySuggestion;
        }
    }];
    self.view.identifier = self.nibName;
}

- (IBAction)baseSDKPopupClicked:(id)sender
{
    IKBBaseSDK *selectedBaseSDK = self.baseSDKs[[_baseSDKPopup indexOfSelectedItem]];
    self.baseSDKsArrayController.selectedObjects = @[selectedBaseSDK];
	self.compilerPreferences.preferredBaseSDK = selectedBaseSDK;
}

@end
