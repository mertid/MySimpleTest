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
    
        NSLog(@"%s ", __FUNCTION__);
    
    [TealiumHelper startTracking];

    splitViewController.delegate = self;
    splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;

    return YES;
}

- (void) applicationDidBecomeActive:(UIApplication *)application {
        NSLog(@"%s", __FUNCTION__);
}


- (void) applicationWillEnterForeground:(UIApplication *)application{
        NSLog(@"%s ", __FUNCTION__);
}

#pragma mark - UISplitViewControllerDelegate

- (UISplitViewControllerDisplayMode)targetDisplayModeForActionInSplitViewController:(UISplitViewController *)splitViewController {
    return UISplitViewControllerDisplayModeAllVisible;
}

@end
