//See COPYING for licence details.

#import <Cocoa/Cocoa.h>

@class IKBCommandBus;
@interface IKBAppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) IKBCommandBus *commandBus;

@end
