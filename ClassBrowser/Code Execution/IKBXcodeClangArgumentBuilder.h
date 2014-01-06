//
//  IKBXcodeClangArgumentBuilder.h
//  ClassBrowser
//
//  Created by Graham Lee on 06/01/2014.
//  Copyright (c) 2014 Project Isambard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IKBCompilerArgumentBuilder.h"

@interface IKBXcodeClangArgumentBuilder : NSObject <IKBCompilerArgumentBuilder>

@end

extern NSString *IKBXcodeClangArgumentBuilderErrorDomain;

typedef NS_ENUM(NSInteger, IKBXcodeClangArgumentBuilderError) {
    IKBXcodeClangArgumentBuilderErrorCannotLocateXcode = 1,
};
