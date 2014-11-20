//
//  RolloutDynamic.m
//  MoMe
//
//  Created by eyal keren on 3/9/14.
//  Copyright (c) 2014 eyal keren. All rights reserved.
//

#import <Rollout/private/RolloutDynamic.h>
#import <Rollout/private/RolloutInvocation.h>
#import <Rollout/private/RolloutTypeWrapper.h>
#import <Rollout/private/RolloutInvocationsListFactory.h>
#import <objc/runtime.h>


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

#define ROLLOUT_SWIZZLE_DEFINITION_AREA
   #include "RolloutSwizzlerDynamic.include"
#undef ROLLOUT_SWIZZLE_DEFINITION_AREA

#pragma clang diagnostic pop


@implementation RolloutDynamic
+ (void) onApplicationStarts{
    
}
#ifndef ROLLOUT_TRANSPARENT





+(void)setup {
    #pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        
#define ROLLOUT_SWIZZLE_ACT_AREA 1
   #include "RolloutSwizzlerDynamic.include"
#undef ROLLOUT_SWIZZLE_ACT_AREA
        
#pragma clang diagnostic pop
   
}
#endif
@end


