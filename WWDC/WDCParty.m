//
//  WDCParty.m
//  WWDC
//
//  Created by Genady Okrain on 5/17/14.
//  Copyright (c) 2014 Sugar So Studio. All rights reserved.
//

#import "WDCParty.h"
#import <PFObject+Subclass.h>

@implementation WDCParty

@dynamic title;
@dynamic icon;
@dynamic logo;
@dynamic details;
@dynamic address1;
@dynamic address2;
@dynamic address3;
@dynamic url;
@dynamic latitude;
@dynamic longitude;
@dynamic endDate;
@dynamic startDate;

+ (NSString *)parseClassName
{
    return @"WDCParty";
}

- (NSString *)sortDate
{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"d"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PDT"]];
    return [dateFormatter stringFromDate:self.startDate];
}

- (NSString *)date
{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"EEEE, MMMM d"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PDT"]];
    return [dateFormatter stringFromDate:self.startDate];
}

- (NSString *)hours
{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSDateFormatter *dateFormatterStart = [[NSDateFormatter alloc] init];
    [dateFormatterStart setLocale:locale];
    [dateFormatterStart setDateFormat:@"h:mm a"];
    [dateFormatterStart setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PDT"]];
    NSDateFormatter *dateFormatterEnd = [[NSDateFormatter alloc] init];
    [dateFormatterEnd setLocale:locale];
    [dateFormatterEnd setDateFormat:@"h:mm a"];
    [dateFormatterEnd setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PDT"]];
    return [NSString stringWithFormat:@"%@ to %@", [dateFormatterStart stringFromDate:self.startDate], [dateFormatterEnd stringFromDate:self.endDate]];
}

@end