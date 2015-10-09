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
    
    if (!key){
        return nil;
    }
    
    configuration.instanceID = key;
    
    Tealium *instance = [Tealium instanceWithConfiguration:configuration completion:^(BOOL success, NSError *error) {
        
        if (error) {
            
            NSLog(@"Problem initializing Tealium instance: %@ \nerror:%@ \nreason:%@ \nsuggestion:%@",
             key, [error localizedDescription], [error localizedFailureReason], [error localizedRecoverySuggestion]);
             
        }
        
    }];
    
    if (instance) [Tealium addInstance:instance key:key];
    
    return instance;
    
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
        [self disableCore];
        [self disableModules];
        
        [self.logger logQA:@"Library Disabled."];
        [self.logger disable];
        self.enabled = NO;
    }
}

- (void) enable {
    
    [self.logger logQA:@"Library Enabled."];

    @synchronized(self) {
        [self enableCore];
        [self enableModules];
        [self.logger enable];
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
    
    if (!self.isEnabled) return;
    
    NSDictionary *universalInfo = [self universalTrackDataSources];
    NSDictionary *captureTimeDataSources = [self.dataSources captureTimeDatasourcesForEventType:TEALDispatchTypeEvent title:title];
    
    NSDictionary *compositeDataSources = [TEALSystemHelpers compositeDictionaries:@[
                                                                                    universalInfo? universalInfo:@{},
                                                                                    captureTimeDataSources? captureTimeDataSources:@{},
                                                                                    clientDataSources? clientDataSources:@{}
                                                                                    ]];
    
    TEALDispatch *dispatch = [TEALDispatch dispatchForType:TEALDispatchTypeEvent withPayload:compositeDataSources];

    __weak Tealium *weakSelf = self;
    
    [weakSelf.operationManager addOperationWithBlock:^{
       
        [weakSelf trackDispatch:dispatch];

    }];
    
}

- (void) trackViewWithTitle:(NSString *)title dataSources:(NSDictionary *)clientDataSources {
    
    if (!self.isEnabled) return;

    NSDictionary *universalDataSources = [self universalTrackDataSources];
    NSDictionary *captureTimeDataSources = [self.dataSources captureTimeDatasourcesForEventType:TEALDispatchTypeView title:title];
    
    NSMutableArray *dataToComposite = [NSMutableArray array];
    
    if (universalDataSources)   [dataToComposite addObject:universalDataSources];
    if (captureTimeDataSources) [dataToComposite addObject:captureTimeDataSources];
    if (clientDataSources)      [dataToComposite addObject:clientDataSources];

    NSDictionary *compositeDataSources = [TEALSystemHelpers compositeDictionaries:dataToComposite];
    
    TEALDispatch *dispatch = [TEALDispatch dispatchForType:TEALDispatchTypeEvent withPayload:compositeDataSources];

    __weak Tealium *weakSelf = self;

    [weakSelf.operationManager addOperationWithBlock:^{
        
        [weakSelf trackDispatch:dispatch];
        
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
    NSDictionary *connectionInfo = [self.urlSessionManager.reachability connectionDataSources];
    NSDictionary *deviceInfo = self.settings.autotrackingDeviceInfoEnabled? [TEALDataSources deviceInfoDataSources]:@{};
    NSDictionary *tealiumInfo = [TEALDataSources tealiumInfoDataSources];
    
    NSDictionary *clientVolatileInfo = [self.dataSources clientVolatileDataSources];
    
    NSDictionary *compositeDataSources = [TEALSystemHelpers compositeDictionaries:@[
                                                                                    applicationInfo,
                                                                                    carrierInfo,
                                                                                    connectionInfo,
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
        [self.logger logProd:@"Non-array passed into argument of removeVolatileDataSourcesForKey: method."];
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

+ (instancetype) instanceWithConfiguration:(TEALConfiguration *)configuration completion:(TEALBooleanCompletionBlock) completion{
    
    Tealium *instance = [[Tealium alloc] initPrivate];
    
    __weak Tealium *weakInstance = instance;
    
    [weakInstance.operationManager addOperationWithBlock:^{
        
        [weakInstance privateInstanceWithConfiguration:configuration completion:^(BOOL success, NSError *error) {
            
            if (success) {
                
                [weakInstance.dispatchManager runQueuedDispatches];
                
            } else {
                
                [weakInstance disable];
                
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

- (void) privateInstanceWithConfiguration:(TEALConfiguration *)configuration
                        completion:(TEALBooleanCompletionBlock)setupCompletion {
    
    BOOL success = NO;
    NSError *error = nil;
    
    // Check configuration
    if (![TEALConfiguration isValidConfiguration:configuration]) {
        
        error = [TEALError errorWithCode:TEALErrorCodeMalformed
                                      description:@"Could not initialize instance."
                                           reason:@"Invalid Configuration."
                                       suggestion:@"Check the account, profile and environment options."];

    }
    
    // Init data sources
    self.dataSources = [[TEALDataSources alloc]initWithInstanceID:configuration.instanceID];
    if (!error &&
        !self.dataSources) {
        error =[TEALError errorWithCode:TEALErrorCodeFailure
                            description:@"Could not initialize data sources."
                                 reason:@"Unknown problem with initialization."
                             suggestion:@"Consult Tealium Mobile Engineering - Tealium Line 400"];
    }
    
#warning What will handle update in application version check and notification?
    
    // Init Settings
    self.settings = [self settingsFromConfiguration:configuration];
    if (!error &&
        !self.settings){
        error = [TEALError errorWithCode:TEALErrorCodeFailure
                             description:NSLocalizedString(@"Could not initialize settings.", @"")
                                  reason:NSLocalizedString(@"Unknown problem with initialization", @"")
                              suggestion:NSLocalizedString(@"Consult Tealium Mobile Engineering - Tealium Line 410", @"")];
    }
    
    // Init logger
    self.logger = [[TEALLogger alloc] initWithInstanceID:configuration.instanceID];
    [self.logger updateLogLevel:[self.settings logLevel]];
    [self.logger logProd:[NSString stringWithFormat:@"Log level: %@", [TEALLogger logLevelStringFromLogLevel:[self.logger currentLogLevel]]]];
    if (!error &&
        !self.logger) {
        
        error = [TEALError errorWithCode:TEALErrorCodeFailure
                             description:NSLocalizedString(@"Could not initialize logger.", @"")
                                  reason:NSLocalizedString(@"Unknown problem with initialization.", @"")
                              suggestion:NSLocalizedString(@"Consult Tealium Mobile Engineering - Tealium Line 388", @"")];
        
    } else {
    
        [self.logger logDev:@"Configuration: %@", [self.settings configurationDescription]];
        [self.logger logDev:@"Remote Publish Settings: %@", [self.settings publishSettingsDescription]];
    }

    // Finalize
    if (!error) {
        
        success = YES;
        [self enable];

    }

    if (setupCompletion) setupCompletion(success, error);

}

- (void) addModuleData:(NSDictionary *) dictionary {
    
    NSMutableDictionary *mDict = [[NSMutableDictionary alloc] init];
    [mDict addEntriesFromDictionary:self.moduleData];
    [mDict addEntriesFromDictionary:dictionary];
    
    NSDictionary *newModuleData = [NSDictionary dictionaryWithDictionary:mDict];
    
    self.moduleData = newModuleData;
    
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

- (void) enableCore {
    self.dispatchManager = [TEALDispatchManager dispatchManagerWithConfiguration:self
                                                                        delegate:self];
    [self setupSettingsReachabilityCallbacks];
}

- (void) enableModules {
    
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
    
    if ([self.settings autotrackingCrashesEnabled]) {
        if ([self.modulesDelegate respondsToSelector:@selector(enableAutotrackingCrashes)]) {
            [self.modulesDelegate enableAutotrackingCrashes];
        }
    }
    
}

- (void) disableCore {
#warning IMPLEMENT
    
}

- (void) disableModules {
    
#warning IMPLEMENT
    
    if ([self.modulesDelegate respondsToSelector:@selector(disableAutotrackingCrashes)]){
        [self.modulesDelegate disableAutotrackingCrashes];
    }
    if ([self.modulesDelegate respondsToSelector:@selector(disableAutotrackingLifecycle)]) {
        [self.modulesDelegate disableAutotrackingLifecycle];
    }
    if ([self.modulesDelegate respondsToSelector:@selector(disableUIEventAutotracking)]) {
        [self.modulesDelegate disableAutotrackingUIEvents];
    }
    if ([self.modulesDelegate respondsToSelector:@selector(disableViewAutotracking)]) {
        [self.modulesDelegate disableAutotrackingViews];
    }
    if ([self.modulesDelegate respondsToSelector:@selector(disableMobileCompanion)]) {
        [self.modulesDelegate disableMobileCompanion];
    }
    if ([self.modulesDelegate respondsToSelector:@selector(disableRemoteCommands)]) {
        [self.modulesDelegate disableRemoteCommands];
    }
}

- (void) setCurrentDispatchNetworkServices:(NSArray *)newServices {
    
    self.dispatchNetworkServices = nil;
    self.dispatchNetworkServices = newServices;
    
}

- (void) setActiveViewController:(UIViewController *)viewController {

    [self.logger logDev:@"Current View Controller is now: %@", viewController];
    
    self.privateActiveViewController = viewController;
}

- (void) trackDispatch:(TEALDispatch *) dispatch {
    
    __block typeof(self) __weak weakSelf = self;
    
    [self.dispatchManager addDispatch:dispatch
                      completionBlock:^(TEALDispatchStatus status, TEALDispatch *dispatch, NSError *error) {
                          
                          [weakSelf logDispatch:dispatch status:status error:error];
                          [weakSelf notifyDelegateOfDispatch:dispatch status:status];
                          
#warning Move to Collect module
                          
                          if ([weakSelf.settings pollingFrequency] == TEALVisitorProfilePollingFrequencyOnRequest) {
                              return;
                          }
                          
                      }];
    
}

- (void) logDispatch:(TEALDispatch *) dispatch status:(TEALDispatchStatus) status error:(NSError *)error{
    
    if ([self.settings logLevel] >= TEALLogLevelNone) {
        
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
            
            [self.logger logDev:@"%@ dispatch with payload %@%@%@", statusString, datalayerDump, error? reason:@"", error? suggestion:@""];
            
        } else {
            
            [self.logger logDev:@"%@ dispatch: %@%@%@", statusString, dispatch, error? reason:@"", error? suggestion:@""];
            
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

- (TEALSettings *) settingsFromConfiguration:(TEALConfiguration *) configuration {
    
    TEALSettings *settings = [[TEALSettings alloc] initWithConfiguration:configuration];
    settings.visitorIDCopy = [self.dataSources visitorIDCopy];
    settings.urlSessionManager = self.urlSessionManager;
    
    return settings;
}

- (void) fetchNewSettingsWithCompletion:(TEALBooleanCompletionBlock)completion {
    
    __block typeof(self) __weak weakSelf = self;
    
    [self.settings fetchNewRawPublishSettingsWithCompletion:^(NSDictionary *dataDictionary, NSError *error) {
        
        BOOL success = NO;

        if (dataDictionary){
            
            // New raw setting found
            success = YES;
            
        }
        
        if (completion) completion (success, error);
    }];
    
}

- (void) setupSettingsReachabilityCallbacks {
    
#warning DISABLE CALLBACKS IF LIBRARY DISABLED - PERMIT ONLY AT LAUNCH TIME TO CHECK FOR CHANGE
    
    if (self.urlSessionManager.reachability.reachableBlock) {
        return;
    }
    
    [self.urlSessionManager.reachability startNotifier];
    
    __weak Tealium *weakSelf = self;
    
    weakSelf.urlSessionManager.reachability.reachableBlock = ^(TEALReachabilityManager *reachability) {
        
        [weakSelf.logger logDev:@"Network found."];
        
        [weakSelf fetchNewSettingsWithCompletion:^(BOOL success, NSError *error) {
            
            if (error){
                [weakSelf.logger logProd:[NSString stringWithFormat:@"%@ \nReason:%@ \nSuggestion:%@",
                                             [error localizedDescription],
                                             [error localizedFailureReason],
                                             [error localizedRecoverySuggestion]
                                             ]];
            }
            
            if (success){
                
                [weakSelf.logger logDev:@"New Remote Publish Settings: %@", [weakSelf.settings publishSettingsDescription]];
                
                [weakSelf.logger updateLogLevel:[weakSelf.settings logLevel]];
                [self.logger logDev:[NSString stringWithFormat:@"Log level: %@", [TEALLogger logLevelStringFromLogLevel:[self.logger currentLogLevel]]]];

#warning REPLACE WITH AN UPDATE SYSTEM
                [weakSelf enableModules];

            }
            
            if ([weakSelf.settings libraryShouldDisable]){
                
                [weakSelf disable];
                
                return;
            }
            
            [weakSelf.dispatchManager runQueuedDispatches];

        }];
        
    };
    
    weakSelf.urlSessionManager.reachability.unreachableBlock = ^(TEALReachabilityManager *reachability) {
        
        [self.logger logDev:@"Network unreachable."];

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

- (BOOL) networkReadyForDispatch {
    
    BOOL reachable = [self.urlSessionManager.reachability isReachable];
    
    return reachable;
    
}

- (BOOL) suppressForWifiOnly {
    
    BOOL suppress = NO;
    if ([self.settings wifiOnlySending]){
        suppress = ![self.urlSessionManager.reachability isReachableViaWiFi];
    }
    
    return suppress;
}

- (BOOL) suppressForBetterBatteryLevels {
    // 20% is cutoff
    
    BOOL suppress = NO;
    double batteryLevel = [self.dataSources deviceBatteryLevel];
    
    if ([self.settings goodBatteryLevelOnlySending] &&
        (batteryLevel < 20.0 && batteryLevel >= 0)) {
            
        suppress = YES;
    }
    
    return suppress;

}

#pragma mark - TEALDISPATCHMANAGER DELEGATE

 //Agnostic - use configuration
 // TODO: handle wifi only, low battery and other settings
 // ~commHandlers big if else checks

- (BOOL) dispatchManagerShouldDispatch {
    
    BOOL shouldDispatch = YES;
    
    if (!self.settings ||
        ![self networkReadyForDispatch] ||
        [self suppressForWifiOnly] ||
        [self suppressForBetterBatteryLevels]){
        
        shouldDispatch = NO;
    }
    
    return shouldDispatch;
}

- (void) dispatchManager:(TEALDispatchManager *)dataManager
        requestsDispatch:(TEALDispatch *)dispatch
         completionBlock:(TEALDispatchBlock)completionBlock {
    
    // Pass dispatch to dispatch services
    for ( id<TEALDispatchService> service in [self currentDispatchNetworkServices]) {
        
        [service sendDispatch:dispatch
                   completion:^(TEALDispatchStatus serviceStatus, TEALDispatch *serviceDispatch, NSError *serviceError) {
                       
                       dispatch.dispatchServiceName = [service name];
            
                       if (completionBlock) completionBlock(serviceStatus, serviceDispatch, serviceError);
                       
                   }];
    }
    
}

- (void) dispatchManagerWillEnqueueDispatch:(TEALDispatch *)dispatch {
    
}

- (void) dispatchManagerdDidEnqueueDispatch:(TEALDispatch *)dispatch {
    
    [self.delegateManager tealium:self didQueueDispatch:dispatch];
    
}

- (void) dispatchManagerdDidUpdateDispatchQueues {
    
}

- (BOOL) dispatchManagerdShouldPurgeDispatch:(TEALDispatch *)dispatch {
    
    BOOL hasExpired = NO;
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:dispatch.timestamp];
    NSDate *now = [NSDate date];
    
    double shelfLife = self.settings.daysDispatchesValid;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay
                                               fromDate:date
                                                 toDate:now
                                                options:0];
    double daysPast = (double)[components day];
    
    if(daysPast > shelfLife && shelfLife >= 0) {
        hasExpired = YES;
    }
    
    return hasExpired;

}

- (void) dispatchManagerdDidPurgeDispatch:(TEALDispatch *)dispatch {

}

- (void) dispatchManagerdWillRunDispatchQueueWithCount:(NSUInteger)count {
    
}

- (void) dispatchManagerdDidRunDispatchQueueWithCount:(NSUInteger)count {
    
}

#pragma mark - TEALDISPATCHMANAGER CONFIGURATION

- (NSUInteger) dispatchBatchSize {
    
    return [self.settings dispatchSize];
}

- (NSUInteger) dispatchQueueCapacity {
        
    return [self.settings offlineDispatchQueueSize];
}

/**
 *  Return an error if the dispatch manager should not send now
 */
- (NSError *) errorSendingDispatch:(TEALDispatch *)dispatch {
    
    NSError *error = nil;
    NSArray *dispatchServices = [self currentDispatchNetworkServices];

    if (!self.enabled) {
        
        error = [TEALError errorWithCode:999
                             description:NSLocalizedString(@"Ignoring dispatch.", @"")
                                  reason:NSLocalizedString(@"Library currently disabled.", @"")
                              suggestion:NSLocalizedString(@"Re-enable library prior to track request.", @"")];
        
    } else if  (![self.delegateManager tealium:self shouldSendDispatch:dispatch]) {
        
        error = [TEALError errorWithCode:999
                             description:NSLocalizedString(@"Dispatch destroyed.", @"")
                                  reason:NSLocalizedString(@"Public delegate requested suppression of dispatch.", @"")
                              suggestion:NSLocalizedString(@"See implemented tealium:shouldSendDispatch delegate method.", @"")];
        
    } else if ([self.delegateManager tealium:self shouldQueueDispatch:dispatch]) {

        error = [TEALError errorWithCode:400
                             description:NSLocalizedString(@"Dispatch queued.", @"")
                                  reason:NSLocalizedString(@"Public delegate requested queing of dispatch.", @"")
                              suggestion:NSLocalizedString(@"See implemented tealium:shouldQueueDispatch delegate method.", @"")];
        
    } else if (![self networkReadyForDispatch]) {
            
        error = [TEALError errorWithCode:400
                             description:NSLocalizedString(@"Dispatch queued.", @"")
                                  reason:NSLocalizedString(@"No network detected.", @"")
                              suggestion:NSLocalizedString(@"Wait for network availability.", @"")];
        
    } else if ([self suppressForWifiOnly]) {
        
        error = [TEALError errorWithCode:400
                             description:NSLocalizedString(@"Dispatch queued.", @"")
                                  reason:NSLocalizedString(@"Queing calls for wifi only.", @"")
                              suggestion:NSLocalizedString(@"Wait for wifi availability.", @"")];
        
    } else if ([self suppressForBetterBatteryLevels]) {
        
        error = [TEALError errorWithCode:400
                             description:NSLocalizedString(@"Dispatch queued.", @"")
                                  reason:NSLocalizedString(@"Queing calls due to low battery level.", @"")
                              suggestion:NSLocalizedString(@"Wait for battery levels to be above 20%.", @"")];
        
    } else if (!dispatchServices ||
             [dispatchServices count] == 0) {
        
        error = [TEALError errorWithCode:400
                             description:NSLocalizedString(@"Dispatch queued.", @"")
                                  reason:NSLocalizedString(@"No active dispatch services enabled to process dispatch.", @"")
                              suggestion:NSLocalizedString(@"Check TIQ Mobile Publish Settings and make sure at least one dispatch service option is enabled.", @"")];
        
    }
    
    return error;
}

@end
