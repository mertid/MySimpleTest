//
//  Tealium+TagManagement.h
//  Tealium
//
//  Created by Jason Koo on 8/20/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#ifndef TEAL_MODULE_TAGMANAGEMENT
#define TEAL_MODULE_TAGMANAGEMENT
#endif

#import "Tealium.h"

#import "TEALRemoteCommandResponse.h"

@interface Tealium (TagManagement)

/**
 *  The UIWebView instance used by the internal tag management system.
 *
 *  @return UIWebView if the remote publish settings tag management toggle is TRUE, otherwise will return nil.
 */
- (UIWebView *) webView;


- (void) addRemoteCommandId:(NSString*)name description:(NSString*)description targetQueue:(dispatch_queue_t)queue block:(TEALRemoteCommandResponseBlock)responseBlock;

@end
