//
//  WDCParties.m
//  WWDC
//
//  Created by Genady Okrain on 5/17/14.
//  Copyright (c) 2014 Sugar So Studio. All rights reserved.
//

#import "WDCParties.h"
#import "WDCParty.h"

@interface WDCParties ()

@property (strong, nonatomic) void (^block)(BOOL succeeded, NSArray *parties);
@property (assign, nonatomic) BOOL disableCache;

@end

@implementation WDCParties

+ (instancetype)sharedInstance
{
    static WDCParties *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[WDCParties alloc] init];
    });
    return sharedInstance;
}

- (void)refreshWithBlock:(void (^)(BOOL succeeded, NSArray *parties))block
{
    self.block = block;

    PFQuery *query = [WDCParty query];
    [query orderByAscending:@"startDate"];
    [query whereKeyExists:@"show"];
    if (!self.disableCache) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved %lu scores.", (unsigned long)objects.count);

            NSMutableArray *mutableParties = [[NSMutableArray alloc] init];
            for (WDCParty *party in objects) {
                [mutableParties addObject:party];
            }

            if (block) {
                block(YES, [mutableParties copy]);
            }
        } else {
            NSLog(@"Error: %@ %@", error, [error userInfo]);

            if (block) {
                block(NO, nil);
            }
        }
        self.disableCache = YES;
    }];
}

- (NSMutableArray *)going
{
    if (!_going) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"going"];
        if (data) {
            _going = [[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
        } else {
            _going = [[NSMutableArray alloc] init];
        }
    }
    return _going;
}

- (void)saveGoing
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.going];
    [userDefaults setObject:data forKey:@"going"];
    [userDefaults synchronize];
}

@end
