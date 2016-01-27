//
//  TEALReachability.h
//  TealiumiOS
//
//  Created by Jason Koo on 11/30/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//
/*
 
 TEALReachability is a modification of the original code from: https://github.com/tonymillion/Reachability
 
 */

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

/**
 * Create NS_ENUM macro if it does not exist on the targeted version of iOS or OS X.
 *
 * @see http://nshipster.com/ns_enum-ns_options/
 **/
#ifndef NS_ENUM
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#endif

extern NSString *const kTEALReachabilityChangedNotification;

typedef NS_ENUM(NSInteger, TEALNetworkStatus) {
    // Apple NetworkStatus Compatible Names.
    TEALNetworkStatusNotReachable = 0,
    TEALNetworkStatusReachableViaWiFi = 2,
    TEALNetworkStatusReachableViaWWAN = 1
};

@class TEALReachability;

typedef void (^NetworkReachable)(TEALReachability * reachability);
typedef void (^NetworkUnreachable)(TEALReachability * reachability);


@interface TEALReachability : NSObject

@property (nonatomic, copy) NetworkReachable    reachableBlock;
@property (nonatomic, copy) NetworkUnreachable  unreachableBlock;

@property (nonatomic, assign) BOOL reachableOnWWAN;


+(instancetype)reachabilityWithHostname:(NSString*)hostname;
// This is identical to the function above, but is here to maintain
//compatibility with Apples original code. (see .m)
+(instancetype)reachabilityWithHostName:(NSString*)hostname;
+(instancetype)reachabilityForInternetConnection;
+(instancetype)reachabilityWithAddress:(void *)hostAddress;
+(instancetype)reachabilityForLocalWiFi;

-(instancetype)initWithReachabilityRef:(SCNetworkReachabilityRef)ref;

-(BOOL)startNotifier;
-(void)stopNotifier;

-(BOOL)isReachable;
-(BOOL)isReachableViaWWAN;
-(BOOL)isReachableViaWiFi;

// WWAN may be available, but not active until a connection has been established.
// WiFi may require a connection for VPN on Demand.
-(BOOL)isConnectionRequired; // Identical DDG variant.
-(BOOL)connectionRequired; // Apple's routine.
// Dynamic, on demand connection?
-(BOOL)isConnectionOnDemand;
// Is user intervention required?
-(BOOL)isInterventionRequired;

-(TEALNetworkStatus)currentReachabilityStatus;
-(SCNetworkReachabilityFlags)reachabilityFlags;
-(NSString*)currentReachabilityString;
-(NSString*)currentReachabilityFlags;

- (NSDictionary *) reachabilityDataSources:(NSDictionary *)clientDataSources;

@end
