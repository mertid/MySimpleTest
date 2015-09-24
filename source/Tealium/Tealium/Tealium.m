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
#import "TEALExceptionHandler.h"
#import "TEALError.h"
#import "TEALOperationManager.h"
#import "TEALLogger.h"
#import "TEALModulesDelegate.h"
#import "TEALNetworkHelpers.h"
#import "TEALOperationManager.h"
#import "TEALSettings+PrivateHeader.h"
#import "TEALSystemHelpers.h"
#import "TEALTimestampDataSources.h"
#import "TEALURLSessionManager.h"

@interface Tealium () <
                        TEALDispatchManagerDelegate,
                        TEALDispatchManagerConfiguration,
                        TEALModulesDelegate>

@property (nonatomic, strong) NSArray *dispatchNetworkServices;
@property (nonatomic, strong) TEALLogger *logger;
@property (nonatomic, strong) TEALOperationManager *operationManager;
@property (nonatomic, strong) TEALURLSessionManager *urlSessionManager;
@property (nonatomic, strong) TEALDataSources *dataSources;
@property (nonatomic, strong) TEALDelegateManager *delegateManager;
@property (nonatomic, strong) TEALDispatchManager *dispatchManager;
@property (nonatomic, strong) TEALSettings *settings;
@property (nonatomic, weak) id<TealiumDelegate> delegate;
@property (nonatomic, weak) id<TEALModulesDelegate> modulesDelegate;
@property (nonatomic, weak) UIViewController *privateActiveViewController;

@property (nonatomic, strong) NSDictionary *moduleData;

@property (readwrite) BOOL enabled;

@end

__strong static NSDictionary *staticAllInstances = nil;

@implementation Tealium

#pragma mark - PUBLIC CLASS METHODS


+ (instancetype) newInstanceForKey:(NSString *)key configuration:(TEALConfiguration *)configuration {
    
    return [Tealium instanceForKey:key configuration:configuration completion:nil];

}


+ (instancetype) instanceForKey:(NSString *)key {
    
    if (!key) {
        return nil;
    }
    
    Tealium *instance = staticAllInstances[key];
    
    return instance;
    
}


+ (void) destroyInstanceForKey:(NSString *)key {
    
    if (!key) {
        return;
    }
    
    Tealium *instance = [Tealium instanceForKey:key];
    instance = nil;
    
    [Tealium removeInstanceWithKey:key];
    
}


#pragma mark - PUBLIC INSTANCE METHODS

- (id<TealiumDelegate>) delegate {
    @synchronized(self){
        return self.delegateManager.delegate;
    }
}

- (void) disable {
    @synchronized(self) {
#warning remove all observers in all objects here
        
        self.enabled = NO;
    }
}

- (void) enable {
    
    @synchronized(self) {
        
        self.enabled = YES;
    }
}

- (void) setDelegate:(id<TealiumDelegate> _Nullable)delegate {
    
    @synchronized(self){
        
        [self.delegateManager updateWithDelegate:delegate];
    }
    
}


- (BOOL) isEnabled {
    return self.enabled? YES: NO;
}

- (void) trackEventWithTitle:(NSString *)title dataSources:(NSDictionary *)clientDataSources {
    
    NSDictionary *universalInfo = [self universalTrackDataSources];
    NSDictionary *captureTimeDataSources = [self.dataSources captureTimeDatasourcesForEventType:TEALDispatchTypeEvent title:title];
    
    NSDictionary *compositeDataSources = [TEALSystemHelpers compositeDictionaries:@[
                                                                                    universalInfo? universalInfo:@{},
                                                                                    captureTimeDataSources? captureTimeDataSources:@{},
                                                                                    clientDataSources? clientDataSources:@{}
                                                                                    ]];
    
    __weak Tealium *weakSelf = self;
    
    [weakSelf.operationManager addOperationWithBlock:^{
       
        [weakSelf sendEvent:TEALDispatchTypeEvent withData:compositeDataSources title:title];

    }];
    
}

