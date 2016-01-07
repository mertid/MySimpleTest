//
//  TEALViewScanner.m
//  Tealium
//
//  Created by Jason Koo on 9/14/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import "TEALViewScanner.h"

@implementation TEALViewScanner

+ (UIViewController*) rootWindowController{
    UIWindow *window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    UIViewController *vc = [TEALViewScanner rootControllerForController:window.rootViewController];
    
    return vc;
}

+ (UIViewController *) rootControllerForController:(UIViewController *)viewController {
    
    if ([viewController respondsToSelector:@selector(rootViewController)]){
        return [TEALViewScanner rootControllerForController:viewController];
    }
    else if ([viewController respondsToSelector:@selector(selectedViewController)]){
        UIViewController *newViewController = [viewController performSelector:@selector(selectedViewController)];
        return [TEALViewScanner rootControllerForController:newViewController];
    }
    else if ([viewController respondsToSelector:@selector(visibleViewController)]){
        UIViewController *newViewController = [viewController performSelector:@selector(visibleViewController)];
        return [TEALViewScanner rootControllerForController:newViewController];
    }
    return viewController;

}

@end
