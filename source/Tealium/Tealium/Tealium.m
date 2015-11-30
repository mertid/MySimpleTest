//
//  Tealium.m
//  Tealium
//
//  Created by George Webster on 7/15/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "Tealium.h"

#import "TEALDataSources.h"
#import "TEALDispatch+PrivateHeader.h"
#import "TEALDispatchManager.h"
#import "TEALDelegateManager.h"
#import "TEALDispatchService.h"
#import "TEALDataSourceConstants.h"
#import "TEALDataSources.h"
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
#import "TEALVersion.h"

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
@property (nonatomic, weak) id<TEALModulesDelegate> modulesDelegate;
//@property (nonatomic, weak) UIViewController *privateActiveViewController;

@property (nonatomic, strong) NSDictionary *moduleData;

@end

__strong static NSDictionary *staticAllInstances = nil;

@implementation Tealium

#pragma mark - PUBLIC CLASS METHODS

+ (instancetype) newInstanceForKey:(NSString * _Nonnull)key configuration:(TEALConfiguration *)configuration {
    
#warning OPTIMIZE this property assignment
    
    configuration.instanceID  = key;
    
    return [Tealium newInstanceForKey:key
                        configuration:configuration
                           completion:^(BOOL success, NSError * _Nullable error) {
                               
                               if (error) {
                                   
                                   NSLog(@"Problem initializing Tealium instance: %@ error:%@",
                                         key, error);
                               }
                               
                           }];
    
}

+ (instancetype) instanceForKey:(NSString * _Nonnull)key {
    
    Tealium *instance = staticAllInstances[key];
    
    return instance;
    
}

+ (void) destroyInstanceForKey:(NSString * _Nonnull)key {
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:[staticAllInstances copy]];
    
    [mDict removeObjectForKey:key];
    
    NSDictionary *newInstances = [NSDictionary dictionaryWithDictionary:mDict];
    
    staticAllInstances = newInstances;
    
}

#pragma mark - PUBLIC INSTANCE METHODS

- (id<TealiumDelegate> _Nullable) delegate {
    @synchronized(self){
        return self.delegateManager.delegate;
    }
}

- (void) setDelegate:(id<TealiumDelegate> _Nullable)delegate {
    
    @synchronized(self){
        
        [self.delegateManager updateWithDelegate:delegate];
    }
    
}

