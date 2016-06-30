//
//  TEALSettings+TagManagement.m
//  UIKitCatalog
//
//  Created by Jason Koo on 1/10/16.
//
//

#import "TEALSettings+TagManagement.h"
#import "TEALSettings+PrivateHeader.h"
#import "TEALPublishSettings+TagManagement.h"
#import "TEALConfiguration+TagManagement.h"

@implementation TEALSettings (TagManagement)

- (BOOL) tagManagementEnabled {
    
    return [[self publishSettings] enableTagManagement];

}

- (BOOL) remoteCommandsEnabled {
    
    return [[self configuration] remoteCommandsEnabled];
}


- (NSString * _Nullable) tagManagementPublishURLString {
    
    return [TEALSettings publishURLFromConfiguration:self.configuration];
    
}

+ (NSString *) publishURLFromConfiguration:(TEALConfiguration *)configuration {
    
    if ([configuration overrideTagManagementURL]) {
        return configuration.overrideTagManagementURL;
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
