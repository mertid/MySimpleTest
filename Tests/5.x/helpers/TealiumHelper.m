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

    if ([self isTesting]){ return; }
    
    Tealium *instance = [Tealium instanceForKey:TEALIUM_INSTANCE_ID];
    
    if (instance){
        return;
    }
    
    // Configure Tealium
    
    TEALConfiguration *configuration = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                           profile:@"demo"
                       environment:@"dev"];
    
//    configuration.overrideCollectDispatchURL = @"https://test.overide.com";
    
//    configuration.overrideS2SLegacyDispatchURL = @"testS2sOverrideURL";
    
//    configuration.overridePublishSettingsURL = @"https://tags.tiqcdn.com/utag/tealiummobile/ios/dev/mobile.html";
    
    configuration.remoteCommandsEnabled = YES;
    
    configuration.collectPollingFrequency = TEALVisitorProfilePollingFrequencyOnRequest;
    
    Tealium *tealiumInstance1 = [Tealium newInstanceForKey:TEALIUM_INSTANCE_ID configuration:configuration];
    
    [tealiumInstance1 setDelegate:[TealiumHelper sharedInstance]];
    
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

    [[Tealium instanceForKey:TEALIUM_INSTANCE_ID] addRemoteCommandId:@"testCommand"
        description:@"An example remote command block"
        targetQueue:dispatch_get_main_queue()
        block:^(TEALRemoteCommandResponse * _Nullable response) {
        
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
    // Make sure target test arguments has this value added to it's Environment variables
    NSDictionary* environment = [[NSProcessInfo processInfo] environment];
    return [environment objectForKey:@"TESTING"] != nil;
}
@end
