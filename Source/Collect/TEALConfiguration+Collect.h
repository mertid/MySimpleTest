//
//  TEALConfiguration+Collect.h
//  UIKitCatalog
//
//  Created by Jason Koo on 1/9/16.
//
//

#import "TEALConfiguration.h"

@interface TEALConfiguration (Collect)


/**
 *  If assigned, will replace the destination endpoint for Collect dispatch calls.
 */
- (NSString * _Nullable) overrideCollectDispatchURL;


/**
 *  Set the destination endpoint for Collect dispatch calls.
 *
 *  @param overrideURL The NSString representation of the target URL address to use.
 */
- (void) setOverrideCollectDispatchURL:(NSString * _Nonnull) overrideURL;


@end
