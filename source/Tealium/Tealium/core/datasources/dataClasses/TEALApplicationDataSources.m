//
//  TEALApplicationDataSources.m
//  Tealium
//
//  Created by Jason Koo on 9/21/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import "TEALApplicationDataSources.h"
#import "TEALDataSourceConstants.h"

@implementation TEALApplicationDataSources

+ (NSDictionary *) dataSources {
    
    NSMutableDictionary *dataSources = [NSMutableDictionary dictionary];
    
    NSString *appName = [self applicationName];
    NSString *appRDNS = [self bundleId];
    NSString *appVersion = [self bundleVersion];
    
    if (appName) dataSources[TEALDataSourceKey_ApplicationName] = appName;
    if (appRDNS) dataSources[TEALDataSourceKey_ApplicationRDNS] = appRDNS;
    if (appVersion) dataSources[TEALDataSourceKey_ApplicationVersion] = appVersion;
    
    return [NSDictionary dictionaryWithDictionary:dataSources];
}

+ (NSString *) applicationName {
    
    NSDictionary *bundle = [[NSBundle mainBundle] infoDictionary];
    
    return [bundle objectForKey:@"CFBundleName"];
}

+ (NSString *) bundleId {
    NSBundle *bundle = [NSBundle mainBundle];
    
    if (bundle) {
        return [bundle bundleIdentifier];
    }
    return nil;
}

+ (NSString *) bundleVersion {
    NSDictionary *bundle = [[NSBundle mainBundle] infoDictionary];
    
    NSString *version = [bundle objectForKey:@"CFBundleShortVersionString"];
    
    if (version == nil) {
        version = [bundle objectForKey:@"CFBundleVersion"];
    }
    return version;
}

@end
