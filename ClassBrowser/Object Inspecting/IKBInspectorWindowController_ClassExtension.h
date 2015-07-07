//See COPYING for licence details.

#import "IKBInspectorWindowController.h"

@class IKBInspectorDataSource;

@interface IKBInspectorWindowController ()

@property (weak) IBOutlet NSTableView *ivarTable;
@property (nonatomic, readonly, strong) IKBInspectorDataSource *dataSource;

@end