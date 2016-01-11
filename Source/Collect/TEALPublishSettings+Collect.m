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
    
    [self setModuleDescription:[NSString teal_stringFromBool:enableCollect] forKey:@"enable Collect"];
    
    return enableCollect;

    
}

- (BOOL) enableS2SLegacy {
    
    NSString *enable = self.privatePublishSettingsData[TEALPublishSettingKeyS2SLegacyEnable];
    
    BOOL enableS2S = [enable boolValue];
    
    [self setModuleDescription:[NSString teal_stringFromBool:enableS2S  ] forKey:@"enable S2S Legacy"];
    
    return enableS2S;
    
}


@end
