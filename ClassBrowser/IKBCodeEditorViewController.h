//See COPYING for licence details.

#import <Cocoa/Cocoa.h>

@class IKBCodeRunner;

@interface IKBCodeEditorViewController : NSViewController

@property (nonatomic, readonly) NSTextView *textView;
@property (nonatomic, strong) IKBCodeRunner *codeRunner;

- (void)printIt:(id)sender;

@end