- (void) trackViewWithTitle:(NSString *)title dataSources:(NSDictionary *)clientDataSources {
    
    NSDictionary *universalDataSources = [self universalTrackDataSources];
    NSDictionary *captureTimeDataSources = [self.dataSources captureTimeDatasourcesForEventType:TEALDispatchTypeView title:title];
    
    NSMutableArray *dataToComposite = [NSMutableArray array];
    
    if (universalDataSources)   [dataToComposite addObject:universalDataSources];
    if (captureTimeDataSources) [dataToComposite addObject:captureTimeDataSources];
    if (clientDataSources)      [dataToComposite addObject:clientDataSources];

    NSDictionary *compositeDataSources = [TEALSystemHelpers compositeDictionaries:dataToComposite];
    
    __weak Tealium *weakSelf = self;

    [weakSelf.operationManager addOperationWithBlock:^{
        
        [weakSelf sendEvent:TEALDispatchTypeView withData:compositeDataSources title:title];
        
    }];
}

- (NSDictionary *) universalTrackDataSources {
    
    NSDictionary *persistentDataSources = [self persistentDataSourcesCopy];
    NSDictionary *timestampDataSources = [self.settings autotrackingTimestampInfoEnabled]? [TEALTimestampDataSources dataSourcesForDate:[NSDate date]]:@{};
    NSDictionary *volatileDataSources = [self volatileDataSourcesCopy];
    NSDictionary *compositeDataSources = [TEALSystemHelpers compositeDictionaries:@[
                                                                                    persistentDataSources? persistentDataSources:@{},
                                                                                    timestampDataSources,
                                                                                    volatileDataSources? volatileDataSources:@{}
                                                                                    ]];
    
    return compositeDataSources;
    
}

- (NSDictionary *) volatileDataSourcesCopy {
    
    NSDictionary *applicationInfo = self.settings.autotrackingApplicationInfoEnabled? [TEALDataSources applicationInfoDataSources]:@{};
    NSDictionary *carrierInfo = self.settings.autotrackingCarrierInfoEnabled? [TEALDataSources carrierInfoDataSources]:@{};
    NSDictionary *deviceInfo = self.settings.autotrackingDeviceInfoEnabled? [TEALDataSources deviceInfoDataSources]:@{};
    NSDictionary *tealiumInfo = [TEALDataSources tealiumInfoDataSources];
    NSDictionary *clientVolatileInfo = [self.dataSources clientVolatileDataSources];
    
    NSDictionary *compositeDataSources = [TEALSystemHelpers compositeDictionaries:@[
                                                                                    applicationInfo,
                                                                                    carrierInfo,
                                                                                    deviceInfo,
                                                                                    tealiumInfo? tealiumInfo:@{},
                                                                                    clientVolatileInfo? clientVolatileInfo:@{},
                                                                                    ]];
    
    return compositeDataSources;
}

- (void) addVolatileDataSources:(NSDictionary *)additionalDataSources {
 
    __block typeof(self) __weak weakSelf = self;
    
    [self.operationManager addOperationWithBlock:^{
        [[weakSelf.dataSources clientVolatileDataSources] addEntriesFromDictionary:[additionalDataSources copy]];
    }];
}

- (void) removeVolatileDataSourcesForKeys:(NSArray *)dataSourceKeys {
    
    if (![dataSourceKeys isKindOfClass:([NSArray class])]) {
        [self.logger logWarning:@"Non-array passed into argument of removeVolatileDataSourcesForKey: method."];
        return;
        
    }
    __block typeof(self) __weak weakSelf = self;
    __block NSArray *keys = [dataSourceKeys copy];
    
    [self.operationManager addOperationWithBlock:^{
        [[weakSelf.dataSources clientVolatileDataSources] removeObjectsForKeys:keys];
    }];
}

- (NSDictionary *) persistentDataSourcesCopy {
    return [self.dataSources persistentDataSourcesCopy];
}

- (void) addPersistentDataSources:(NSDictionary *)additionalDataSources {

    __block typeof(self) __weak weakSelf = self;

    [self.operationManager addOperationWithBlock:^{
        [weakSelf.dataSources addPersistentDataSources:additionalDataSources];

    }];
    
}

- (void) removePersistentDataSourcesForKeys:(NSArray *)dataSourceKeys {
    
    __block typeof(self) __weak weakSelf = self;

    [self.operationManager addOperationWithBlock:^{
        [weakSelf.dataSources removePersistentDataSourceForKeys:dataSourceKeys];

    }];
}

#pragma mark - PRIVATE CLASS METHODS

+ (instancetype) instanceForKey:(NSString *)key configuration:(TEALConfiguration *)configuration completion:(TEALBooleanCompletionBlock)completion {

    if (!key){
        return nil;
    }
    
    configuration.instanceID = key;
    
    Tealium *instance = [Tealium instanceWithConfiguration:configuration completion:completion];
    
    [Tealium addInstance:instance key:key];
    
    return instance;
    
}

