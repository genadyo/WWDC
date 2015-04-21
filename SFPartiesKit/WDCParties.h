//
//  WDCParties.h
//  WWDC
//
//  Created by Genady Okrain on 5/17/14.
//  Copyright (c) 2014 Sugar So Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDCParties : NSObject

+ (instancetype)sharedInstance;
- (void)refreshWithBlock:(void (^)(BOOL succeeded, NSArray *parties))block;
- (void)saveGoing;

@property (assign, nonatomic) BOOL disableCache;
@property (readonly, strong, nonatomic) NSArray *filteredParties;

@end
