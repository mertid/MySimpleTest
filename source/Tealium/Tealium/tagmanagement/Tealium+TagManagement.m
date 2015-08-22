//
//  Tealium+TagManagement.m
//  Tealium
//
//  Created by Jason Koo on 8/20/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "Tealium+TagManagement.h"
#import "TEALTagDispatchService.h"
#import "NSArray+Tealium.h"
#import <objc/runtime.h>

BOOL const TEAL_MODULE_TAGMANAGEMENT_ENABLED = 1;

char const * const TEALIUM_KVO_TAGMANAGEMENT_WEBVIEW = "com.tealium.kvo.tagmanagement.webview";

@implementation Tealium (TagManagement)

- (void) enableTagManagement {
        NSLog(@"%s ", __FUNCTION__);
    [self tagManagement_enable];
}

- (UIWebView *) webView {
    
    if (![self.settings tagManagementEnabled]) {
        return nil;
    }
    
    __block UIWebView *webView = nil;

    dispatch_sync(dispatch_get_main_queue(), ^{
        id raw = objc_getAssociatedObject(self, TEALIUM_KVO_TAGMANAGEMENT_WEBVIEW)
        ;
        if ([raw isKindOfClass:([UIWebView class])]){
            webView = raw;
        }
        else {
            webView = [[UIWebView alloc] init];
            objc_setAssociatedObject(self, TEALIUM_KVO_TAGMANAGEMENT_WEBVIEW, webView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    });
    
    return webView;
}

- (void) tagManagement_enable {
    
    if ([[self.dispatchNetworkServices copy] teal_containsObjectOfClass:[TEALTagDispatchService class]]){
        return;
    }
    
    NSMutableArray *newServices = [NSMutableArray arrayWithArray:self.dispatchNetworkServices];
    
    TEALTagDispatchService *tagService = [[TEALTagDispatchService alloc] initWithPublishURLString:self.settings.publishURLString operationManager:self.operationManager];
    
    [tagService setup];

    [newServices addObject:tagService];
    
    self.dispatchNetworkServices = [NSArray arrayWithArray:newServices];
    
}

@end
