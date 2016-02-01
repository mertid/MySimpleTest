//
//  TEALWKExtensionConfiguration.m
//  WatchKit Catalog
//
//  Created by Jason Koo on 12/3/15.
//  Copyright © 2015 Apple Inc. All rights reserved.
//

#import "TEALWKExtensionConfiguration.h"

@interface TEALWKExtensionConfiguration()

@end

@implementation TEALWKExtensionConfiguration

#pragma mark - PUBLIC CLASS

+ (instancetype) configuration{
    
    TEALWKExtensionConfiguration *configuration = [[TEALWKExtensionConfiguration alloc] init];
    
    if (!configuration) {
        return nil;
    }
    
    configuration.offlineDispatchQueueSize = 100;
    configuration.logLevel = TEALLogLevelNone;
    
    return configuration;
}

#pragma mark - PRIVATE INSTANCE

- (NSString *) description {
    
    NSString *title = @"Tealium Watch Kit Extension Configuration";
    
    NSString *offlineSizeAsString = [NSString stringWithFormat:@"%lu", (unsigned long)self.offlineDispatchQueueSize];
    
    NSDictionary *descriptionData = @{
                                      @"offline dispatch queue size":offlineSizeAsString,
                                      @"log level":[TEALLogger stringFromLogLevel:self.logLevel]
                                      
                                      };
    
    
    NSString *displayClass              = NSStringFromClass([self class]);
    
    NSMutableString *descriptionString = [NSMutableString stringWithString:[NSString stringWithFormat:@"\r\r === %@ === \r", displayClass]];
    
    if (title){
        [descriptionString appendString:[NSString stringWithFormat:@"( %@ )\r", title]];
    }
    
    NSArray *keys = [[descriptionData allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    for (NSString *key in keys){
        NSString *keyValue = descriptionData[key];
        if (keyValue) {
            [descriptionString appendString:[NSString stringWithFormat:@"%@:%@ \r", key, keyValue]];
        }
    }
    
    [descriptionString appendString:@"\r"];
    
    return [NSString stringWithString:descriptionString];
    
}

@end
