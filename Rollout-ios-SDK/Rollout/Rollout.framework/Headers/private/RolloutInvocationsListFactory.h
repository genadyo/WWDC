//
//  RolloutInvocationsListFactory.h
//  Rollout
//
//  Created by Sergey Ilyevsky on 9/17/14.
//  Copyright (c) 2014 DeDoCo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RolloutInvocationsList.h"

@class RolloutActionProducer;
@class RolloutConfiguration;

@interface RolloutInvocationsListFactory : NSObject

+ (void)setupWithConfiguration:(RolloutConfiguration *)configuration withProducer: (RolloutActionProducer*) producer;

+ (RolloutInvocationsList *)invocationsListForInstanceMethod:(NSString *)method forClass:(NSString*) clazz;
+ (RolloutInvocationsList *)invocationsListForClassMethod:(NSString *)method forClass:(NSString*) clazz;
+ (RolloutInvocationsList *)invocationsListFromConfiguration:(NSArray*)configuration;

+ (void) markInstanceSwizzle:(NSString*) method forClass:(NSString*) clazz;
+ (void) markClassSwizzle:(NSString*) method forClass:(NSString*) clazz;

+ (BOOL) shouldSetupInstanceSwizzle:(NSString*) method forClass:(NSString*) clazz;
+ (BOOL) shouldSetupClassSwizzle:(NSString*) method forClass:(NSString*) clazz;

@end
