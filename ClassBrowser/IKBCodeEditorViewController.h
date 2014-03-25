//See COPYING for licence details.

#import <Cocoa/Cocoa.h>

@class IKBCommandBus;
@class IKBCompilerTranscriptWindowController;

@interface IKBCodeEditorViewController : NSViewController

@property (nonatomic, readonly, unsafe_unretained) NSTextView *textView;
@property (nonatomic, strong) IKBCompilerTranscriptWindowController *transcriptWindowController;
@property (nonatomic, strong) IKBCommandBus *commandBus;

- (void)printIt:(id)sender;

- (void)setEditedMethod:(id)method;
@end
