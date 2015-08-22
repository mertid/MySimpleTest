//
//  Tealium+TagManagement.h
//  Tealium
//
//  Created by Jason Koo on 8/20/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "Tealium.h"

@interface Tealium (TagManagement)

/**
 *  The UIWebView instance used by the internal tag management system.
 *
 *  @return UIWebView if the remote publish settings tag management toggle is TRUE, otherwise will return nil.
 */
- (UIWebView *) webView;

@end
