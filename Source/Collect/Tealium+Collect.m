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
    
    __weak Tealium *weakSelf = self;
    
    [weakSelf.operationManager addOperationWithBlock:^{
        
        if (![weakSelf isCollectEnabled]) {
            
            NSError *error = [TEALError errorWithCode:TEALErrorCodeFailure
                                          description:NSLocalizedString(@"Fetch visitor request failed.", @"")
                                               reason:NSLocalizedString(@"Collect module disabled or not finished initializing.", @"")
                                           suggestion:NSLocalizedString(@"Enable collect in your TIQ Mobile Publish Settings OR make fetch request later.", @"")];
            
            if (completion) {
                
                completion(nil, error);
            }
            
            return;
        }

        
        [[weakSelf profileStore] fetchProfileWithCompletion:^(TEALVisitorProfile *profile, NSError *error) {
           
                [weakSelf collect_setCachedProfile:profile];
            
                if (completion){
                    completion(weakSelf.collect_cachedProfile, error);
                }
            
        }];
        
    }];
}

#pragma mark - MODULES DELEGATE

- (void) updateCollect {
    
    if (![self.settings libraryShouldDisable] &&
        [self.settings collectEnabled]){
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
    
    NSArray *dispatchServices = [self currentDispatchServices];
    
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
    
    NSString *vid = [[self dataSources] visitorIDCopy];
    
    if (!vid) {
        [self.logger logQA:@"Could not enable Collect. Visitor id not yet assigned from dataSources for generating target Collect URL endpoint."];
        return;
    }

    NSString *collectDispatchString = [self.settings collectDispatchURLStringForVisitorID:vid];
    
    if (!collectDispatchString){
        [self.logger logQA:@"Could not enable Collect Dispatch Service. Settings could not generate the dispatch URL string for visitor id:%@", vid];
        return;
    }
    
    TEALCollectDispatchService *dispatchService = [[TEALCollectDispatchService alloc] initWithDispatchURLString:collectDispatchString
                                                                                                 sessionManager:self.urlSessionManager];
    
    [dispatchService setup];
    
    [self addNewDispatchService:dispatchService];
    
}

- (void) disableCollect {
    
    TEALCollectDispatchService *service = [self currentCollectDispatchService];
    
    if (service){
        [self removeDispatchService:service];        
    }
}

- (TEALS2SLegacyDispatchService *) currentS2SLegacyDispatchService {
    
    __block TEALS2SLegacyDispatchService *targetService = nil;
    
    NSArray *dispatchServices = [self currentDispatchServices];
    
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
        
    TEALS2SLegacyDispatchService *dispatchService = [[TEALS2SLegacyDispatchService alloc] initWithDispatchURLString:[self.settings s2SLegacyDispatchURLString]
                                                                                              visitorID:[self.dataSources visitorIDCopy] sessionManager:self.urlSessionManager];
    
    [dispatchService setup];
    
    [self addNewDispatchService:dispatchService];
    
}

- (void) disableS2SLegacy {
    
    TEALS2SLegacyDispatchService *service = [self currentS2SLegacyDispatchService];
    
    if (service){
        [self removeDispatchService:service];
        
    }
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
