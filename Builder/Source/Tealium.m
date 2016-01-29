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
                        TEALModulesDelegate>

@property (atomic, strong) NSMutableArray *privateDispatchNetworkServices;
@property (nonatomic, strong) TEALLogger *logger;
@property (nonatomic, strong) TEALOperationManager *operationManager;
@property (nonatomic, strong) TEALURLSessionManager *urlSessionManager;
@property (nonatomic, strong) TEALDataSources *dataSources;
@property (nonatomic, strong) TEALDelegateManager *delegateManager;
@property (nonatomic, strong) TEALDispatchManager *dispatchManager;
@property (nonatomic, strong) TEALSettings *settings;
@property (nonatomic, weak) id<TEALModulesDelegate> modulesDelegate;

@property (nonatomic, strong) NSDictionary *moduleData;

@end

__strong static NSDictionary *staticAllInstances = nil;

@implementation Tealium

#pragma mark - PUBLIC CLASS METHODS

+ (instancetype) newInstanceForKey:(NSString * _Nonnull)key
                     configuration:(TEALConfiguration *)configuration {
    
    return [Tealium newInstanceForKey:key
                        configuration:configuration
                           completion:^(BOOL success, NSError * _Nullable error) {
                               
                               if (error) {
                                   
                                   NSLog(@"Problem initializing Tealium instance: %@ error:%@",
                                         key, error);
                               }
                               
                           }];
    
}

+ (instancetype) newInstanceForKey:(NSString * _Nonnull)key
                          delegate:(id<TealiumDelegate>)delegate
                     configuration:(TEALConfiguration *)configuration {
    
    return [Tealium newInstanceForKey:key
                        configuration:configuration
                             delegate:delegate
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
    
    Tealium *instance = staticAllInstances[key];
    
    [instance.settings purgeAllArchives];
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:staticAllInstances];
    
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
    
        [self trackDispatchOfType:TEALDispatchTypeEvent
                            title:title
                      dataSources:clientDataSources
                       completion:nil];
    
}

- (void) trackViewWithTitle:(NSString *)title dataSources:(NSDictionary *)clientDataSources {
    
        [self trackDispatchOfType:TEALDispatchTypeView
                            title:title
                      dataSources:clientDataSources
                       completion:nil];
            
}

- (TEALDispatchBlock) feedbackBlock {
    
    __block typeof(self) __weak weakSelf = self;

    TEALDispatchBlock feedbackBlock = ^(TEALDispatchStatus status, TEALDispatch *dispatch, NSError *error) {
        
        if ([weakSelf.modulesDelegate respondsToSelector:@selector(fetchVisitorProfileAfterEvent)]){
            [weakSelf.modulesDelegate fetchVisitorProfileAfterEvent];
        }
        
        if (status == TEALDispatchStatusSent){
            [weakSelf.delegateManager tealium:self didSendDispatch:dispatch];
        }
        if (status == TEALDispatchStatusQueued){
            [weakSelf.delegateManager tealium:self didQueueDispatch:dispatch];
        }
        
        [weakSelf logDispatch:dispatch status:status error:error];
    };
    
    return feedbackBlock;
}

- (void) trackDispatchOfType:(TEALDispatchType)type
                 title:(NSString *)title
           dataSources:(NSDictionary *) clientDataSources
            completion:(TEALDispatchBlock)completion{
    
    
    if (!completion){
    
        completion = [self feedbackBlock];
    }
    
    [self.operationManager addOperationWithBlock:^{
        
        NSDictionary *compositeDataSources = [self finalDispatchDataSourcesForDispatchType:type
                                                                                     title:title
                                                                               dataSources:clientDataSources];
        
        TEALDispatch *dispatch = [TEALDispatch dispatchForType:type withPayload:compositeDataSources];
        
        __weak Tealium *weakSelf = self;
        
        [weakSelf trackDispatch:dispatch completion:completion];
        
    }];

}

