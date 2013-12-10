//
//  FakeClassList.h
//  ClassBrowser
//
//  Created by Graham Lee on 10/12/2013.
//  Copyright (c) 2013 Project Isambard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IKBClassList.h"

@interface FakeClassList : NSObject <IKBClassList>

@property (nonatomic, strong) NSDictionary *classes;
@property (nonatomic, readonly) NSArray *classGroups;
@property (nonatomic, readonly) NSString *selectedClassGroup;
@property (nonatomic, readonly) NSString *selectedClass;

@end
