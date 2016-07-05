//
//  TEALPublishSettingsConstants.m
//  UIKitCatalog
//
//  Created by Jason Koo on 1/10/16.
//
//

#import "TEALPublishSettingsConstants.h"

NSString * const TEALPublishSettingKeyIsEnabled = @"_is_enabled";
NSString * const TEALPublishSettingKeyOverrideLog = @"override_log";

NSString * const TEALPublishSettingKeyUrl = @"url";
NSString * const TEALPublishSettingKeyMinutesBetweenRefresh = @"minutes_between_refresh";
NSString * const TEALPublishSettingKeyDispatchExpiration = @"dispatch_expiration"; // Number of days dispatch is valid
NSString * const TEALPublishSettingKeyDispatchSize = @"event_batch_size";
NSString * const TEALPublishSettingKeyOfflineDispatchSize = @"offline_dispatch_limit";
NSString * const TEALPublishSettingKeyLowBatteryMode = @"battery_saver";
NSString * const TEALPublishSettingKeyWifiOnlyMode = @"wifi_only_sending";
NSString * const TEALPublishSettingKeyCollectEnable = @"enable_collect";
NSString * const TEALPublishSettingKeyS2SLegacyEnable = @"enable_s2s_legacy";
NSString * const TEALPublishSettingKeyTagManagementEnable = @"enable_tag_management";
NSString * const TEALPublishSettingKeyStatus = @"status";


NSString * const TEALPublishSettingKeyDisableApplicationInfoAutotracking = @"disable_application_info_autotracking";
NSString * const TEALPublishSettingKeyDisableCarrierInfoAutotracking = @"disable_carrer_info_autotracking";
NSString * const TEALPublishSettingKeyDisableDeviceInfoAutotracking = @"disable_device_info_autotracking";
NSString * const TEALPublishSettingKeyDisableUIEventAutotracking = @"disable_uievent_autotracking";
NSString * const TEALPublishSettingKeyDisableViewAutotracking = @"disable_view_autotracking";
NSString * const TEALPublishSettingKeyDisableiVarAutotracking = @"disable_ivar_autotracking";
NSString * const TEALPublishSettingKeyDisableLifecycleAutotracking = @"disable_lifecycle_autotracking";
NSString * const TEALPublishSettingKeyDisableTimestampAutotracking = @"disable_timestamp_autotracking";
NSString * const TEALPublishSettingKeyDisableCrashAutotracking = @"disable_crash_autotracking";
NSString * const TEALPublishSettingKeyDisableMobileCompanion = @"disable_mobilecompanion";

//NSString * const TEALPublishSettingKeyModuleData = @"module_data";
//NSString * const TEALPublishSettingKeyModuleDescriptionData = @"module_description_data";

@implementation TEALPublishSettingsConstants

@end
