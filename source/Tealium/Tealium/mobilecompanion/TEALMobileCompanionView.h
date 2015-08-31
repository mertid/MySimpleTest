//
//  TEALMobileCompanionView.h
//  Tealium
//
//  Created by Jason Koo on 8/27/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TEALMobileCompanionViewDelegate <NSObject>

- (void) tealiumMobileCompanionViewDismissed;

@end

@interface TEALMobileCompanionView : UIView

@property (nonatomic, weak) id<TEALMobileCompanionViewDelegate> delegate;

- (void) expand;

- (void) minimize;

- (void) dismiss;

@end
