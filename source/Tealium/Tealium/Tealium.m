//
//  Tealium.m
//  Tealium
//
//  Created by George Webster on 7/15/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "Tealium.h"

#import "TEALSettingsStore.h"
#import "TEALDispatchManager.h"

//#import "TEALDatasourceManager.h"

#import "TEALVisitorProfileStore.h"
#import "TEALSettings.h"

// Queue / Operation Managers

#import "TEALOperationManager.h"

// Networking

#import "TEALURLSessionManager.h"
#import "TEALNetworkHelpers.h"
#import "TEALDispatchNetworkService.h"
#import "TEALCollectNetworkService.h"
#import "TEALTagNetworkService.h"

// Events
#import "TEALApplicationLifecycle.h"

// Dispatch

#import "TEALDispatch.h"

// Logging

#import "TEALLogger.h"

// Datasources

#import "TEALDatasources.h"
#import "TEALDataSourceStore.h"
#import "TEALDatasourceStore+TealiumAdditions.h"

// Profile

#import "TEALVisitorProfileHelpers.h"

// API

#import "TEALAPIHelpers.h"

@interface Tealium () <TEALSettingsStoreConfiguration,
                        TEALDispatchManagerDelegate,
                        TEALDispatchManagerConfiguration,
                        TEALVisitorProfileStoreConfiguration,
                        TEALCollectNetworkServiceConfiguration,
                        TEALTagNetworkServiceConfiguration>

@property (strong, nonatomic) TEALSettingsStore *settingsStore;
@property (strong, nonatomic) TEALDispatchManager *dispatchManager;
@property (strong, nonatomic) TEALVisitorProfileStore *profileStore;

@property (strong, nonatomic) TEALDatasourceStore *datasourceStore;

@property (strong, nonatomic) TEALOperationManager *operationManager;

@property (strong, nonatomic) TEALURLSessionManager *urlSessionManager;

@property (strong, nonatomic) NSArray *dispatchNetworkServices;

@property (strong, nonatomic) TEALApplicationLifecycle *lifecycle;

@property (copy, readwrite) NSString *visitorID;
@property (copy, readwrite) TEALVisitorProfile *cachedProfile;
@property (readwrite) BOOL enabled;



@end

@implementation Tealium

+ (instancetype) sharedInstance {
    
    static dispatch_once_t onceToken = 0;
    __strong static Tealium *_sharedObject = nil;
    
    dispatch_once(&onceToken, ^{
        _sharedObject = [[Tealium alloc] initPrivate];
    });
    
    return _sharedObject;
}

- (instancetype) init {
    [NSException raise:@"should not be initialized directly"
                format:@"please use [Tealium sharedInstance] or public class methods"];
    return nil;
}

- (instancetype) initPrivate {
    
    self = [super init];
    
    if (self) {
        _operationManager   = [TEALOperationManager new];
        _urlSessionManager  = [[TEALURLSessionManager alloc] initWithConfiguration:nil];
        
        _urlSessionManager.completionQueue = _operationManager.underlyingQueue;
        
        _settingsStore      = [[TEALSettingsStore alloc] initWithConfiguration:self];
        
        [_settingsStore unarchiveCurrentSettings];
        
    }
    
    return self;
}

#pragma mark - Enable / Disable / Configure settings / startup

+ (void) enableWithConfiguration:(TEALConfiguration *)configuration {
    
    [[self class] enableWithConfiguration:configuration
                               completion:nil];
}

+ (void) enableWithConfiguration:(TEALConfiguration *)configuration
                      completion:(TEALBooleanCompletionBlock)completion {
    
    __weak Tealium *instance = [[self class] sharedInstance];
    
    [instance.operationManager addOperationWithBlock:^{
        
        [instance setupConfiguration:configuration completion:completion];
        
    }];
    
    [instance enable];
}

