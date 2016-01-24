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
#import "TEALSettings+TagManagement.h"

@interface Tealium() <TEALTagDispatchServiceDelegate>

@end

@implementation Tealium (TagManagement)

#pragma mark - PUBLIC INSTANCE

- (UIWebView *) webView {
    
    TEALTagDispatchService *currentService = [self currentTagDispatchService];
    
    return currentService.webView;
    
}

- (void) addRemoteCommandId:(NSString*)name description:(NSString*)description targetQueue:(dispatch_queue_t)queue block:(TEALRemoteCommandResponseBlock)responseBlock {
    
    
    if (![self.settings tagManagementEnabled]){
        return;
    }
    
    TEALTagDispatchService *service = [self currentTagDispatchService];

    __block typeof(self) __weak weakSelf = self;

    if (!service){
        
        [weakSelf.logger logDev:@"Could not add Remote Command %@ at this time - Tag Management Service not yet ready.", name];


        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [weakSelf addRemoteCommandId:name
                             description:description
                             targetQueue:queue
                                   block:responseBlock];
        });
        return;
    }
    
    __block TEALRemoteCommandManager *remoteCommandManager = [service remoteCommandManager];
    
    if (!remoteCommandManager){
        
        [weakSelf.logger logDev:@"Could not add Remote Command %@ at this time - Remote Command Manager not ready", name];
        
        [weakSelf addRemoteCommandId:name
                         description:description
                         targetQueue:queue
                               block:responseBlock];
        
        return;
        
    }

    [self.operationManager addOperationWithBlock:^{
        
        BOOL added = [remoteCommandManager addRemoteCommandId:name
                                                  description:description
                                                  targetQueue:queue
                                                        block:responseBlock];
        
        if (added){
            [weakSelf.logger logDev:@"Added remote command %@.", name];
        }
    }];

    
}

#pragma mark - PRIVATE INSTANCE

- (void) updateTagManagement {
    
    if ([self.settings tagManagementEnabled]){
        
        [self enableTagManagement];
        
        if ([self.settings remoteCommandsEnabled]){
            
            [self enableRemoteCommands];
            
        } else {
            
            [self disableRemoteCommands];
            
        }
        
    } else {
        [self disableTagManagement];
        [self disableRemoteCommands];
    }
    
}

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
    
    if (![service.remoteCommandManager isEnabled]){
        
//        [self.logger logDev:@"Could not enable remote commands - check that Tag Management services enabled."];
        
        return;
    }
    
    [self.logger logDev:@"Remote Commands enabled."];

    __block typeof(self) __weak weakSelf = self;
    
    [service.remoteCommandManager addReservedCommands:^(BOOL successful) {
        
        if (successful) {
        
            [weakSelf.logger logDev:@"Reserved Remote Commands enabled."];
            
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
            if ([aService.publishURLStringCopy isEqualToString:[self.settings tagManagementPublishURLString]]){
                targetService = aService;
                *stop = YES;
            }
            
        }];
    }
    
    return targetService;
}

- (TEALTagDispatchService *) newTagDispatchService {
    
    TEALTagDispatchService *tagService = [[TEALTagDispatchService alloc] initWithPublishURLString:[self.settings tagManagementPublishURLString] operationManager:self.operationManager];
    
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
    
    [self.logger logDev:@"Processed remote command: %@ - payload: %@", response, response.requestPayload];
    
}

@end
