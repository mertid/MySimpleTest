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
#import "TEALURLSessionManager.h"

@interface Tealium (Private)

@property (strong, nonatomic) TEALDataSources *dataSources;
@property (strong, nonatomic) TEALLogger *logger;
@property (strong, nonatomic) TEALOperationManager *operationManager;
@property (strong, nonatomic) TEALSettings *settings;
@property (strong, nonatomic) TEALURLSessionManager *urlSessionManager;

- (void) setCurrentDispatchNetworkServices:(NSArray *)newServices;
- (void) addModuleData:(NSDictionary *) dictionary;
- (void) removeModuleDataForKey:(NSString *)key;
- (NSDictionary *) moduleDataCopy;
- (NSArray *) currentDispatchNetworkServices;

@end

#endif