- (NSDictionary *) finalDispatchDataSourcesForDispatchType:(TEALDispatchType)type
                                                     title:(NSString *)title
                                               dataSources:(NSDictionary *)dataSources {
        
    // Configurable Options
    NSDictionary *applicationInfo = self.settings.autotrackingApplicationInfoEnabled? [TEALDataSources applicationInfoDataSources]:@{};
    NSDictionary *carrierInfo = self.settings.autotrackingCarrierInfoEnabled? [TEALDataSources carrierInfoDataSources]:@{};
    NSDictionary *connectionInfo = [self.urlSessionManager.reachabilityManager reachabilityDataSources:dataSources];
    NSDictionary *deviceInfo = self.settings.autotrackingDeviceInfoEnabled? [TEALDataSources deviceInfoDataSources]:@{};
    
    // Non-configurable Options
    NSDictionary *tealiumInfo = [TEALDataSources tealiumInfoDataSources];
    NSDictionary *persistentDataSources = [self persistentDataSourcesCopy];
    NSDictionary *volatileDataSources = [self volatileDataSourcesCopy];
    NSDictionary *timestampDataSources = [self timestampDataSourcesForDataSources:dataSources];
    NSDictionary *captureTimeDataSources = [self.dataSources captureTimeDatasourcesForEventType:type title:title];
    NSDictionary *clientDataSources = dataSources? dataSources: @{};
    
    NSDictionary *compositeDataSources = [TEALSystemHelpers compositeDictionaries:@[
                                                                                    applicationInfo,
                                                                                    carrierInfo,
                                                                                    connectionInfo,
                                                                                    deviceInfo,
                                                                                    tealiumInfo,
                                                                                    timestampDataSources,
                                                                                    captureTimeDataSources,
                                                                                    persistentDataSources,
                                                                                    volatileDataSources,
                                                                                    clientDataSources
                                                                                    ]];
    
    
    
    return compositeDataSources;
}

- (NSDictionary *) timestampDataSourcesForDataSources:(NSDictionary *)dataSources {
    
    if ([self.settings autotrackingTimestampInfoEnabled]) {
        NSString *dateString = dataSources[TEALDataSourceKey_TimestampUnix];
        return [TEALTimestampDataSources dataSourcesForDate:dateString];
    }
    
    return @{};
}

- (NSDictionary *) volatileDataSourcesCopy {
    
    return [[self.dataSources clientVolatileDataSources] copy];
    
}

- (void) addVolatileDataSources:(NSDictionary *)additionalDataSources {
    
    NSError *error = nil;
    
    __block typeof(self) __weak weakSelf = self;

    __block NSDictionary *dataSources = [additionalDataSources copy];
    
    [self addVolatileDataSources:dataSources
                      completion:^(BOOL success, NSError * _Nullable error) {
        
              [weakSelf.logger logDev:@"Volatile DataSources added: %@", dataSources];

    }];
    
    if (error){
        [self.logger logQA:@"%@", error];
    }
}


