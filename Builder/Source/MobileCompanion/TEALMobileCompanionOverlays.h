//
//  TEALMobileCompanionOverlays.h
//  Tealium
//
//  Created by Jason Koo on 9/11/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TEALMobileCompanionOverlaysDelegate <NSObject>

- (void) tealiumMobileCompanionOverlayTriggeredInspectionForObject:(NSObject *)object;

@end

@interface TEALMobileCompanionOverlays : NSObject

@property (nonatomic, weak) id<TEALMobileCompanionOverlaysDelegate> delegate;

- (void) addOverlays;
- (void) removeOverlays;

@end
