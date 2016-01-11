//
//  TEALConfiguration+TagManagement.h
//  UIKitCatalog
//
//  Created by Jason Koo on 1/10/16.
//
//

#import "TEALConfiguration.h"

@interface TEALConfiguration (TagManagement)

/**
 *  Read-only flag for remote commands triggerablilty status.
 *
 *  @default YES
 */
- (BOOL) remoteCommandsEnabled;

- (NSString * _Nullable) overrideTagManagementPublishURL;

- (void) setOverrideTagManagementPublishURL:(NSString * _Nonnull)publishURL;

- (void) setRemoteCommandsEnabled:(BOOL)enabled;

@end
