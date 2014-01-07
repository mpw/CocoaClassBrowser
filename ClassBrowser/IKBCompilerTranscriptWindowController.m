//See COPYING for licence details.

#import "IKBCompilerTranscriptWindowController.h"

@implementation IKBCompilerTranscriptWindowController

- (void)setTranscriptText:(NSString *)transcriptText
{
    self.transcriptView.string = transcriptText;
}

- (NSString *)transcriptText
{
    return self.transcriptView.string;
}

@end
