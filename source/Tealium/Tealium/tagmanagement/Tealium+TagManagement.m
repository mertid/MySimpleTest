//
//  Tealium+TagManagement.m
//  Tealium
//
//  Created by Jason Koo on 8/20/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//


#import "NSArray+Tealium.h"
#import "NSString+Tealium.h"
#import <objc/runtime.h>
#import "Tealium+TagManagement.h"
#import "Tealium+PrivateHeader.h"
#import "TEALModulesDelegate.h"
#import "TEALNetworkHelpers.h"
#import "TEALTagDispatchService.h"
#import "TEALRemoteCommandConstants.h"
#import "TEALRemoteCommandManager.h"

@interface Tealium() <TEALModulesDelegate, TEALTagDispatchServiceDelegate>

@end

@implementation Tealium (TagManagement)

#pragma mark - PUBLIC INSTANCE

- (UIWebView *) webView {
    
    
    TEALTagDispatchService *currentService = [self currentTagDispatchService];
    
    return currentService.webView;
    
}

- (void) addRemoteCommandId:(NSString*)name description:(NSString*)description targetQueue:(dispatch_queue_t)queue block:(TEALRemoteCommandResponseBlock)responseBlock {
 
    [self.operationManager addOperationWithBlock:^{
       
        TEALTagDispatchService *service = [self currentTagDispatchService];
                
        [[service remoteCommandManager] addRemoteCommandId:name
                                               description:description
                                               targetQueue:queue
                                                     block:responseBlock];
    }];

    
}


#pragma mark - PRIVATE INSTANCE

- (void) enableTagManagement {
    
    if ([[[self currentDispatchServices] copy] teal_containsObjectOfClass:[TEALTagDispatchService class]]){
        return;
    }

    TEALTagDispatchService *tagService = [self currentTagDispatchService];
    [tagService.remoteCommandManager enable];
    
    if (!tagService){
        tagService = [self newTagDispatchService];
        [self addNewDispatchService:tagService];
    }
        
    if (tagService) {
        [self.logger logDev:@"TagManagement enabled."];
    }

}

- (void) enableRemoteCommands {
    
    TEALTagDispatchService *service = [self currentTagDispatchService];
        
    [service.remoteCommandManager enable];
    
    [self.logger logDev:@"Remote Commands enabled."];

    [service.remoteCommandManager addReservedCommands:^(BOOL successful) {
        if (successful) {
            [self.logger logDev:@"Reserved Remote Commands enabled."];
        }
    }];
    
}

- (void) disableTagManagement {

    
    TEALTagDispatchService *service = [self currentTagDispatchService];
    
    [service.remoteCommandManager disable];
    
    
}

- (void) disableRemoteCommands {
    
    TEALTagDispatchService *service = [self currentTagDispatchService];

    [service.remoteCommandManager disable];
}

#pragma mark - HELPERS

- (TEALTagDispatchService *) currentTagDispatchService {
    
    __block TEALTagDispatchService *targetService = nil;
    
    NSArray *dispatchServices = [[self currentDispatchServices] copy];
    
    if (dispatchServices) {
        
        [dispatchServices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            if (![obj isMemberOfClass:([TEALTagDispatchService class])]){
                return;
            }
            
            TEALTagDispatchService *aService = obj;
            if ([aService.publishURLStringCopy isEqualToString:self.settings.publishURLString]){
                targetService = aService;
                *stop = YES;
            }
            
        }];
    }
    
    return targetService;
}

- (TEALTagDispatchService *) newTagDispatchService {
    
    TEALTagDispatchService *tagService = [[TEALTagDispatchService alloc] initWithPublishURLString:self.settings.publishURLString operationManager:self.operationManager];
    
    [tagService setDelegate:self];
    
    [tagService setup];
    
    return tagService;

}

#pragma mark - TEAL TAG DISPATCH SERVICE DELEGATE

- (void) tagDispatchServiceWebViewReady:(UIWebView *)webView {
    
    if ([self.delegate respondsToSelector:@selector(tealium:webViewIsReady:)]) {
        
        [self.delegate tealium:self webViewIsReady:webView];
    }
}

- (void) tagDispatchServiceWebView:(UIWebView*)webView encounteredError:(NSError *)error {
    
    [self.logger logQA:@"Tag Management Webview error: %@", error];
    
}

- (void) tagDispatchServiceWebView:(UIWebView*)webView processedCommandResponse:(TEALRemoteCommandResponse *)response{
    
    [self.logger logDev:@"Processed remote command: %@", response];
    
}

@end
