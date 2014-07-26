//
//  WDCParty.h
//  WWDC
//
//  Created by Genady Okrain on 5/17/14.
//  Copyright (c) 2014 Sugar So Studio. All rights reserved.
//

@import CloudKit;
@interface WDCParty : NSObject<NSCoding>

@property (readonly, strong, nonatomic) NSString *title;
@property (readonly, strong, nonatomic) NSString *details;
@property (readonly, strong, nonatomic) NSString *address1;
@property (readonly, strong, nonatomic) NSString *address2;
@property (readonly, strong, nonatomic) NSString *address3;
@property (readonly, strong, nonatomic) NSString *url;
@property (readonly, strong, nonatomic) NSNumber *latitude;
@property (readonly, strong, nonatomic) NSNumber *longitude;
@property (readonly, strong, nonatomic) UIImage *icon;
@property (readonly, strong, nonatomic) UIImage *logo;
@property (readonly, strong, nonatomic) NSDate *startDate;
@property (readonly, strong, nonatomic) NSDate *endDate;
@property (readonly, assign, nonatomic) BOOL show;
@property (readonly, strong, nonatomic) NSString *objectId;
@property (readonly, strong, nonatomic) NSString *sortDate;
@property (readonly, strong, nonatomic) NSString *date;
@property (readonly, strong, nonatomic) NSString *hours;

- (instancetype)initWithCKRecord:(CKRecord *)record;
- (void)setLogoWithData:(NSData *)data;
- (void)setIconWithData:(NSData *)data;
- (BOOL)isLogoCached;
- (BOOL)isIconCached;

@end