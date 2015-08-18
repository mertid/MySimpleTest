//
//  Tealium.m
//  Tealium
//
//  Created by George Webster on 7/15/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "Tealium.h"

#import "TEALDispatchManager.h"
#import "TEALDelegateManager.h"
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

// Autotracking
#import "TEALAutotrackingManager.h"

// Events
#import "TEALApplicationLifecycle.h"

// Logging

#import "TEALLogger.h"

// Datasources

#import "TEALDatasourceConstants.h"
#import "TEALDataSources.h"

// Profile

#import "TEALVisitorProfileHelpers.h"

@interface Tealium () <
                        TEALDispatchManagerDelegate,
                        TEALDispatchManagerConfiguration,
                        TEALVisitorProfileStoreConfiguration,
                        TEALCollectNetworkServiceConfiguration,
                        TEALTagNetworkServiceConfiguration>

@property (strong, nonatomic) TEALLogger *logger;
@property (strong, nonatomic) TEALSettings *settings;
@property (strong, nonatomic) TEALDispatchManager *dispatchManager;
@property (strong, nonatomic) TEALVisitorProfileStore *profileStore;
@property (strong, nonatomic) TEALDatasources *dataSources;
@property (strong, nonatomic) TEALOperationManager *operationManager;
@property (strong, nonatomic) TEALURLSessionManager *urlSessionManager;

@property (strong, nonatomic) NSArray *dispatchNetworkServices;

@property (strong, nonatomic) TEALApplicationLifecycle *lifecycle;
@property (strong, nonatomic) TEALAutotrackingManager *autotrackingManager;
@property (strong, nonatomic) TEALDelegateManager *delegateManager;

@property (copy, readwrite) TEALVisitorProfile *cachedProfile;

@property (weak, nonatomic) UIWebView *tagManagementWebView;

@property (readwrite) BOOL enabled;

@end

__strong static Tealium *_sharedObject = nil;

@implementation Tealium

#pragma mark - PRIVATE CLASS METHODS

+ (instancetype) instanceWithConfiguration:(TEALConfiguration *)configuration completion:(TEALBooleanCompletionBlock) completion{
    
    Tealium *instance = [[Tealium alloc] initPrivate];
    
    __weak Tealium *weakInstance = instance;
    
    [weakInstance.operationManager addOperationWithBlock:^{
        [weakInstance instanceWithConfiguration:configuration completion:^(BOOL success, NSError *error) {
            if (success) {
                [weakInstance.dispatchManager runQueuedDispatches];
                TEAL_LogNormal(@"Library instance ready.");
            } else {
                [weakInstance disable];
                TEAL_LogNormal(@"Library failed to start: %@", error);
            }
            if (completion) completion(success, error);
        }];
    }];
    
    return instance;
}

+ (instancetype) sharedInstanceWithConfiguration:(TEALConfiguration *)configuration completion:(TEALBooleanCompletionBlock) completion {
    Tealium *instance = [Tealium instanceWithConfiguration:configuration completion:completion];
    [Tealium setSharedInstance:instance];
    return instance;
}

+ (void) setSharedInstance:(Tealium *)instance {
    _sharedObject = instance;
}

#pragma mark - PRIVATE INSTANCE METHODS

- (instancetype) initPrivate {
    
    self = [super init];
    
    if (self) {
        _operationManager   = [TEALOperationManager new];
        _urlSessionManager  = [[TEALURLSessionManager alloc] initWithConfiguration:nil];
        _urlSessionManager.completionQueue = _operationManager.underlyingQueue;
        _delegateManager    = [[TEALDelegateManager alloc] init];
        
    }
    
    return self;
}

- (instancetype) init {
    [NSException raise:@"should not be initialized directly"
                format:@"please use [Tealium sharedInstance] or public class methods"];
    return nil;
}

