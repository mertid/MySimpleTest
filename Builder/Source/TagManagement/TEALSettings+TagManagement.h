//
//  TEALSettings+TagManagement.h
//  UIKitCatalog
//
//  Created by Jason Koo on 1/10/16.
//
//

#import "TEALSettings.h"

@interface TEALSettings (TagManagement)

- (BOOL) tagManagementEnabled;

- (BOOL) remoteCommandsEnabled;

- (NSString * _Nullable) tagManagementPublishURLString;

@end
