//See COPYING for licence details.

#import <Cocoa/Cocoa.h>

@class IKBCommandBus;
@class IKBSourceRepository;

@interface IKBAppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) IKBCommandBus *commandBus;
@property (nonatomic, strong) IKBSourceRepository *repository;

@end
