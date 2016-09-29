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
#import "TEALURLSessionManager.h"
#import "TEALVersion.h"

@interface Tealium () <
                        TEALDispatchManagerDelegate,
                        TEALModulesDelegate>

@property (atomic, strong) NSMutableArray<TEALDispatchService> *privateDispatchNetworkServices;
@property (nonatomic, strong) TEALLogger *logger;
@property (nonatomic, strong) TEALOperationManager *operationManager;
@property (nonatomic, strong) TEALURLSessionManager *urlSessionManager;
@property (nonatomic, strong) TEALDataSources *dataSources;
@property (nonatomic, strong) TEALDelegateManager *delegateManager;
@property (nonatomic, strong) TEALDispatchManager *dispatchManager;
@property (nonatomic, strong) TEALSettings *settings;
@property (nonatomic, weak) id<TEALModulesDelegate> modulesDelegate;

@property (nonatomic, strong) NSDictionary *moduleData;
@property BOOL isEnabled;

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
    
    [instance.dataSources purgePersistentDataSources];
    
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

- (void) trackEventWithTitle:(NSString *)title
                 dataSources:(NSDictionary *)clientDataSources {
    
        [self trackDispatchOfType:TEALDispatchTypeEvent
                            title:title
                      dataSources:clientDataSources
                       completion:nil];
    
    
}

- (void) trackViewWithTitle:(NSString *)title
                dataSources:(NSDictionary *)clientDataSources {
    
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
    
    
    // Default behavior is to log the dispatch result
    if (!completion){
        completion = [self feedbackBlock];
    }
    
    // Data that should be captured on the main thread or nearest to time of call
    __block NSDictionary *captureData = [self captureTimeDataSourcesForType:type
                                                              title:title];
    
    __block NSDictionary *clientData = [clientDataSources copy];
    
    __weak Tealium *weakSelf = self;

    [self.operationManager addOperationWithBlock:^{
        
        /*
         Add remaining data sources for static data, background-thread safe data,
         volatile and persistent data. Client data from the track call datasources
         argument should always supercede any other automatically generated or
         retrieved data.
         */
        NSDictionary *backgroundData = [self.dataSources backgroundSafeDataSources];
        NSDictionary *accountSettings  = [self getTealiumAccountInfo:self.settings];
  
        
        
        if (!backgroundData){
            [weakSelf.logger logQA:@"TrackDispatchOfType:title:dataSources:completion: backgroundData could not be retrieved at this time. Some data sources may not be available in the next dispatch."];
        }
        
        NSMutableDictionary *payload = [NSMutableDictionary dictionary];

        [payload addEntriesFromDictionary:accountSettings];
        [payload addEntriesFromDictionary:captureData];
        [payload addEntriesFromDictionary:backgroundData];
        [payload addEntriesFromDictionary:clientData];
        
        TEALDispatch *dispatch = [TEALDispatch dispatchForType:type withPayload:payload];
        
        [weakSelf trackDispatch:dispatch completion:completion];
        
    }];

}

- (NSMutableDictionary *) getTealiumAccountInfo: (TEALSettings *)settings {
    
    NSMutableDictionary *tealiumSettingsDict = [NSMutableDictionary dictionary];
    
    [tealiumSettingsDict setValue: settings.environment forKey:TEALDataSourceKey_Tealium_Environment];
    [tealiumSettingsDict setValue: settings.tiqProfile forKey: TEALDataSourceKey_Tealium_Profile];
    [tealiumSettingsDict setValue: settings.account forKey:TEALDataSourceKey_Tealium_Account];
    
    return tealiumSettingsDict;
}

