//
//  TEALNotifications.h
//  Tealium
//
//  Created by Jason Koo on 11/3/15.
//  Copyright © 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TEALNotifications : NSObject

typedef NS_ENUM(NSInteger, TEALNotificationType) {
    TEALNotificationNone        = 0,
    TEALNotificationDispatchesSent
};


@end