- (void) instanceWithConfiguration:(TEALConfiguration *)configuration
                 completion:(TEALBooleanCompletionBlock)setupCompletion {
    
    self.logger = [[TEALLogger alloc] initWithConfiguration:configuration];
    
    if (![TEALConfiguration isValidConfiguration:configuration]) {
        TEAL_LogNormal(@"Invalid Configuration, check your account, profile and enviornment options.");
        if (setupCompletion) {
            setupCompletion(NO, nil);
        }
        return;
    }
    
    [self.logger logNormal:@"%@", configuration];
    
    self.enabled = YES;
    
    // AudienceStream
    self.dataSources = [[TEALDatasources alloc]initWithInstanceID:configuration.instanceID];
    
    // TODO: Move later
    self.profileStore = [[TEALVisitorProfileStore alloc] initWithConfiguration:self];  // needs valid visitorID
    
    [self setupSettingsWithConfiguration:configuration visitorID:[self.dataSources visitorID] completion:^(BOOL success, NSError *error) {
        
        
        if (success) {
            self.dispatchManager = [TEALDispatchManager dispatchManagerWithConfiguration:self
                                                                                delegate:self];
            
            [self setupNetworkServicesForSettings:self.settings];
            
            [self setupLifecycleForSettings:self.settings];
            
            [self setupAutotrackingForSettings:self.settings];
            
            [self setupSettingsReachabilityCallbacks];
            
        } else {
            
            [self disable];
            
        }
        
        if (setupCompletion) setupCompletion(success, error);

    }];
    
    
}

