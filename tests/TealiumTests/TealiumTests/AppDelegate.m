//
//  AppDelegate.m
//  TealiumTests
//
//  Created by George Webster on 7/15/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "AppDelegate.h"

#import <Tealium/Tealium.h>

@interface AppDelegate () <TealiumDelegate>


@property (strong, nonatomic) Tealium *tealiumInstance;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
#ifndef TEST
    TEALConfiguration *configuration = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                           profile:@"non-exists"
                                                                       environment:@"dev"];
    
    configuration.logLevel = TEALLogLevelExtremeVerbosity;
    configuration.pollingFrequency = TEALVisitorProfilePollingFrequencyOnRequest;
    configuration.lifecycleEnabled = YES;
    configuration.autotrackingUIEventsEnabled = NO;
    configuration.autotrackingViewsEnabled = NO;
//    configuration.overridePublishSettingsURL = @"http://tags.tiqcdn.com/utag/tealiummobile/demo/dev/mobile.html";
    
//    self.tealiumInstance = [Tealium instanceWithConfiguration:configuration];
//    
//    [self.tealiumInstance trackEventWithTitle:@"testInstanceLaunch" dataSources:nil];
    
    [Tealium sharedInstanceWithConfiguration:configuration];
    [[Tealium sharedInstance] setDelegate:self];
    
    
    if (configuration.autotrackingUIEventsEnabled == NO){
        [[Tealium sharedInstance] trackEventWithTitle:@"testSharedInstanceLaunch" dataSources:nil];
    }
    
#endif
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - TEALIUM DELEGATE

- (BOOL) tealium:(Tealium *)tealium shouldSendDispatch:(TEALDispatch *)dispatch {
//        NSLog(@"%s dispatch: %@", __FUNCTION__, dispatch);
    
    NSDictionary *payload = dispatch.payload;
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:dispatch.payload];
    mDict[@"ClientAddedKey"] = @"clientAddedValue";
    
    dispatch.payload = [NSDictionary dictionaryWithDictionary:mDict];
    
    if ([payload[@"custom_key"] isEqualToString:@"custom_value_event"]) {
        return NO;
    }
    
    return YES;
}

- (void) tealium:(Tealium *)tealium didQueueDispatch:(TEALDispatch *)dispatch {
    NSLog(@"%s dispatch: %@", __FUNCTION__, dispatch);
}

- (void) tealium:(Tealium *)tealium didSendDispatch:(TEALDispatch *)dispatch {
        NSLog(@"%s dispatch: %@", __FUNCTION__, dispatch);
}
@end
