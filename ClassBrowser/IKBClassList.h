//
//  IKBClassList.h
//  ClassBrowser
//
//  Created by Graham Lee on 10/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IKBClassList <NSObject>

- (NSArray *)allClassGroups;
- (NSUInteger)countOfClassGroups;
- (NSString *)objectInClassGroupsAtIndex:(NSUInteger)index;
- (void)selectClassGroupAtIndex:(NSInteger)index;

- (NSArray *)classesInSelectedGroup;
- (NSUInteger)countOfClasses;
- (NSString *)objectInClassesAtIndex:(NSUInteger)index;
- (void)selectClassAtIndex:(NSInteger)index;

- (NSArray *)protocolsInSelectedClass;
- (NSUInteger)countOfProtocols;
- (NSString *)objectInProtocolsAtIndex:(NSUInteger)index;
- (void)selectProtocolAtIndex:(NSInteger)index;

- (NSUInteger)countOfMethods;
- (NSString *)objectInMethodsAtIndex:(NSUInteger)index;

@end

@interface IKBClassList : NSObject <IKBClassList>

@end

extern NSString const *IKBProtocolAllMethods;
extern NSString const *IKBProtocolUncategorizedMethods;