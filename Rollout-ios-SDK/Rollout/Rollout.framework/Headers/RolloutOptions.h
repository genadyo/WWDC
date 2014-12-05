//
// Created by Sergey Ilyevsky on 11/19/14.
// Copyright (c) 2014 DeDoCo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RolloutTracker)(NSDictionary *data);

@interface RolloutOptions : NSObject

@property (nonatomic, copy) RolloutTracker tracker;
@property (nonatomic) BOOL disableSyncLoadingFallback;

@end