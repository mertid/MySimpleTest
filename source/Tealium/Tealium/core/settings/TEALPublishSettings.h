//
//  TEALPublishSettings.h
//  Tealium
//
//  Created by Jason Koo on 7/30/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TEALPublishSettingsStatus) {
    TEALPublishSettingsStatusDefault,
    TEALPublishSettingsStatusLoadedRemote,
    TEALPublishSettingsStatusLoadedArchive,
    TEALPublishSettingsStatusDisable
};

@interface TEALPublishSettings : NSObject <NSSecureCoding>

@property (nonatomic) TEALPublishSettingsStatus status;
@property (nonatomic, strong) NSString *url;
@property (nonatomic) NSUInteger dispatchSize; // batching
@property (nonatomic) NSUInteger offlineDispatchQueueSize;
@property (nonatomic) double minutesBetweenRefresh;
@property (nonatomic) double numberOfDaysDispatchesAreValid;
@property (nonatomic) BOOL enableLowBatterySuppress;
@property (nonatomic) BOOL enableSendWifiOnly;
@property (nonatomic) BOOL enableAudienceStream;
@property (nonatomic) BOOL enableTagManagement;

@property (nonatomic) BOOL overrideDisableUIEventAutotracking;
@property (nonatomic) BOOL overrideDisableViewAutotracking;
@property (nonatomic) BOOL overrideDisableiVarAutotracking;
@property (nonatomic) BOOL overrideDisableLifecycleAutotracking;
@property (nonatomic) BOOL overrideDisableCrashTracking;
@property (nonatomic) BOOL overrideDisableMobileCompanion;

- (instancetype) initWithURLString:(NSString *)url;

- (BOOL) areValidRawPublishSettings:(NSDictionary *) rawPublishSettings;
- (void) updateWithRawSettings:(NSDictionary *)rawPublishSettings;
- (void) loadArchived;
- (NSString *) mpsVersion;
- (NSDictionary *) mobilePublishSettingsFromHTMLData:(NSData *)data error:(NSError **)error;

@end
