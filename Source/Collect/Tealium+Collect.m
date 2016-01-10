//
//  Tealium+Collect.m
//  Tealium
//
//  Created by Jason Koo on 8/20/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "Tealium+Collect.h"
#import "Tealium+PrivateHeader.h"
#import "TEALModulesDelegate.h"
#import "TEALVisitorProfileHelpers.h"
#import "TEALVisitorProfileStore.h"
#import "TEALCollectDispatchService.h"
#import "TEALS2SLegacyDispatchService.h"
#import "TEALS2SLegacyDispatchService.h"
#import "TEALSettings+Collect.h"
#import "TEALError.h"
#import "NSArray+Tealium.h"
#import <objc/runtime.h>

char const * const TEALKVOAutotrackCollectProfile = "com.tealium.kvo.collect.profile";
char const * const TEALKVOAutotrackCollectProfileStore = "com.tealium.kvo.collect.profilestore";

@implementation Tealium (Collect)

#pragma mark - PUBLIC

- (NSURL *) profileURL {
    
    if (![self isCollectEnabled]) {
        return nil;
    }
    
    return [self.settings profileURL];
}

- (NSURL *) profileDefinitionURL {
    
    if (![self isCollectEnabled]) {
        return nil;
    }
    
    return [self.settings profileDefinitionsURL];
}

- (NSString *) visitorIDCopy {
    
    if (![self isCollectEnabled]) {
        return nil;
    }
    
    @synchronized(self) {
        return [self.dataSources visitorIDCopy];
    }
}

- (TEALVisitorProfile *) cachedVisitorProfileCopy {
    
    if (![self isCollectEnabled]) {
        return nil;
    }
    
    @synchronized(self) {
        
        return [self.collect_cachedProfile copy];
    }
}

- (void) fetchVisitorProfileWithCompletion:(void (^)(TEALVisitorProfile *profile, NSError *error))completion {
    
    if (![self isCollectEnabled]) {
        if (completion){
            NSError *error = [TEALError errorWithCode:400 description:@"Fetch Visitor Profile request ignored." reason:@"Collect module not enabled." suggestion:@"Check Publish Settings."];
            completion(nil, error);
        }
        return;
    }
    
    __weak Tealium *weakSelf = self;
    
    [weakSelf.operationManager addOperationWithBlock:^{
        
        if (![weakSelf.settings collectEnabled]) {
            
            [weakSelf.logger logDev:@"Audience Stream disabled, Ignoring: %s", __func__];
            if (completion) {
                
                completion(nil, nil);
            }
            
            return;
        }
        
        TEALVisitorProfileCompletionBlock storeCompletion = ^(TEALVisitorProfile *profile, NSError *error) {
            
            if (profile) {
                
                [weakSelf collect_setCachedProfile:profile];
                
                completion(weakSelf.collect_cachedProfile, nil);
                
            } else {
                
#warning Move this error message to callback
                
                [weakSelf.logger logDev:@"problem fetching profile: %@ - %@", [error localizedDescription], [error localizedRecoverySuggestion]];
                
            }
        };
        
        [[weakSelf profileStore] fetchProfileWithCompletion:storeCompletion];
        
    }];
}

- (void) joinTraceWithToken:(NSString * _Nonnull)token
                 completion:(TEALBooleanCompletionBlock)completion {
    
    NSError *error = nil;
    
    if (![self isCollectEnabled]) {
        
        error = [TEALError errorWithCode:TEALErrorCodeFailure
                             description:NSLocalizedString(@"Join trace call failed.", @"")
                                  reason:NSLocalizedString(@"Collect not enabled.", @"")
                              suggestion:NSLocalizedString(@"Enable Collect service.", @"")];
        
    }   else if (!token || ![token length]) {
        
        error = [TEALError errorWithCode:TEALErrorCodeFailure
                             description:NSLocalizedString(@"Join trace call failed.", @"")
                                  reason:NSLocalizedString(@"No token passed into joinTraceWithToken: call", @"")
                              suggestion:NSLocalizedString(@"Add a token.", @"")];
    }
    
    if (completion && error){
        completion(false, error);
        return;
    }
    
    __weak Tealium *weakSelf = self;
    
    [weakSelf.operationManager addOperationWithBlock:^{
        
        weakSelf.settings.traceID = token;
        
        if (completion) completion(true, nil);
        
    }];
    
}