- (void) removeVolatileDataSourcesForKeys:(NSArray *)dataSourceKeys {
    
    __block typeof(self) __weak weakSelf = self;

    [self removeVolatileDataSourcesForKeys:dataSourceKeys
                                completion:^(BOOL success, NSError * _Nullable error) {
                                   
        [weakSelf.logger logDev:@"Unable to remove volatile data sources. Error: %@", error];
                                    
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

- (void) joinTraceWithToken:(NSString *)token {
    
    [self addVolatileDataSources:@{TEALDataSourceKey_TraceID:token}];
}

- (void) leaveTrace {
    
    [self removeVolatileDataSourcesForKeys:@[TEALDataSourceKey_TraceID]];
    
}

#pragma mark - PRIVATE INSTANCE METHODS

- (void) addVolatileDataSources:(NSDictionary *)additionalDataSources
                     completion:(TEALBooleanCompletionBlock)completion{
    
    NSError *error = nil;
    
    if (!self.dataSources){
        error = [TEALError errorWithCode:TEALErrorCodeException
                             description:NSLocalizedString(@"Unable to add volatile data sources", @"")
                                  reason:NSLocalizedString(@"DataSources object not yet ready.", @"")
                              suggestion:NSLocalizedString(@"Try again later.", @"")];
        
        if (completion) completion(NO, error);
        
        return;
    }
    
    if (!self.operationManager){
        error = [TEALError errorWithCode:TEALErrorCodeException
                             description:NSLocalizedString(@"Unable to add volatile data sources", @"")
                                  reason:NSLocalizedString(@"Operation Manager not yet ready.", @"")
                              suggestion:NSLocalizedString(@"Try again later.", @"")];
        
        if (completion) completion(NO, error);
        
        return;
    }
    
    __block typeof(self) __weak weakSelf = self;
    
    __block NSDictionary *additionalDataSourcesCopy = [additionalDataSources copy];
    
    [self.operationManager addOperationWithBlock:^{
        
        [[weakSelf.dataSources clientVolatileDataSources] addEntriesFromDictionary:additionalDataSourcesCopy];
        
        if (completion) completion(YES, nil);
        
    }];
    
}


- (void) removeVolatileDataSourcesForKeys:(NSArray *)dataSourceKeys
                               completion:(TEALBooleanCompletionBlock)completion {
    
    if (![dataSourceKeys isKindOfClass:([NSArray class])]) {
        
        NSError *error = [TEALError errorWithCode:TEALErrorCodeFailure
                                      description:NSLocalizedString(@"Could not remove volatile data source(s)", @"")
                                           reason:NSLocalizedString(@"Array not passed into removeVolatileDataSourcesForKeys call.", @"")
                                       suggestion:NSLocalizedString(@"Check removeVolatileDataSourcesForKeys: arguments.", @"")];
        
        if (completion) completion(NO, error);
        return;
        
    }
    __block typeof(self) __weak weakSelf = self;
    
    __block NSArray *keys = [dataSourceKeys copy];
    
    [self.operationManager addOperationWithBlock:^{
        
        [[weakSelf.dataSources clientVolatileDataSources] removeObjectsForKeys:keys];
        
        [weakSelf.logger logDev:@"Volatile Data Sources removed with keys: %@", keys];
        
        if (completion) completion(YES, nil);
        
    }];
}

#pragma mark - PRIVATE CLASS METHODS

+ (instancetype) newInstanceForKey:(NSString * _Nonnull)key
                     configuration:(TEALConfiguration *)configuration
                        completion:(TEALBooleanCompletionBlock)completion{
    
    return [self newInstanceForKey:key
                     configuration:configuration
                          delegate:nil
                        completion:completion];
    
}

+ (instancetype) newInstanceForKey:(NSString * _Nonnull)key
                     configuration:(TEALConfiguration *)configuration
                          delegate:(id<TealiumDelegate>)delegate
                        completion:(TEALBooleanCompletionBlock)completion{
    
    /*
     *  Key - Used to identify a unique Tealium instance from all others in the 
     *  multiton. The instance itself and all components do NOT need to know this
     *  key.  Instead, the configuration option creates an instanceID from the
     *  account-profile-env settings that is used separate storage files and queues
     *  from other Tealium instances.
    */
    
    // Bail out check
    NSError *error = nil;
    
    if (![TEALConfiguration isValidConfiguration:configuration]) {
        
        // Check configuration
        
        NSError *error = [TEALError errorWithCode:TEALErrorCodeMalformed
                                      description:@"Could not initialize instance."
                                           reason:@"Invalid Configuration."
                                       suggestion:@"Check the account, profile and environment options."];
        
        
        if (completion) { completion(NO, error);}
        
        return nil;
    }
    
    Tealium *instance = [Tealium instanceWithConfiguration:configuration
                                                  delegate:delegate
                                                completion:completion];
    
    // Unlikely error
    if (!instance) {
        
        error = [TEALError errorWithCode:TEALErrorCodeFailure
                             description:NSLocalizedString(@"Failed to create new Tealium instance", @"")
                                  reason:NSLocalizedString(@"Unknown failure in newInstanceForKey:configuration:completion: call.", @"")
                              suggestion:NSLocalizedString(@"Consult Tealium Engineering", @"")];
        
        if (completion) { completion(NO, error);}
        
        return nil;
    }
    
    [Tealium addInstance:instance key:key];
    
    return instance;
    
}


+ (instancetype) instanceWithConfiguration:(TEALConfiguration * _Nonnull)configuration completion:(TEALBooleanCompletionBlock _Nullable) completion{
    
    return [self instanceWithConfiguration:configuration
                                  delegate:nil
                                completion:completion];
}

+ (instancetype) instanceWithConfiguration:(TEALConfiguration * _Nonnull)configuration
                                  delegate:(id<TealiumDelegate>)delegate
                                completion:(TEALBooleanCompletionBlock _Nullable) completion{
    
    Tealium *instance = [[Tealium alloc] initPrivateWithInstanceID:configuration.instanceID];
    
    if (delegate){
        instance.delegate = delegate;
    }
    
    __weak Tealium *weakInstance = instance;
    
    [instance.operationManager addOperationWithBlock:^{
        
        [weakInstance finalizeWithConfiguration:configuration
                                     completion:completion];
        
    }];
    
    return instance;
}

+ (NSDictionary *) allInstances {
    return staticAllInstances;
}

+ (void) addInstance:(Tealium * _Nonnull)instance
                 key:(NSString * _Nonnull)key {

    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:staticAllInstances];
    
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
        _dispatchManager = [TEALDispatchManager dispatchManagerWithInstanceID:instanceID
                                                                         delegate:self];
    }
    
    return self;
}

- (instancetype) init {
    [NSException raise:@"should not be initialized directly"
                format:@"please use [Tealium sharedInstance] or public class methods"];
    return nil;
}

- (void) finalizeWithConfiguration:(TEALConfiguration *)configuration
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
    
    [self updateCore];

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
        
        [self setupSettingsReachabilityCallbacks];
        
        [self enable];

    } else {
        
        [self disable];
        
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
    
    NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:self.moduleData];
    
    if (![[mDict allKeys] containsObject:key]){
        return;
    }
    
    [mDict removeObjectForKey:key];
    
    NSDictionary *dict = [NSDictionary dictionaryWithDictionary:mDict];
    
    self.moduleData = dict;
    
}

