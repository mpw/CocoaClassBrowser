//See COPYING for licence details.

#import <Foundation/Foundation.h>

@class IKBInspectorWindowController;

@interface IKBInspectorProvider : NSObject

/**
 * Always gives out an inspector.
 */
- (IKBInspectorWindowController *)inspectorForObject:object;
/**
 * Gives you an inspector if it already has one for the target object.
 */
- (IKBInspectorWindowController *)inspectorIfAvailableForObject:object;

@end