- (NSDictionary *) captureTimeDataSourcesForType:(TEALDispatchType)type
                                           title:(NSString *)title {

    NSDictionary *dispatchData = [TEALDataSources dispatchDatasourcesForEventType:type
                                                                            title:title];
    
    NSDictionary *connectionData = [self.urlSessionManager.reachabilityManager reachabilityDataSources];
    
    NSDictionary *mainThreadData = [self.dataSources mainThreadDataSources];
    
    NSDictionary *persistentData = [self.dataSources persistentDataSources];
    
    NSDictionary *clientVolatileData = [self.dataSources clientVolatileDataSources];
    
    if (!dispatchData){
        [self.logger logQA:@"CaptureTimeDataSources: dispatchData could not be retrieved at this time. Some data sources may not be available in the next dispatch."];
    }
    
    if (!connectionData){
        [self.logger logQA:@"CaptureTimeDataSources: connectionData could not be retrieved at this time. Some data sources may not be available in the next dispatch."];
    }
    
    if (!mainThreadData){
        [self.logger logQA:@"CaptureTimeDataSources: mainThreadData could not be retrieved at this time. Some data sources may not be available in the next dispatch."];
    }
    
    NSMutableDictionary *compositeDataSources = [NSMutableDictionary dictionary];
    
    [compositeDataSources addEntriesFromDictionary:dispatchData];
    
    [compositeDataSources addEntriesFromDictionary:connectionData];
    
    [compositeDataSources addEntriesFromDictionary:mainThreadData];
    
    [compositeDataSources addEntriesFromDictionary:persistentData];

    [compositeDataSources addEntriesFromDictionary:clientVolatileData];

    return compositeDataSources;
    
}

- (NSDictionary *) volatileDataSourcesCopy {
    
    return [[self.dataSources clientVolatileDataSources] copy];
    
}

- (void) addVolatileDataSources:(NSDictionary *)additionalDataSources {
    
    __block typeof(self) __weak weakSelf = self;

    __block NSDictionary *dataSources = [additionalDataSources copy];
    
    [self.operationManager addOperationWithBlock:^{

        [self addVolatileDataSources:dataSources
                          completion:^(BOOL success, NSError * _Nullable error) {
            
                  if (success){
                      [weakSelf.logger logDev:@"Volatile DataSources added: %@", dataSources];
                  }
                  if (error){
                      [weakSelf.logger logQA:@"%@", error];
                  }
        }];
        
    }];
    

}

- (void) removeVolatileDataSourcesForKeys:(NSArray *)dataSourceKeys {
    
    __block typeof(self) __weak weakSelf = self;

    [self removeVolatileDataSourcesForKeys:dataSourceKeys
                                completion:^(BOOL success, NSError * _Nullable error) {
              
    if (!success ||
        error){
        
        [weakSelf.logger logQA:@"Unable to remove volatile data sources. Error: %@", error];
        
    } else {
        [weakSelf.logger logDev:@"Volatile dataSources removed for keys:%@", dataSourceKeys];

    }
                                    
    }];
    
}

- (NSDictionary *) persistentDataSourcesCopy {
    
    return [[self.dataSources persistentDataSources] copy];
    
}

- (void) addPersistentDataSources:(NSDictionary *)additionalDataSources {

    __block NSDictionary *dataCopy = [additionalDataSources copy];
    __block typeof(self) __weak weakSelf = self;
    
    [self.operationManager addOperationWithBlock:^{
        [weakSelf.dataSources addPersistentDataSources:dataCopy];
        [weakSelf.logger logDev:@"Persistent DataSources added: %@", dataCopy];
    }];
    
}

- (void) removePersistentDataSourcesForKeys:(NSArray *)dataSourceKeys {
  
    __block typeof(self) __weak weakSelf = self;

    [self.operationManager addOperationWithBlock:^{
        [weakSelf.dataSources removePersistentDataSourceForKeys:dataSourceKeys];
        [weakSelf.logger logDev:@"Persistent dataSources removed for keys:%@", dataSourceKeys];

    }];
}

- (void) joinTraceWithToken:(NSString *)token {
    
    [self addVolatileDataSources:@{TEALDataSourceKey_TraceID:token}];
}

- (void) leaveTrace {
    
    [self removeVolatileDataSourcesForKeys:@[TEALDataSourceKey_TraceID]];
    
}