- (void) enableCore {

//    [self setupSettingsReachabilityCallbacks];
    
    [self.dispatchManager enable];
    
}

- (void) updateCore {
    
    if ([self.logger updateLogLevel:[self.settings logLevelString]]){
        [self.logger logQA:[NSString stringWithFormat:@"Log level: %@", [TEALLogger stringFromLogLevel:[self.logger currentLogLevel]]]];
    }
}

- (void) updateModules {
    
    // TODO: Optimize this
    
    self.modulesDelegate = self;
    
    // Tag Management
    if ([self.modulesDelegate respondsToSelector:@selector(updateTagManagement)]){
        [self.modulesDelegate updateTagManagement];
    }
    
    // Collect
    if ([self.modulesDelegate respondsToSelector:@selector(updateCollect)]){
        [self.modulesDelegate updateCollect];
    }
    
    // S2S Legacy
    if ([self.modulesDelegate respondsToSelector:@selector(updateS2SLegacy)]){
        [self.modulesDelegate updateS2SLegacy];
    }
    
}

- (void) disableCore {
    
    [self.dispatchManager disable];
    
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

- (void) trackDispatch:(TEALDispatch *) dispatch completion:(TEALDispatchBlock)completion {
    
    [self.dispatchManager addDispatch:dispatch
                      completionBlock:completion];
    
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
            case TEALDispatchStatusDestroyed:
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
        case TEALDispatchStatusDestroyed:
            break;
        default:
            break;
    }
    
}

