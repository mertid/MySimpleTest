//
//  TEALSettings.h
//  Tealium Mobile Library
//
//  Created by George Webster on 12/29/14.
//  Copyright (c) 2014 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TEALVisitorProfile;
@class TEALDatasource;
@class TEALConfiguration;

#import "TEALConfiguration.h"

typedef NS_ENUM(NSUInteger, TEALSettingsStatus) {
    TEALSettingsStatusNew,
    TEALSettingsStatusLoadedRemote,
    TEALSettingsStatusLoadedArchive,
    TEALSettingsStatusInvalid
};

@interface TEALRemoteSettings : NSObject <NSSecureCoding>


@property (strong, nonatomic) NSString *account;
@property (strong, nonatomic) NSString *tiqProfile;
@property (strong, nonatomic) NSString *asProfile;
@property (strong, nonatomic) NSString *environment;

@property (strong, nonatomic) NSString *visitorID;

@property (strong, nonatomic) NSString *traceID;

@property (nonatomic, readonly) NSString *audienceStreamAddressString;
@property (nonatomic, readonly) NSString *mobileConfigBaseURLString;

@property (nonatomic) TEALSettingsStatus status;
@property (nonatomic, readonly) BOOL isValid;

#pragma mark - Configuration

@property (nonatomic) BOOL useHTTP;
@property (nonatomic) TEALVisitorProfilePollingFrequency pollingFrequency;  // ? Move to MPS
@property (nonatomic) TEALLogLevel logLevel;

#pragma mark - Mobile Publish Settings

@property (copy, nonatomic) NSString *mpsVersion;

@property (nonatomic) NSUInteger dispatchSize; // batching
@property (nonatomic) NSUInteger offlineDispatchQueueSize;

@property (nonatomic) NSInteger numberOfDaysDispatchesAreValid;

@property (nonatomic) BOOL shouldLowBatterySuppress;

@property (nonatomic) BOOL shouldSendWifiOnly;

@property (nonatomic) BOOL autotrackingUIEventsEnabled;
@property (nonatomic) BOOL autotrackingViewsEnabled;

@property (nonatomic) BOOL audienceStreamEnabled;
@property (nonatomic) BOOL tagManagementEnabled;
@property (nonatomic) BOOL lifecycleEnabled;

@property (nonatomic) NSString *overridePublishSettingsURL;
@property (nonatomic) NSString *overridePublishURL;


+ (instancetype) settingWithConfiguration:(TEALConfiguration *)configuration
                                visitorID:(NSString *)visitorID;

#pragma mark - trace

- (void) storeTraceID:(NSString *)traceID;
- (void) disableTrace;

- (void) storeMobilePublishSettings:(NSDictionary *)rawSettings;

@end
