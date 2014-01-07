//See COPYING for licence details.

#import <Cocoa/Cocoa.h>

@class IKBCodeRunner;
@class IKBCompilerTranscriptWindowController;

@interface IKBCodeEditorViewController : NSViewController

@property (nonatomic, readonly) NSTextView *textView;
@property (nonatomic, strong) IKBCodeRunner *codeRunner;
@property (nonatomic, strong) IKBCompilerTranscriptWindowController *transcriptWindowController;

- (void)printIt:(id)sender;

@end
