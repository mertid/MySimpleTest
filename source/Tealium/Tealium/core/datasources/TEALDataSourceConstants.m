//
//  TEALCollectDatasources.m
//  Tealium Mobile Library
//
//  Created by George Webster on 4/17/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALDataSourceConstants.h"

@implementation TEALDataSourceConstants

#pragma mark - UDO / Datasource Keys

NSString * const TEALDataSourceKey_ApplicationName      = @"app_name";
NSString * const TEALDataSourceKey_ApplicationRDNS      = @"app_rdns";
NSString * const TEALDataSourceKey_ApplicationVersion   = @"app_version";
NSString * const TEALDataSourceKey_AssociatedViewTitle  = @"associated_screen_title";
NSString * const TEALDataSourceKey_Autotracked          = @"autotracked";
NSString * const TEALDataSourceKey_CallType             = @"callType";

NSString * const TEALDataSourceKey_Carrier              = @"carrier";
NSString * const TEALDataSourceKey_CarrierISO           = @"carrier_iso";
NSString * const TEALDataSourceKey_CarrierMCC           = @"carrier_mcc";
NSString * const TEALDataSourceKey_CarrierMNC           = @"carrier_mnc";
NSString * const TEALDataSourceKey_ConnectionType       = @"connection_type";

NSString * const TEALDataSourceKey_Device               = @"device";
NSString * const TEALDataSourceKey_DeviceArchitecture   = @"device_architecture";
NSString * const TEALDataSourceKey_DeviceBatteryLevel   = @"device_battery_percent";
NSString * const TEALDataSourceKey_DeviceCPUType        = @"device_cputype";
NSString * const TEALDataSourceKey_DeviceIsCharging     = @"device_ischarging";
NSString * const TEALDataSourceKey_DeviceLanguage       = @"device_language";
NSString * const TEALDataSourceKey_DeviceResolution     = @"device_resolution";
NSString * const TEALDataSourceKey_DeviceToken          = @"device_push_token";
NSString * const TEALDataSourceKey_EventName            = @"event_name";
NSString * const TEALDataSourceKey_EventTitle           = @"link_id";
NSString * const TEALDataSourceKey_ExceptionName        = @"exception_name";
NSString * const TEALDataSourceKey_ExceptionReason      = @"exception_reason";
NSString * const TEALDataSourceKey_ExceptionTrace       = @"exception_trace";
NSString * const TEALDataSourceKey_ExceptionTotalCount  = @"exception_totalcrashcount";
NSString * const TEALDataSourceKey_ExcludeClasses       = @"exclude_classes";
NSString * const TEALDataSourceKey_LibraryVersion       = @"library_version";

