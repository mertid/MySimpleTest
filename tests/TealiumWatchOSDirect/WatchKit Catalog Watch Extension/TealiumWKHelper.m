//
//  TealiumHelper.m
//
//  Created by Jason Koo on 11/12/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import "TealiumWKHelper.h"

@import WatchConnectivity;

// Tealium supports multiple instances, but if only using one, can use a constant
NSString * const TEALIUM_INSTANCE_ID = @"1";

@implementation TealiumWKHelper

static TealiumWKHelper * _sharedInstance;

#pragma mark - PUBLIC

+ (void) trackEventWithTitle:(NSString *)title dataSources:(NSDictionary *)data {
    
    [TealiumWKHelper startTracking];
    
    [[TEALWKExtension instanceForKey:TEALIUM_INSTANCE_ID] trackEventWithTitle:title dataSources:data];
}

+ (void) trackViewWithTitle:(NSString *)title dataSources:(NSDictionary *)data {
    
    [TealiumWKHelper startTracking];
    
    [[TEALWKExtension instanceForKey:TEALIUM_INSTANCE_ID] trackViewWithTitle:title dataSources:data];
}

+ (void) setDelegate:(id<TEALWKExtensionDelegate>)delegate {
    
    [[TEALWKExtension instanceForKey:TEALIUM_INSTANCE_ID] setDelegate:delegate];
    
}

#pragma mark - PRIVATE

+ (instancetype) sharedInstance {
    
    if (!_sharedInstance){
        _sharedInstance = [[TealiumWKHelper alloc] init];
    }
    
    return _sharedInstance;
}

+ (void) startTracking {
    
    // Edit below for supporting more than one instance
    if ([TEALWKExtension instanceForKey:TEALIUM_INSTANCE_ID]) {
        return;
    }
    
    TEALWKExtensionConfiguration *config = [TEALWKExtensionConfiguration configuration];
    
    config.logLevel = TEALWKLogLevelDev;
    
    [TEALWKExtension newInstanceForKey:TEALIUM_INSTANCE_ID configuration:config];
    
}

#pragma mark - SAMPLE

// Implement a public method like this if providing a disable tracking option.
+ (void) stopTracking{
    
    [TEALWKExtension destroyInstanceForKey:TEALIUM_INSTANCE_ID];
    
}


@end