- (void) fetchNewSettingsWithCompletion:(TEALBooleanCompletionBlock)completion {

    if (!self.settings) {
        
        NSError *error = [TEALError errorWithCode:TEALErrorCodeFailure
                             description:NSLocalizedString(@"Failed to fetch new publish settings", @"")
                                  reason:NSLocalizedString(@"Settings object not yet ready.", @"")
                              suggestion:NSLocalizedString(@"Wait for next fetch opportunity", @"")];
        
        if (completion){
            completion(NO, error);
        }
        
        return;
    }
    
    [self.settings fetchNewRawPublishSettingsWithCompletion:completion];
    
}

- (void) setupSettingsReachabilityCallbacks {
    
    // Disregard if block has already been setup
    if ([self.urlSessionManager.reachabilityManager isReachableBlockEnabled]) {
        return;
    }
    
    [self.urlSessionManager.reachabilityManager startListeningForReachabilityChanges];
    
    __weak Tealium *weakSelf = self;
    
    [self.urlSessionManager.reachabilityManager reachabilityChanged:^(BOOL canReach) {
       
        [weakSelf.operationManager addOperationWithBlock:^{
            
            [weakSelf reachabilityChanged:canReach];

        }];
        
    }];
    
}

- (void) reachabilityChanged:(BOOL)canReach {
 
    if (canReach){
        
        [self.logger logDev:@"Network found."];
        
        __block typeof(self) __weak weakSelf = self;

        [self fetchNewSettingsWithCompletion:^(BOOL success, NSError * _Nullable error) {
            
            if (error){
                [weakSelf.logger logProd:[NSString stringWithFormat:@"%@ \nReason:%@ \nSuggestion:%@",
                                          [error localizedDescription],
                                          [error localizedFailureReason],
                                          [error localizedRecoverySuggestion]
                                          ]];
                
            }
            
            if (success){
                
                [weakSelf.logger logDev:@"New Remote Publish Settings: %@", [weakSelf.settings publishSettingsDescription]];
                
            }
            
            if (!success &&
                !error){
                
                [weakSelf.logger logDev:@"No changes in current Remote Publish Settings from server."];
                
            }
            
            // if !success then we're using archived or default version
            
            if ([weakSelf.logger updateLogLevel:[weakSelf.settings logLevelString]]){
                
                [weakSelf.logger logDev:[NSString stringWithFormat:@"Log level: %@", [TEALLogger stringFromLogLevel:[weakSelf.logger currentLogLevel]]]];
                
            }
            
            [weakSelf updateCore];
            [weakSelf updateModules];
            
            if ([weakSelf.delegate respondsToSelector:@selector(tealiumInstanceDidUpdatePublishSettings:)]) {
                [weakSelf.delegate tealiumInstanceDidUpdatePublishSettings:weakSelf];
            }
            
            [weakSelf.dispatchManager updateQueuedCapacity:[self.settings offlineDispatchQueueSize]];
            
            [weakSelf.dispatchManager runQueuedDispatches];
            
            
            
            if ([weakSelf.settings libraryShouldDisable]){
                
                [weakSelf disable];
                
                return;
            }
            
        }];
        
    } else {
        
        [self.logger logDev:@"Network unreachable."];
        
    }
    
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
    
    BOOL isCharging = [TEALDataSources deviceIsCharging];
    
    BOOL batterySaveOn = [self.settings goodBatteryLevelOnlySending];
    
    return (!isCharging &&
            batterySaveOn &&
            (batteryLevel < 20.0 && batteryLevel > 0));
    
}

- (NSString *) description {
    
    NSString *version = TEALLibraryVersion;
    
    
    NSString *accountProfileEnvironment = [NSString stringWithFormat:@"%@/%@/%@", self.settings.account, self.settings.tiqProfile, self.settings.environment];
    
    return [NSString stringWithFormat:@"TEALIUM %@: instance:%@: ", version, accountProfileEnvironment];
}

