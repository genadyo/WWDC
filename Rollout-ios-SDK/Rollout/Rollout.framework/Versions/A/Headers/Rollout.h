//
//  Swiz.h
//  MoMe
//
//  Created by eyal keren on 3/6/14.
//  Copyright (c) 2014 eyal keren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Rollout : NSObject

+(void) setup: (NSString*) projectId debug: (BOOL) debug withTracker:(void (^)(NSDictionary *data))track;
+(void) setup: (NSString*) projectId debug: (BOOL) debug;

@end
