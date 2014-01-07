//See COPYING for licence details.

#import <Cocoa/Cocoa.h>

@interface IKBCompilerTranscriptWindowController : NSWindowController

@property (nonatomic, copy) NSString *transcriptText;
@property (unsafe_unretained) IBOutlet NSTextView *transcriptView;

@end
