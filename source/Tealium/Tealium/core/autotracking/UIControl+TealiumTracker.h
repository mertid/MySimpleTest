//
//  UIControl+TealiumTracker.h
//  UICatalog
//
//  Created by Jason Koo on 5/8/14.
//
//

#import <UIKit/UIKit.h>

@interface UIControl (TealiumTracker)

@property (nonatomic, strong) id mobileCompanionRevealObserver;

- (id) initWithOriginalFrame:(CGRect)frame;
- (void) requestOverlay;
- (void) hideOverlay:(NSNotification*)notification;
//- (void) dealloc;

@end
