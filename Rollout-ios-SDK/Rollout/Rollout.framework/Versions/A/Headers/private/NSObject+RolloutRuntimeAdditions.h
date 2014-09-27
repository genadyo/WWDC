//
//  NSObject+RolloutRuntimeAdditions.h
//  MoMe
//
//  Created by eyal keren on 3/9/14.
//  Copyright (c) 2014 eyal keren. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef IMP *IMPPointer;

@interface NSObject(RolloutRuntimeAdditions) 

+ (BOOL)rollout_swizzleInstance:(SEL)original with:(IMP)replacement store:(IMPPointer)store ;
+ (BOOL)rollout_swizzleClass:(SEL)original with:(IMP)replacement store:(IMPPointer)store ;
    
@end
