//See COPYING for licence details.

#import <Foundation/Foundation.h>

@protocol IKBClassList <NSObject>

- (NSArray *)allClassGroups;
- (NSUInteger)countOfClassGroups;
- (NSString *)objectInClassGroupsAtIndex:(NSUInteger)index;

- (NSArray *)classesInGroup:(NSString *)group;
- (NSUInteger)countOfClassesInGroup:(NSString *)group;
- (NSString *)classInGroup:(NSString *)group atIndex:(NSUInteger)index;

- (NSArray *)protocolsInClass:(NSString *)className;
- (NSUInteger)countOfProtocolsInClass:(NSString *)className;
- (NSString *)protocolInClass:(NSString *)className atIndex:(NSUInteger)index;

- (NSArray *)methodsInProtocol:(NSString *)protocolName ofClass:(NSString *)className;
- (NSUInteger)countOfMethodsInProtocol:(NSString *)protocolName ofClass:(NSString *)className;
- (NSString *)methodInProtocol:(NSString *)protocolName ofClass:(NSString *)className atIndex:(NSUInteger)index;

@end

extern NSString const *IKBProtocolAllMethods;
extern NSString const *IKBProtocolUncategorizedMethods;

NSArray *IKBSortedMethodList(NSArray *unsorted);
