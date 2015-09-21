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

@property () TEALPublishSettingsStatus status;
@property () NSString *url;
@property () NSUInteger dispatchSize; // batching
@property () NSUInteger offlineDispatchQueueSize;
@property () double minutesBetweenRefresh;
@property () double numberOfDaysDispatchesAreValid;
@property () BOOL enableLowBatterySuppress;
@property () BOOL enableSendWifiOnly;
@property () BOOL enableAudienceStream;
@property () BOOL enableTagManagement;

@property () BOOL disableApplicationInfoAutotracking;
@property () BOOL disableCarrierInfoAutotracking;
@property () BOOL disableDeviceInfoAutotracking;
@property () BOOL disableUIEventAutotracking;
@property () BOOL disableViewAutotracking;
@property () BOOL disableiVarAutotracking;
@property () BOOL disableLifecycleAutotracking;
@property () BOOL disableTimestampAutotracking;
@property () BOOL disableCrashTracking;
@property () BOOL disableMobileCompanion;

- (instancetype) initWithURLString:(NSString *)url;

- (BOOL) areValidRawPublishSettings:(NSDictionary *) rawPublishSettings;
- (void) updateWithRawSettings:(NSDictionary *)rawPublishSettings;
- (void) loadArchived;
- (NSString *) mpsVersion;
- (NSDictionary *) mobilePublishSettingsFromHTMLData:(NSData *)data error:(NSError **)error;

@end