- (NSString *)resetSessionID {
    
    NSString *newSessionID = [TEALDataSources resetSessionID: [NSDate date]];
    
    NSDictionary *sessionDict = @{
                                  TEALDataSourceKey_Tealium_Session_Id: newSessionID
                                  };
    
    [self addVolatileDataSources: sessionDict];
    
    return newSessionID;
       
}


#pragma mark - PRIVATE INSTANCE METHODS

- (void) addVolatileDataSources:(NSDictionary *)additionalDataSources
                     completion:(TEALBooleanCompletionBlock)completion{
    
    NSError *error = nil;
    
    if (!self.dataSources){
        
        NSString *description = [NSString stringWithFormat:@"Unable to add volatile data sources:%@", additionalDataSources];
        error = [TEALError errorWithCode:TEALErrorCodeException
                             description:description
                                  reason:NSLocalizedString(@"DataSources object not yet ready.", @"")
                              suggestion:NSLocalizedString(@"Try again later.", @"")];
        
        if (completion) completion(NO, error);
        
        return;
    }
    
    NSDictionary *additionalDataSourcesCopy = [additionalDataSources copy];
    
    [[self.dataSources clientVolatileDataSources] addEntriesFromDictionary:additionalDataSourcesCopy];
    
    if (completion) completion(YES, nil);
        
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
    
    Tealium *instance = [Tealium instanceWithConfiguration:configuration
                                                  delegate:delegate
                                                completion:completion];
    
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
    
    [self updateLogger];
    
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
        
        if (!self.isEnabled){
            return;
        }
        self.isEnabled = NO;
        [self.logger logDev:@"Library Disabled. New configuration check will continue running, all other subsystems disabled"];
    }
}

- (void) refresh {
    
    [self updateModules];
    [self updateLogger];
    
}

- (void) enable {
    
    @synchronized(self) {
       
        if (self.isEnabled){
            return;
        }
        
        [self enableCore];
        [self refresh];
        [self.logger logDev:@"Library Enabled."];
        
        self.isEnabled = YES;

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
    
    [self.dispatchManager enable];
    
}

- (void) updateLogger {
    
    if ([self.logger updateLogLevel:[self.settings logLevelString]]){
        [self.logger logProd:[NSString stringWithFormat:@"Log level: %@", [TEALLogger stringFromLogLevel:[self.logger currentLogLevel]]]];
    }
}

- (void) updateModules {
    
    // TODO: Optimize this
    
    self.modulesDelegate = self;
    
    // TODO: ideally lets do this...
//    [self.modulesDelegate updateALL];
    
    // Lifecycle
    if ([self.modulesDelegate respondsToSelector:@selector(updateLifecycle)]){
        [self.modulesDelegate updateLifecycle];
    }
    
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

- (void) trackDispatch:(TEALDispatch *) dispatch
            completion:(TEALDispatchBlock)completion {
    
    [self.dispatchManager addDispatch:dispatch
                      completionBlock:completion];
    
}

- (void) logDispatch:(TEALDispatch *)dispatch
              status:(TEALDispatchStatus)status
               error:(NSError *)error{
    
    TEALLogLevel logLevel = [TEALLogger logLevelFromString:[self.settings logLevelString]];
    
    if (logLevel == TEALLogLevelNone){
        return;
    }
    
    NSString *statusString = [TEALDispatch stringFromDispatchStatus:status];
    
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
        
        // Verbosity level to report
        [self.logger logDev:@"%@ dispatch.", statusString];
        [self.logger logDev:@"Dispatch: %@", dispatch];

        if (error){
            [self.logger logDev:@"Dispatch error: %@", errorInfo];
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
    
    __block NSDictionary *fetchParameters = [self.dataSources fetchQueryStringDataSources];
    
    __block typeof(self) __weak weakSelf = self;

    [self.operationManager addOperationWithBlock:^{
        
        [weakSelf.settings fetchNewRawPublishSettingsWithURLParameters:fetchParameters
                                                            completion:completion];
        
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSelf reachabilityChanged:canReach];

        });
        
    }];
    
}

