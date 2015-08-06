//
//  TEALCollectDatasources.m
//  Tealium Mobile Library
//
//  Created by George Webster on 4/17/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALDatasources.h"

#pragma mark - UDO / Datasource Keys

NSString * const TEALDatasourceKey_ApplicationName  = @"app_name";
NSString * const TEALDatasourceKey_Autotracked      = @"autotracked";
NSString * const TEALDatasourceKey_CallType         = @"callType";
NSString * const TEALDatasourceKey_Device                  = @"device";
NSString * const TEALDatasourceKey_DeviceArchitecture      = @"device_architecture";
NSString * const TEALDatasourceKey_DeviceBatteryLevel      = @"device_battery_percent";
NSString * const TEALDatasourceKey_DeviceCPUType           = @"device_cputype";
NSString * const TEALDatasourceKey_DeviceIsCharging        = @"device_ischarging";
NSString * const TEALDatasourceKey_DeviceLanguage          = @"device_language";
NSString * const TEALDatasourceKey_DeviceResolution        = @"device_resolution";
NSString * const TEALDatasourceKey_DeviceToken             = @"device_push_token";
NSString * const TEALDatasourceKey_EventName        = @"event_name";
NSString * const TEALDatasourceKey_EventTitle       = @"link_id";
NSString * const TEALDatasourceKey_ExceptionType =                     @"exception_type";
NSString * const TEALDatasourceKey_ExceptionName =                     @"exception_name";
NSString * const TEALDatasourceKey_ExceptionReason =                   @"exception_reason";
NSString * const TEALDatasourceKey_ExceptionTrace =                    @"exception_trace";
NSString * const TEALDatasourceKey_ExcludeClasses =                    @"exclude_classes";
NSString * const TEALDatasourceKey_LibraryVersion   = @"library_version";
NSString * const TEALDatasourceKey_LifecycleType    = @"lifecycle_type";
NSString * const TEALDatasourceKey_ObjectClass      = @"object_class";
NSString * const TEALDatasourceKey_Orientation =                       @"orientation";
NSString * const TEALDatasourceKey_Pagetype         = @"page_type";
NSString * const TEALDatasourceKey_Platform         = @"platform";
NSString * const TEALDatasourceKey_SelectedRow =                       @"selected_row";
NSString * const TEALDatasourceKey_SelectedSection =                   @"selected_section";
NSString * const TEALDatasourceKey_SelectedTitle    = @"selected_title";
NSString * const TEALDatasourceKey_SelectedValue =                     @"selected_value";
NSString * const TEALDatasourceKey_SystemVersion    = @"os_version";
NSString * const TEALDatasourceKey_Timestamp        = @"timestamp";
NSString * const TEALDatasourceKey_UUID             = @"uuid";
NSString * const TEALDatasourceKey_ViewTitle        = @"screen_title";
NSString * const TEALDatasourceKey_ViewHeight       = @"view_height";
NSString * const TEALDatasourceKey_ViewWidth        = @"view_width";
NSString * const TEALDatasourceKey_WasQueued =                         @"was_queued";
NSString * const TEALDatasourceKey_WebViewServiceType =                @"webview_servicetype";
NSString * const TEALDatasourceKey_WebViewURL =                        @"webview_url";


#pragma mark - UDO / Datasource Values

NSString * const TEALDatasourceValue_EventName          = @"mobile_link";
NSString * const TEALDatasourceValue_Exception =                         @"exception";
NSString * const TEALDatasourceValue_ExceptionCaught =                   @"caught";
NSString * const TEALDatasourceValue_ExceptionUncaught =                 @"uncaught";
NSString * const TEALDatasourceValue_False              = @"false";
NSString * const TEALDatasourceValue_LifecycleLaunch    = @"launch";
NSString * const TEALDatasourceValue_LifecycleWake      = @"wake";
NSString * const TEALDatasourceValue_LifecycleSleep     = @"sleep";
NSString * const TEALDatasourceValue_LifecycleTerminate = @"terminate";
NSString * const TEALDatasourceValue_Link               = @"link";
NSString * const TEALDatasourceValue_Pagetype           = @"mobile_view";
NSString * const TEALDatasourceValue_Platform           = @"ios";
NSString * const TEALDatasourceValue_True               = @"true";
NSString * const TEALDatasourceValue_View               = @"view";
NSString * const TEALDatasourceValue_Unknown =                           @"unknown";

#pragma mark - AudienceStream API Keys

NSString * const TEALCollectKey_Account      = @"tealium_account";
NSString * const TEALCollectKey_Environment  = @"tealium_environment";
NSString * const TEALCollectKey_Profile      = @"tealium_profile";
NSString * const TEALCollectKey_TraceID      = @"tealium_trace_id";
NSString * const TEALCollectKey_VisitorID    = @"tealium_vid";

@implementation TEALDatasources

@end
