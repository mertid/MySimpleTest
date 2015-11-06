//
//  AppDelegate.m
//  TealiumTests
//
//  Created by George Webster on 7/15/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "AppDelegate.h"

#import <Tealium/iOS.h>

@interface AppDelegate () <TealiumDelegate>


@property (nonatomic, strong) Tealium *tealiumInstance;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
#ifndef TEST
    
    [self startupTealiumInstance1];
    
#endif
    
    return YES;
}

- (void) startupTealiumInstance1 {
    
    TEALConfiguration *configuration = [TEALConfiguration configurationWithAccount:@"tealiummobile"
                                                                           profile:@"demo"
                                                                       environment:@"dev"];
    
    configuration.pollingFrequency = TEALVisitorProfilePollingFrequencyOnRequest;
    
    //    configuration.overridePublishSettingsURL = @"http://tags.tiqcdn.com/utag/tealiummobile/demo/dev/mobile.html";
    
    Tealium *tealiumInstance1 = [Tealium newInstanceForKey:@"1" configuration:configuration];
    
    [tealiumInstance1 setDelegate:self];
    
    [tealiumInstance1 removePersistentDataSourcesForKeys:@[@"somePersistKey"]];
    
    [tealiumInstance1 addVolatileDataSources:@{@"volatileKey":@"volatileValue"}];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[Tealium instanceForKey:@"1"] trackEventWithTitle:@"sleep" dataSources:nil];

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [[Tealium instanceForKey:@"1"] trackEventWithTitle:@"wake" dataSources:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - TEALIUM DELEGATE

//- (BOOL) tealium:(Tealium *)tealium shouldDropDispatch:(TEALDispatch *)dispatch {
//
//    /**
//     *  Uncomment to test delegate suppression of dispatches
//     */
//    
////    NSDictionary *payload = dispatch.payload;
////    
////    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:dispatch.payload];
////    mDict[@"ClientAddedKey"] = @"clientAddedValue";
////    
////    dispatch.payload = [NSDictionary dictionaryWithDictionary:mDict];
////    
////    if ([payload[@"custom_key"] isEqualToString:@"custom_value_event"]) {
////        return NO;
////    }
////    return YES;
////    
//}

//- (BOOL) tealium:(Tealium *)tealium shouldQueueDispatch:(TEALDispatch *)dispatch {
//    return YES;
//}

- (void) tealium:(Tealium *)tealium didQueueDispatch:(TEALDispatch *)dispatch {
//    NSLog(@"%s %@ dispatch: %@", __FUNCTION__, tealium, dispatch);
}

- (void) tealium:(Tealium *)tealium didSendDispatch:(TEALDispatch *)dispatch {
//        NSLog(@"%s %@ dispatch: %@", __FUNCTION__, tealium, dispatch);
}

- (void) tealium:(Tealium *)tealium webViewIsReady:(UIWebView *)webView {
    
        NSLog(@"%s webViewReady: %@", __FUNCTION__, webView);
}
@end