+ (instancetype) instanceWithConfiguration:(TEALConfiguration *)configuration completion:(TEALBooleanCompletionBlock) completion{
    
    Tealium *instance = [[Tealium alloc] initPrivate];
    
    __weak Tealium *weakInstance = instance;
    
    [weakInstance.operationManager addOperationWithBlock:^{
        [weakInstance instanceWithConfiguration:configuration completion:^(BOOL success, NSError *error) {
            if (success) {
                [weakInstance.dispatchManager runQueuedDispatches];
            } else {
                [weakInstance disable];
                [weakInstance.logger logNormal:@"Failed to start: %@", error ];
            }
            if (completion) completion(success, error);
        }];
    }];
    
    return instance;
}

+ (NSDictionary *) allInstances {
    return staticAllInstances;
}

+ (void) addInstance:(Tealium *)instance key:(NSString *)key {
    
    if (!instance ||
        !key) {
        return;
    }
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:[staticAllInstances copy]];
    mDict[key] = instance;
    
    NSDictionary *newInstances = [NSDictionary dictionaryWithDictionary:mDict];

    staticAllInstances = newInstances;
}

+ (void) removeInstanceWithKey:(NSString *)key {
    
    if (!key) {
        return;
    }
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:[staticAllInstances copy]];
    [mDict removeObjectForKey:key];
    
    NSDictionary *newInstances = [NSDictionary dictionaryWithDictionary:mDict];
    
    staticAllInstances = newInstances;
    
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
    
    if (!self.dataSources) {
        [self.logger logNormal:@"Datasources did not init - Could not instantiate library"];
        NSError *error =[TEALError errorWithCode:400
                                     description:@"Could not init library instance."
                                          reason:@"DataSources failed to init."
                                      suggestion:@"Check that all configuration data is correct."];
        if (setupCompletion) setupCompletion(NO, error);
        return;
    }
    
    __block typeof(self) __weak weakSelf = self;
    
#warning What will handle update in application version check and notification?
    
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

- (void) addModuleData:(NSDictionary *) dictionary {
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:self.moduleData];
    [mDict addEntriesFromDictionary:dictionary];
    
    NSDictionary *newModuleData = [NSDictionary dictionaryWithDictionary:mDict];
    
    __block typeof(self) __weak weakSelf = self;
    
    [self.operationManager addOperationWithBlock:^{
        weakSelf.moduleData = newModuleData;
    }];
    
}

- (void) removeModuleDataForKey:(NSString *)key {
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:[self.moduleData copy]];
    
    if (![[mDict allKeys] containsObject:key]){
        return;
    }
    
    [mDict removeObjectForKey:key];
    
    NSDictionary *dict = [NSDictionary dictionaryWithDictionary:mDict];
    
    self.moduleData = dict;
    
}

- (void) setupCore {
    self.dispatchManager = [TEALDispatchManager dispatchManagerWithConfiguration:self
                                                                        delegate:self];
    [self setupSettingsReachabilityCallbacks];
}

- (void) setupModules {
    
    self.modulesDelegate = self;
    
    if ([self.settings autotrackingLifecycleEnabled]){
        if ([self.modulesDelegate respondsToSelector:@selector(enableAutotrackingLifecycle)]) {
            [self.modulesDelegate enableAutotrackingLifecycle];
        }
    }
    
    if ([self.settings tagManagementEnabled]){
        if ([self.modulesDelegate respondsToSelector:@selector(enableTagManagement)]) {
            [self.modulesDelegate enableTagManagement];
        }
        
        if ([self.settings remoteCommandsEnabled]){
            if ([self.modulesDelegate respondsToSelector:@selector(enableRemoteCommands)]) {
                [self.modulesDelegate enableRemoteCommands];
            }
        }
    }
    
    if ([self.settings audienceStreamEnabled]){
        if ([self.modulesDelegate respondsToSelector:@selector(enableAudienceStream)]) {
            [self.modulesDelegate enableAudienceStream];
        }
    }
    
    if ([self.settings autotrackingUIEventsEnabled]) {
        if ([self.modulesDelegate respondsToSelector:@selector(enableAutotrackingUIEvents)]) {
            [self.modulesDelegate enableAutotrackingUIEvents];
        }
    }
    
    if ([self.settings autotrackingViewsEnabled]) {
        if ([self.modulesDelegate respondsToSelector:@selector(enableAutotrackingViews)]) {
            [self.modulesDelegate enableAutotrackingViews];
        }
    }
    
    if ([self.settings mobileCompanionEnabled]) {
        if ([self.modulesDelegate respondsToSelector:@selector(enableMobileCompanion)]) {
            [self.modulesDelegate enableMobileCompanion];
        }
    }
    
    if ([self.settings crashTrackingEnabled]) {
        if ([self.modulesDelegate respondsToSelector:@selector(enableAutotrackingCrashes)]) {
            [self.modulesDelegate enableAutotrackingCrashes];
        }
    }
    
}

