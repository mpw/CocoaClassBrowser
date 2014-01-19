//See COPYING for licence details.

#import "IKBCompilerPreferencesViewController_ClassExtension.h"

@interface IKBCompilerPreferencesViewController ()

@property (nonatomic, strong) NSArray *baseSDKs;
@property (strong) IBOutlet NSArrayController *baseSDKsArrayController;

@end

@implementation IKBCompilerPreferencesViewController

- (id)init
{
    self = [super initWithNibName:NSStringFromClass([IKBCompilerPreferencesViewController class]) bundle:nil];
    if (self) {
		_compilerDefaults = [IKBCompilerDefaults new];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    self.baseSDKs = self.compilerDefaults.baseSDKs;
    self.baseSDKsArrayController.selectedObjects = @[self.compilerDefaults.currentBaseSDK];
    self.view.identifier = self.nibName;
}

- (IBAction)baseSDKPopupClicked:(id)sender
{
    IKBBaseSDK *selectedBaseSDK = self.baseSDKs[[_baseSDKPopup indexOfSelectedItem]];
    self.baseSDKsArrayController.selectedObjects = @[selectedBaseSDK];
	self.compilerDefaults.currentBaseSDK = selectedBaseSDK;
}

@end
