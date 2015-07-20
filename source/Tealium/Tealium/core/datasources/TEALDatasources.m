//
//  TEALCollectDatasources.m
//  Tealium Mobile Library
//
//  Created by George Webster on 4/17/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALDatasources.h"

#pragma mark - UDO / Datasource Keys

NSString * const TEALDatasourceKey_EventName        = @"event_name";
NSString * const TEALDatasourceKey_Pagetype         = @"page_type";
NSString * const TEALDatasourceKey_Platform         = @"platform";
NSString * const TEALDatasourceKey_SystemVersion    = @"os_version";
NSString * const TEALDatasourceKey_LibraryVersion   = @"library_version";
NSString * const TEALDatasourceKey_UUID             = @"uuid";
NSString * const TEALDatasourceKey_ApplicationName  = @"app_name";
NSString * const TEALDatasourceKey_Timestamp        = @"timestamp";
NSString * const TEALDatasourceKey_CallType         = @"callType";

NSString * const TEALDatasourceKey_LifecycleType    = @"lifecycle_type";

#pragma mark - UDO / Datasource Values

NSString * const TEALDatasourceValue_LifecycleLaunch     = @"launch";
NSString * const TEALDatasourceValue_LifecycleWake       = @"wake";
NSString * const TEALDatasourceValue_LifecycleSleep      = @"sleep";
NSString * const TEALDatasourceValue_LifecycleTerminate  = @"terminate";

#pragma mark - AudienceStream API Keys

NSString * const TEALCollectKey_Account      = @"tealium_account";
NSString * const TEALCollectKey_Profile      = @"tealium_profile";
NSString * const TEALCollectKey_Environment  = @"tealium_environment";
NSString * const TEALCollectKey_VisitorID    = @"tealium_vid";
NSString * const TEALCollectKey_TraceID      = @"tealium_trace_id";

@implementation TEALDatasources

@end