- (void) disableModules {
    
#warning IMPLEMENT
    
}

- (void) setCurrentDispatchNetworkServices:(NSArray *)newServices {
    
    self.dispatchNetworkServices = nil;
    self.dispatchNetworkServices = newServices;
    
}

- (void) setActiveViewController:(UIViewController *)viewController {

    [self.logger logVerbose:@"Current View Controller is now: %@", viewController];
    
    self.privateActiveViewController = viewController;
}

- (void) sendEvent:(TEALDispatchType)eventType withData:(NSDictionary *)customData title:(NSString *)title{
    
    if (!self.enabled) {
        [self.logger logNormal:@"Library Disabled, Ignoring dispatch.",nil];
        [self.logger logVerbose:@"Dispatch title:%@, DataSources:%@", title, customData];
        return;
    }
    
    __weak Tealium *weakSelf = self;
    
    TEALDispatch *dispatch = [TEALDispatch dispatchForType:eventType withPayload:customData];
    
    [self.dispatchManager addDispatch:dispatch
                      completionBlock:^(TEALDispatchStatus status, TEALDispatch *dispatch, NSError *error) {
                          
                          [weakSelf logDispatch:dispatch status:status error:error];
                          [weakSelf notifyDelegateOfDispatch:dispatch status:status];
                          
#warning Move to Collect module
                          
                          if ([weakSelf.settings pollingFrequency] == TEALVisitorProfilePollingFrequencyOnRequest) {
                              return;
                          }
                          
#warning Enable a refetch system
                          //    [self fetchVisitorProfileWithCompletion:^(TEALVisitorProfile *profile, NSError *error) {
                          //
                          //        TEAL_LogVerbose(@"did fetch profile: %@ after dispatch event", profile);
                          //    }];
                          
                          [weakSelf.dispatchManager archiveDispatchQueue];

                      }];

}

- (void) logDispatch:(TEALDispatch *) dispatch status:(TEALDispatchStatus) status error:(NSError *)error{
    if ([self.settings logLevel] >= TEALLogLevelVerbose) {
        
        NSString *statusString = nil;
        
        switch (status) {
            case TEALDispatchStatusSent:
                statusString = @"Sent";
                break;
            case TEALDispatchStatusQueued:
                statusString = @"Queued";
                break;
            case TEALDispatchStatusShouldDestroy:
                statusString = @"Destroyed";
                break;
            case TEALDispatchStatusFailed:
                statusString = @"Failed to send";
                break;
            case TEALDispatchStatusUnknown:
                statusString = @"Unknown status for";
                break;
        }
        
        NSString *reason = [NSString stringWithFormat:@"\rReason: %@",[error localizedFailureReason]];
        NSString *suggestion = [NSString stringWithFormat:@"\rSuggestion: %@",[error localizedRecoverySuggestion]];
        
        if ([dispatch.payload isKindOfClass:[NSString class]]) {
            NSDictionary *datalayerDump = [TEALNetworkHelpers dictionaryFromUrlParamString:(NSString *)dispatch.payload];
            
            [self.logger logVerbose:@"%@ dispatch with payload %@%@%@", statusString, datalayerDump, error? reason:@"", error? suggestion:@""];
            
        } else {
            
            [self.logger logVerbose:@"%@ dispatch: %@%@%@", statusString, dispatch, error? reason:@"", error? suggestion:@""];
            
        }
    }
}

