//
//  UIApplication+TealiumTracker.m
//  DigitalVelocity
//
//  Created by Jason Koo on 10/16/13.
//  Copyright (c) 2013 Tealium. All rights reserved.
//

#import "UIApplication+Tealium.h"
#import <objc/runtime.h>
#import "Tealium+Autotracking.h"
#import "Tealium+PrivateHeader.h"
#import "TEALDataSourceConstants.h"
#import "TEALDataSources+Autotracking.h"
#import "NSObject+Tealium.h"
#import "NSObject+TealiumAutotracking.h"

static BOOL alreadySwizzled;

@implementation UIApplication (Tealium)

void (*oSendEvent)(id, SEL, UIEvent *e);

+ (void) swizzleWithCompletion:(TEALBooleanCompletionBlock)completion {
    
    if (alreadySwizzled){
        return;
    }
    
    alreadySwizzled = true;
    
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
    
#warning OPTIMIZE
    
    // Extract target touch object
    NSSet *touches = e.allTouches;
    UITouch *touch = (UITouch*)[touches anyObject];
    id view = touch.view;

    if (e.type == UIEventTypeMotion || e.type == UIEventTypeTouches) {
        // TODO: mobile companion
    }
    
    // check for tracking viability - duplicate suppression
//    BOOL isViable = YES;
    
    if (touch.phase == UITouchPhaseEnded && view){
        
//        NSDate *now = [NSDate date];
//        if ([now compare:_lastEventTS] == NSOrderedAscending && _lastEvent == view) {
//            isViable = NO;
//        }
//        if (isViable &&
//            [view respondsToSelector:@selector(isUserInteractionEnabled)]){
//            isViable = [view isUserInteractionEnabled];
//        }
//        if (isViable){
        
            __weak UIView *weakTargetView = [self teal_viewToAutoTrack:view scanCount:0];
            
            if (weakTargetView) {
                
                [self teal_autotrackEvent:weakTargetView];
            }
//        }
//        
//        _lastEvent = view;
//        _lastEventTS = [NSDate dateWithTimeInterval:0.1 sinceDate:now];
    }
    
    // Forward event to original target object
    oSendEvent(self, _cmd, e);
}

- (void) teal_autotrackEvent:(UIView *)target {
    
    NSArray *validInstances = [Tealium allAutotrackingUIEventInstances];
 
#warning OPTIMIZE
    
    [validInstances enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if (![obj isKindOfClass:([Tealium class])]){
            return;
        }
        
        Tealium *instance = obj;
        
        NSMutableDictionary *dataSources = [NSMutableDictionary dictionary];

        // General object data
        [dataSources addEntriesFromDictionary:[target teal_autotrackDataSources]];
        
        // Lifecycle info
        if (instance.settings.autotrackingLifecycleEnabled) {
            [dataSources addEntriesFromDictionary:[instance currentLifecycleData]];
        }
        
        // Ivars
        if (instance.settings.autotrackingIvarsEnabled) {
            NSDictionary *ivars = [target teal_autotrackIvarDataSources];
            [dataSources addEntriesFromDictionary:ivars];
        }
        
        // Associated View
        NSString *associatedTitle = [TEALDataSources titleForViewEventWithObject:[instance activeViewController]];
        if (associatedTitle) {
            [dataSources addEntriesFromDictionary:@{TEALDataSourceKey_AssociatedViewTitle: associatedTitle}];
        }
        
        // Custom client data
        NSDictionary *customDataSources = [target teal_dataSources];
        [dataSources addEntriesFromDictionary:customDataSources];
        

        
        [instance trackEventWithTitle:nil
                          dataSources:dataSources];
        
    }];
    
}


- (UIView *) teal_viewToAutoTrack:(UIView *)view scanCount:(int)scanCount {

    NSString *vClass = NSStringFromClass([view class]);

//    NSLog(@"%s view:%@ vClass:%@", __FUNCTION__, view, vClass);
    
    if (![view teal_autotrackingEnabled]){
        return nil;
    }
    
    // if private skip and move up the chain
    if (![vClass hasPrefix:@"_"]) {
        if ([view isKindOfClass:[UIResponder class]]) return view;
        if ([[view gestureRecognizers] count]) return view;
        if ([view respondsToSelector:@selector(action)]) return view;
    }
    
    UIView *parent = view.superview;
    
    if (parent &&
        ![parent isKindOfClass:[UITableViewCell class]] &&
        scanCount < _maxScans){
        
        scanCount++;
        return [self teal_viewToAutoTrack:parent scanCount:scanCount];
        
    }
    
    return nil;
}

@end
