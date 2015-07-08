//See COPYING for licence details.

#import <Cocoa/Cocoa.h>
#import "IKBInspectorWindowController.h"

@class IKBCommandBus;
@class IKBCompilerTranscriptWindowController;

@interface IKBCodeEditorViewController : NSViewController <IKBInspectorWindowControllerDelegate>

@property (nonatomic, readonly, unsafe_unretained) NSTextView *textView;
@property (nonatomic, strong) IKBCompilerTranscriptWindowController *transcriptWindowController;
@property (nonatomic, strong) IKBCommandBus *commandBus;

- (void)printIt:(id)sender;
- (void)inspectIt:(id)sender;

- (void)setEditedMethod:(id)method;
@end
