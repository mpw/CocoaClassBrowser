//See COPYING for licence details.

#import "IKBCodeEditorViewController.h"

@interface IKBCodeEditorViewController ()

- (void)updateSourceViewWithResult:(id)returnValue ofSourceInRange:(NSRange)textRange compilerOutput:(NSString *)transcript error:(NSError *)error;

@end