- (void) notifyDelegateOfDispatch:(TEALDispatch *) dispatch status:(TEALDispatchStatus) status {
    switch (status) {
        case TEALDispatchStatusSent:
            [self.delegateManager tealium:self didSendDispatch:dispatch];
            break;
        case TEALDispatchStatusQueued:
            [self.delegateManager tealium:self didQueueDispatch:dispatch];
            break;
        case TEALDispatchStatusShouldDestroy:
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
    
    [self.urlSessionManager.reachability startNotifier];
    
    __weak Tealium *weakSelf = self;
    __weak TEALSettings *weakSettings = weakSelf.settings;
    
    weakSelf.urlSessionManager.reachability.reachableBlock = ^(TEALReachabilityManager *reachability) {
        
        [self.logger logVerbose:@"Network found."];
#warning IMPLMENT minutes to refresh system here
        [weakSettings fetchPublishSettingsWithCompletion:nil];
    };
    
    weakSelf.urlSessionManager.reachability.unreachableBlock = ^(TEALReachabilityManager *reachability) {
        
        [self.logger logVerbose:@"Network unreachable."];

    };
}

- (NSArray *) currentDispatchNetworkServices {
    
    NSArray *array = nil;
    
    if (!self.dispatchNetworkServices) {
        
        array = [[NSArray alloc] init];
        
    } else {
        array = self.dispatchNetworkServices;
    }
    
    return array;
}

- (NSString *) description {
    
    NSString *version = TEALLibraryVersion;
    NSString *accountProfileEnvironment = [NSString stringWithFormat:@"%@/%@/%@", self.settings.account, self.settings.tiqProfile, self.settings.environment];
    
    return [NSString stringWithFormat:@"TEALIUM %@: instance:%@: ", version, accountProfileEnvironment];
}

- (NSDictionary *) moduleDataCopy {
    
    return [self.moduleData copy];
    
}

- (UIViewController *) activeViewController {
    
    return self.privateActiveViewController;
    
}

#pragma mark - TEALDISPATCHMANAGER DELEGATE

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
    
    
    // Prep
    NSError *error = nil;
    NSArray *dispatchServices = [self currentDispatchNetworkServices];
    TEALDispatchStatus status = TEALDispatchStatusUnknown;
    
    // Bail out checks
    if (![self shouldAttemptDispatch]) {
        
        status = TEALDispatchStatusQueued;
        error = [TEALError errorWithCode:400
                             description:NSLocalizedString(@"Dispatch queued.", @"")
                                  reason:NSLocalizedString(@"No network detected.", @"")
                              suggestion:NSLocalizedString(@"Waiting for network availability.", @"")];
    
    }
    else if  (![self.delegateManager tealium:self shouldSendDispatch:dispatch]) {

        status = TEALDispatchStatusShouldDestroy;
        error = [TEALError errorWithCode:400
                             description:NSLocalizedString(@"Dispatch destroyed.", @"")
                                  reason:NSLocalizedString(@"Public delegate requested suppression of dispatch.", @"")
                              suggestion:NSLocalizedString(@"See implemented tealium:shouldSendDispatch delegate method.", @"")];
    
    }
    else if (!dispatchServices ||
             [dispatchServices count] == 0) {
        
        status = TEALDispatchStatusQueued;
        error = [TEALError errorWithCode:400
                             description:NSLocalizedString(@"Dispatch queued.", @"")
                                  reason:NSLocalizedString(@"No active dispatch services enabled to process dispatch.", @"")
                              suggestion:NSLocalizedString(@"See your account TIQ Mobile Publish Setting and make sure at least one dispatch service option is enabled.", @"")];
        
    }
    
    if (error){
        if (completionBlock) completionBlock (status, dispatch, error);
        return;
    }
    
    // Queue check
    if ([self.delegateManager tealium:self shouldQueueDispatch:dispatch]) {
        status = TEALDispatchStatusQueued;
        if (completionBlock) completionBlock (status, dispatch, nil);
        return;
    }
    

    // Pass dispatch to dispatch services
    for ( id<TEALDispatchService> service in [self currentDispatchNetworkServices]) {
        
        [service sendDispatch:dispatch
                   completion:^(TEALDispatchStatus serviceStatus, TEALDispatch *serviceDispatch, NSError *serviceError) {
                       
                       dispatch.dispatchServiceName = [service name];
            
                       if (completionBlock) completionBlock(serviceStatus, serviceDispatch, serviceError);
                       
                   }];
    }
    
}

- (void) willEnqueueDispatch:(TEALDispatch *)dispatch {
    
}

- (void) didEnqueueDispatch:(TEALDispatch *)dispatch {
    
    [self.delegateManager tealium:self didQueueDispatch:dispatch];
    
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

#pragma mark - TEALDISPATCHMANAGER CONFIGURATION

- (NSUInteger) dispatchBatchSize {
    
    return [self.settings dispatchSize];
}

- (NSUInteger) dispatchQueueCapacity {
        
    return [self.settings offlineDispatchQueueSize];
}

@end
