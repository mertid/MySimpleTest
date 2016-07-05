//
//  TEALPublishSettings+TagManagement.m
//  UIKitCatalog
//
//  Created by Jason Koo on 1/10/16.
//
//

#import "TEALPublishSettings+TagManagement.h"
#import "TEALPublishSettings+PrivateHeader.h"
#import "NSString+Tealium.h"
#import "TEALPublishSettingsConstants.h"

@implementation TEALPublishSettings (TagManagement)

- (BOOL) enableTagManagement {
    
    NSString *tagMangement = self.privatePublishSettingsData[TEALPublishSettingKeyTagManagementEnable];
    
    BOOL enable = [tagMangement boolValue];
        
    return enable;
    
}

@end