- (NSDictionary *) moduleDataCopy {
    
    return [self.moduleData copy];
    
}

- (TEALSettings *) settingsFromConfiguration:(TEALConfiguration *) configuration {
    
    TEALSettings *settings = [[TEALSettings alloc] initWithConfiguration:configuration];
    settings.urlSessionManager = self.urlSessionManager;
    
    return settings;
}

#pragma mark - DISPATCH SERVICES

- (NSMutableArray *) currentDispatchServices {
    
    if (!self.privateDispatchNetworkServices){

        // Max 3 options at the moment
        self.privateDispatchNetworkServices = [[NSMutableArray alloc] initWithCapacity:3];
        
    }
    
    return self.privateDispatchNetworkServices;
}

- (void) addNewDispatchService:(id<TEALDispatchService>)service {
    
    __block typeof(self) __weak weakSelf = self;

    [self addNewDispatchService:service
                         completion:^(BOOL success, NSError * _Nullable error) {
                             
                             if (success){
                                 [weakSelf.logger logQA:@"Dispatch service enabled: %@", [service name]];
                             }
                             
                             if (error){
                                 [weakSelf.logger logDev:@"Could not add dispatch service: %@ - error: %@", [service name], error];
                             }
                             
                         }];
    
    
}

- (void) removeDispatchService:(id<TEALDispatchService>)service {
    
    __block typeof(self) __weak weakSelf = self;
    
    [self removeDispatchService:service
                     completion:^(BOOL success, NSError * _Nullable error) {
                         
                         if (success){
                             [weakSelf.logger logQA:@"Dispatch service disabled: %@", [service name]];
                         }
                         
                         if (error){
                             [weakSelf.logger logDev:@"Could not remove dispatch service: %@ - error: %@", [service name], error];
                         }
                         
                     }];
    
}

- (void) addNewDispatchService:(id<TEALDispatchService>)service
                    completion:(TEALBooleanCompletionBlock)completion{
    
    NSError *error = nil;
    
//    if ([[self currentDispatchServices] containsObject:service]){
//        if (completion){
//            error = [TEALError errorWithCode:TEALErrorCodeNotAcceptable
//                                 description:NSLocalizedString(@"Could not add dispatch service.", @"")
//                                      reason:NSLocalizedString(@"Dispatch service already present.", @"")
//                                  suggestion:NSLocalizedString(@"Ignore or remove unneeded addDispatchService: call.", @"")];
//            completion(NO, error);
//        }
//        return;
//    }
    
    NSString *serviceName = [service name];
    
    for (id<TEALDispatchService> service in [self currentDispatchServices]) {
        
        if ([[service name] isEqualToString:serviceName]){
            if (completion){
                completion(NO, error);
            }
            return;
        }
    }
    
    // Source call needs to put this on the operation block
    
    [[self currentDispatchServices] addObject:service];
    
    if (completion){
        completion(YES, nil);
    }
    
}

- (void) removeDispatchService:(id)service
                    completion:(TEALBooleanCompletionBlock)completion {
    
    NSError *error = nil;
    
    if (![[self currentDispatchServices] containsObject:service]){
        if (completion){
            error = [TEALError errorWithCode:TEALErrorCodeNotAcceptable
                                 description:NSLocalizedString(@"Could not remove dispatch service.", @"")
                                      reason:NSLocalizedString(@"Dispatch service already NOT present.", @"")
                                  suggestion:NSLocalizedString(@"Ignore or remove unneeded removeDispatchService: call.", @"")];
            completion(NO, error);
        }
        return;
    }
    
    [[self currentDispatchServices ] removeObject:service];
    
    if (completion){
        completion(YES, nil);
    }
    
}


#pragma mark - TEALDISPATCHMANAGER DELEGATE

