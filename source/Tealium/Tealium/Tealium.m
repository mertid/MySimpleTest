//
//  Tealium.m
//  Tealium
//
//  Created by George Webster on 7/15/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "Tealium.h"

#import "TEALDataSources.h"
#import "TEALDispatchManager.h"
#import "TEALDelegateManager.h"
#import "TEALDispatchService.h"
#import "TEALDataSourceConstants.h"
#import "TEALDataSources.h"
#import "TEALOperationManager.h"
#import "TEALLogger.h"
#import "TEALModulesDelegate.h"
#import "TEALNetworkHelpers.h"
#import "TEALOperationManager.h"
#import "TEALSystemHelpers.h"
#import "TEALURLSessionManager.h"

@interface Tealium () <
                        TEALDispatchManagerDelegate,
                        TEALDispatchManagerConfiguration,
                        TEALModulesDelegate>

@property (strong, nonatomic) NSArray *dispatchNetworkServices;
@property (strong, nonatomic) TEALLogger *logger;
@property (strong, nonatomic) TEALOperationManager *operationManager;
@property (strong, nonatomic) TEALURLSessionManager *urlSessionManager;
@property (strong, nonatomic) TEALDataSources *dataSources;
@property (strong, nonatomic) TEALDelegateManager *delegateManager;
@property (strong, nonatomic) TEALDispatchManager *dispatchManager;
@property (strong, nonatomic) TEALSettings *settings;
@property (weak, nonatomic)   id<TEALModulesDelegate> modulesDelegate;

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
                [weakInstance.logger logNormal:@"Instance ready."];
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
        [self.logger logNormal:(@"Invalid Configuration, check your account, profile and enviornment options.")];
        if (setupCompletion) {
            setupCompletion(NO, nil);
        }
        return;
    }
    
    [self.logger logNormal:@"%@", configuration];
    
    self.enabled = YES;
    self.dataSources = [[TEALDataSources alloc]initWithInstanceID:configuration.instanceID];
    
    __block typeof(self) __weak weakSelf = self;

    [self setupSettingsWithConfiguration:configuration completion:^(BOOL success, NSError *error) {
        
        if (success) {

            [weakSelf setupCore];
            [weakSelf setupModules];
            
        } else {
            
            [weakSelf.logger logNormal:@"Problem creating instance: %@", [error localizedDescription]];
            [weakSelf disable];
            
        }
        
        if (setupCompletion) setupCompletion(success, error);

    }];
    
}

- (void) setupCore {
    self.dispatchManager = [TEALDispatchManager dispatchManagerWithConfiguration:self
                                                                        delegate:self];
    [self setupSettingsReachabilityCallbacks];
}

- (void) setupModules {
    
    self.modulesDelegate = self;
    
    if ([self.settings autotrackingIvarsEnabled]){
        if ([self.modulesDelegate respondsToSelector:@selector(enableAutotrackingIvars)]){
            [self.modulesDelegate enableAutotrackingIvars];
        }
    }
    
    if ([self.settings autotrackingLifecycleEnabled]){
        if ([self.modulesDelegate respondsToSelector:@selector(enableAutotrackingLifecycle)]){
            [self.modulesDelegate enableAutotrackingLifecycle];
        }
    }
    
    if ([self.settings tagManagementEnabled]){
        if ([self.modulesDelegate respondsToSelector:@selector(enableTagManagement)]){
            [self.modulesDelegate enableTagManagement];
        }
        
        if ([self.settings remoteCommandsEnabled]){
            if ([self.modulesDelegate respondsToSelector:@selector(enableRemoteCommands)]){
                [self.modulesDelegate enableRemoteCommands];
            }
        }
    }
    
    
    if ([self.settings audienceStreamEnabled]){
        if ([self.modulesDelegate respondsToSelector:@selector(enableAudienceStream)]){
            [self.modulesDelegate enableAudienceStream];
        }
    }
    
    if ([self.settings autotrackingUIEventsEnabled]) {
        if ([self.modulesDelegate respondsToSelector:@selector(enableAutotrackingUIEvents)]){
            [self.modulesDelegate enableAutotrackingUIEvents];
        }
    }
    if ([self.settings autotrackingViewsEnabled]) {
        if ([self.modulesDelegate respondsToSelector:@selector(enableAutotrackingViews)]){
            [self.modulesDelegate enableAutotrackingViews];
        }
    }
    
}

