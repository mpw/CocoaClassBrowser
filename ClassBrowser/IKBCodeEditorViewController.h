//See COPYING for licence details.

#import <Cocoa/Cocoa.h>

@class IKBCodeRunner;
@class IKBCommandBus;
@class IKBCompilerTranscriptWindowController;

@interface IKBCodeEditorViewController : NSViewController

@property (nonatomic, readonly) NSTextView *textView;
@property (nonatomic, strong) IKBCodeRunner *codeRunner;
@property (nonatomic, strong) IKBCompilerTranscriptWindowController *transcriptWindowController;
@property (nonatomic, strong) IKBCommandBus *commandBus;

- (void)printIt:(id)sender;

@end