- (BOOL) dispatchManagerShouldDispatch:(NSError *__autoreleasing _Nullable)error {
    
    BOOL shouldDispatch = YES;
    
    if (!self.settings){
        error = [TEALError errorWithCode:TEALErrorCodeFailure
                             description:NSLocalizedString(@"Dispatch Manager should not dispatch", @"")
                                  reason:NSLocalizedString(@"Settings not ready.", @"")
                              suggestion:NSLocalizedString(@"Wait.", @"")];
        shouldDispatch = NO;
    }
    if (![self networkReadyForDispatch]){
        error = [TEALError errorWithCode:TEALErrorCodeFailure
                             description:NSLocalizedString(@"Dispatch Manager should not dispatch", @"")
                                  reason:NSLocalizedString(@"Network not ready.", @"")
                              suggestion:NSLocalizedString(@"Check network access.", @"")];
        shouldDispatch = NO;
    }
    if ([self suppressForWifiOnly]){
        error = [TEALError errorWithCode:TEALErrorCodeFailure
                             description:NSLocalizedString(@"Dispatch Manager should not dispatch", @"")
                                  reason:NSLocalizedString(@"Suppressing calls until WIFI available.", @"")
                              suggestion:NSLocalizedString(@"Check network access.", @"")];
        shouldDispatch = NO;
    }
    if ([self suppressForBetterBatteryLevels]){
        error = [TEALError errorWithCode:TEALErrorCodeFailure
                             description:NSLocalizedString(@"Dispatch Manager should not dispatch", @"")
                                  reason:NSLocalizedString(@"Suppressing for better battery levels.", @"")
                              suggestion:NSLocalizedString(@"Charge device.", @"")];
        shouldDispatch = NO;
    }
    if ([self currentDispatchServices].count==0){
        error = [TEALError errorWithCode:TEALErrorCodeNotAcceptable
                             description:NSLocalizedString(@"Dispatch Manager should not dispatch", @"")
                                  reason:NSLocalizedString(@"No network dispatch services available", @"")
                              suggestion:NSLocalizedString(@"Check TIQ Mobile Publish Settings.", @"")];
        shouldDispatch = NO;
    }
    
    NSUInteger batchSize = [self.settings dispatchSize];
    NSUInteger queueSize = [self.dispatchManager queuedDispatches].count;
    if (batchSize > queueSize){
        error = [TEALError errorWithCode:TEALErrorCodeNotAcceptable
                             description:NSLocalizedString(@"Dispatch Manager should not dispatch", @"")
                                  reason:NSLocalizedString(@"Queue size is smaller than batch size", @"")
                              suggestion:NSLocalizedString(@"Wait for additional track calls OR adjust publish settings batch size.", @"")];
        shouldDispatch = NO;
        
    }
    
    return shouldDispatch;
}

- (BOOL) dispatchManagerShouldDestroyDispatch:(TEALDispatch *)dispatch {
    
    return [self.delegateManager tealium:self shouldDropDispatch:dispatch];
    
}

- (BOOL) dispatchManagerShouldQueueDispatch:(TEALDispatch *)dispatch {
    
    return [self.delegateManager tealium:self shouldQueueDispatch:dispatch];
    
}

- (void) dispatchManager:(TEALDispatchManager *)dataManager
        requestsDispatch:(TEALDispatch *)dispatch
         completionBlock:(TEALDispatchBlock)completionBlock {

    // Pass dispatch to dispatch services
    for ( id<TEALDispatchService> service in [self currentDispatchServices]) {
        
        [service sendDispatch:dispatch
                   completion:^(TEALDispatchStatus serviceStatus, TEALDispatch *serviceDispatch, NSError *serviceError) {
                       
                       serviceDispatch.dispatchServiceName = [service name];
                       
                       if (completionBlock) completionBlock(serviceStatus, serviceDispatch, serviceError);
                       
                   }];
    }
    
}

// For internal expiration check
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


#pragma mark - TEALDISPATCHMANAGER CONFIGURATION

- (NSUInteger) dispatchBatchSize {
    
    return [self.settings dispatchSize];
}

- (NSUInteger) dispatchQueueCapacity {
        
    return [self.settings offlineDispatchQueueSize];
}

@end
