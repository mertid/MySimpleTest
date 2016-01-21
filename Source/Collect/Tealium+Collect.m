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
    
    NSString *urlString = [[self dataSources] visitorIDCopy];
    
    NSURL *url = [self.settings collectProfileURLForVisitorID:urlString];
    
    return url;
}

- (NSURL *) profileDefinitionURL {
    
    if (![self isCollectEnabled]) {
        return nil;
    }
    
    return [self.settings collectProfileDefinitionsURL];
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

        
        [[weakSelf profileStore] fetchProfileWithCompletion:^(TEALVisitorProfile *profile, NSError *error) {
           
            if (profile) {
                
                [weakSelf collect_setCachedProfile:profile];
                
                if (completion){
                    completion(weakSelf.collect_cachedProfile, nil);
                }
                
            } else {
                
#warning Move this error message to callback
                
                [weakSelf.logger logDev:@"problem fetching profile: %@ - %@", [error localizedDescription], [error localizedRecoverySuggestion]];
                
            }
            
        }];
        
    }];
}

- (void) joinTraceWithToken:(NSString * _Nonnull)token
                 completion:(void(^)(BOOL successful, NSError *error))completion {
    
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
        
        [weakSelf.logger logDev:@"Joining trace id:%@", token];
        
        [weakSelf.settings setTraceID:token completion:completion];
        
    }];
    
}

- (void) leaveTraceWithCompletion:(void(^)(BOOL successful, NSError *error))completion {
    
    
    if (![self isCollectEnabled]) {
        if (completion){
            completion(false, nil);
        }
        return;
    }
    
    __weak Tealium *weakSelf = self;
    
    [weakSelf.operationManager addOperationWithBlock:^{
        
        [weakSelf.settings setTraceID:nil completion:completion];
        
    }];
    
}

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

- (TEALCollectDispatchService *) currentCollectDispatchService {
    
    __block TEALCollectDispatchService *targetService = nil;
    
    NSArray *dispatchServices = [[self currentDispatchServices] copy];
    
    if (dispatchServices) {
        
        [dispatchServices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            if (![obj isMemberOfClass:([TEALCollectDispatchService class])]){
                return;
            }
            
            TEALCollectDispatchService *aService = obj;
            
            NSString *visitorID = [[self dataSources]visitorIDCopy];
            
            NSString *collectDispatchURLString = [self.settings collectDispatchURLStringForVisitorID:visitorID];
            
            if ([aService.dispatchURLStringCopy isEqualToString:collectDispatchURLString]){
                targetService = aService;
                *stop = YES;
            }
            
        }];
    }
    
    return targetService;
}

- (BOOL) isCollectEnabled {

    return [self.settings collectEnabled];
    
}

- (void) enableCollect {
    
    NSArray *dispatchNetworkServices = [[self currentDispatchServices] copy];
    
    if ([dispatchNetworkServices teal_containsObjectOfClass:[TEALCollectDispatchService class]]){
        return;
    }
    
    NSMutableArray *newServices = [NSMutableArray arrayWithArray:dispatchNetworkServices];
    
    NSString *collectDispatchString = [self.settings collectDispatchURLStringForVisitorID:[[self dataSources] visitorIDCopy]];
    
    TEALCollectDispatchService *dispatchService = [[TEALCollectDispatchService alloc] initWithDispatchURLString:collectDispatchString
                                                                                                 sessionManager:self.urlSessionManager];
    
    [dispatchService setup];
    
    [newServices addObject:dispatchService];
    
    [self setCurrentDispatchServices:[NSArray arrayWithArray:newServices]];
    
    [self.logger logDev:@"Collect enabled."];

}

- (void) disableCollect {
    
    [self removeDispatchService:[self currentCollectDispatchService]];
    
    [self.logger logDev:@"Collect disabled."];

}

- (TEALS2SLegacyDispatchService *) currentS2SLegacyDispatchService {
    
    __block TEALS2SLegacyDispatchService *targetService = nil;
    
    NSArray *dispatchServices = [[self currentDispatchServices] copy];
    
    if (dispatchServices) {
        
        [dispatchServices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            if (![obj isMemberOfClass:([TEALS2SLegacyDispatchService class])]){
                return;
            }
            
            TEALS2SLegacyDispatchService *aService = obj;
            
            NSString *dispatchURLString = [self.settings s2SLegacyDispatchURLString];
            
            if ([aService.dispatchURLStringCopy isEqualToString:dispatchURLString]){
                targetService = aService;
                *stop = YES;
            }
            
        }];
    }
    
    return targetService;
}

- (void) enableS2SLegacy {
    
    NSArray *dispatchNetworkServices = [[self currentDispatchServices] copy];
    
    if ([dispatchNetworkServices teal_containsObjectOfClass:[TEALS2SLegacyDispatchService class]]){
        return;
    }
    
    NSMutableArray *newServices = [NSMutableArray arrayWithArray:dispatchNetworkServices];
    
    TEALS2SLegacyDispatchService *dispatchService = [[TEALS2SLegacyDispatchService alloc] initWithDispatchURLString:[self.settings s2SLegacyDispatchURLString]
                                                                                              visitorID:[self.dataSources visitorIDCopy] sessionManager:self.urlSessionManager];
    
    [dispatchService setup];
    
    [newServices addObject:dispatchService];
    
    [self setCurrentDispatchServices:[NSArray arrayWithArray:newServices]];
    
    [self.logger logDev:@"S2S Legacy enabled."];
    
}

- (void) disableS2SLegacy {
    
    [self removeDispatchService:[self currentS2SLegacyDispatchService]];
    
    [self.logger logDev:@"S2S enabled."];

}

- (void) fetchVisitorProfileAfterEvent {
    
    if ([self.settings collectPollingFrequency] == TEALVisitorProfilePollingFrequencyAfterEveryEvent) {

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
        
        profileStore = [[TEALVisitorProfileStore alloc] initWithVisitorID:self.dataSources.visitorIDCopy
                                                               profileURL:[self profileURL]
                                                     profileDefinitionURL:self.settings.collectProfileDefinitionsURL
                                                        urlSessionManager:self.urlSessionManager];
        
        objc_setAssociatedObject(self, TEALKVOAutotrackCollectProfileStore, profileStore, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
    }
    
    return profileStore;
}

@end