- (void) leaveTraceWithCompletion:(TEALBooleanBlock)completion {
    
    
    if (![self isCollectEnabled]) {
        if (completion){
            completion(FALSE);
        }
        return;
    }
    
    __weak Tealium *weakSelf = self;
    
    [weakSelf.operationManager addOperationWithBlock:^{
        
        weakSelf.settings.traceID = nil;
        
        if (completion){
            completion(TRUE);
        }
        
    }];
    
}

//- (BOOL) collect_isEnabled {
//    return [self.settings collectEnabled];
//}

#pragma mark - MODULES DELEGATE

- (void) updateCollect {
    
    if ([self.settings collectEnabled]){
        [self enableCollect];
    } else {
        [self disableCollect];
    }
}

- (void) updateS2SLegacy {

    if ([self.settings s2SLegacyEnabled]){
        
        [self enableS2SLegacy];
        
    } else {
        
        [self disableS2SLegacy];
    }
    
}

#pragma mark - PRIVATE

- (BOOL) isCollectEnabled {

    return [self.settings collectEnabled];
    
}



- (void) enableCollect {
    
    NSArray *dispatchNetworkServices = [[self currentDispatchServices] copy];
    
    if ([dispatchNetworkServices teal_containsObjectOfClass:[TEALCollectDispatchService class]]){
        return;
    }
    
    NSMutableArray *newServices = [NSMutableArray arrayWithArray:dispatchNetworkServices];
    
    TEALCollectDispatchService *dispatchService = [[TEALCollectDispatchService alloc] initWithDispatchURLString:[self.settings collectDispatchURLString] sessionManager:self.urlSessionManager];
    
    [dispatchService setup];
    
    [newServices addObject:dispatchService];
    
    [self setCurrentDispatchServices:[NSArray arrayWithArray:newServices]];
    
    [self.logger logDev:@"Collect enabled."];

}

- (void) disableCollect {
    
#warning TODO
    
}

- (void) enableS2SLegacy {
    
    NSArray *dispatchNetworkServices = [[self currentDispatchServices] copy];
    
    if ([dispatchNetworkServices teal_containsObjectOfClass:[TEALS2SLegacyDispatchService class]]){
        return;
    }
    
    NSMutableArray *newServices = [NSMutableArray arrayWithArray:dispatchNetworkServices];
    
    TEALS2SLegacyDispatchService *dispatchService = [[TEALS2SLegacyDispatchService alloc] initWithDispatchURLString:[self.settings s2SLegacyDispatchURLString]
                                                                                              visitorID:[self.settings visitorIDCopy] sessionManager:self.urlSessionManager];
    
    [dispatchService setup];
    
    [newServices addObject:dispatchService];
    
    [self setCurrentDispatchServices:[NSArray arrayWithArray:newServices]];
    
    [self.logger logDev:@"S2S Legacy enabled."];
    
}

- (void) disableS2SLegacy {
    
#warning TODO
    
}

- (void) fetchVisitorProfileAfterEvent {
    
    if ([self.settings pollingFrequency] == TEALVisitorProfilePollingFrequencyAfterEveryEvent) {

        [self fetchVisitorProfile];
    
    }
}

- (void) fetchVisitorProfile {
    
    [self fetchVisitorProfileWithCompletion:^(TEALVisitorProfile * _Nullable profile, NSError * _Nullable error) {
    
        [self.logger logDev:@"Did fetch profile: %@", profile];
        
    }];
    
}

- (void) collect_setCachedProfile:(TEALVisitorProfile*)profile {
    
    if (![self isCollectEnabled]) {
        return;
    }
    
    id profileRaw = objc_getAssociatedObject(self, TEALKVOAutotrackCollectProfile);
    if (profileRaw) profileRaw = nil;
    
    objc_setAssociatedObject(self, TEALKVOAutotrackCollectProfile, profile, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TEALVisitorProfile *) collect_cachedProfile {
    
    if (![self isCollectEnabled]) {
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

- (TEALVisitorProfileStore *) profileStore {
    
    if (![self isCollectEnabled]) {
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


//- (void) leaveTrace {
//    
//    if (![self collect_isEnabled]) {
//        return;
//    }
//    
//    __weak Tealium *weakSelf = self;
//    
//    [weakSelf.operationManager addOperationWithBlock:^{
//        
//        weakSelf.settings.traceID = nil;
//    }];
//    
//}


@end
