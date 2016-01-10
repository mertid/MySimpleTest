//
//  TEALConfiguration+TagManagement.h
//  UIKitCatalog
//
//  Created by Jason Koo on 1/10/16.
//
//

#import "TEALConfiguration.h"

@interface TEALConfiguration (TagManagement)

- (NSString *) overrideTagManagementPublishURL;

- (void) setOverrideTagManagementPublishURL:(NSString *)publishURL;


@end
