//
//  IKBCodeEditorViewController_ClassExtension.h
//  ClassBrowser
//
//  Created by Graham Lee on 08/01/2014.
//  Copyright (c) 2014 Project Isambard. All rights reserved.
//

#import "IKBCodeEditorViewController.h"

@interface IKBCodeEditorViewController ()

- (void)updateSourceViewWithResult:(id)returnValue ofSourceInRange:(NSRange)textRange compilerOutput:(NSString *)transcript error:(NSError *)error;

@end
