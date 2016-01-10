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

@implementation TEALConfiguration (TagManagement)

- (NSString *) overrideTagManagementPublishURL {
    
    NSDictionary *moduleData =  [self moduleData];
    
    return [moduleData[TEALTagManagementOverridePublishURLKey] copy];
    
}

- (void) setOverrideTagManagementPublishURL:(NSString *)publishURL {
    
    [self setModuleObject:publishURL forKey:TEALTagManagementOverridePublishURLKey];
    
    [self setModuleDescription:publishURL forKey:@"override tag management publish url"];
    
}

@end