- (void) sendEvent:(TEALDispatchType)eventType withData:(NSDictionary *)customData title:(NSString *)title{
    
    if (!self.enabled) {
        [self.logger logNormal:@"Library Disabled, Ignoring dispatch.",nil];
        [self.logger logVerbose:@"Dispatch title:%@, DataSources:%@", title, customData];
        return;
    }
    
    __weak Tealium *weakSelf = self;
    
    TEALDispatchBlock completion = ^(TEALDispatchStatus status, TEALDispatch *dispatch, NSError *error) {
        
        switch (status) {
            case TEALDispatchStatusSent:
            case TEALDispatchStatusQueued:
            case TEALDispatchStatusShouldDestory:
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
    
    TEALDispatch *dispatch = [TEALDispatch dispatchForType:eventType withPayload:customData];
    
    [self.dispatchManager addDispatch:dispatch
                      completionBlock:completion];
    
    [self.dispatchManager archiveDispatchQueue];
}

- (void) dispatchManager:(TEALDispatchManager *)dispatchManager didProcessDispatch:(TEALDispatch *)dispatch status:(TEALDispatchStatus)status {
    // Log + Fetch Profile

    [self logDispatch:dispatch status:status];
    [self notifyDispatch:dispatch status:status];
    
    if ([self.settings pollingFrequency] == TEALVisitorProfilePollingFrequencyOnRequest) {
        return;
    }
    
    
    [self fetchVisitorProfileWithCompletion:^(TEALVisitorProfile *profile, NSError *error) {
        
        TEAL_LogVerbose(@"did fetch profile: %@ after dispatch event", profile);
    }];
}

// Delegate Callback

- (void) logDispatch:(TEALDispatch *) dispatch status:(TEALDispatchStatus) status {
    if ([self.settings logLevel] >= TEALLogLevelVerbose) {
        
        NSString *statusString = @"sent";
        
        if  (status == TEALDispatchStatusQueued) {
            statusString = @"queued";
        }
        else if (status == TEALDispatchStatusShouldDestory) {
            statusString = @"destroyed";
        }
        
        if ([dispatch.payload isKindOfClass:[NSString class]]) {
            NSDictionary *datalayerDump = [TEALNetworkHelpers dictionaryFromUrlParamString:(NSString *)dispatch.payload];
            
            TEAL_LogVerbose(@"Successfully %@ dispatch with payload %@", statusString, datalayerDump);
            
        } else {
            
            TEAL_LogVerbose(@"Successfully %@ dispatch.", statusString)
        }
    }
}

- (void) notifyDispatch:(TEALDispatch *) dispatch status:(TEALDispatchStatus) status {
    switch (status) {
        case TEALDispatchStatusSent:
            [self.delegateManager tealium:self didSendDispatch:dispatch];
            break;
        case TEALDispatchStatusQueued:
            [self.delegateManager tealium:self didQueueDispatch:dispatch];
            break;
        case TEALDispatchStatusShouldDestory:
            break;
        default:
            break;
    }
    
}

- (void) setupSettingsWithConfiguration:(TEALConfiguration *) configuration visitorID:(NSString *)visitorID completion:(TEALBooleanCompletionBlock)setupCompletion{
    
    self.settings = [[TEALSettings alloc] initWithConfiguration:configuration];
    [self.settings setVisitorIDCopy:visitorID];
    self.settings.urlSessionManager = self.urlSessionManager;
    
    __weak TEALSettings *weakSettings = self.settings;
    
    [weakSettings fetchPublishSettingsWithCompletion:^(TEALPublishSettingsStatus status, NSError *error) {
        
        if (error) {
            [self.logger logNormal:@"Remote Publish Settings Error: %@", [error localizedDescription]];
        }
        
        BOOL success = NO;
        switch (status) {
            case TEALPublishSettingsStatusDefault:
                [self.logger logVerbose:@"Using default Remote Publish Settings."];
                success = YES;
                break;
            case TEALPublishSettingsStatusLoadedArchive:
                [self.logger logVerbose:@"Archived Remote Publish Settings loaded."];
                success = YES;
                break;
            case TEALPublishSettingsStatusLoadedRemote:
                [self.logger logVerbose:@"New Remote Publish Settings set."];
                success = YES;
                break;
            case TEALPublishSettingsStatusDisable:
                [self.logger logVerbose:@"Library disabled by Remote Publish Settings."];
                break;
            default:
                break;
        }
        
        
        [self.logger logVerbose:@"Remote Publish Settings: %@", [weakSettings publishSettingsDescription]];
        if (setupCompletion) setupCompletion (success, nil);
    }];
}

- (void) setupAutotrackingForSettings:(TEALSettings *) settings {
    
    if ([settings autotrackingViewsEnabled] || [settings autotrackingUIEventsEnabled]) {
        self.autotrackingManager = [[TEALAutotrackingManager alloc] init];
    }
    if ([settings autotrackingUIEventsEnabled]) {
        [self.autotrackingManager enableEventTracking];
    }
    if ([settings autotrackingViewsEnabled]) {
        [self.autotrackingManager enableViewTracking];
    }
    
    //    else if (self.autotrackingManager) {
    // TODO: disable
    //        [self.autotrackingManager disable];
    //        self.autotrackingManager = nil;
    //    }
    
}

- (void) setupLifecycleForSettings:(TEALSettings *) settings {
    
    if ([settings lifecycleEnabled]){
        self.lifecycle = [[TEALApplicationLifecycle alloc] init];
        
        __weak Tealium *weakSelf = self;
        
        [weakSelf.lifecycle enableWithEventProcessingBlock:^(NSDictionary *dataDictionary, NSError *error) {
            
            [weakSelf trackEventWithTitle:nil dataSources:dataDictionary];
        }];
        
    } else if (self.lifecycle){
        [self.lifecycle disable];
        self.lifecycle = nil;
    }
    
}

- (void) setupNetworkServicesForSettings:(TEALSettings *)settings {
    
    NSMutableArray *possibleNetworkServices = [NSMutableArray array];
    
    if ([settings tagManagementEnabled]){
        TEALTagNetworkService *tagService = [[TEALTagNetworkService alloc] initWithConfiguration:self];
        self.tagManagementWebView = tagService.webView;
        [possibleNetworkServices addObject:tagService];
    }
    
    if ([settings audienceStreamEnabled]){
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
            completion:(TEALBooleanCompletionBlock)fetchCompletion {
    //    __weak Tealium *weakSelf = self;
    //
    //    [self.settingsStore fetchRemoteSettingsWithSetting:settings
    //                                            completion:^(TEALRemoteSettings *settings, NSError *error) {
    //
    //                                                BOOL settingsSuccess = NO;
    //
    //                                                if (settings) {
    //                                                    TEAL_LogVerbose(@"Retrieved settings: %@", settings);
    //
    //                                                    if (settings.status == TEALSettingsStatusLoadedRemote) {
    //                                                        settingsSuccess = YES;
    //                                                    }
    //
    //                                                    [weakSelf updateStateForSettingsStatus:settings.status];
    //                                                }
    //
    //                                                if (error) {
    //                                                    TEAL_LogVerbose(@"Problems while fetching settings: %@ \r error:%@", settings, [error localizedDescription]);
    //                                                    settingsSuccess = NO;
    //                                                }
    //
    //                                                [weakSelf.operationManager addOperationWithBlock:^{
    //
    //                                                    [weakSelf.settingsStore archiveCurrentSettings];
    //                                                }];
    //
    //                                                if (fetchCompletion) {
    //                                                    fetchCompletion(settingsSuccess, error);
    //                                                }
    //                                            }];
    //
    //
    //    [self.dispatchManager unarchiveDispatchQueue];
}

- (void) setupSettingsReachabilityCallbacks {
    
    if (self.urlSessionManager.reachability.reachableBlock) {
        return;
    }
    
    __weak Tealium *weakSelf = self;
    __weak TEALSettings *weakSettings = weakSelf.settings;
    
    weakSelf.urlSessionManager.reachability.reachableBlock = ^(TEALReachabilityManager *reachability) {
        
        
        [weakSettings fetchPublishSettingsWithCompletion:nil];
    };
}

#pragma mark - PUBLIC CLASS METHODS

+ (instancetype) sharedInstanceWithConfiguration:(TEALConfiguration *)configuration {
    
    return [Tealium sharedInstanceWithConfiguration:configuration completion:nil];
    
}

+ (instancetype) sharedInstance {
    
    return _sharedObject;
}

+ (void) destroySharedInstance {
    [[Tealium sharedInstance] disable];
    _sharedObject = nil;
}

+ (instancetype) instanceWithConfiguration:(TEALConfiguration *)configuration {
    
    return [Tealium instanceWithConfiguration:configuration completion:nil];

}

- (instancetype) instanceWithConfiguration:(TEALConfiguration *) configuration {
    return [Tealium instanceWithConfiguration:configuration completion:nil];
}

#pragma mark - PUBLIC INSTANCE METHODS

- (void) setDelegate:(id<TealiumDelegate>)delegate {

    @synchronized(self){
        
        [self.delegateManager updateWithDelegate:delegate];
    }
    
}

- (id<TealiumDelegate>) delegate {
    @synchronized(self){
        return self.delegateManager.delegate;
    }
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

- (void) trackEventWithTitle:(NSString *)title dataSources:(NSDictionary *)clientDataSources {
    
    // capture time datasources
    NSDictionary *captureTimeDataSources = [self compositeDictionaries:@[
                                                                         [self.dataSources captureTimeDatasourcesForEventType:TEALDispatchTypeEvent title:title],
                                                                         clientDataSources
                                                                         ]];
    
    __weak Tealium *weakSelf = self;
    
    [weakSelf.operationManager addOperationWithBlock:^{
       
        [weakSelf sendEvent:TEALDispatchTypeEvent withData:captureTimeDataSources title:title];

    }];
    
}

- (void) trackViewWithTitle:(NSString *)title dataSources:(NSDictionary *)clientDataSources {
    
    NSDictionary *captureTimeDataSources = [self compositeDictionaries:@[
                                                                         [self.dataSources captureTimeDatasourcesForEventType:TEALDispatchTypeEvent title:title],
                                                                         clientDataSources
                                                                         ]];
    __weak Tealium *weakSelf = self;

    [weakSelf.operationManager addOperationWithBlock:^{
        
        [weakSelf sendEvent:TEALDispatchTypeView withData:captureTimeDataSources title:title];
        
    }];
}

- (NSDictionary*) compositeDictionaries:(NSArray*)dictionaries {
    
    NSMutableDictionary *compositeDictionary = [NSMutableDictionary dictionary];
    
    for (NSDictionary *dictionary in dictionaries) {
        if ([dictionary isKindOfClass:([NSDictionary class])]){
            [compositeDictionary addEntriesFromDictionary:dictionary];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:compositeDictionary];
    
}

// AudienceStream

- (void) fetchVisitorProfileWithCompletion:(void (^)(TEALVisitorProfile *profile, NSError *error))completion {
    
    __weak Tealium *weakSelf = self;
    
    [weakSelf.operationManager addOperationWithBlock:^{
        
        if (!self.enabled) {
            TEAL_LogVerbose(@"Library Disabled, Ignoring: %s", __func__);
            return; // No fail log because these they should be logged once for each public method
        }
        
        if (![self.settings audienceStreamEnabled]) {
            
            TEAL_LogVerbose(@"Audience Stream disabled, Ignoring: %s", __func__);
            if (completion) {
                
                completion(nil, nil);
            }
            
            return;
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
        [weakSelf.profileStore fetchProfileWithCompletion:storeCompletion];
        
    }];
}

- (TEALVisitorProfile *) cachedVisitorProfileCopy {
    
    @synchronized(self) {
        
        return [self.cachedProfile copy];
    }
}

- (NSString *) visitorIDCopy {
    
    @synchronized(self) {
        return [self.dataSources visitorID];
    }
}

- (void) joinTraceWithToken:(NSString *)token {
    
    __weak Tealium *weakSelf = self;
    
    [weakSelf.operationManager addOperationWithBlock:^{
        if (!weakSelf.enabled) {
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
    
    __weak Tealium *weakSelf = self;
    
    [weakSelf.operationManager addOperationWithBlock:^{
        if (!weakSelf.enabled) {
            TEAL_LogVerbose(@"Library Disabled, Ignoring: %s", __func__);
            return;
        }
        
        weakSelf.settings.traceID = nil;
    }];
    
}

// Tag Managment

- (UIWebView *) webView {
    return self.tagManagementWebView;
}

- (NSDictionary *) persistentDataSourcesCopy {
    return [self.dataSources dataSourcesCopy];
}

- (void) setPersistentDataSources:(NSDictionary *) newDataSources {
    
    [self.dataSources setDataSources:newDataSources];
}

#pragma mark - TEALDispatchManagerDelegate methods

 //Agnostic - use configuration
 // TODO: handle wifi only, low battery and other settings
 // ~commHandlers big if else checks

- (BOOL) shouldAttemptDispatch {
    
    BOOL shouldAttempt = YES;
    
    if (shouldAttempt) {
        shouldAttempt = [self.urlSessionManager.reachability isReachable];
    }
    
    return shouldAttempt;
}

- (void) addDatasources:(NSDictionary *)datasources toDispatch:(TEALDispatch *)dispatch {
    
    NSDictionary *userInfo = dispatch.payload;
    
    if (userInfo) {
        NSMutableDictionary *combined = [NSMutableDictionary dictionaryWithDictionary:datasources];
        
        [combined addEntriesFromDictionary:userInfo];
        datasources = combined;
    }
    
    dispatch.payload = datasources;

}

- (void) dispatchManager:(TEALDispatchManager *)dataManager
        requestsDispatch:(TEALDispatch *)dispatch
         completionBlock:(TEALDispatchBlock)completionBlock {

    // Send Time (static) datasources
    
    NSDictionary *datasources = [self.dataSources transmissionTimeDatasourcesForEventType:dispatch.dispatchType];

    
    [self addDatasources:datasources
              toDispatch:dispatch];
    
    // for now fire and forget
    
    // one more check for network and settings
    if ([self shouldAttemptDispatch]) {
        
        if  ([self.delegateManager tealium:self shouldSendDispatch:dispatch]) {
            completionBlock(TEALDispatchStatusSent, dispatch, nil);
            
            for ( id<TEALDispatchNetworkService> service in self.dispatchNetworkServices) {
                
                [service sendDispatch:dispatch
                           completion:nil];
            }
        } else if (completionBlock) {
            completionBlock(TEALDispatchStatusShouldDestory, dispatch, nil);
        }

    } else {
        
        NSError *error = nil; // type of network or setting failure
        completionBlock(TEALDispatchStatusFailed, dispatch, error);
    }
    
}

- (void) willEnqueueDispatch:(TEALDispatch *)dispatch {
    
}

- (void) didEnqueueDispatch:(TEALDispatch *)dispatch {
    
}

- (void) didUpdateDispatchQueues {
    
}

- (BOOL) shouldPurgeDispatch:(TEALDispatch *)dispatch {
    // TODO: connect to expiration check


    return NO;
}

- (void) didPurgeDispatch:(TEALDispatch *)dispatch {

}

- (void) willRunDispatchQueueWithCount:(NSUInteger)count {
    
}

- (void) didRunDispatchQueueWithCount:(NSUInteger)count {
    
}

#pragma mark - TEALDispatchManagerConfiguration methods

- (NSUInteger) dispatchBatchSize {
    
    return [self.settings dispatchSize];
}

- (NSUInteger) dispatchQueueCapacity {
        
    return [self.settings offlineDispatchQueueSize];
}

#pragma mark - TEALCollectNetworkServiceConfiguration

- (NSString *) collectDispatchURLString {
    
    return [self.settings dispatchURLString];
}

#pragma mark - TEALTagNetworkServiceConfiguration

- (NSString*) tagTargetURLString {
    
    return [self.settings publishURLString];
    
}


#pragma mark - TEALVisitorProfileStoreConfiguration

- (NSString *) visitorID {
    return [self.dataSources visitorID];
}

- (NSURL *) profileURL {
    
    return [self.settings profileURL];
}

- (NSURL *) profileDefinitionURL {
    
    return [self.settings profileDefinitionsURL];
}


@end