- (NSArray *) currentDispatchNetworkServices {
    
    NSArray *array = nil;
    
    if (!self.dispatchNetworkServices) {
        
        array = [[NSArray alloc] init];
        
    }
    else {
        array = self.dispatchNetworkServices;
    }
    
    return array;
}

- (void) setCurrentDispatchNetworkServices:(NSArray *)newServices {
    
    self.dispatchNetworkServices = nil;
    self.dispatchNetworkServices = newServices;
    
}

- (void) sendEvent:(TEALDispatchType)eventType withData:(NSDictionary *)customData title:(NSString *)title{
    
        NSLog(@"%s ", __FUNCTION__);
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
    
        NSLog(@"%s about to add dispatch", __FUNCTION__);
    [self.dispatchManager addDispatch:dispatch
                      completionBlock:completion];
    
    [self.dispatchManager archiveDispatchQueue];
}

- (void) dispatchManager:(TEALDispatchManager *)dispatchManager didProcessDispatch:(TEALDispatch *)dispatch status:(TEALDispatchStatus)status {
    // Log + Fetch Profile

#warning UPDATE To use NSNotifications
    
    [self logDispatch:dispatch status:status];
    [self notifyDispatch:dispatch status:status];
    
#warning Move to Collect module
    
    if ([self.settings pollingFrequency] == TEALVisitorProfilePollingFrequencyOnRequest) {
        return;
    }
    
//    [self fetchVisitorProfileWithCompletion:^(TEALVisitorProfile *profile, NSError *error) {
//        
//        TEAL_LogVerbose(@"did fetch profile: %@ after dispatch event", profile);
//    }];
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

- (void) setupSettingsWithConfiguration:(TEALConfiguration *) configuration completion:(TEALBooleanCompletionBlock)setupCompletion{
    
    self.settings = [[TEALSettings alloc] initWithConfiguration:configuration];
    self.settings.visitorIDCopy = [self.dataSources visitorIDCopy];
//    [self.settings setVisitorIDCopy:self.dataSources.visitorIDCopy];
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

- (NSString *) description {
    
    NSString *version = TEALLibraryVersion;
    NSString *accountProfileEnvironment = [NSString stringWithFormat:@"%@/%@/%@", self.settings.account, self.settings.tiqProfile, self.settings.environment];
    
    return [NSString stringWithFormat:@"TEALIUM %@: instance:%@: ", version, accountProfileEnvironment];
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

- (BOOL) isEnabled {
    return self.enabled? YES: NO;
}

- (void) trackEventWithTitle:(NSString *)title dataSources:(NSDictionary *)clientDataSources {
    
    // capture time datasources
    NSDictionary *captureTimeDataSources = [TEALSystemHelpers compositeDictionaries:@[
                                                                         [self.dataSources captureTimeDatasourcesForEventType:TEALDispatchTypeEvent title:title],
                                                                         clientDataSources
                                                                         ]];
    
    __weak Tealium *weakSelf = self;
    
    [weakSelf.operationManager addOperationWithBlock:^{
       
        [weakSelf sendEvent:TEALDispatchTypeEvent withData:captureTimeDataSources title:title];

    }];
    
}

- (void) trackViewWithTitle:(NSString *)title dataSources:(NSDictionary *)clientDataSources {
    
    NSDictionary *captureTimeDataSources = [TEALSystemHelpers compositeDictionaries:@[
                                                                         [self.dataSources captureTimeDatasourcesForEventType:TEALDispatchTypeEvent title:title],
                                                                         clientDataSources
                                                                         ]];
    __weak Tealium *weakSelf = self;

    [weakSelf.operationManager addOperationWithBlock:^{
        
        [weakSelf sendEvent:TEALDispatchTypeView withData:captureTimeDataSources title:title];
        
    }];
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
    
    __block __weak TEALLogger *weakLogger = self.logger;
    
    // one more check for network and settings
    if ([self shouldAttemptDispatch]) {
        
        if  ([self.delegateManager tealium:self shouldSendDispatch:dispatch]) {
            
            for ( id<TEALDispatchService> service in [self currentDispatchNetworkServices]) {
                
                [service sendDispatch:dispatch
                           completion:^(TEALDispatchStatus status, TEALDispatch *dispatch, NSError *error) {
                               
                               [weakLogger logVerbose:[NSString stringWithFormat:@"\n %@ \n status: %lu \n errors:%@", dispatch, (unsigned long)status, error? [error localizedDescription]:@""]];
                               
                           }];
            }
            
            completionBlock(TEALDispatchStatusSent, dispatch, nil);

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

@end
