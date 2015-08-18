//
//  TEALCollectDatasources.h
//  Tealium Mobile Library
//
//  Created by George Webster on 4/17/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

// TODO: Make a strings file instead?

#import <Foundation/Foundation.h>

#pragma mark - UDO / Datasource Keys

extern NSString * const TEALDatasourceKey_ApplicationName;
extern NSString * const TEALDatasourceKey_Autotracked;
extern NSString * const TEALDatasourceKey_CallType;
extern NSString * const TEALDatasourceKey_Device;
extern NSString * const TEALDatasourceKey_DeviceArchitecture;
extern NSString * const TEALDatasourceKey_DeviceBatteryLevel;
extern NSString * const TEALDatasourceKey_DeviceCPUType;
extern NSString * const TEALDatasourceKey_DeviceIsCharging;
extern NSString * const TEALDatasourceKey_DeviceLanguage;
extern NSString * const TEALDatasourceKey_DeviceResolution;
extern NSString * const TEALDatasourceKey_DeviceToken;
extern NSString * const TEALDatasourceKey_EventName;
extern NSString * const TEALDatasourceKey_EventTitle;
extern NSString * const TEALDatasourceKey_ExceptionType;
extern NSString * const TEALDatasourceKey_ExceptionName;
extern NSString * const TEALDatasourceKey_ExceptionReason;
extern NSString * const TEALDatasourceKey_ExceptionTrace;
extern NSString * const TEALDatasourceKey_LibraryVersion;
extern NSString * const TEALDatasourceKey_LifecycleType;
extern NSString * const TEALDatasourceKey_ObjectClass;
extern NSString * const TEALDatasourceKey_Orientation;
extern NSString * const TEALDatasourceKey_Pagetype;
extern NSString * const TEALDatasourceKey_Platform;
extern NSString * const TEALDatasourceKey_SelectedRow;
extern NSString * const TEALDatasourceKey_SelectedSection;
extern NSString * const TEALDatasourceKey_SelectedTitle;
extern NSString * const TEALDatasourceKey_SelectedValue;
extern NSString * const TEALDatasourceKey_SystemVersion;
extern NSString * const TEALDatasourceKey_Timestamp;
extern NSString * const TEALDatasourceKey_UUID;
extern NSString * const TEALDatasourceKey_ViewTitle;
extern NSString * const TEALDatasourceKey_ViewHeight;
extern NSString * const TEALDatasourceKey_ViewWidth;
extern NSString * const TEALDatasourceKey_WasQueued;
extern NSString * const TEALDatasourceKey_WebViewServiceType;
extern NSString * const TEALDatasourceKey_WebViewURL;


#pragma mark - UDO / Datasource Values

extern NSString * const TEALDatasourceValue_EventName;
extern NSString * const TEALDatasourceValue_False;
extern NSString * const TEALDatasourceValue_LifecycleLaunch;
extern NSString * const TEALDatasourceValue_LifecycleWake;
extern NSString * const TEALDatasourceValue_LifecycleSleep;
extern NSString * const TEALDatasourceValue_LifecycleTerminate;
extern NSString * const TEALDatasourceValue_Link;
extern NSString * const TEALDatasourceValue_Pagetype;
extern NSString * const TEALDatasourceValue_Platform;
extern NSString * const TEALDatasourceValue_True;
extern NSString * const TEALDatasourceValue_View;
extern NSString * const TEALDatasourceValue_Exception;
extern NSString * const TEALDatasourceValue_ExceptionCaught;
extern NSString * const TEALDatasourceValue_ExceptionUncaught;
extern NSString * const TEALDatasourceValue_Unknown;


#pragma mark - AudienceStream API Keys

extern NSString * const TEALCollectKey_Account;
extern NSString * const TEALCollectKey_Environment;
extern NSString * const TEALCollectKey_Profile;
extern NSString * const TEALCollectKey_TraceID;
extern NSString * const TEALCollectKey_VisitorID;

@interface TEALDatasourceConstants : NSObject

@end
