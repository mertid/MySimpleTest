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
    
    [TealiumHelper trackEventWithTitle:@"launch" dataSources:nil];
    
    [TealiumHelper incrementLifetimeValueForKey:@"launch" amount:1];
    
    return YES;
}

- (void) applicationDidEnterBackground:(UIApplication *)application {
    
    [TealiumHelper trackEventWithTitle:@"sleep" dataSources:nil];
    
    [TealiumHelper incrementLifetimeValueForKey:@"sleep" amount:1];

}

- (void) applicationWillEnterForeground:(UIApplication *)application{

    [TealiumHelper trackEventWithTitle:@"wake" dataSources:nil];
    
    [TealiumHelper incrementLifetimeValueForKey:@"wake" amount:1];

}
#pragma mark - UISplitViewControllerDelegate

- (UISplitViewControllerDisplayMode)targetDisplayModeForActionInSplitViewController:(UISplitViewController *)splitViewController {
    return UISplitViewControllerDisplayModeAllVisible;
}

@end
