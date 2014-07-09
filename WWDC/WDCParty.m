//
//  WDCParty.m
//  WWDC
//
//  Created by Genady Okrain on 5/17/14.
//  Copyright (c) 2014 Sugar So Studio. All rights reserved.
//

#import <TMCache/TMCache.h>
#import "WDCParty.h"

@interface WDCParty()

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *details;
@property (strong, nonatomic) NSString *address1;
@property (strong, nonatomic) NSString *address2;
@property (strong, nonatomic) NSString *address3;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSNumber *longitude;
@property (strong, nonatomic) UIImage *icon;
@property (strong, nonatomic) UIImage *logo;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (assign, nonatomic) BOOL show;
@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) NSString *sortDate;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *hours;

@end

@implementation WDCParty

- (instancetype)initWithCKRecord:(CKRecord *)record
{
    self = [super init];

    if (self) {
        self.title = record[@"title"];
        self.address1 = record[@"address1"];
        self.address2 = record[@"address2"];
        self.address3 = record[@"address3"];
        self.details = record[@"details"];
        self.startDate = record[@"startDate"];
        self.endDate = record[@"endDate"];
        self.latitude = [NSNumber numberWithDouble:((CLLocation *)record[@"location"]).coordinate.latitude];
        self.longitude = [NSNumber numberWithDouble:((CLLocation *)record[@"location"]).coordinate.longitude];
        self.show = [((NSNumber *)record[@"show"]) isEqualToNumber:[NSNumber numberWithInt:1]] ? YES : NO;
        self.url = record[@"url"];
        self.objectId = record.recordID.recordName;
        [self loadImagesFromCache];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];

    if (self) {
        self.title = [decoder decodeObjectForKey:@"title"];
        self.address1 = [decoder decodeObjectForKey:@"address1"];
        self.address2 = [decoder decodeObjectForKey:@"address2"];
        self.address3 = [decoder decodeObjectForKey:@"address3"];
        self.details = [decoder decodeObjectForKey:@"details"];
        self.startDate = [decoder decodeObjectForKey:@"startDate"];
        self.endDate = [decoder decodeObjectForKey:@"endDate"];
        self.latitude = [decoder decodeObjectForKey:@"latitude"];
        self.longitude = [decoder decodeObjectForKey:@"longitude"];
        self.show = [decoder decodeBoolForKey:@"show"];
        self.url = [decoder decodeObjectForKey:@"url"];
        self.objectId = [decoder decodeObjectForKey:@"objectId"];
        [self loadImagesFromCache];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.address1 forKey:@"address1"];
    [encoder encodeObject:self.address2 forKey:@"address2"];
    [encoder encodeObject:self.address3 forKey:@"address3"];
    [encoder encodeObject:self.details forKey:@"details"];
    [encoder encodeObject:self.startDate forKey:@"startDate"];
    [encoder encodeObject:self.endDate forKey:@"endDate"];
    [encoder encodeObject:self.latitude forKey:@"latitude"];
    [encoder encodeObject:self.longitude forKey:@"longitude"];
    [encoder encodeBool:self.show forKey:@"show"];
    [encoder encodeObject:self.url forKey:@"url"];
    [encoder encodeObject:self.objectId forKey:@"objectId"];
}

- (NSString *)iconCacheKey
{
    return [NSString stringWithFormat:@"icon-%@", self.objectId];
}

- (NSString *)logoCacheKey
{
    return [NSString stringWithFormat:@"logo-%@", self.objectId];
}

- (void)loadImagesFromCache
{
    [[TMCache sharedCache] objectForKey:[self iconCacheKey]
                                  block:^(TMCache *cache, NSString *key, id object) {
                                      self.icon = (UIImage *)object;
                                  }];

    [[TMCache sharedCache] objectForKey:[self logoCacheKey]
                                  block:^(TMCache *cache, NSString *key, id object) {
                                      self.logo = (UIImage *)object;
                                  }];
}

- (void)setLogoWithData:(NSData *)data
{
    self.logo = [[UIImage alloc] initWithData:data scale:[UIScreen mainScreen].scale];
    [[TMCache sharedCache] setObject:self.logo forKey:[self logoCacheKey] block:nil];
}

- (void)setIconWithData:(NSData *)data
{
    self.icon = [[UIImage alloc] initWithData:data scale:[UIScreen mainScreen].scale];
    [[TMCache sharedCache] setObject:self.icon forKey:[self iconCacheKey] block:nil];
}

- (NSString *)sortDate
{
    if (!_sortDate) {
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:locale];
        [dateFormatter setDateFormat:@"d"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PDT"]];
        return [dateFormatter stringFromDate:self.startDate];
    }
    return _sortDate;
}

- (NSString *)date
{
    if (!_date) {
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:locale];
        [dateFormatter setDateFormat:@"EEEE, MMMM d"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PDT"]];
        _date = [dateFormatter stringFromDate:self.startDate];
    }
    return _date;
}

- (NSString *)hours
{
    if (!_hours) {
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        NSDateFormatter *dateFormatterStart = [[NSDateFormatter alloc] init];
        [dateFormatterStart setLocale:locale];
        [dateFormatterStart setDateFormat:@"h:mm a"];
        [dateFormatterStart setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PDT"]];
        NSDateFormatter *dateFormatterEnd = [[NSDateFormatter alloc] init];
        [dateFormatterEnd setLocale:locale];
        [dateFormatterEnd setDateFormat:@"h:mm a"];
        [dateFormatterEnd setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PDT"]];
        _hours = [NSString stringWithFormat:@"%@ to %@", [dateFormatterStart stringFromDate:self.startDate], [dateFormatterEnd stringFromDate:self.endDate]];
    }
    return _hours;
}

@end