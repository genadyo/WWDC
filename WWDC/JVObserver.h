//
//  JVObserver.h
//  Jovie
//
//  Created by Elad Ben-Israel on 4/24/14.
//  Copyright (c) 2014 Jovie Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JVObserver : NSObject

+ (instancetype)observerForObject:(id)object keyPath:(NSString *)keyPath target:(id)weakself block:(void(^)(__weak id self))block;

@end