//
//  Tealium+PrivateHeader.h
//  Tealium
//
//  Created by Jason Koo on 8/24/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#ifndef Tealium_Tealium_PrivateHeader_h
#define Tealium_Tealium_PrivateHeader_h

#import "Tealium.h"
#import "TEALDataSources.h"
#import "TEALLogger.h"
#import "TEALOperationManager.h"
#import "TEALSettings.h"
#import "TEALDispatchManager.h"
#import "TEALURLSessionManager.h"

@interface Tealium (Private)

@property (nonatomic, strong) TEALDataSources * _Nonnull dataSources;
@property (nonatomic, strong) TEALDispatchManager * _Nonnull dispatchManager;
@property (nonatomic, strong) TEALLogger * _Nonnull logger;
@property (nonatomic, strong) TEALOperationManager * _Nonnull operationManager;
@property (nonatomic, strong) TEALSettings * _Nonnull settings;
@property (nonatomic, strong) TEALURLSessionManager *_Nonnull urlSessionManager;
@property (nonatomic, weak) id<TealiumDelegate> delegate;

+ (instancetype _Nullable) newInstanceForKey:(NSString * _Nonnull)key
                               configuration:(TEALConfiguration * _Nonnull)configuration
                                  completion:(TEALBooleanCompletionBlock _Nullable)completion;

+ (NSDictionary * _Nonnull) allInstances;

- (void) addModuleData:(NSDictionary * _Nonnull) dictionary;
- (void) removeModuleDataForKey:(NSString * _Nonnull)key;

- (NSArray * _Nonnull) currentDispatchServices;
- (void) setCurrentDispatchServices:(NSArray * _Nonnull)newServices;
- (void) addNewDispatchService:(id _Nonnull)newService;

- (NSDictionary * _Nonnull) moduleDataCopy;

- (NSDictionary * _Nonnull) finalDispatchDataSourcesForDispatchType:(TEALDispatchType)type
                                                              title:(NSString * _Nonnull)title
                                                        dataSources:(NSDictionary * _Nullable)dataSources;

- (void) fetchNewSettingsWithCompletion:(TEALBooleanCompletionBlock _Nullable)completion;

- (void) trackDispatch:(TEALDispatch * _Nonnull) dispatch completion:(TEALDispatchBlock _Nullable)completion;

- (void) trackDispatchOfType:(TEALDispatchType)type
                       title:(NSString * _Nonnull)title
                 dataSources:(NSDictionary * _Nullable) clientDataSources
                  completion:(TEALDispatchBlock _Nullable)completion;

@end

#endif
