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

@interface Tealium() <TEALModulesDelegate>

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
    
    if ([[[self currentDispatchNetworkServices] copy] teal_containsObjectOfClass:[TEALTagDispatchService class]]){
        return;
    }

    TEALTagDispatchService *tagService = [self currentTagDispatchService];
    
    if (tagService) {
        [self.logger logVerbose:@"TagManagement enabled."];
    }

}

- (void) enableRemoteCommands {
    
    TEALTagDispatchService *service = [self currentTagDispatchService];
        
    [service.remoteCommandManager enable];
    
    [self.logger logVerbose:@"Remote Commands enabled."];

    [service.remoteCommandManager addReservedCommands:^(BOOL successful) {
        if (successful) {
            [self.logger logVerbose:@"Reserved Remote Commands enabled."];
        }
    }];
    
    
}

- (void) disableTagManagement {

#warning COMPLETE
    
}

- (void) disableRemoteCommands {
    
    TEALTagDispatchService *service = [self currentTagDispatchService];

    [service.remoteCommandManager disable];
}

#pragma mark - HELPERS

- (TEALTagDispatchService *) currentTagDispatchService {
    
    __block TEALTagDispatchService *targetService = nil;
    
    NSArray *dispatchServices = [[self currentDispatchNetworkServices] copy];
    
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
    
    if (!targetService) {
        
        targetService = [self newTagDispatchService];
        
        NSMutableArray *newServices = [NSMutableArray arrayWithArray:dispatchServices];
        
        [newServices addObject:targetService];
        
        [self setCurrentDispatchNetworkServices:[NSArray arrayWithArray:newServices]];
    }
    
    return targetService;
}

- (TEALTagDispatchService *) newTagDispatchService {
    
    TEALTagDispatchService *tagService = [[TEALTagDispatchService alloc] initWithPublishURLString:self.settings.publishURLString operationManager:self.operationManager];
    
    [tagService setup];
    
    
    return tagService;

}

#pragma mark - TEAL TAG DISPATCH SERVICE DELEGATE


@end
