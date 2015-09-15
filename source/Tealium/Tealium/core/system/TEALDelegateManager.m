//
//  TEALDelegateManager.m
//  Tealium
//
//  Created by Jason Koo on 7/22/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALDelegateManager.h"

@interface TEALDelegateManager ()

@property (weak, nonatomic) id<TealiumDelegate> delegate;
@property (nonatomic) BOOL hasDidFinishLoadingRemoteSettings;
@property (nonatomic) BOOL hasShouldSendDispatch;
@property (nonatomic) BOOL hasDidSendDispatch;
@property (nonatomic) BOOL hasDidQueueDispatch;

@end

@implementation TEALDelegateManager


- (void) updateWithDelegate:(id<TealiumDelegate>)delegate {
    
    self.delegate = delegate;

    self.hasDidFinishLoadingRemoteSettings = [self.delegate respondsToSelector:@selector(tealiumDidFinishLoadingRemoteSettings:)];
    self.hasShouldSendDispatch = [self.delegate respondsToSelector:@selector(tealium:shouldSendDispatch:)];
    self.hasDidSendDispatch = [self.delegate respondsToSelector:@selector(tealium:didSendDispatch:)];
    self.hasDidQueueDispatch = [self.delegate respondsToSelector:@selector(tealium:didQueueDispatch:)];
}


- (void) tealiumDidFinishLoadingRemoteSettings:(Tealium *) tealium {
    if (self.hasDidFinishLoadingRemoteSettings) {

    }
}

- (BOOL) tealium:(Tealium *)tealium shouldSendDispatch:(TEALDispatch *)dispatch {
    
#warning THIS check does not actually work
    
    if (self.hasDidSendDispatch) {
        return [self.delegate tealium:tealium shouldSendDispatch:dispatch];
    }
    return YES;
}

- (void) tealium:(Tealium *)tealium didSendDispatch:(TEALDispatch *)dispatch {
    if (self.hasDidSendDispatch) {
        [self.delegate tealium:tealium didSendDispatch:dispatch];
    }
}

- (void) tealium:(Tealium *)tealium didQueueDispatch:(TEALDispatch *)dispatch {
    if (self.hasDidQueueDispatch){
        [self.delegate tealium:tealium didQueueDispatch:dispatch];
    }
}


@end
