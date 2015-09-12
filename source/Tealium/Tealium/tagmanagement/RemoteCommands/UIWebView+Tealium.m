//
//  UIWebView+Tealium.m
//  Tealium
//
//  Created by Jason Koo on 8/25/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "UIWebView+Tealium.h"
#import <objc/runtime.h>

char const * const TEALKVOAutotrackWebViewRemoteCommand = "com.tealium.kvo.webview.remotecommand.enable";

@implementation UIWebView (Tealium)


- (BOOL) teal_areRemoteCommandsEnabled {
    NSNumber *enableOnNumber = objc_getAssociatedObject(self, &TEALKVOAutotrackWebViewRemoteCommand);
    if (enableOnNumber){
        return [enableOnNumber boolValue];
    }
    return YES;
}

- (void) teal_setAreRemoteCommandsEnabled:(BOOL) enable {
    
    NSNumber *enableOnNumber = @(enable);
    objc_setAssociatedObject(self, &TEALKVOAutotrackWebViewRemoteCommand, enableOnNumber, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
}

@end
