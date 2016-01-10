//
//  TEALSettings+Collect.m
//  UIKitCatalog
//
//  Created by Jason Koo on 1/9/16.
//
//

#import "TEALSettings+Collect.h"
#import "TEALSettings+PrivateHeader.h"
#import "TEALConfiguration+Collect.h"
#import "TEALDataSourceConstants.h"
#import "TEALNetworkHelpers.h"


static NSString * defaultCollectDispatchURLString = nil;

@implementation TEALSettings (Collect)

- (NSString *) collectDispatchURLString {
    
    NSString *overrideDispatchString = [self.configuration overrideCollectDispatchURL];
    
    if (overrideDispatchString){
        return overrideDispatchString;
    } else {
        return [TEALSettings defaultCollectDispatchURLStringFromConfiguration:self];
    }
    
}

+ (NSString *) defaultCollectDispatchURLStringFromConfiguration:(TEALSettings *)settings {
    
    if (!defaultCollectDispatchURLString){
        
        NSString *urlPrefix = @"https";
        
        if ([settings useHTTP]) {
            urlPrefix = @"http";
        }
        
        NSString *baseURLString = [NSString stringWithFormat:@"%@://datacloud.tealiumiq.com/vdata/i.gif?", urlPrefix];
        
        NSMutableDictionary *params = [NSMutableDictionary new];
        
        params[TEALCollectKey_Account]   = [settings account];
        params[TEALCollectKey_Profile]   = [settings asProfile];
        params[TEALCollectKey_VisitorID] = [settings visitorIDCopy];
        
        if (settings.traceID) {
            params[TEALCollectKey_TraceID] = settings.traceID;
        }
        
        NSString *queryString = [TEALNetworkHelpers urlParamStringFromDictionary:params];
        
        defaultCollectDispatchURLString = [baseURLString stringByAppendingString:queryString];
    }
    
    return defaultCollectDispatchURLString;
}

@end
