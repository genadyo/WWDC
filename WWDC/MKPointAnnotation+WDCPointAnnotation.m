//
//  MKPointAnnotation+WDCPointAnnotation.m
//  SFParties
//
//  Created by Genady Okrain on 4/30/16.
//  Copyright © 2016 Okrain. All rights reserved.
//

#import "MKPointAnnotation+WDCPointAnnotation.h"
#import <objc/runtime.h>

static const char kPartyKey;

@implementation MKPointAnnotation (WDCPointAnnotation)

- (NSNumber *)partyIndex {
    return objc_getAssociatedObject(self, &kPartyKey);
}

- (void)setPartyIndex:(NSNumber *)partyIndex {
    objc_setAssociatedObject(self, &kPartyKey, partyIndex, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end