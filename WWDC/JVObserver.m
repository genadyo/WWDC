//
//  JVObserver.m
//  Jovie
//
//  Created by Elad Ben-Israel on 4/24/14.
//  Copyright (c) 2014 Jovie Inc. All rights reserved.
//

@import ObjectiveC;
#import "JVObserver.h"

@interface JVObserver ()

@property (copy, nonatomic) NSString *keyPath;
@property (copy, nonatomic) void(^block)(__weak id self);

@property (assign, nonatomic) id observee; // do not use zeroing ref here so we can remove observation
@property (weak, nonatomic) id target;

- (void)removeObserver;

@end

@interface JVObserverAutoremove : NSObject

@property (weak, nonatomic) JVObserver *observer;

@end

@implementation JVObserver

+ (instancetype)observerForObject:(id)observee keyPath:(NSString *)keyPath target:(id)weakself block:(void(^)(__weak id self))block
{
    if (!observee || keyPath.length == 0) {
        return nil;
    }

    JVObserver *observer = [[JVObserver alloc] init];
    observer.observee = observee;
    observer.keyPath = keyPath;
    observer.block = block;
    observer.target = weakself;
    
    // add self as observer to object
    [observee addObserver:observer forKeyPath:keyPath options:NSKeyValueObservingOptionInitial context:nil];
    
    // associate an object that will auto-remove the observer in case the observee deallocates
    JVObserverAutoremove *autorelease = [[JVObserverAutoremove alloc] init];
    autorelease.observer = observer;
    objc_setAssociatedObject(observee, (__bridge void*)observer, autorelease, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    return observer;
}

- (void)removeObserver
{
    [self.observee removeObserver:self forKeyPath:self.keyPath];
    self.observee = nil; // we must zero the reference because it's `assign`
}

- (void)dealloc
{
    [self removeObserver];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self.block) {
        if ([NSThread isMainThread]) {
            self.block(self.target);
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.block(self.target);
            });
        }
    }
}

@end

@implementation JVObserverAutoremove

- (void)dealloc
{
    [self.observer removeObserver];
}

@end