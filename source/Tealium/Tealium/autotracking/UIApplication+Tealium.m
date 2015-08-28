//
//  UIApplication+TealiumTracker.m
//  DigitalVelocity
//
//  Created by Jason Koo on 10/16/13.
//  Copyright (c) 2013 Tealium. All rights reserved.
//

#import "UIApplication+Tealium.h"
#import <objc/runtime.h>
#import "Tealium.h"
#import "TEALDataSourceConstants.h"
#import "TEALDataSources+Autotracking.h"
#import "NSObject+Tealium.h"
#import "NSObject+TealiumAutotracking.h"

@implementation UIApplication (Tealium)

void (*oSendEvent)(id, SEL, UIEvent *e);

+ (void) swizzleWithCompletion:(TEALBooleanCompletionBlock)completion {
    
    Method origMethod1 = class_getInstanceMethod(self, @selector(sendEvent:));
    oSendEvent = (void *)method_getImplementation(origMethod1);
    if(!class_addMethod(self, @selector(sendEvent:), (IMP)teal_sendEvent, method_getTypeEncoding(origMethod1))) method_setImplementation(origMethod1, (IMP)teal_sendEvent);
    
    if (completion) completion(YES, nil);
}

// duplicate suppression
static id     _lastEvent;
static NSDate *_lastEventTS;
static int _maxScans = 6;

static void teal_sendEvent(UIApplication *self, SEL _cmd, UIEvent *e) {
    
    // Extract target touch object
    NSSet *touches = e.allTouches;
    UITouch *touch = (UITouch*)[touches anyObject];
    id view = touch.view;

    if (e.type == UIEventTypeMotion || e.type == UIEventTypeTouches) {
        // TODO: mobile companion
    }
    
    // check for tracking viability - duplicate suppression
    BOOL isViable = YES;
    
    if (touch.phase == UITouchPhaseEnded && view){
        NSDate *now = [NSDate date];
            NSLog(@"%s now:%@", __FUNCTION__, now);
        if ([now compare:_lastEventTS] == NSOrderedAscending && _lastEvent == view) {
            isViable = NO;
        }
        if (isViable &&
            [view respondsToSelector:@selector(isUserInteractionEnabled)]){
            isViable = [view isUserInteractionEnabled];
        }
        if (isViable){
            
            __weak UIView *weakTargetView = [self teal_viewToAutoTrack:view scanCount:0];
            
            if (weakTargetView) {
                [self teal_autotrackEvent:weakTargetView];
            }
        }
        
        _lastEvent = view;
        _lastEventTS = [NSDate dateWithTimeInterval:0.1 sinceDate:now];
    }
    
    // Forward event to original target object
    oSendEvent(self, _cmd, e);
}

- (void) teal_autotrackEvent:(UIView *)target {
    
    if (![target teal_autotrackingEnabled]){
        return;
    }
    
    if (![Tealium sharedInstance].settings.autotrackingUIEventsEnabled){
        return;
    }
    
    // Includes eventTitle
    NSDictionary *autoDataSources = [TEALDataSources autotrackDataSourcesForDispatchType:TEALDispatchTypeEvent withObject:target];
    
    NSMutableDictionary *dataSources = [NSMutableDictionary dictionaryWithDictionary:autoDataSources];
    
    NSDictionary *ivars = [target teal_autotrackIvarDataSources];
    [dataSources addEntriesFromDictionary:ivars];
    
    NSDictionary *customDataSources = [target teal_dataSources];
    [dataSources addEntriesFromDictionary:customDataSources];

    
    [[Tealium sharedInstance] trackEventWithTitle:nil
                                      dataSources:dataSources];
    
}


- (UIView *) teal_viewToAutoTrack:(UIView *)view scanCount:(int)scanCount {

    NSString *vClass = NSStringFromClass([view class]);

    // if private skip and move up the chain
    if (![vClass hasPrefix:@"_"]) {
        if ([view isKindOfClass:[UIControl class]]) return view;
        if ([[view gestureRecognizers] count]) return view;
    }
    
    UIView *parent = view.superview;
    
    if (parent && ![parent isKindOfClass:[UITableViewCell class]] && scanCount < _maxScans){
        scanCount++;
        return [self teal_viewToAutoTrack:parent scanCount:scanCount];
    }
    return nil;
}

@end
