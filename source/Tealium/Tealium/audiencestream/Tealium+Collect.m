//
//  Tealium+Collect.m
//  Tealium
//
//  Created by Jason Koo on 8/20/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "Tealium+Collect.h"
#import "TEALVisitorProfileHelpers.h"
#import "TEALVisitorProfileStore.h"
#import "TEALCollectDispatchService.h"
#import "TEALError.h"
#import "NSArray+Tealium.h"
#import <objc/runtime.h>

char const * const TEALIUM_KVO_COLLECT_PROFILE = "com.tealium.kvo.collect.profile";
char const * const TEALIUM_KVO_COLLECT_PROFILESTORE = "com.tealium.kvo.collect.profilestore";

@implementation Tealium (Collect)

- (BOOL) collect_isEnabled {
    return [self.settings audienceStreamEnabled];
}

- (void) enableAudienceStream {
    
    if ([[self.dispatchNetworkServices copy] teal_containsObjectOfClass:[TEALCollectDispatchService class]]){
        return;
    }
    
    NSMutableArray *newServices = [NSMutableArray arrayWithArray:self.dispatchNetworkServices];
    
    TEALCollectDispatchService *dispatchService = [[TEALCollectDispatchService alloc] initWithDispatchURLString:[self.settings dispatchURLString] sessionManager:self.urlSessionManager];
    
    [dispatchService setup];
    
    [newServices addObject:dispatchService];
    
    self.dispatchNetworkServices = [NSArray arrayWithArray:newServices];
    
    [self.logger logVerbose:@"Audiencestream active."];

}

- (void) fetchVisitorProfileWithCompletion:(void (^)(TEALVisitorProfile *profile, NSError *error))completion {
    
    if (![self collect_isEnabled]) {
        if (completion){
            NSError *error = [TEALError errorWithCode:400 description:@"Fetch Visitor Profile request ignored." reason:@"Collect module not enabled." suggestion:@"Check Publish Settings."];
            completion(nil, error);
        }
        return;
    }
    
    __weak Tealium *weakSelf = self;
    
    [weakSelf.operationManager addOperationWithBlock:^{
        
        if (![weakSelf isEnabled]) {
            [weakSelf.logger logVerbose:@"Library Disabled, Ignoring: %s", __func__];
            return; // No fail log because these they should be logged once for each public method
        }
        
        if (![weakSelf.settings audienceStreamEnabled]) {
            [weakSelf.logger logVerbose:@"Audience Stream disabled, Ignoring: %s", __func__];
            if (completion) {
                
                completion(nil, nil);
            }
            
            return;
        }
        
        TEALVisitorProfileCompletionBlock storeCompletion = ^(TEALVisitorProfile *profile, NSError *error) {
            
            if (profile) {
                [weakSelf.logger logVerbose:@"got profile!!! : %@", profile];
                
                [weakSelf collect_setCachedProfile:profile];
                
                completion(weakSelf.collect_cachedProfile, nil);
                
            } else {
                [weakSelf.logger logVerbose:@"problem fetching profile: %@", [error localizedDescription]];
            }
        };
        [[weakSelf profileStore] fetchProfileWithCompletion:storeCompletion];
        
    }];
}


#pragma mark - PROFILE

- (void) collect_setCachedProfile:(TEALVisitorProfile*)profile {
    
    if (![self collect_isEnabled]) {
        return;
    }
    
    id profileRaw = objc_getAssociatedObject(self, TEALIUM_KVO_COLLECT_PROFILE);
    if (profileRaw) profileRaw = nil;
    
    objc_setAssociatedObject(self, TEALIUM_KVO_COLLECT_PROFILE, profile, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TEALVisitorProfile *) collect_cachedProfile {
    
    if (![self collect_isEnabled]) {
        return nil;
    }
    
    TEALVisitorProfile *profile = nil;
    
    id profileRaw = objc_getAssociatedObject(self, TEALIUM_KVO_COLLECT_PROFILE);
    
    if ([profileRaw isKindOfClass:([TEALVisitorProfile class])]){
        profile = profileRaw;
    }
    else {
        profile = [[TEALVisitorProfile alloc] initWithVisitorID:self.visitorIDCopy];
        objc_setAssociatedObject(self, TEALIUM_KVO_COLLECT_PROFILE, profile, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return profile;
}

- (TEALVisitorProfile *) cachedVisitorProfileCopy {
    
    if (![self collect_isEnabled]) {
        return nil;
    }
    
    @synchronized(self) {
        
        return [self.collect_cachedProfile copy];
    }
}

- (NSString *) visitorIDCopy {

    if (![self collect_isEnabled]) {
        return nil;
    }
    
    @synchronized(self) {
        return [self.dataSources visitorID];
    }
}

#pragma mark - PROFILESTORE

- (TEALVisitorProfileStore *) profileStore {
    
    if (![self collect_isEnabled]) {
        return nil;
    }
    
    TEALVisitorProfileStore *profileStore;
    
    id profileStoreRaw = objc_getAssociatedObject(self, TEALIUM_KVO_COLLECT_PROFILESTORE);
    if ([profileStoreRaw isKindOfClass:([TEALVisitorProfileStore class])]){
        profileStore = profileStoreRaw;
    }
    else {
        profileStore = [[TEALVisitorProfileStore alloc] initWithVisitorID:self.settings.visitorIDCopy profileURL:self.settings.profileURL profileDefinitionURL:self.settings.profileDefinitionsURL urlSessionManager:self.urlSessionManager];
        objc_setAssociatedObject(self, TEALIUM_KVO_COLLECT_PROFILESTORE, profileStore, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return profileStore;
}

#pragma mark - PROFILESTORE CONFIGURATION DELEGATE


- (NSURL *) profileURL {

    if (![self collect_isEnabled]) {
        return nil;
    }
    
    return [self.settings profileURL];
}

- (NSURL *) profileDefinitionURL {
    
    if (![self collect_isEnabled]) {
        return nil;
    }
    
    return [self.settings profileDefinitionsURL];
}

#pragma mark - TRACE

- (void) joinTraceWithToken:(NSString *)token {
    
    if (![self collect_isEnabled]) {
        return;
    }
    
    __weak Tealium *weakSelf = self;
    
    [weakSelf.operationManager addOperationWithBlock:^{
        if (![weakSelf isEnabled]) {
            TEAL_LogVerbose(@"Library Disabled, Ignoring: %s", __func__);
            return;
        }
        
        if (!token || ![token length]) {
            return;
        }
        
        weakSelf.settings.traceID = token;
    }];
    
}

- (void) leaveTrace {
    
    if (![self collect_isEnabled]) {
        return;
    }
    
    __weak Tealium *weakSelf = self;
    
    [weakSelf.operationManager addOperationWithBlock:^{
        if (![weakSelf isEnabled]) {
            TEAL_LogVerbose(@"Library Disabled, Ignoring: %s", __func__);
            return;
        }
        
        weakSelf.settings.traceID = nil;
    }];
    
}


@end
