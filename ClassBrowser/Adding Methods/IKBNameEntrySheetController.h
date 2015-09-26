//See COPYING for licence details.

#import <Cocoa/Cocoa.h>

@interface IKBNameEntrySheetController : NSWindowController <NSTextFieldDelegate>

@property (nonatomic, copy) NSString *className;
@property (nonatomic, copy) NSString *textEntered;
@property (weak) IBOutlet NSTextField *problemLabel;
@property (weak) IBOutlet NSTextField *entryField;
@property (weak) IBOutlet NSButton *createEntryButton;

- (BOOL)isEntryValid;
- (void)reset;
- (void)setControlState:(BOOL)entryValidity;
- (IBAction)cancel:(id)sender;
- (IBAction)createEntry:(id)sender;

@end
