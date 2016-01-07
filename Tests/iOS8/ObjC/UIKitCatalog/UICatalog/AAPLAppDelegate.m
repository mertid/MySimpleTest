/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The application-specific delegate class.
*/

#import "AAPLAppDelegate.h"

@interface AAPLAppDelegate() <UISplitViewControllerDelegate>
@end

@implementation AAPLAppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    
    splitViewController.delegate = self;
    splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
	
    NSString *accountName = @"tealiummobile";
    NSString *profileName = @"demo";
    NSString *environmentName = @"dev";
    
#ifndef TargetTypeNoLib

#ifdef TargetTypeCollect
    
    TEALCollectConfiguration *configuration = [TEALCollectConfiguration configurationWithAccount:accountName
                                                                                         profile:profileName
                                                                                     environment:environmentName];
    configuration.logLevel = TEALCollectLogLevelNone;
    
    [TealiumCollect enableWithConfiguration:configuration];
#else
    [Tealium initSharedInstance:accountName
                        profile:profileName
                         target:environmentName
                        options:TLSuppressLogs];
#endif

#endif
    return YES;
}

#pragma mark - UISplitViewControllerDelegate

- (UISplitViewControllerDisplayMode)targetDisplayModeForActionInSplitViewController:(UISplitViewController *)splitViewController {
    return UISplitViewControllerDisplayModeAllVisible;
}

@end