- (void) reachabilityChanged:(BOOL)canReach {
 
    [self.logger logDev:@"Network %@", canReach? @"found": @"unreachable"];
    
    if (!canReach){
        return;
    }
    
    __block typeof(self) __weak weakSelf = self;
    
    [self fetchNewSettingsWithCompletion:^(BOOL success, NSError * _Nullable error) {
        
        // Error only in fetching new config - continue running after to load archive or default mode
        if (error){
            [weakSelf.logger logProd:[NSString stringWithFormat:@"%@ \nReason:%@ \nSuggestion:%@",
                                      [error localizedDescription],
                                      [error localizedFailureReason],
                                      [error localizedRecoverySuggestion]
                                      ]];
        }
        
        // New, saved, or default publish settings?
        if (success){
            
            [weakSelf processNewSettings];
            
        } else if (!success &&
                   !error){
            
            [weakSelf processSavedSettings];
            
        }
        
    }];
    
}

- (void) processSavedSettings {
    
    [self.logger logDev:@"No changes in current Remote Publish Settings from server."];

    if (!self.isEnabled){
        [self enable];
    } else {
        [self refresh];
    }
    
    [self.dispatchManager runQueuedDispatches];
    
}

- (void) processNewSettings {
    
    // New, saved, or default publish settings?
    
    [self.logger logDev:@"New Remote Publish Settings: %@", [self.settings publishSettingsDescription]];
        
    
    // Update logger
    if ([self.logger updateLogLevel:[self.settings logLevelString]]){
        
        [self.logger logDev:[NSString stringWithFormat:@"Log level: %@", [TEALLogger stringFromLogLevel:[self.logger currentLogLevel]]]];
        
    }
    
    // Settings disabling library?
    if ([self.settings libraryShouldDisable]){
        
        [self disable];
        
        return;
        
    }
    
    // Enable library or just update to settings
    if (!self.isEnabled){
        [self enable];
    } else {
        [self refresh];
    }
    
    if ([self.delegate respondsToSelector:@selector(tealiumInstanceDidUpdatePublishSettings:)]) {
        [self.delegate tealiumInstanceDidUpdatePublishSettings:self];
    }
    
    [self.dispatchManager updateQueuedCapacity:[self.settings offlineDispatchQueueSize]];
    
    [self.dispatchManager runQueuedDispatches];
    
}

+ (BOOL) networkReadyForDispatchWithUrlSessionManager:(TEALURLSessionManager*)urlSessionManager{
    
    BOOL reachable = [urlSessionManager.reachabilityManager isReachable];
    
    return reachable;
    
}

+ (BOOL) suppressForWifiOnlyWithSettings:(TEALSettings*)settings
                       urlSessionManager:(TEALURLSessionManager*)urlSessionManager{
    
    BOOL suppress = NO;
    if ([settings wifiOnlySending]){
        suppress = ![urlSessionManager.reachabilityManager isReachableViaWifi];
    }
    
    return suppress;
}

