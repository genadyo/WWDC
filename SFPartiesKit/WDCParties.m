//
//  WDCParties.m
//  WWDC
//
//  Created by Genady Okrain on 5/17/14.
//  Copyright (c) 2014 Sugar So Studio. All rights reserved.
//

@import CloudKit;
#import "WDCParties.h"
#import "WDCParty.h"

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
    if (!self.disableCache) {
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.so.sugar.SFParties"];
        NSData *data = [userDefaults objectForKey:@"parties"];
        if (data && block) {
            block(YES, [NSKeyedUnarchiver unarchiveObjectWithData:data]);
        }
        self.disableCache = YES;
    }

    NSMutableArray *parties = [[NSMutableArray alloc] init];

    CKDatabase *publicDatabase = [[CKContainer defaultContainer] publicCloudDatabase];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"show = 1"];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Party" predicate:predicate];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES];
    query.sortDescriptors = @[sortDescriptor];

    CKQueryOperation *queryOperation = [[CKQueryOperation alloc] initWithQuery:query];
    queryOperation.desiredKeys = @[@"title", @"address1", @"address2", @"address3", @"details", @"startDate", @"endDate", @"location", @"url", @"show"];
    queryOperation.queuePriority = NSOperationQueuePriorityVeryHigh;

    queryOperation.recordFetchedBlock = ^(CKRecord *record) {
        WDCParty *party = [[WDCParty alloc] initWithCKRecord:record];

        if (![party isIconCached]) {
            [self getDataForRecordID:record.recordID desiredKey:@"icon" queuePriority:NSOperationQueuePriorityHigh block:^(NSData *data, NSError *error) {
                if (error) {
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                } else {
                    [party setIconWithData:data];
                }
            }];
        }

        if (![party isLogoCached]) {
            [self getDataForRecordID:record.recordID desiredKey:@"logo" queuePriority:NSOperationQueuePriorityNormal block:^(NSData *data, NSError *error) {
                if (error) {
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                } else {
                    [party setLogoWithData:data];
                }
            }];
        }

        [parties addObject:party];
    };

    queryOperation.queryCompletionBlock = ^(CKQueryCursor *cursor, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);

            if (block) {
                block(NO, nil);
            }
        } else {
            NSLog(@"Successfully retrieved %lu scores.", (unsigned long)parties.count);

            NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.so.sugar.SFParties"];
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[parties copy]];
            [userDefaults setObject:data forKey:@"parties"];
            [userDefaults synchronize];

            if (block) {
                block(YES, [parties copy]);
            }
        }
    };

    [publicDatabase addOperation:queryOperation];
}

- (void)getDataForRecordID:(CKRecordID *)RecordID desiredKey:(NSString *)desiredKey queuePriority:(NSOperationQueuePriority)queuePriority block:(void (^)(NSData *data, NSError *error))block
{
    CKDatabase *publicDatabase = [[CKContainer defaultContainer] publicCloudDatabase];

    CKFetchRecordsOperation *fetchRecordsIconOperation = [[CKFetchRecordsOperation alloc] initWithRecordIDs:@[RecordID]];
    fetchRecordsIconOperation.desiredKeys = @[desiredKey];
    fetchRecordsIconOperation.queuePriority = queuePriority;

    fetchRecordsIconOperation.perRecordCompletionBlock = ^(CKRecord *record, CKRecordID *recordID, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            if (block) {
                block(nil, error);
            }
        } else {
            if (block) {
                block([NSData dataWithContentsOfURL:[record[desiredKey] fileURL]], nil);
            }
        }
    };

    [publicDatabase addOperation:fetchRecordsIconOperation];
}

- (NSMutableArray *)going
{
    if (!_going) {
        NSData *data = [[[NSUserDefaults alloc] initWithSuiteName:@"group.so.sugar.SFParties"] objectForKey:@"going"];
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.so.sugar.SFParties"];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.going];
        [userDefaults setObject:data forKey:@"going"];

        // cache localy all the going parties for the watchkit extension
        data = [userDefaults objectForKey:@"parties"];
        if (data) {
            NSArray *parties = [NSKeyedUnarchiver unarchiveObjectWithData:data];

            // order by days
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            for (WDCParty *party in parties) {
                if (![dict objectForKey:[party sortDate]]) {
                    [dict setObject:[[NSMutableArray alloc] init] forKey:[party sortDate]];
                }
                [[dict objectForKey:[party sortDate]] addObject:party];
            }
            NSArray *sortedKeys = [[dict allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
            NSMutableArray *daysArray = [[NSMutableArray alloc] init];
            for (NSString *key in sortedKeys) {
                [daysArray addObject:[dict objectForKey:key]];
            }

            // filter going
            NSMutableArray *filteredPartiesMutable = [[NSMutableArray alloc] init];
            for (NSArray *array in daysArray) {
                for (WDCParty *party in array) {
                    if ([[WDCParties sharedInstance].going indexOfObject:party.objectId] != NSNotFound) {
                        [party shortDate];
                        [filteredPartiesMutable addObject:party];
                    }
                }
            }

            // save to disk
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:filteredPartiesMutable];
            [userDefaults setObject:data forKey:@"filteredParties"];
        }
        
        [userDefaults synchronize];
    });
}

- (NSArray *)filteredParties
{
    NSData *data = [[[NSUserDefaults alloc] initWithSuiteName:@"group.so.sugar.SFParties"] objectForKey:@"filteredParties"];
    if (data) {
        NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return array;
    }

    return @[];
}

@end
