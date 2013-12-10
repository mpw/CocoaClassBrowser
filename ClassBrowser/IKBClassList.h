//
//  IKBClassList.h
//  ClassBrowser
//
//  Created by Graham Lee on 10/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IKBClassList <NSObject>

- (NSUInteger)countOfClassGroups;
- (NSString *)objectInClassGroupsAtIndex:(NSUInteger)index;

@end
