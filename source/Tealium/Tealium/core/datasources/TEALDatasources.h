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

extern NSString * const TEALDatasourceKey_Autotracked;
extern NSString * const TEALDatasourceKey_EventName;
extern NSString * const TEALDatasourceKey_Pagetype;
extern NSString * const TEALDatasourceKey_Platform;
extern NSString * const TEALDatasourceKey_SystemVersion;
extern NSString * const TEALDatasourceKey_LibraryVersion;
extern NSString * const TEALDatasourceKey_UUID;
extern NSString * const TEALDatasourceKey_ApplicationName;
extern NSString * const TEALDatasourceKey_Timestamp;
extern NSString * const TEALDatasourceKey_CallType;
extern NSString * const TEALDatasourceKey_EventTitle;
extern NSString * const TEALDatasourceKey_ViewTitle;


extern NSString * const TEALDatasourceKey_LifecycleType;

#pragma mark - UDO / Datasource Values

extern NSString * const TEALDatasourceValue_LifecycleLaunch;
extern NSString * const TEALDatasourceValue_LifecycleWake;
extern NSString * const TEALDatasourceValue_LifecycleSleep;
extern NSString * const TEALDatasourceValue_LifecycleTerminate;
extern NSString * const TEALDatasourceValue_True;
extern NSString * const TEALDatasourceValue_False;
extern NSString * const TEALDatasourceValue_EventName;
extern NSString * const TEALDatasourceValue_Pagetype;
extern NSString * const TEALDatasourceValue_Platform;

#pragma mark - AudienceStream API Keys

extern NSString * const TEALCollectKey_Account;
extern NSString * const TEALCollectKey_Profile;
extern NSString * const TEALCollectKey_Environment;
extern NSString * const TEALCollectKey_VisitorID;
extern NSString * const TEALCollectKey_TraceID;

@interface TEALDatasources : NSObject

@end
