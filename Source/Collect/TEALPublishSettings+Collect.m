//
//  TEALPublishSettings+Collect.m
//  UIKitCatalog
//
//  Created by Jason Koo on 1/10/16.
//
//

#import "TEALPublishSettings+Collect.h"
#import "TEALPublishSettingsConstants.h"
#import "TEALPublishSettings+PrivateHeader.h"
#import "NSString+Tealium.h"

@implementation TEALPublishSettings (Collect)


- (BOOL) enableCollect {
    
    NSString *collectEnable = self.privatePublishSettingsData[TEALPublishSettingKeyCollectEnable];

    BOOL enableCollect = [collectEnable boolValue];
    
    return enableCollect;

    
}

- (BOOL) enableS2SLegacy {
    
    NSString *enable = self.privatePublishSettingsData[TEALPublishSettingKeyS2SLegacyEnable];
    
    BOOL enableS2S = [enable boolValue];
        
    return enableS2S;
    
}


@end
