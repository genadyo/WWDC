//
//  RolloutInvocation.h
//  MoMe
//
//  Created by eyal keren on 5/21/14.
//  Copyright (c) 2014 eyal keren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RolloutTypeWrapper.h"

typedef IMP *IMPPointer;

@class RolloutActions;
@class RolloutActionProducer;

#define ROLLOUT_TYPE_WITH_SIZE(s) __rollout_type_ ## s
#define CREATE_ROLLOUT_TYPE_WITH_SIZE(s) typedef struct { unsigned char buff[s];} ROLLOUT_TYPE_WITH_SIZE(s);

typedef enum{
    RolloutInvocationTypeNormal = 0,
    RolloutInvocationTypeTryCatch,
    RolloutInvocationTypeDisable,
    RolloutInvocationTypesCount
} RolloutInvocationType;

extern  BOOL rollout_swizzleInstanceMethodAndStore(Class class, SEL original, IMP replacement, IMPPointer store) ;
extern  BOOL rollout_swizzleClassMethodAndStore(Class class, SEL original, IMP replacement, IMPPointer store) ;

@interface RolloutInvocation : NSObject

- (id)initWithConfiguration:(NSDictionary *)configuration actionProducer:(RolloutActionProducer *)actionProducer;

@property (nonatomic, readonly) NSDictionary *configuration;
@property (nonatomic, readonly) RolloutActions *actions;
@property (nonatomic, readonly) RolloutInvocationType type;

-(BOOL)satisfiesDynamicData:(RolloutInvocationDynamicData*)dynamicData;

- (void) runBefore;
- (void) runAfterExceptionCaught;

@property (nonatomic) NSArray *originalArguments;
@property (nonatomic) RolloutTypeWrapper* originalReturnValue;


-(NSArray*)tweakedArguments;
-(RolloutTypeWrapper*)conditionalReturnValue;
-(RolloutTypeWrapper *)disableReturnValue;
-(RolloutTypeWrapper *)tryCatchReturnValue;

@end

