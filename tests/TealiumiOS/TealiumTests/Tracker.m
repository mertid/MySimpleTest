//
//  Tracker.m
//  TealiumiOS
//
//  Created by Jason Koo on 11/12/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import "Tracker.h"

NSString *const TEALIUM_INSTANCE_ID = @"1";

@implementation Tracker

static Tracker * _sharedInstance;

+ (instancetype) sharedInstance {
    
    if (!_sharedInstance){
        _sharedInstance = [[Tracker alloc] init];
    }
    
    return _sharedInstance;
}

+ (void) startTracking {
    
    TEALConfiguration *configuration = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                           profile:@"demo"
                                                                       environment:@"dev"];
    
    configuration.pollingFrequency = TEALVisitorProfilePollingFrequencyOnRequest;
    
    //    configuration.overridePublishSettingsURL = @"http://tags.tiqcdn.com/utag/tealiummobile/demo/dev/mobile.html";
    
    Tealium *tealiumInstance1 = [Tealium newInstanceForKey:TEALIUM_INSTANCE_ID configuration:configuration];
    
    [tealiumInstance1 setDelegate:[Tracker sharedInstance]];
    
    [tealiumInstance1 removePersistentDataSourcesForKeys:@[@"somePersistKey"]];
    
    [tealiumInstance1 addVolatileDataSources:@{@"volatileKey":@"volatileValue"}];
    
}

+ (void) trackEventWithTitle:(NSString *)title dataSources:(NSDictionary *)data {
    
    [[Tealium instanceForKey:TEALIUM_INSTANCE_ID] trackEventWithTitle:title dataSources:data];
}

+ (void) trackViewWithTitle:(NSString *)title dataSources:(NSDictionary *)data {
    
    [[Tealium instanceForKey:TEALIUM_INSTANCE_ID] trackViewWithTitle:title dataSources:data];
}

+ (void) stopTracking{
    
    [Tealium destroyInstanceForKey:TEALIUM_INSTANCE_ID];
    
}

#pragma mark - TEALIUM DELEGATE

@end
