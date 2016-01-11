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

- (BOOL) remoteCommandsEnabled {
    
    NSDictionary *moduleData =  [self moduleData];
    
    return [moduleData[TEALRemoteCommandsEnableKey] boolValue];
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


@end
