//
//  Tracker.m
//  TealiumiOS
//
//  Created by Jason Koo on 11/12/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import "TealiumHelper.h"

// We only need one instance to demo
NSString *const TEALIUM_INSTANCE_ID = @"1";

@implementation TealiumHelper

static TealiumHelper * _sharedInstance;

+ (instancetype) sharedInstance {
    
    if ([self isTesting]){ return nil; }

    if (!_sharedInstance){
        _sharedInstance = [[TealiumHelper alloc] init];
    }
    
    return _sharedInstance;
}

+ (void) startTracking {

    if ([self isTesting]){
    
        NSLog(@"%s In test mode, application instance of tealium disabled.", __FUNCTION__);
        
        return;
    }
    
    Tealium *instance = [Tealium instanceForKey:TEALIUM_INSTANCE_ID];
    
    if (instance){
        return;
    }
    
    
    // Configure Tealium

    TEALConfiguration *configuration = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                           profile:@"demo"
                                                                       environment:@"qa"];
    
//    TEALConfiguration *configuration = [TEALConfiguration configurationWithAccount:@"services-crouse"
//                                                                           profile:@"mobile"
//                                                                       environment:@"dev"];
    
//    configuration.overrideCollectDispatchURL = @"https://datacloud.tealiumiq.com/vdata/i.gif?tealium_account=tealiummobile-tagbridge&tealium_profile=main";

//    configuration.overrideCollectDispatchURL = @"https://datacloud.tealiumiq.com/vdata/i.gif?tealium_account=tealiummobile&tealium_profile=main";

//    configuration.overrideS2SLegacyDispatchURL = @"testS2sOverrideURL";
    
//    configuration.overridePublishSettingsURL = @"http://localhost:4321/json/5/?minutes_between_refresh=0.0&enable_collect=true";

//    configuration.overrideS2SLegacyDispatchURL = @"https://www.test.com?";
    
//    configuration.overridePublishSettingsURL = @"https://jalakoo.github.io/tealium-ios/test_mps/5/all_dispatchers_ON.json";
    
//    configuration.overridePublishSettingsURL = @"https://chadhartman.github.io/tealium-ios/mps_collect_batch.json";
    
//    configuration.overridePublishSettingsURL = @"https://www.tealium.com/this_page_does_not_exists";

//    configuration.overridePublishSettingsURL = @"http://localhost:4321/json/5/?minutes_between_refresh=0.0&flux_key=_is_enabled&flux_values=true,false";

//    configuration.remoteCommandsEnabled = YES;
    
    configuration.collectPollingFrequency = TEALVisitorProfilePollingFrequencyOnRequest;
    
    Tealium *tealiumInstance1 = [Tealium newInstanceForKey:TEALIUM_INSTANCE_ID configuration:configuration];
    
    [tealiumInstance1 addVolatileDataSources:@{@"idfa":@"testIDFA",
                                               @"afterDelegateSet":@"NO"}];
    
    [tealiumInstance1 setDelegate:[TealiumHelper sharedInstance]];

    
    [tealiumInstance1 addVolatileDataSources:@{
                                               @"afterDelegateSet":@"YES"}];
    
    [tealiumInstance1 addPersistentDataSources:@{@"persistentKey":@"added"}];
    
    
    [tealiumInstance1 trackEventWithTitle:@"launch" dataSources:@{@"addWithLaunchCall":@"someValue"}];
    
    [tealiumInstance1 removePersistentDataSourcesForKeys:@[@"persistentKey"]];
    
//    [tealiumInstance1 trackEventWithTitle:@"anotherLaunchWherePersistentKeyShouldBeGone" dataSources:nil];

//
//    [tealiumInstance1 addVolatileDataSources:@{TEALDataSourceKey_Origin:@"newOrigin",
//                                               TEALDataSourceKey_Platform:@"mySoapBox"}];
//    
//    [[Tealium instanceForKey:@"1"] fetchVisitorProfileWithCompletion:^(TEALVisitorProfile * _Nullable profile, NSError * _Nullable error) {
//        
//            NSLog(@"%s profile:%@ error:%@", __FUNCTION__, profile, error);
//        
//    }];
}

+ (void) trackEventWithTitle:(NSString *)title dataSources:(NSDictionary *)data {
    
    if ([self isTesting]){ return; }

    [[Tealium instanceForKey:TEALIUM_INSTANCE_ID] trackEventWithTitle:title dataSources:data];
}

