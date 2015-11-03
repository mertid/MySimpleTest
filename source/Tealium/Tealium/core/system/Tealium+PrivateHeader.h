//
//  Tealium+PrivateHeader.h
//  Tealium
//
//  Created by Jason Koo on 8/24/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#ifndef Tealium_Tealium_PrivateHeader_h
#define Tealium_Tealium_PrivateHeader_h

#import "TEALDataSources.h"
#import "TEALLogger.h"
#import "TEALOperationManager.h"
#import "TEALSettings.h"
#import "TEALDispatchManager.h"
#import "TEALURLSessionManager.h"

@interface Tealium (Private)

@property (nonatomic, strong) TEALDataSources *dataSources;
@property (nonatomic, strong) TEALDispatchManager *dispatchManager;
@property (nonatomic, strong) TEALLogger *logger;
@property (nonatomic, strong) TEALOperationManager *operationManager;
@property (nonatomic, strong) TEALSettings *settings;
@property (nonatomic, strong) TEALURLSessionManager *urlSessionManager;
@property (nonatomic, weak) id<TealiumDelegate> delegate;

+ (NSDictionary *) allInstances;

- (void) addModuleData:(NSDictionary *) dictionary;
- (void) removeModuleDataForKey:(NSString *)key;

- (NSArray *) currentDispatchServices;
- (void) setCurrentDispatchServices:(NSArray *)newServices;
- (void) addNewDispatchService:(id)newService;

- (NSDictionary *) moduleDataCopy;

- (void) setActiveViewController:(UIViewController *)viewController;

- (UIViewController *) activeViewController;
    
@end

#endif
