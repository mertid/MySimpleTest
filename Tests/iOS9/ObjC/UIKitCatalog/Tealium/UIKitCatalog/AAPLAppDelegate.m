/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The application-specific delegate class.
*/

#import "AAPLAppDelegate.h"
#import "TealiumHelper.h"

@interface AAPLAppDelegate() <UISplitViewControllerDelegate>
@end

@implementation AAPLAppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    
    splitViewController.delegate = self;
    splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;

    [TealiumHelper startTracking];

    
//    Tealium *tealiumInstance1 = [Tealium instanceForKey:@"1"];
//    
//    [tealiumInstance1 addVolatileDataSources:@{@"zzz":@"testValue"}];

    
    [TealiumHelper trackEventWithTitle:@"launch" dataSources:nil];
    
    [TealiumHelper incrementLifetimeValueForKey:@"launches" amount:1];
    
    [TealiumHelper enableRemoteCommandBlock];

    
    return YES;
}

- (void) applicationDidEnterBackground:(UIApplication *)application {
    
    [TealiumHelper trackEventWithTitle:@"sleep" dataSources:nil];
    
    [TealiumHelper incrementLifetimeValueForKey:@"sleeps" amount:1];

}

- (void) applicationWillEnterForeground:(UIApplication *)application{

    [TealiumHelper trackEventWithTitle:@"wake" dataSources:nil];
    
    [TealiumHelper incrementLifetimeValueForKey:@"wakes" amount:1];

}
#pragma mark - UISplitViewControllerDelegate

- (UISplitViewControllerDisplayMode)targetDisplayModeForActionInSplitViewController:(UISplitViewController *)splitViewController {
    return UISplitViewControllerDisplayModeAllVisible;
}

@end