+ (void) trackViewWithTitle:(NSString *)title dataSources:(NSDictionary *)data {
    
    if ([self isTesting]){ return; }

    [[Tealium instanceForKey:TEALIUM_INSTANCE_ID] trackViewWithTitle:title dataSources:data];
}

+ (void) stopTracking{
    
    if ([self isTesting]){ return; }

    [Tealium destroyInstanceForKey:TEALIUM_INSTANCE_ID];
    
}

+ (void) joinTrace:(NSString * _Nonnull) traceID {
    
    [[Tealium instanceForKey:TEALIUM_INSTANCE_ID] joinTraceWithToken:traceID];

}

+ (void) leaveTrace {
 
    [[Tealium instanceForKey:TEALIUM_INSTANCE_ID] leaveTrace];
}

#pragma mark - TEALIUM DELEGATES

- (void) tealiumInstanceDidUpdatePublishSettings:(Tealium *)tealium {
    
        NSLog(@"%s: tealium instance: %@", __FUNCTION__, tealium);
    
}

#pragma mark - EXAMPLE METHODS USING OTHER TEALIUM APIS

+ (void) incrementLifetimeValueForKey:(NSString *)key amount:(int)number{
    
    if ([self isTesting]){ return; }

    NSDictionary *persistentData = [[Tealium instanceForKey:TEALIUM_INSTANCE_ID] persistentDataSourcesCopy];
    
    int oldNumber = [persistentData[key] intValue];

    int newNumber = oldNumber + number;
    
    [[Tealium instanceForKey:TEALIUM_INSTANCE_ID] addPersistentDataSources:@{key:@(newNumber)}];
    
    NSLog(@"%s Current lifetime value for %@ is: %i", __FUNCTION__, key, newNumber);
    
}

+ (void) enableRemoteCommandBlock {

    if ([self isTesting]){ return; }

    [[Tealium instanceForKey:TEALIUM_INSTANCE_ID]
     addRemoteCommandID:@"logger"
     description:@"An example remote command block"
     targetQueue:dispatch_get_main_queue()
     responseBlock:^(TEALRemoteCommandResponse * _Nullable response) {
        
        NSLog(@"%s response: %@", __FUNCTION__, response);
        // Put any code here that can execute on the main thread - ie content
        // modification, A/B testing, etc.
        
    }];
    
    [[Tealium instanceForKey:TEALIUM_INSTANCE_ID]
     addRemoteCommandID:@"flogger"
     description:@"An example remote command block"
     targetQueue:dispatch_get_main_queue()
     responseBlock:^(TEALRemoteCommandResponse * _Nullable response) {
         
         NSLog(@"%s response: %@", __FUNCTION__, response);
         // Put any code here that can execute on the main thread - ie content
         // modification, A/B testing, etc.
         
     }];
    
    [[Tealium instanceForKey:TEALIUM_INSTANCE_ID]
     addRemoteCommandID:@"blogger"
     description:@"An example remote command block"
     targetQueue:dispatch_get_main_queue()
     responseBlock:^(TEALRemoteCommandResponse * _Nullable response) {
         
         NSLog(@"%s response: %@", __FUNCTION__, response);
         // Put any code here that can execute on the main thread - ie content
         // modification, A/B testing, etc.
         
     }];
    
}

#pragma mark - WATCHKIT RESPONSE HANDLING

+ (void)session:(nonnull WCSession *)session
didReceiveMessage:(nonnull NSDictionary<NSString *,id> *)message
   replyHandler:(nullable void (^)(NSDictionary<NSString *,id> * _Nullable responseMessage))replyHandler {
    
    if ([self isTesting]){ return; }

    // Process only calls for messages targeting available Tealium instances
    if (![Tealium instanceAvailableForMessage:message]){
        return;
    }
    
    [[Tealium instanceForKey:TEALIUM_INSTANCE_ID] session:session didReceiveMessage:message replyHandler:replyHandler];
        
    
}

#pragma mark - TESTING

+ (BOOL) isTesting
{
    // Make sure target test arguments has "TESTING" value added to it's Environment variables
    NSDictionary* environment = [[NSProcessInfo processInfo] environment];
    return [environment objectForKey:@"TESTING"] != nil;
}
@end
