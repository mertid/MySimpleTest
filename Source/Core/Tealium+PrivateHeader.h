//
//  Tealium+PrivateHeader.h
//  Tealium
//
//  Created by Jason Koo on 8/24/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "Tealium.h"
#import "TEALDataSources.h"
#import "TEALLogger.h"
#import "TEALOperationManager.h"
#import "TEALSettings.h"
#import "TEALDispatchManager.h"
#import "TEALURLSessionManager.h"
#import "TEALDispatchService.h"

@interface Tealium (Private)

@property (nonatomic, strong) TEALDataSources * _Nonnull dataSources;
@property (nonatomic, strong) TEALDispatchManager * _Nonnull dispatchManager;
@property (nonatomic, strong) TEALLogger * _Nonnull logger;
@property (nonatomic, strong) TEALOperationManager * _Nonnull operationManager;
@property (nonatomic, strong) TEALSettings * _Nonnull settings;
@property (nonatomic, strong) TEALURLSessionManager *_Nonnull urlSessionManager;
@property (nonatomic, weak) id<TealiumDelegate>  _Nullable delegate;

+ (instancetype _Nullable) newInstanceForKey:(NSString * _Nonnull)key
                               configuration:(TEALConfiguration * _Nonnull)configuration
                                  completion:(TEALBooleanCompletionBlock _Nullable)completion;

+ (instancetype _Nullable) newInstanceForKey:(NSString * _Nonnull)key
                               configuration:(TEALConfiguration * _Nonnull)configuration
                                    delegate:(id<TealiumDelegate> _Nullable)delegate
                                  completion:(TEALBooleanCompletionBlock _Nullable)completion;

+ (NSDictionary * _Nonnull) allInstances;

+ (BOOL) suppressForQueueSize:(NSUInteger)sizeLimit
             currentQueueSize:(NSUInteger)currentSize;
+ (BOOL) dispatchServicesReady:(NSArray <TEALDispatchService >* _Nullable)dispatchServices;

+ (BOOL) dispatchPermissableBasedOnSettings:(TEALSettings * _Nullable)settings
                            dispatchManager:(TEALDispatchManager * _Nullable)dispatchManager
                          urlSessionManager:(TEALURLSessionManager * _Nullable)urlSessionManager
                                dataSources:(TEALDataSources * _Nullable)dataSources
                           dispatchServices:(NSArray <TEALDispatchService>* _Nullable)dispatchServices
                                      error:(NSError * __autoreleasing *)error;

- (void) addModuleData:(NSDictionary * _Nonnull) dictionary;
- (void) removeModuleDataForKey:(NSString * _Nonnull)key;

- (NSMutableArray * _Nonnull) currentDispatchServices;
- (void) addNewDispatchService:(id<TEALDispatchService> _Nonnull)service;
- (void) removeDispatchService:(id<TEALDispatchService> _Nonnull)service;

- (BOOL) dispatchManagerShouldDispatch:(NSError * __autoreleasing *)error;

- (void) addVolatileDataSources:(NSDictionary * _Nonnull)additionalDataSources
                     completion:(TEALBooleanCompletionBlock _Nullable)completion;
- (void) removeVolatileDataSourcesForKeys:(NSArray * _Nonnull)dataSourceKeys
                               completion:(TEALBooleanCompletionBlock _Nullable)completion;

- (NSDictionary * _Nonnull) moduleDataCopy;

- (NSDictionary * _Nonnull) dispatchReadyDataSourcesFrom:(NSDictionary* _Nullable)captureData;

- (NSDictionary * _Nonnull) captureTimeDataSourcesForType:(TEALDispatchType)type
                                                    title:(NSString * _Nonnull)title;

- (NSDictionary * _Nullable) fetchQueryStringData;

- (void) fetchNewSettingsWithCompletion:(TEALBooleanCompletionBlock _Nullable)completion;

- (void) trackDispatch:(TEALDispatch * _Nonnull) dispatch completion:(TEALDispatchBlock _Nullable)completion;

- (void) trackDispatchOfType:(TEALDispatchType)type
                       title:(NSString * _Nonnull)title
                 dataSources:(NSDictionary * _Nullable) clientDataSources
                  completion:(TEALDispatchBlock _Nullable)completion;

@end