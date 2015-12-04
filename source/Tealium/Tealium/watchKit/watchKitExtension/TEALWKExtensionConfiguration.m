//
//  TEALWKExtensionConfiguration.m
//  WatchKit Catalog
//
//  Created by Jason Koo on 12/3/15.
//  Copyright © 2015 Apple Inc. All rights reserved.
//

#import "TEALWKExtensionConfiguration.h"

@implementation TEALWKExtensionConfiguration

#pragma mark - PUBLIC CLASS

+ (instancetype) configurationWithAccount:(NSString *)accountName
                                  profile:(NSString *)profileName
                              environment:(NSString *)environmentName{
    
    TEALWKExtensionConfiguration *configuration = [[TEALWKExtensionConfiguration alloc] init];
    
    if (!configuration) {
        return nil;
    }
    
    // Default configuration
    configuration.accountName       = [accountName lowercaseString];
    configuration.profileName       = [profileName lowercaseString];
    configuration.environmentName   = [environmentName lowercaseString];
    
    return configuration;
}

+ (BOOL) isValidConfiguration:(TEALWKExtensionConfiguration *)configuration {
    if (!configuration.accountName) return NO;
    if (!configuration.profileName) return NO;
    if (!configuration.environmentName) return NO;
    
    NSString *accountSpacesRemoved = [configuration.accountName stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([accountSpacesRemoved isEqualToString:@""]) return NO;
    
    NSString *profileSpacesRemoved = [configuration.profileName stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([profileSpacesRemoved isEqualToString:@""]) return NO;
    
    NSString *environmentSpacesRemoved = [configuration.environmentName stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([environmentSpacesRemoved isEqualToString:@""]) return NO;
    
    return YES;
}

#pragma mark - PRIVATE INSTANCE

- (NSString *) description {
    
    NSString *title = @"Tealium Watch Kit Extension Configuration";
    
    NSDictionary *descriptionData = @{
                                      @"instance id":self.instanceID? self.instanceID:@"",
                                      @"account - name":self.accountName? self.accountName:@"",
                                      @"account - profile":self.profileName? self.profileName:@"",
                                      @"account - target environment":self.environmentName? self.environmentName:@""
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