- (void) setupConfiguration:(TEALConfiguration *)configuration
                 completion:(TEALBooleanCompletionBlock)setupCompletion {
    
    
    self.datasourceStore = [TEALDatasourceStore sharedStore];
    [self.datasourceStore loadWithUUIDKey:configuration.accountName];
    
    NSString *accountUUID = self.datasourceStore[TEALDatasourceKey_UUID];
    
    NSString *visitorID = [accountUUID stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    self.visitorID = visitorID;
    
    // TODO: Move later
    self.profileStore = [[TEALVisitorProfileStore alloc] initWithConfiguration:self];  // needs valid visitorID
    
    TEALSettings *settings = [self.settingsStore settingsFromConfiguration:configuration visitorID:visitorID];
    
    [TEALLogger setLogLevel:settings.logLevel];
    
    // TODO: Move later + Needs settings
    self.dispatchManager = [TEALDispatchManager dispatchManagerWithConfiguration:self
                                                                       delegate:self];
    // TODO: Move later + Needs settings
    [self setupNetworkServicesForSettings:settings];

    [self setupLifecycleForSettings:settings];
    
    [self fetchSettings:settings
             completion:setupCompletion];
    
    [self setupSettingsReachabilitiyCallbacks];
}

- (void) setupLifecycleForSettings:(TEALSettings *) settings {
    
    if (settings.lifecycleEnabled){
        self.lifecycle = [[TEALApplicationLifecycle alloc] init];
        
        __weak Tealium *weakSelf = self;
        
        [weakSelf.lifecycle enableWithEventProcessingBlock:^(NSDictionary *dataDictionary, NSError *error) {
            
            if (!weakSelf.enabled) {
                
                // TODO: add reporting for instance
                TEAL_LogVerbose(@"Lifecycle Disabled, Ignoring: %s", __PRETTY_FUNCTION__);
                return;
            }
            
            [weakSelf.operationManager addOperationWithBlock:^{
                
                [weakSelf sendEvent:TEALEventTypeLink
                           withData:dataDictionary];
            }];
        }];
        
    } else if (self.lifecycle){
        [self.lifecycle disable];
        self.lifecycle = nil;
    }
    
}


- (void) setupNetworkServicesForSettings:(TEALSettings *)settings {
    
    NSMutableArray *possibleNetworkServices = [NSMutableArray array];
    
    if (settings.tagManagementEnabled){
        TEALTagNetworkService *tagService = [[TEALTagNetworkService alloc] initWithConfiguration:self];
        [possibleNetworkServices addObject:tagService];
    }
    
    if (settings.audienceStreamEnabled){
        TEALCollectNetworkService *collectService = [TEALCollectNetworkService networkServiceWithConfiguration:self];
        [possibleNetworkServices addObject:collectService];
    }
    
    // TODO: Use NSOperations
    
    self.dispatchNetworkServices = [NSArray arrayWithArray:possibleNetworkServices];
    
    for (id<TEALDispatchNetworkService> service in self.dispatchNetworkServices) {
        [service setup];
    }

}

- (void) fetchSettings:(TEALSettings *)settings
            completion:(TEALBooleanCompletionBlock)setupCompletion {
    
    __weak Tealium *weakSelf = self;
    
    TEALSettingsCompletionBlock settingsCompletion = ^(TEALSettings *settings, NSError *error) {
        
        BOOL settingsSuccess = NO;
        
        if (settings) {
            TEAL_LogVerbose(@"Retrieved settings: %@", settings);
            
            if (settings.status == TEALSettingsStatusLoadedRemote) {
                settingsSuccess = YES;
            }
            
            [weakSelf updateStateForSettingsStatus:settings.status];
        }
        
        if (error) {
            TEAL_LogVerbose(@"Problems while fetching settings: %@ \r error:%@", settings, [error localizedDescription]);
            settingsSuccess = NO;
        }
        
        [weakSelf.operationManager addOperationWithBlock:^{
            
            [weakSelf.settingsStore archiveCurrentSettings];
        }];
        
        if (setupCompletion) {
            setupCompletion(settingsSuccess, error);
        }
        
        if (settingsSuccess) {
            [weakSelf.dispatchManager runQueuedDispatches];
        } else {
            [weakSelf disable];
        }
    };
    
    [self.settingsStore fetchRemoteSettingsWithSetting:settings
                                            completion:settingsCompletion];
    
    
    [self.dispatchManager unarchiveDispatchQueue];
}

- (void) updateStateForSettingsStatus:(TEALSettingsStatus)status {
    
    switch (status) {
        case TEALSettingsStatusNew:
        case TEALSettingsStatusLoadedArchive:
        case TEALSettingsStatusLoadedRemote:

            break;
        case TEALSettingsStatusInvalid:
            TEAL_LogVerbose(@"Invalid Settings library is shutting now.  Please enable with valid configuration.");
            [Tealium disable];
            break;
    }
}

- (void) setupSettingsReachabilitiyCallbacks {
    
    if (self.urlSessionManager.reachability.reachableBlock) {
        return;
    }
    
    __weak Tealium *weakSelf = self;
    __weak TEALSettings *settings = weakSelf.settingsStore.currentSettings;
    
    weakSelf.urlSessionManager.reachability.reachableBlock = ^(TEALReachabilityManager *reachability) {
        
        [weakSelf fetchSettings:settings
                     completion:nil];
    };
}


#pragma mark - TEALSettingsStoreConfiguration methods

- (NSString *) mobilePublishSettingsURLStringForSettings:(TEALSettings *)settings {
    
    if (!settings) {
        return nil;
    }
    
    return [TEALAPIHelpers mobilePublishSettingsURLStringFromSettings:settings];
}

- (NSDictionary *) mobilePublishSettingsURLParams {
    return [self.datasourceStore systemInfoDatasources];
}


#pragma mark - Enable/Disable

+ (void) disable {
    [[self sharedInstance] disable];
}

- (void) disable {
    @synchronized(self) {
        
        self.enabled = NO;
    }
}

- (void) enable {
    
    @synchronized(self) {
        
        self.enabled = YES;
    }
}

#pragma mark - Tracking / Send Data

+ (void) sendEventWithData:(NSDictionary *)customData {
    
    __weak Tealium *instance = [[self class] sharedInstance];
    
    // TODO: move these to the instance methods
    
    if (!instance.enabled) {
        TEAL_LogVerbose(@"AudienceStream Library Disabled, Ignoring: %s", __PRETTY_FUNCTION__);
        return;
    }
    
    [instance.operationManager addOperationWithBlock:^{
        
        [instance sendEvent:TEALEventTypeLink
                   withData:customData];
    }];
}

+ (void) sendViewWithData:(NSDictionary *)customData {
    
    __weak Tealium *instance = [[self class] sharedInstance];
    
    if (!instance.enabled) {
        TEAL_LogVerbose(@"AudienceStream Library Disabled, Ignoring: %s", __PRETTY_FUNCTION__);
        return;
    }
    
    [instance.operationManager addOperationWithBlock:^{
        
        [instance sendEvent:TEALEventTypeView
                   withData:customData];
    }];
}

- (void) sendEvent:(TEALEventType)eventType withData:(NSDictionary *)customData {
    
    __weak Tealium *weakSelf = self;
    
    TEALDispatchBlock completion = ^(TEALDispatchStatus status, TEALDispatch *dispatch, NSError *error) {
        
        switch (status) {
            case TEALDispatchStatusSent:
            case TEALDispatchStatusQueued:
                
                [weakSelf dispatchManager:weakSelf.dispatchManager
                       didProcessDispatch:dispatch
                                   status:status];
                
                break;
            case TEALDispatchStatusFailed:
            case TEALDispatchStatusUnknown:
                
                TEAL_LogVerbose(@"error: %@", [error localizedDescription]);
                break;
        }
    };
    
    [self.dispatchManager addDispatchForEvent:eventType
                                     withData:customData
                              completionBlock:completion];
    
    [self.dispatchManager archiveDispatchQueue];
}

- (void) dispatchManager:(TEALDispatchManager *)dispatchManager didProcessDispatch:(TEALDispatch *)dispatch status:(TEALDispatchStatus)status {
    
    if (self.settingsStore.currentSettings.logLevel >= TEALLogLevelVerbose) {
        
        NSString *statusString = @"sent";
        
        if  (status == TEALDispatchStatusQueued) {
            statusString = @"queued";
        }
        
        if ([dispatch.payload isKindOfClass:[NSString class]]) {
            NSDictionary *datalayerDump = [TEALNetworkHelpers dictionaryFromUrlParamString:(NSString *)dispatch.payload];
            
            TEAL_LogVerbose(@"Successfully %@ dispatch with payload %@", statusString, datalayerDump);
            
        } else {
            
            TEAL_LogVerbose(@"Successfully %@ dispatch.", statusString)
        }
    }
    if (self.settingsStore.currentSettings.pollingFrequency == TEALVisitorProfilePollingFrequencyOnRequest) {
        return;
    }
    
    [self fetchProfileWithCompletion:^(TEALVisitorProfile *profile, NSError *error) {
        
        TEAL_LogVerbose(@"did fetch profile: %@ after dispatch event", profile);
    }];
}

#pragma mark - TEALDispatchManagerDelegate methods

- (BOOL) shouldAttemptDispatch {
    
    TEALSettings *settings = self.settingsStore.currentSettings;
    
    BOOL shouldAttempt = ( [settings isValid] && settings.status != TEALSettingsStatusNew );
    
    if (shouldAttempt) {
        shouldAttempt = [self.urlSessionManager.reachability isReachable];
    }
    
    return shouldAttempt;
}


- (void) dispatchManager:(TEALDispatchManager *)dataManager
        requestsDispatch:(TEALDispatch *)dispatch
         completionBlock:(TEALDispatchBlock)completionBlock {

    for ( id<TEALDispatchNetworkService> service in self.dispatchNetworkServices) {
        
        // TODO:
        // two completions ?
        // build composite obj / nsoperation ?
        // if one service fails, should the disaptch requeue
        
        [service sendDispatch:dispatch
                   completion:completionBlock];
    }
}

- (void) willEnqueueDispatch:(TEALDispatch *)dispatch {
    
}

- (void) didEnqueueDispatch:(TEALDispatch *)dispatch {
    
}

- (void) didUpdateDispatchQueues {
    
}

- (BOOL) shouldRemoveDispatch:(TEALDispatch *)dispatch {

    return NO;
}

- (void) willRunDispatchQueueWithCount:(NSUInteger)count {
    
}
- (void) didRunDispatchQueueWithCount:(NSUInteger)count {
    
}

#pragma mark - TEALDispatchManagerConfiguration methods

- (NSDictionary *) datasourcesForEventType:(TEALEventType)eventType {
    return [self.datasourceStore datasourcesForEventType:eventType];
}

- (NSUInteger) dispatchBatchSize {
    
    TEALSettings *settings = self.settingsStore.currentSettings;
    
    return [settings dispatchSize];
}

- (NSUInteger) dispatchQueueCapacity {
    
    TEALSettings *settings = self.settingsStore.currentSettings;
    
    return [settings offlineDispatchQueueSize];
}

#pragma mark - TEALCollectNetworkServiceConfiguration

- (NSString *) collectDispatchURLString {
    
    TEALSettings *settings = self.settingsStore.currentSettings;
    
    return [TEALAPIHelpers sendDataURLStringFromSettings:settings];
}

#pragma mark - TEALTagNetworkServiceConfiguration

- (NSString*) tagTargetURLString {
    
    TEALSettings *settings = self.settingsStore.currentSettings;
    
    return [TEALAPIHelpers mobileHTMLURLStringFromSettings:settings];
    
}

#pragma mark - Profile

+ (void) fetchVisitorProfileWithCompletion:(void (^)(TEALVisitorProfile *profile, NSError *error))completion {
    
    __weak Tealium *instance = [[self class] sharedInstance];
    
    if (!instance.enabled) {
        TEAL_LogVerbose(@"AudienceStream Library Disabled, Ignoring: %s", __func__);
        return;
    }
    
    [instance.operationManager addOperationWithBlock:^{
        
        [instance fetchProfileWithCompletion:completion];
    }];
}

- (void) fetchProfileWithCompletion:(void (^)(TEALVisitorProfile *profile, NSError *error))completion {
    
    __weak Tealium *weakSelf = self;
    
    if (!self.enabled) {
        return; // No fail log because these they should be logged once for each public method
    }
    
    
    TEALVisitorProfileCompletionBlock storeCompletion = ^(TEALVisitorProfile *profile, NSError *error) {
        
        if (profile) {
            TEAL_LogVerbose(@"got profile!!! : %@", profile);
            
            weakSelf.cachedProfile = profile;
            
            completion(weakSelf.cachedProfile, nil);
            
        } else {
            TEAL_LogVerbose(@"problem fetching profile: %@", [error localizedDescription]);
        }
    };
    [self.profileStore fetchProfileWithCompletion:storeCompletion];
}

+ (TEALVisitorProfile *) cachedVisitorProfileCopy {
    
    Tealium *instance = [self sharedInstance];
    
    @synchronized(instance) {
        
        return instance.cachedProfile;
    }
}

#pragma mark - TEALVisitorProfileStoreConfiguration

- (NSURL *) profileURL {
    
    TEALSettings *settings = self.settingsStore.currentSettings;
    
    return [TEALAPIHelpers profileURLFromSettings:settings];
}

- (NSURL *) profileDefinitionURL {
    
    TEALSettings *settings = self.settingsStore.currentSettings;
    
    return [TEALAPIHelpers profileDefinitionsURLFromSettings:settings];
}

#pragma mark - Visitor ID

+ (NSString *) visitorID {
    
    Tealium *instance = [self sharedInstance];
    
    @synchronized(instance) {
        
        return instance.visitorID;
    }
}


#pragma mark - Trace

+ (void) joinTraceWithToken:(NSString *)token {
    
    __weak Tealium *instance = [[self class] sharedInstance];
    
    [instance.operationManager addOperationWithBlock:^{
        [instance joinTraceWithToken:token];
    }];
}

- (void) joinTraceWithToken:(NSString *)token {
    
    if (!self.enabled) {
        TEAL_LogVerbose(@"AudienceStream Library Disabled, Ignoring: %s", __func__);
        return;
    }
    
    if (!token || ![token length]) {
        return;
    }
    
    [self.settingsStore.currentSettings storeTraceID:token];
}

+ (void) leaveTrace {
    
    __weak Tealium *instance = [[self class] sharedInstance];
    
    [instance.operationManager addOperationWithBlock:^{
        [instance leaveTrace];
    }];
}

- (void) leaveTrace {
    
    if (!self.enabled) {
        TEAL_LogVerbose(@"AudienceStream Library Disabled, Ignoring: %s", __func__);
        return;
    }
    
    [self.settingsStore.currentSettings disableTrace];
}


@end