- (void) trackEventWithTitle:(NSString *)title dataSources:(NSDictionary *)clientDataSources {
        
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
    NSDictionary *connectionInfo = [self.urlSessionManager.reachabilityManager reachabilityDataSources];
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

+ (instancetype) newInstanceForKey:(NSString * _Nonnull)key
                     configuration:(TEALConfiguration *)configuration
                        completion:(TEALBooleanCompletionBlock)completion{
    
    __block NSError *newInstanceError = nil;
    
    Tealium *instance = [Tealium instanceWithConfiguration:configuration completion:^(BOOL success, NSError *error) {
        
        if (error) {
            
            newInstanceError = error;
            
        }
        
    }];
    
    
    if (instance){
        [Tealium addInstance:instance key:key];
    } else {
        newInstanceError = [TEALError errorWithCode:TEALErrorCodeFailure
                             description:NSLocalizedString(@"Failed to create new Tealium instance", @"")
                                  reason:NSLocalizedString(@"Unknown failure in newInstanceForKey:configuration:completion: call.", @"")
                              suggestion:NSLocalizedString(@"Consult Tealium Engineering", @"")];
    }
    
    if (completion) completion(true, newInstanceError);
    
    return instance;
    
}


+ (instancetype) instanceWithConfiguration:(TEALConfiguration * _Nonnull)configuration completion:(TEALBooleanCompletionBlock _Nullable) completion{
    
    // TODO: Optimize this method
    
    if (![TEALConfiguration isValidConfiguration:configuration]) {
        
        // Check configuration
        
        NSError *error = [TEALError errorWithCode:TEALErrorCodeMalformed
                                      description:@"Could not initialize instance."
                                           reason:@"Invalid Configuration."
                                       suggestion:@"Check the account, profile and environment options."];
        
        
        if (completion) {
            completion(NO, error);
        }
        return nil;
    }
    
    Tealium *instance = [[Tealium alloc] initPrivateWithInstanceID:configuration.instanceID];
    
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

+ (void) addInstance:(Tealium * _Nonnull)instance key:(NSString * _Nonnull)key {

    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:[staticAllInstances copy]];
    mDict[key] = instance;
    
    NSDictionary *newInstances = [NSDictionary dictionaryWithDictionary:mDict];

    staticAllInstances = newInstances;
}

#pragma mark - PRIVATE INSTANCE METHODS

- (instancetype) initPrivateWithInstanceID:(NSString * _Nonnull) instanceID {
    
    self = [super init];
    
    if (self) {
        _operationManager   = [[TEALOperationManager alloc] initWithInstanceID:instanceID];
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
    
    // Init data sources
    self.dataSources = [[TEALDataSources alloc]initWithInstanceID:configuration.instanceID];
    if (!error &&
        !self.dataSources) {
        error =[TEALError errorWithCode:TEALErrorCodeFailure
                            description:@"Could not initialize data sources."
                                 reason:@"Unknown problem with initialization."
                             suggestion:@"Consult Tealium Mobile Engineering - Tealium Line 400"];
    }
    
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
    
    [self.logger updateLogLevel:[self.settings logLevelString]];
    
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

- (void) disable {
    
    @synchronized(self) {
        
        [self disableCore];
        [self disableModules];
        
        [self.logger logQA:@"Library Disabled. New configuration check will continue running, all other subsystems disabled"];
        [self.logger disable];
    }
}

- (void) enable {
    
    [self.logger logQA:@"Library Enabled."];
    
    @synchronized(self) {
        [self enableCore];
        [self updateModules];
        [self.logger enable];
    }
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
    self.dispatchManager = [TEALDispatchManager dispatchManagerWithInstanceID:self.settings.instanceID
                                                                Configuration:self
                                                                     delegate:self];
    [self setupSettingsReachabilityCallbacks];
}

- (void) updateModules {
    
    // TODO: Optimize this
    
    self.modulesDelegate = self;
    
    // Lifecycle
    if ([self.settings autotrackingLifecycleEnabled]){
        if ([self.modulesDelegate respondsToSelector:@selector(enableAutotrackingLifecycle)]) {
            [self.modulesDelegate enableAutotrackingLifecycle];
        }
    } else {
        if ([self.modulesDelegate respondsToSelector:@selector(disableAutotrackingLifecycle)]) {
            [self.modulesDelegate disableAutotrackingLifecycle];
        }
    }
    
    // Tag Management
    if ([self.settings tagManagementEnabled]){
        
        if ([self.modulesDelegate respondsToSelector:@selector(enableTagManagement)]) {
            [self.modulesDelegate enableTagManagement];
        }
        
        if ([self.settings remoteCommandsEnabled]){
            if ([self.modulesDelegate respondsToSelector:@selector(enableRemoteCommands)]) {
                [self.modulesDelegate enableRemoteCommands];
            }
        } else {
            if ([self.modulesDelegate respondsToSelector:@selector(disableRemoteCommands)]) {
                [self.modulesDelegate disableRemoteCommands];
            }
        }
    } else {
        if ([self.modulesDelegate respondsToSelector:@selector(disableTagMangement)]) {
            [self.modulesDelegate disableTagMangement];
        }
    }
    
    
    // Collect
    if ([self.settings collectEnabled]){
        if ([self.modulesDelegate respondsToSelector:@selector(enableCollect)]) {
            [self.modulesDelegate enableCollect];
        }
    } else {
        if ([self.modulesDelegate respondsToSelector:@selector(disableCollect)]) {
            [self.modulesDelegate disableCollect];
        }
    }
    
    // S2S Legacy
    if ([self.settings s2SLegacyEnabled]){
        
        if ([self.modulesDelegate respondsToSelector:@selector(enableS2SLegacy)]){
            [self.modulesDelegate enableS2SLegacy];
        }
        
    } else {
        if (([self.modulesDelegate respondsToSelector:@selector(disableS2SLegacy)])){
            [self.modulesDelegate disableS2SLegacy];
        }
    }
    
    // UIEvents
    if ([self.settings autotrackingUIEventsEnabled]) {
        if ([self.modulesDelegate respondsToSelector:@selector(enableAutotrackingUIEvents)]) {
            [self.modulesDelegate enableAutotrackingUIEvents];
        }
    } else {
        if ([self.modulesDelegate respondsToSelector:@selector(disableAutotrackingUIEvents)]) {
            [self.modulesDelegate disableAutotrackingUIEvents];
        }
    }
    
    // Views
    if ([self.settings autotrackingViewsEnabled]) {
        if ([self.modulesDelegate respondsToSelector:@selector(enableAutotrackingViews)]) {
            [self.modulesDelegate enableAutotrackingViews];
        }
    } else {
        if ([self.modulesDelegate respondsToSelector:@selector(disableAutotrackingViews)]) {
            [self.modulesDelegate disableAutotrackingViews];
        }
    }
    
    // Mobile Companion
    if ([self.settings mobileCompanionEnabled]) {
        if ([self.modulesDelegate respondsToSelector:@selector(enableMobileCompanion)]) {
            [self.modulesDelegate enableMobileCompanion];
        }
    } else {
        if ([self.modulesDelegate respondsToSelector:@selector(disableMobileCompanion)]) {
            [self.modulesDelegate disableMobileCompanion];
        }
    }
    
    // Crashes
    if ([self.settings autotrackingCrashesEnabled]) {
        if ([self.modulesDelegate respondsToSelector:@selector(enableAutotrackingCrashes)]) {
            [self.modulesDelegate enableAutotrackingCrashes];
        }
    } else {
        if ([self.modulesDelegate respondsToSelector:@selector(disableAutotrackingCrashes)]) {
            [self.modulesDelegate disableAutotrackingCrashes];
        }
    }
    
}



- (void) disableCore {
    
    self.dispatchManager = nil;
    
}

/*
 *  Force disables all modules
 */
- (void) disableModules {
    
    // Lifecycle
    if ([self.modulesDelegate respondsToSelector:@selector(disableAutotrackingLifecycle)]) {
        [self.modulesDelegate disableAutotrackingLifecycle];
    }
    
    // Tag Management
    if ([self.modulesDelegate respondsToSelector:@selector(disableRemoteCommands)]) {
        [self.modulesDelegate disableRemoteCommands];
    }
    if ([self.modulesDelegate respondsToSelector:@selector(disableTagMangement)]) {
        [self.modulesDelegate disableTagMangement];
    }
    
    // Collect
    if ([self.modulesDelegate respondsToSelector:@selector(disableCollect)]) {
        [self.modulesDelegate disableCollect];
    }
    
    // S2S Legacy
    if (([self.modulesDelegate respondsToSelector:@selector(disableS2SLegacy)])){
        [self.modulesDelegate disableS2SLegacy];
    }
    
    // UIEvents
    if ([self.modulesDelegate respondsToSelector:@selector(disableAutotrackingUIEvents)]) {
        [self.modulesDelegate disableAutotrackingUIEvents];
    }
    
    // Views
    if ([self.modulesDelegate respondsToSelector:@selector(disableAutotrackingViews)]) {
        [self.modulesDelegate disableAutotrackingViews];
    }
    
    // Mobile Companion
    if ([self.modulesDelegate respondsToSelector:@selector(disableMobileCompanion)]) {
        [self.modulesDelegate disableMobileCompanion];
    }
    
    // Crashes
    if ([self.modulesDelegate respondsToSelector:@selector(disableAutotrackingCrashes)]) {
        [self.modulesDelegate disableAutotrackingCrashes];
    }
    
}

//- (void) setActiveViewController:(UIViewController *)viewController {
//
//    [self.logger logDev:@"Current View Controller is now: %@", viewController];
//    
//    self.privateActiveViewController = viewController;
//}

- (void) trackDispatch:(TEALDispatch *) dispatch {
    
    if (![self.settings publishSettings]){
        
        
    }
    
    [self.dispatchManager addDispatch:dispatch
                      completionBlock:^(TEALDispatchStatus status, TEALDispatch *dispatchReturned, NSError *error) {

          // Stub for any additional processing
          
      }];
    
}

- (void) logDispatch:(TEALDispatch *) dispatch status:(TEALDispatchStatus) status error:(NSError *)error{
    
    TEALLogLevel logLevel = [TEALLogger logLevelFromString:[self.settings logLevelString]];
    if (logLevel >= TEALLogLevelNone) {
        
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
        
        NSString *errorInfo = @"";
        
        if (error != nil){
            errorInfo = [NSString stringWithFormat:@"\r Error:%@", error.userInfo];
        }
        
        if ([dispatch.payload isKindOfClass:[NSString class]]) {
            
            [self.logger logDev:@"%@ dispatch with payload %@%@",
                 statusString,
                 dispatch.payload,
                 errorInfo];
            
        } else {
            
            [self.logger logDev:@"%@ dispatch: %@%@", statusString, dispatch, errorInfo];
            
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

- (void) fetchNewSettingsWithCompletion:(TEALBooleanCompletionBlock)completion {
    
    __weak Tealium *weakSelf = self;

    [self.settings fetchNewRawPublishSettingsWithCompletion:^(BOOL success, NSError * _Nullable error) {
       
        if (error){
            [weakSelf.logger logProd:[NSString stringWithFormat:@"%@ \nReason:%@ \nSuggestion:%@",
                                      [error localizedDescription],
                                      [error localizedFailureReason],
                                      [error localizedRecoverySuggestion]
                                      ]];
        }
        
        if (success){
            
            [weakSelf.logger logDev:@"New Remote Publish Settings: %@", [weakSelf.settings publishSettingsDescription]];
            
            [weakSelf.logger updateLogLevel:[weakSelf.settings logLevelString]];
            
            [weakSelf.logger logDev:[NSString stringWithFormat:@"Log level: %@", [TEALLogger logLevelStringFromLogLevel:[weakSelf.logger currentLogLevel]]]];
            
            [weakSelf updateModules];
            
            [weakSelf.dispatchManager updateQueuedCapacity:[self.settings offlineDispatchQueueSize]];
                        
            [weakSelf.dispatchManager runQueuedDispatches];

        }
        
        if ([weakSelf.settings libraryShouldDisable]){
            
            [weakSelf disable];
            
            return;
        }
        
    }];
    
}

- (void) setupSettingsReachabilityCallbacks {
    
    // Disregard if block has already been setup
    if ([self.urlSessionManager.reachabilityManager isReachableBlockEnabled]) {
        return;
    }
    
    [self.urlSessionManager.reachabilityManager startListeningForReachabilityChanges];
    
    __weak Tealium *weakSelf = self;
    
    [self.urlSessionManager.reachabilityManager reachabilityChanged:^(BOOL canReach) {
       
        if (canReach){
          
            [weakSelf.logger logDev:@"Network found."];
            
            [weakSelf fetchNewSettingsWithCompletion:nil];
            
        } else {
            
            [weakSelf.logger logDev:@"Network unreachable."];

        }
        
    }];
    
//    self.urlSessionManager.reachability.reachableBlock = ^(TEALReachabilityManager *reachability) {
//        
//        [weakSelf.logger logDev:@"Network found."];
//        
//        [weakSelf fetchNewSettingsWithCompletion:nil];
//        
//    };
//    
//    // When unreachable
//    self.urlSessionManager.reachability.unreachableBlock = ^(TEALReachabilityManager *reachability) {
//        
//        [weakSelf.logger logDev:@"Network unreachable."];
//
//    };
}

- (BOOL) networkReadyForDispatch {
    
    BOOL reachable = [self.urlSessionManager.reachabilityManager isReachable];
    
    return reachable;
    
}

- (BOOL) suppressForWifiOnly {
    
    BOOL suppress = NO;
    if ([self.settings wifiOnlySending]){
        suppress = ![self.urlSessionManager.reachabilityManager isReachableViaWifi];
    }
    
    return suppress;
}

- (BOOL) suppressForBetterBatteryLevels {
    // 20% is cutoff
    
    double batteryLevel = [TEALDataSources deviceBatteryLevel];
    
    return (![TEALDataSources deviceIsCharging] &&
            [self.settings goodBatteryLevelOnlySending] &&
            (batteryLevel < 20.0 && batteryLevel >= 0));
    
}



- (NSString *) description {
    
    NSString *version = TEALLibraryVersion;
    NSString *accountProfileEnvironment = [NSString stringWithFormat:@"%@/%@/%@", self.settings.account, self.settings.tiqProfile, self.settings.environment];
    
    return [NSString stringWithFormat:@"TEALIUM %@: instance:%@: ", version, accountProfileEnvironment];
}

- (NSDictionary *) moduleDataCopy {
    
    return [self.moduleData copy];
    
}

//- (UIViewController *) activeViewController {
//    
//    return self.privateActiveViewController;
//    
//}

- (TEALSettings *) settingsFromConfiguration:(TEALConfiguration *) configuration {
    
    TEALSettings *settings = [[TEALSettings alloc] initWithConfiguration:configuration];
    settings.visitorIDCopy = [self.dataSources visitorIDCopy];
    settings.urlSessionManager = self.urlSessionManager;
    
    return settings;
}

#pragma mark - DISPATCH SERVICES

- (NSArray *) currentDispatchServices {
    
    NSArray *array = nil;
    
    if (!self.dispatchNetworkServices) {
        
        array = [[NSArray alloc] init];
        
    } else {
        array = self.dispatchNetworkServices;
    }
    
    return array;
}

- (void) setCurrentDispatchServices:(NSArray *)newServices {
    
    self.dispatchNetworkServices = nil;
    self.dispatchNetworkServices = newServices;
    
}

- (void) addNewDispatchService:(id)newService {
    
    NSArray *dispatchServices = [[self currentDispatchServices] copy];
    
    NSMutableArray *newServices = [NSMutableArray arrayWithArray:dispatchServices];
    
    [newServices addObject:newService];
    
    [self setCurrentDispatchServices:[NSArray arrayWithArray:newServices]];
    
}

#pragma mark - TEALDISPATCHMANAGER DELEGATE

 //Agnostic - use configuration
 // TODO: handle wifi only, low battery and other settings
 // ~commHandlers big if else checks

#warning Add error argument for additional info

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
    for ( id<TEALDispatchService> service in [self currentDispatchServices]) {
        
        [service sendDispatch:dispatch
                   completion:^(TEALDispatchStatus serviceStatus, TEALDispatch *serviceDispatch, NSError *serviceError) {
                       
                       dispatch.dispatchServiceName = [service name];
                       
                       if (completionBlock) completionBlock(serviceStatus, serviceDispatch, serviceError);
                       
                   }];
    }
    
}

- (void) dispatchManagerDidSendDispatch:(TEALDispatch *)dispatch {
    
    if ([self.settings pollingFrequency] == TEALVisitorProfilePollingFrequencyAfterEveryEvent) {
        if ([self.modulesDelegate respondsToSelector:@selector(fetchVisitorProfile)]){
            [self.modulesDelegate fetchVisitorProfile];
        }
    }
    
    [self.delegateManager tealium:self didSendDispatch:dispatch];
    
    [self logDispatch:dispatch status:TEALDispatchStatusSent error:nil];
    
}

- (void) dispatchManagerWillEnqueueDispatch:(TEALDispatch *)dispatch {
    
    // Stub for possible Mobile Companion use
    
}

- (void) dispatchManagerDidEnqueueDispatch:(TEALDispatch *)dispatch {
    
    [self.delegateManager tealium:self didQueueDispatch:dispatch];
    [self logDispatch:dispatch status:TEALDispatchStatusQueued error:nil];
    
}

- (void) dispatchManagerDidUpdateDispatchQueues {
    
    // Stub for possible Mobile Companion use
    
}

- (BOOL) dispatchManagerShouldPurgeDispatch:(TEALDispatch *)dispatch {
    
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

    [self.logger logDev:[NSString stringWithFormat:@"Did purge dispatch: %@", dispatch]];

}

- (void) dispatchManagerdWillRunDispatchQueueWithCount:(NSUInteger)count {
    
    [self.logger logDev:[NSString stringWithFormat:@"Will dispatch queue with %lu dispatches.", (unsigned long)count]];

    
}

- (void) dispatchManagerdDidRunDispatchQueueWithCount:(NSUInteger)count {
    
    if ([self.settings pollingFrequency] == TEALVisitorProfilePollingFrequencyAfterEveryEvent) {
        if ([self.modulesDelegate respondsToSelector:@selector(fetchVisitorProfile)]){
            [self.modulesDelegate fetchVisitorProfile];
        }
    }
    
    [self.logger logDev:[NSString stringWithFormat:@"Did dispatch queue with %lu dispatches.", (unsigned long)count]];

}

#pragma mark - TEALDISPATCHMANAGER CONFIGURATION

- (NSUInteger) dispatchBatchSize {
    
    return [self.settings dispatchSize];
}

- (NSUInteger) dispatchQueueCapacity {
        
    return [self.settings offlineDispatchQueueSize];
}

- (NSError *) errorSendingDispatch:(TEALDispatch *)dispatch {
    
    // Return an error if the dispatch manager should NOT send now

    NSError *error = nil;
    NSArray *dispatchServices = [self currentDispatchServices];

    if  ([self.delegateManager tealium:self shouldDropDispatch:dispatch]) {
        
        error = [TEALError errorWithCode:999
                             description:NSLocalizedString(@"Dispatch destroyed.", @"")
                                  reason:NSLocalizedString(@"Public delegate requested destruction of dispatch.", @"")
                              suggestion:NSLocalizedString(@"See implemented tealium:shouldDropDispatch delegate method.", @"")];
        
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