+ (BOOL) suppressForBetterBatteryLevelsWithSettings:(TEALSettings*)settings{
    // 20% is cutoff
    
    double batteryLevel = [TEALDataSources deviceBatteryLevel];
    
    BOOL isCharging = [TEALDataSources deviceIsCharging];
    
    BOOL batterySaveOn = [settings goodBatteryLevelOnlySending];
    
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

- (NSMutableArray <TEALDispatchService> *) currentDispatchServices {
    
    if (!self.privateDispatchNetworkServices){

        // Max 3 options at the moment
        self.privateDispatchNetworkServices = [[NSMutableArray <TEALDispatchService> alloc] initWithCapacity:3];
        
    }
    
    return self.privateDispatchNetworkServices;
}


- (void) addNewDispatchService:(id<TEALDispatchService>)service {
    
    __block typeof(self) __weak weakSelf = self;

    [self addNewDispatchService:service
                         completion:^(BOOL success, NSError * _Nullable error) {
                             
                             NSString *name = [service name];
                             NSString *status = [service status]?@"ready":@"not ready";
                             
                             if (success){
                                 [weakSelf.logger logDev:@"Dispatch service added: %@ current status: %@", name, status];
                             }
                             
                             if (error){
                                 [weakSelf.logger logQA:@"Could not add dispatch service: %@ - error: %@", name, error];
                             }
                             
                         }];
    
    
}

- (void) removeDispatchService:(id<TEALDispatchService>)service {
    
    __block typeof(self) __weak weakSelf = self;
    
    [self removeDispatchService:service
                     completion:^(BOOL success, NSError * _Nullable error) {
                         
                         if (success){
                             [weakSelf.logger logDev:@"Dispatch service disabled: %@", [service name]];
                         }
                         
                         if (error){
                             [weakSelf.logger logQA:@"Could not remove dispatch service: %@ - error: %@", [service name], error];
                         }
                         
                     }];
    
}

- (void) addNewDispatchService:(id<TEALDispatchService>)service
                    completion:(TEALBooleanCompletionBlock)completion{
    
    // Source call needs to have put this in a background operation block

    NSError *error = nil;
    
    // Stop if service already available for Tealium instance
    NSString *serviceName = [service name];
    
    for (id<TEALDispatchService> service in [self currentDispatchServices]) {
        
        if ([[service name] isEqualToString:serviceName]){
            if (completion){
                completion(NO, error);
            }
            return;
        }
    }
    
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

- (BOOL) dispatchManagerShouldDispatch:(NSError *__autoreleasing *)error {
    
    // Errors are passed back up to original trackDispatch message's completion block
    
    return [Tealium dispatchPermissableBasedOnSettings:self.settings
                                       dispatchManager:self.dispatchManager
                                     urlSessionManager:self.urlSessionManager
                                      dispatchServices:[self currentDispatchServices]
                                                 error:error];

}

+ (BOOL) suppressForQueueSize:(NSUInteger)sizeLimit
             currentQueueSize:(NSUInteger)currentSize {

    if (currentSize >= sizeLimit){
        
        return NO;
        
    }
    
    return YES;
}

+ (BOOL) dispatchServicesReady:(NSArray <TEALDispatchService >*)dispatchServices {
    
    // Nothing to send with
    if (dispatchServices.count == 0)  { return NO; }
    
    // Are all ready?
    for (id<TEALDispatchService>service in dispatchServices) {
        if ([service status] == TEALDispatchNetworkServiceStatusUnknown){
            return NO;
        }
    }
    
    return YES;
}

+ (BOOL) dispatchPermissableBasedOnSettings:(TEALSettings *)settings
                            dispatchManager:(TEALDispatchManager *)dispatchManager
                          urlSessionManager:(TEALURLSessionManager *)urlSessionManager
                           dispatchServices:(NSArray <TEALDispatchService>*)dispatchServices
                                      error:(NSError * __autoreleasing *)error {
    
    // Check that all required instances are running
    BOOL allComponentsReady = [Tealium dispatchPermissableComponentsReadySettings:settings
                                                                  dispatchManager:dispatchManager
                                                                urlSessionManager:urlSessionManager
                                                                            error:error];
    if (!allComponentsReady) { return NO; }
    
    // Check all flags
    BOOL batchingOk = ![Tealium suppressForQueueSize:[settings dispatchSize]
                                    currentQueueSize:[dispatchManager queuedDispatches].count];
    BOOL networkOk = [Tealium networkReadyForDispatchWithUrlSessionManager:urlSessionManager];
    BOOL wifiOnlyOk = ![self suppressForWifiOnlyWithSettings:settings
                                           urlSessionManager:urlSessionManager];
    BOOL batteryLevelOk = ![self suppressForBetterBatteryLevelsWithSettings:settings];
    BOOL dispatchServicesOk = [Tealium dispatchServicesReady:dispatchServices];
    
    return [Tealium dispatchPermissableBatchingCheckPassed:batchingOk
                                        batteryLevelPassed:batteryLevelOk
                                        dispatchServicesOk:dispatchServicesOk
                                        networkReadyPassed:networkOk
                                            wifiOnlyPassed:wifiOnlyOk
                                             dispatchError:error];
    
    
    return NO;
}

+ (BOOL) dispatchPermissableComponentsReadySettings:(TEALSettings*)settings
                                    dispatchManager:(TEALDispatchManager*)dispatchManager
                                  urlSessionManager:(TEALURLSessionManager*)urlSessionManager
                                              error:(NSError * __autoreleasing *)error {

    if (!settings){
        *error = [TEALError errorWithCode:TEALErrorCodeFailure
                              description:NSLocalizedString(@"Dispatch Manager should not dispatch", @"")
                                   reason:NSLocalizedString(@"Settings not ready.", @"")
                               suggestion:NSLocalizedString(@"Consult Tealium Engineering.", @"")];
        return NO;
    }
    
    if (!dispatchManager){
        *error = [TEALError errorWithCode:TEALErrorCodeFailure
                              description:NSLocalizedString(@"Dispatch Manager should not dispatch", @"")
                                   reason:NSLocalizedString(@"Dispatch manager not ready", @"")
                               suggestion:NSLocalizedString(@"Consult Tealium Engineering.", @"")];
        return NO;
        
    }
    
    if (!urlSessionManager){
        *error = [TEALError errorWithCode:TEALErrorCodeFailure
                              description:NSLocalizedString(@"Dispatch Manager should not dispatch", @"")
                                   reason:NSLocalizedString(@"URL Session manager not ready", @"")
                               suggestion:NSLocalizedString(@"Consult Tealium Engineering.", @"")];
        return NO;
        
    }
    
    return YES;
}

+ (BOOL) dispatchPermissableBatchingCheckPassed:(BOOL)batchingOk
                             batteryLevelPassed:(BOOL)batteryLevelOk
                             dispatchServicesOk:(BOOL)dispatchServicesOk
                             networkReadyPassed:(BOOL)networkOk
                                 wifiOnlyPassed:(BOOL)wifiOnlyOk
                                  dispatchError:(NSError * __autoreleasing *)error {
    
    if (!batchingOk){
        *error = [TEALError errorWithCode:TEALErrorCodeNotAcceptable
                              description:NSLocalizedString(@"Dispatch Manager should not dispatch", @"")
                                   reason:NSLocalizedString(@"Queue size is smaller than batch size", @"")
                               suggestion:NSLocalizedString(@"Wait for additional track calls OR adjust publish settings batch size.", @"")];
        return NO;
        
    }
    
    if (!batteryLevelOk){
        *error = [TEALError errorWithCode:TEALErrorCodeFailure
                              description:NSLocalizedString(@"Dispatch Manager should not dispatch", @"")
                                   reason:NSLocalizedString(@"Suppressing for better battery levels.", @"")
                               suggestion:NSLocalizedString(@"Charge device.", @"")];
        return NO;
    }
    
    if (!dispatchServicesOk){
        *error = [TEALError errorWithCode:TEALErrorCodeNotAcceptable
                              description:NSLocalizedString(@"Dispatch Manager should not dispatch", @"")
                                   reason:NSLocalizedString(@"Dispatch services not ready", @"")
                               suggestion:NSLocalizedString(@"Check TIQ Mobile Publish Settings.", @"")];
        return NO;
    }
    

    if (!networkOk){
        *error = [TEALError errorWithCode:TEALErrorCodeFailure
                              description:NSLocalizedString(@"Dispatch Manager should not dispatch", @"")
                                   reason:NSLocalizedString(@"Network not ready.", @"")
                               suggestion:NSLocalizedString(@"Check network access.", @"")];
        return NO;
    }
    if (!wifiOnlyOk){
        *error = [TEALError errorWithCode:TEALErrorCodeFailure
                              description:NSLocalizedString(@"Dispatch Manager should not dispatch", @"")
                                   reason:NSLocalizedString(@"Suppressing calls until WIFI available.", @"")
                               suggestion:NSLocalizedString(@"Check network access.", @"")];
        return NO;
    }
    
    return YES;
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
