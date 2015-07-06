//See COPYING for licence details.

#import <Cocoa/Cocoa.h>

@interface IKBInspectorDataSource : NSObject <NSTableViewDataSource>

+ (instancetype)inspectorWithObject:target;

@end
