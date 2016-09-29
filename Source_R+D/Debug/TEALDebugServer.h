//
//  TEALDebugServer.h
//  FrameworkBuilder
//
//  Created by Jason Koo on 9/29/16.
//  Copyright © 2016 Tealium. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TEALDebugServerDelegate <NSObject>

@optional

- (void) debugServerFailedToStart(server:TEALDebugServer, error: NSError);
- (void) debugServerDidStart(server:TEALDebugServer);
- (void) debugServerDidStop(server:TEALDebugServer);

//- (void) debugServerReceivedResponse()

@end

@interface TEALDebugServer : NSObject

- (void) startServer;
- (void) stopServer;

@end
