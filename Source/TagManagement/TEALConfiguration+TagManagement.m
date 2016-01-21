//
//  TEALConfiguration+TagManagement.m
//  UIKitCatalog
//
//  Created by Jason Koo on 1/10/16.
//
//

#import "TEALConfiguration+TagManagement.h"
#import "TEALConfiguration+PrivateHeader.h"

NSString * const TEALTagManagementOverridePublishURLKey = @"com.tealium.tagmanagement.override.publishurl";
NSString * const TEALRemoteCommandsEnableKey = @"com.tealium.remotecommands.enable";

@implementation TEALConfiguration (TagManagement)

#pragma mark - PUBLIC

- (BOOL) remoteCommandsEnabled {
    
    NSDictionary *moduleData =  [self moduleData];
    
    id enable = moduleData[TEALRemoteCommandsEnableKey];
                 
    if (!enable ||
        ![enable respondsToSelector:@selector(boolValue)]){
        
        // Default
        return YES;
        
    }
    
    return  [enable boolValue];
}

- (NSString *) tagManagementPublishURL {
    
    return [TEALConfiguration publishURLFromConfiguration:self];
    
}

- (NSString *) overrideTagManagementPublishURL {
    
    NSDictionary *moduleData =  [self moduleData];
    
    return [moduleData[TEALTagManagementOverridePublishURLKey] copy];
    
}

- (void) setOverrideTagManagementPublishURL:(NSString *)publishURL {
    
    [self setModuleObject:publishURL
                   forKey:TEALTagManagementOverridePublishURLKey
               completion:nil];
    
    [self setModuleDescription:publishURL forKey:@"override tag management publish url"];
    
}

- (void) setRemoteCommandsEnabled:(BOOL)enabled {
    
    
    [self setModuleObject:@(enabled)
                   forKey:TEALRemoteCommandsEnableKey
               completion:nil];
    
    [self setModuleDescription:enabled?@"YES":@"NO" forKey:@"remote commands enabled"];
    
}

#pragma mark - PRIVATE

+ (NSString *) publishURLFromConfiguration:(TEALConfiguration *)configuration {
    
    NSString *override = [configuration overridePublishURL];
    
    if (override) {
        return override;
    }
    
    // Default
    NSString *urlPrefix = @"https:";
    
    return [NSString stringWithFormat:@"%@//tags.tiqcdn.com/utag/%@/%@/%@/mobile.html?",
            urlPrefix,
            configuration.accountName,
            configuration.profileName,
            configuration.environmentName];
}

@end
