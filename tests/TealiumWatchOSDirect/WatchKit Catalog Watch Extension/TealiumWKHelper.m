//
//  TealiumHelper.m
//
//  Created by Jason Koo on 11/12/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import "TealiumWKHelper.h"
#import "TealiumWKExtension.h"

NSString *const TEALIUM_INSTANCE_ID = @"1";

@implementation TealiumWKHelper

static TealiumWKHelper * _sharedInstance;

+ (instancetype) sharedInstance {
    
    if (!_sharedInstance){
        _sharedInstance = [[TealiumWKHelper alloc] init];
    }
    
    return _sharedInstance;
}

+ (void) startTracking {
    
    // Make sure watch communications is up
    
    WCSession *session = [WCSession defaultSession];
    
//    if (![session delegate]){
//        [session setDelegate:[TealiumWKHelper sharedInstance]];
//    }
//    
//    [session activateSession];
    
    
    [session sendMessage:@{@"status":@"session_available"} replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
        
            NSLog(@"%s replyMessage: %@", __FUNCTION__, replyMessage);
        
    } errorHandler:^(NSError * _Nonnull error) {
        
            NSLog(@"%s error from session initial check: %@", __FUNCTION__, error);
        
    }];
    
    
    // Configure Tealium Extension to communicate with Tealium instance in iOS app
    TEALConfiguration *configuration = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                           profile:@"demo"
                                                                       environment:@"dev"];
    
    configuration.pollingFrequency = TEALVisitorProfilePollingFrequencyOnRequest;
        
    TealiumWKExtension *extension = [TealiumWKExtension newInstanceForKey:TEALIUM_INSTANCE_ID configuration:configuration];
    
    
//    [TealiumHelper incrementLifetimeValueForKey:@"launches" amount:1];

    
}

+ (void) trackEventWithTitle:(NSString *)title dataSources:(NSDictionary *)data {
    
    [[TealiumWKExtension instanceForKey:TEALIUM_INSTANCE_ID] trackEventWithTitle:title dataSources:data];
}

+ (void) trackViewWithTitle:(NSString *)title dataSources:(NSDictionary *)data {
    
    [[TealiumWKExtension instanceForKey:TEALIUM_INSTANCE_ID] trackViewWithTitle:title dataSources:data];
}

+ (void) stopTracking{
    
    [TealiumWKExtension destroyInstanceForKey:TEALIUM_INSTANCE_ID];
    
}

#pragma mark - EXAMPLE METHODS USING OTHER TEALIUM APIS

//+ (void) incrementLifetimeValueForKey:(NSString *)key amount:(int)number{
//    
//    NSDictionary *persistentData = [[Tealium instanceForKey:TEALIUM_INSTANCE_ID] persistentDataSourcesCopy];
//    
//    int oldNumber = [persistentData[key] intValue];
//    
//    int newNumber = oldNumber + number;
//    
//    [[Tealium instanceForKey:TEALIUM_INSTANCE_ID] addPersistentDataSources:@{key:@(newNumber)}];
//    
//    NSLog(@"%s Current lifetime value for %@ is: %i", __FUNCTION__, key, newNumber);
//    
//}


@end
