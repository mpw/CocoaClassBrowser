//See COPYING for licence details.

#import <Foundation/Foundation.h>


@interface IKBObjectiveCMethod : NSObject <NSCoding>

@property (nonatomic, copy) NSString *declaration;
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSString *className;
@property (nonatomic, copy) NSString *protocolName;

/**
 * The canonical name is that which would be presented in the browser
 * were this method attached to the runtime, which it isn't, necessarily.
 */
@property (nonatomic, readonly) NSString *canonicalName;

@end