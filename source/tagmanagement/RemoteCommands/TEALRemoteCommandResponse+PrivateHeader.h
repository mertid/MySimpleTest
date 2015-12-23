//
//  TEALRemoteCommandResponse+PrivateHeader.h
//  Tealium
//
//  Created by Jason Koo on 11/10/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#ifndef TEALRemoteCommandResponse_PrivateHeader_h
#define TEALRemoteCommandResponse_PrivateHeader_h


#endif /* TEALRemoteCommandResponse_PrivateHeader_h */

#import "TEALRemoteCommandResponse.h"

@interface TEALRemoteCommandResponse (Private)

- (instancetype) initWithURLString:(NSString*)urlString completionHandler:(TEALRemoteCommandResponseBlock)responseBlock;

- (void) send;

@end

@protocol TEALRemoteCommandResponseDelegate <NSObject>

- (void) tealiumRemoteCommandResponseRequestsSend:(TEALRemoteCommandResponse*)response;

@end