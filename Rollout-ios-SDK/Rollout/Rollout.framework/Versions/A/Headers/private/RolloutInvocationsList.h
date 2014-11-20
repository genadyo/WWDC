//
// Created by Sergey Ilyevsky on 10/6/14.
// Copyright (c) 2014 DeDoCo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RolloutInvocation.h"

@class RolloutActionProducer;


@interface RolloutInvocationsList : NSObject

-(id)initWithConfiguration:(NSArray*)configuration actionsProducer:(RolloutActionProducer *)actionProducer;
-(RolloutInvocation *)invocationForArguments:(NSArray *)arguments;

@end