//See COPYING for licence details.

#import "IKBCodeEditorViewController.h"

@class IKBInspectorWindowController;

@interface IKBCodeEditorViewController ()

- (void)updateSourceViewWithResult:(id)returnValue ofSourceInRange:(NSRange)textRange compilerOutput:(NSString *)transcript error:(NSError *)error;
- (void)inspectResult:returnValue compilerOutput:(NSString *)compilerTranscript error:(NSError *)error;
- (IKBInspectorWindowController *)inspectorForObject:object;
- (IKBInspectorWindowController *)testAccessToCurrentInspectorForObject:object;

@end
