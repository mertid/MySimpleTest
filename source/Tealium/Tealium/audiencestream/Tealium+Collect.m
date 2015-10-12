//
//  Tealium+Collect.m
//  Tealium
//
//  Created by Jason Koo on 8/20/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "Tealium+Collect.h"
#import "Tealium+PrivateHeader.h"
#import "TEALVisitorProfileHelpers.h"
#import "TEALVisitorProfileStore.h"
#import "TEALCollectDispatchService.h"
#import "TEALError.h"
#import "NSArray+Tealium.h"
#import <objc/runtime.h>

char const * const TEALKVOAutotrackCollectProfile = "com.tealium.kvo.collect.profile";
char const * const TEALKVOAutotrackCollectProfileStore = "com.tealium.kvo.collect.profilestore";

@implementation Tealium (Collect) 

- (BOOL) collect_isEnabled {
    return [self.settings audienceStreamEnabled];
}

- (void) enableAudienceStream {
    
    NSArray *dispatchNetworkServices = [[self currentDispatchNetworkServices] copy];
    
    if ([dispatchNetworkServices teal_containsObjectOfClass:[TEALCollectDispatchService class]]){
        return;
    }
    
    NSMutableArray *newServices = [NSMutableArray arrayWithArray:dispatchNetworkServices];
    
    TEALCollectDispatchService *dispatchService = [[TEALCollectDispatchService alloc] initWithDispatchURLString:[self.settings dispatchURLString] sessionManager:self.urlSessionManager];
    
    [dispatchService setup];
    
    [newServices addObject:dispatchService];
    
    [self setCurrentDispatchNetworkServices:[NSArray arrayWithArray:newServices]];
    
    [self.logger logDev:@"Audiencestream enabled."];

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
        
        if (![weakSelf.settings audienceStreamEnabled]) {
            [weakSelf.logger logDev:@"Audience Stream disabled, Ignoring: %s", __func__];
            if (completion) {
                
                completion(nil, nil);
            }
            
            return;
        }
        
        TEALVisitorProfileCompletionBlock storeCompletion = ^(TEALVisitorProfile *profile, NSError *error) {
            
            if (profile) {
                [weakSelf.logger logDev:@"got profile!!! : %@", profile];
                
                [weakSelf collect_setCachedProfile:profile];
                
                completion(weakSelf.collect_cachedProfile, nil);
                
            } else {
                [weakSelf.logger logDev:@"problem fetching profile: %@ - %@", [error localizedDescription], [error localizedRecoverySuggestion]];
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
    
    id profileRaw = objc_getAssociatedObject(self, TEALKVOAutotrackCollectProfile);
    if (profileRaw) profileRaw = nil;
    
    objc_setAssociatedObject(self, TEALKVOAutotrackCollectProfile, profile, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TEALVisitorProfile *) collect_cachedProfile {
    
    if (![self collect_isEnabled]) {
        return nil;
    }
    
    TEALVisitorProfile *profile = nil;
    
    id profileRaw = objc_getAssociatedObject(self, TEALKVOAutotrackCollectProfile);
    
    if ([profileRaw isKindOfClass:([TEALVisitorProfile class])]){
        profile = profileRaw;
    } else {
        profile = [[TEALVisitorProfile alloc] initWithVisitorID:self.visitorIDCopy];
        objc_setAssociatedObject(self, TEALKVOAutotrackCollectProfile, profile, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
        return [self.dataSources visitorIDCopy];
    }
}

#pragma mark - PROFILESTORE

- (TEALVisitorProfileStore *) profileStore {
    
    if (![self collect_isEnabled]) {
        return nil;
    }
    
    TEALVisitorProfileStore *profileStore;
    
    id profileStoreRaw = objc_getAssociatedObject(self, TEALKVOAutotrackCollectProfileStore);
    if ([profileStoreRaw isKindOfClass:([TEALVisitorProfileStore class])]){
        profileStore = profileStoreRaw;
    } else {
        profileStore = [[TEALVisitorProfileStore alloc] initWithVisitorID:self.settings.visitorIDCopy profileURL:self.settings.profileURL profileDefinitionURL:self.settings.profileDefinitionsURL urlSessionManager:self.urlSessionManager];
        objc_setAssociatedObject(self, TEALKVOAutotrackCollectProfileStore, profileStore, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
        
        weakSelf.settings.traceID = nil;
    }];
    
}


@end
