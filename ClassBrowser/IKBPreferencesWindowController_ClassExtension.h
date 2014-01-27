//See COPYING for licence details.

#import "IKBPreferencesWindowController.h"

@interface IKBPreferencesWindowController ()

/**
 * Normally, there is no need to publicly expose the contentView outlet since
 * it's only accessed internally within IKBPreferencesWindowController.
 *
 * For the purpose of unit testing however, we allow accessing it so that we
 * can verify that the correct subview is set in the expected usage context.
 */
@property (weak) IBOutlet NSBox *contentView;

@end