NSString * const TEALDataSourceKey_LifecycleDayOfWeek   = @"lifecycle_dayofweek_local";
NSString * const TEALDataSourceKey_LifecycleDaysSinceLaunch=@"lifecycle_dayssincelaunch";
NSString * const TEALDataSourceKey_LifecycleDaysSinceUpdate=@"lifecycle_dayssinceupdate";
NSString * const TEALDataSourceKey_LifecycleFirstLaunchDate=@"lifecycle_firstlaunchdate";
NSString * const TEALDataSourceKey_LifecycleFirstLaunchDate_MMDDYYYY=@"lifecycle_firstlaunchdate_MMDDYYYY";
NSString * const TEALDataSourceKey_LifecycleHourOfDayLocal=@"lifecycle_hourofday_local";
NSString * const TEALDataSourceKey_LifecycleIsFirstLaunch=@"lifecycle_isfirstlaunch";
NSString * const TEALDataSourceKey_LifecycleIsFirstLaunchAfterUpdate=@"lifecycle_isfirstlaunchupdate";
NSString * const TEALDataSourceKey_LifecycleIsFirstWakeThisMonth=@"lifecycle_isfirstwakemonth";
NSString * const TEALDataSourceKey_LifecycleIsFirstWakeToday=@"lifecycle_isfirstwaketoday";
NSString * const TEALDataSourceKey_LifecycleLastLaunchDate=@"lifecycle_lastlaunchdate";
NSString * const TEALDataSourceKey_LifecycleLastWakeDate=@"lifecycle_lastwakedate";
NSString * const TEALDataSourceKey_LifecycleLastSleepDate=@"lifecycle_lastsleepdate";
NSString * const TEALDataSourceKey_LifecycleLaunchCount = @"lifecycle_launchcount";
NSString * const TEALDataSourceKey_LifecyclePriorSecondsAwake=@"lifecycle_priorsecondsawake";
NSString * const TEALDataSourceKey_LifecycleSecondsAwake= @"lifecycle_secondsawake";
NSString * const TEALDataSourceKey_LifecycleSleepCount  = @"lifecycle_sleepcount";
NSString * const TEALDataSourceKey_LifecycleType        = @"lifecycle_type";
NSString * const TEALDataSourceKey_LifecycleTotalLaunchCount=@"lifecycle_totallaunchcount";
NSString * const TEALDataSourceKey_LifecycleTotalWakeCount=@"lifecycle_totalwakecount";
NSString * const TEALDataSourceKey_LifecycleTotalSleepCount=@"lifecycle_totalsleepcount";
NSString * const TEALDataSourceKey_LifecycleUpdateLaunchDate=@"lifecycle_updatelaunchdate";
NSString * const TEALDataSourceKey_LifecycleWakeCount   = @"lifecycle_wakecount";
NSString * const TEALDataSourceKey_ObjectClass          = @"object_class";
NSString * const TEALDataSourceKey_Orientation          = @"orientation";
NSString * const TEALDataSourceKey_Origin               = @"origin";
NSString * const TEALDataSourceKey_Pagetype             = @"page_type";
NSString * const TEALDataSourceKey_Platform             = @"platform";
NSString * const TEALDataSourceKey_SelectedRow          = @"selected_row";
NSString * const TEALDataSourceKey_SelectedSection      = @"selected_section";
NSString * const TEALDataSourceKey_SelectedTitle        = @"selected_title";
NSString * const TEALDataSourceKey_SelectedValue        = @"selected_value";
NSString * const TEALDataSourceKey_SystemVersion        = @"os_version";
NSString * const TEALDataSourceKey_Timestamp            = @"timestamp";
NSString * const TEALDataSourceKey_TimestampLocal       = @"timestamp_local";
NSString * const TEALDataSourceKey_TimestampOffset      = @"timestamp_offset";
NSString * const TEALDataSourceKey_TimestampUnix        = @"timestamp_unix";
NSString * const TEALDataSourceKey_TealiumID            = @"tealium_id";
NSString * const TEALDataSourceKey_UUID                 = @"uuid";
NSString * const TEALDataSourceKey_ViewTitle            = @"screen_title";
NSString * const TEALDataSourceKey_ViewHeight           = @"view_height";
NSString * const TEALDataSourceKey_ViewWidth            = @"view_width";
NSString * const TEALDataSourceKey_VisitorID            = @"visitor_id";
NSString * const TEALDataSourceKey_WasQueued            = @"was_queued";
NSString * const TEALDataSourceKey_WebViewServiceType   = @"webview_servicetype";
NSString * const TEALDataSourceKey_WebViewURL           = @"webview_url";

#pragma mark - UDO / Datasource Values

NSString * const TEALDataSourceValue_ConnectionCellular = @"cellular";
NSString * const TEALDataSourceValue_ConnectionWifi     = @"wifi";
NSString * const TEALDataSourceValue_EventName          = @"mobile_link";
NSString * const TEALDataSourceValue_Exception          = @"exception";
NSString * const TEALDataSourceValue_ExceptionCaught    = @"caught";
NSString * const TEALDataSourceValue_ExceptionUncaught  = @"uncaught";
NSString * const TEALDataSourceValue_False              = @"false";
NSString * const TEALDataSourceValue_LifecycleLaunch    = @"launch";
NSString * const TEALDataSourceValue_LifecycleWake      = @"wake";
NSString * const TEALDataSourceValue_LifecycleSleep     = @"sleep";
NSString * const TEALDataSourceValue_LifecycleTerminate = @"terminate";
NSString * const TEALDataSourceValue_Link               = @"link";
NSString * const TEALDataSourceValue_Origin             = @"mobile";
NSString * const TEALDataSourceValue_Pagetype           = @"mobile_view";
NSString * const TEALDataSourceValue_Platform           = @"iOS";
NSString * const TEALDataSourceValue_True               = @"true";
NSString * const TEALDataSourceValue_View               = @"view";
NSString * const TEALDataSourceValue_Unknown            = @"unknown";


#pragma mark - AudienceStream API Keys

NSString * const TEALCollectKey_Account      = @"tealium_account";
NSString * const TEALCollectKey_Environment  = @"tealium_environment";
NSString * const TEALCollectKey_Profile      = @"tealium_profile";
NSString * const TEALCollectKey_TraceID      = @"tealium_trace_id";
NSString * const TEALCollectKey_VisitorID    = @"tealium_vid";

@end
