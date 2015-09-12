//
//  TEALMobileCompanion.m
//  Tealium
//
//  Created by Jason Koo on 8/27/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALMobileCompanion.h"
#import "TEALMobileCompanionView.h"
#import "TEALMobileCompanionConstants.h"
#import "TEALMobileCompanionTableViewController.h"
#import "TEALMobileCompanionContent.h"
#import "TEALMobileCompanionOverlays.h"

@interface TEALMobileCompanion() <TEALMobileCompanionViewDelegate, TEALMobileCompanionOverlaysDelegate>

@property (nonatomic, strong) NSString *instanceID;
@property (nonatomic, strong) TEALMobileCompanionView *customView;
@property (nonatomic, strong) TEALMobileCompanionTableViewController *tableViewController;
@property (nonatomic, strong) TEALMobileCompanionOverlays *overlays;
@property (nonatomic)   BOOL ivarIsEnabled;

@end

@implementation TEALMobileCompanion

#pragma mark - PUBLIC INSTANCE

- (instancetype) initWithInstanceID:(NSString *)instanceID {
    self = [super init];
    if (self){
        
        _instanceID = instanceID;
        _tableViewController = [[TEALMobileCompanionTableViewController alloc] init];
        _overlays = [[TEALMobileCompanionOverlays alloc] init];
        _ivarIsEnabled = NO;
        
    }
    return self;
}

- (void) addContent:(TEALMobileCompanionContent * )content forTitle:(NSString *)title {
    
    self.tableViewController.currentContent = content;
    [self refresh];
}

- (void) enable {
    
    self.ivarIsEnabled = YES;
    [self addGestureUnlockRecognizer];
}

- (void) disable {

    self.ivarIsEnabled = NO;
    [self removeGestureUnlockRecognizer];
    [self forceDismiss];
    
}

- (BOOL) isEnabled {
    
    return self.ivarIsEnabled;
    
}

- (void) refresh {
    
    if (!self.ivarIsEnabled) return;
    
    [self.customView redrawExpanded];
}

- (void) reveal {
    
    if (!self.ivarIsEnabled) return;
    if ([self rootWindowControllerViewContainsSelf]) return;
    
    self.view.alpha = 0.0;
    
    [self.overlays addOverlays];
    
    [[self rootWindowController].view addSubview:self.view];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.view.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (BOOL) rootWindowControllerViewContainsSelf {
    
    return [[[self rootWindowController].view subviews] containsObject:self];
    
}

- (void) forceDismiss {
    
    // This triggers the same method the popup close button executes when tapped.
    [self.customView dismiss];
    
}

#pragma mark - PRIVATE INSTANCE

- (instancetype) init {
    [NSException raise:@"Should not be initialized directly"
                format:@"Please use initWithInstanceID method."];
    return nil;
}

- (UIView *) view {
    
    if (!self.customView){
        self.customView = [[TEALMobileCompanionView alloc] init];
        [self.customView setDelegate:self];
        [self.customView setTableViewDelegate:self.tableViewController];
        [self.customView setTableViewDataSourceDelegate:self.tableViewController];
        
        [self.customView addGestureRecognizer:[self panGestureRecognizers]];
        [self.customView addGestureRecognizer:[self tapGestureRecognizers]];
        [self.customView addGestureRecognizer:[self pinchGestureRecognizer]];
    }
    
    return self.customView;
}

- (void) addGestureUnlockRecognizer {
 
#warning IMPLEMENT gesture enablement

}

- (void) removeGestureUnlockRecognizer {
    
#warning IMPLEMENT gesture disablement

}

#pragma mark - HELPERS

- (UIViewController*) rootWindowController{
    UIWindow *window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    UIViewController *vc = window.rootViewController;
    return vc;
}

- (UIPanGestureRecognizer *) panGestureRecognizers {
    
    return [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    
}

- (UITapGestureRecognizer *) tapGestureRecognizers {
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(open:)];
    [recognizer setNumberOfTouchesRequired:1];
    
    return recognizer;
    
}

- (UIPinchGestureRecognizer *) pinchGestureRecognizer {
    return [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(resize:)];
}

- (void) open:(UITapGestureRecognizer *) recognizer {
    
    [self.customView expand];
    
}

- (void) resize:(UIPinchGestureRecognizer *) recognizer {
    
    CGFloat scale = recognizer.scale;
    
        CGFloat x = self.customView.frame.origin.x;
        CGFloat y = self.customView.frame.origin.y;
        CGFloat newWidth = self.customView.bounds.size.width * scale;
        CGFloat newHeight = self.customView.bounds.size.height  * scale;
    
    if (newWidth > kMinWidth &&
        newHeight > kMinHeight){
        
        [self.customView setFrame:CGRectMake(x, y, newWidth, newHeight)];
        [self.customView redrawExpanded];
    }
}

- (void) panView:(UIPanGestureRecognizer*) recognizer {
    
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
}

#pragma mark - TEAL MOBILE COMPANION VIEW DELEGATE

- (void) tealiumMobileCompanionViewDismissed {
    
    [self.overlays removeOverlays];
    
    if (self.delegate) {
        [self.delegate tealiumMobileCompanionDidDismiss];
    }
    
}

- (void) tealiumMobileCompanionViewRequestsDataForTabTitle:(NSString *)title {
    
    if ([title isEqualToString:TEALMobileCompanionTabTitleOverview]) {
        if (self.delegate){
            [self.delegate tealiumMobileCompanionRequestsSettings:self];
        }
    }
    if ([title isEqualToString:TEALMobileCompanionTabTitleView]) {
        if (self.delegate){
            [self.delegate tealiumMobileCompanionRequestsViewDataSources:self forObject:nil];
        }
    }
    
#warning REMOVE?
    if ([title isEqualToString:TEALMobileCompanionTabTitleElement]) {
        if (self.delegate){
            [self.delegate tealiumMobileCompanionRequestsEventDataSources:self forObject:nil];
        }
    }
    
    if ([title isEqualToString:TEALMobileCompanionTabTitleLogs]) {
        if (self.delegate){
            [self.delegate tealiumMobileCompanionRequestsDispatchLogs:self];
        }
    }
    
    if ([title isEqualToString:TEALMobileCompanionTabTitleTools]) {
        if (self.delegate){
            [self.delegate tealiumMobileCompanionRequestsTools:self];
        }
    }
}

#pragma mark - TEAL MOBILE COMPANION OVERLAY DELEGATE

- (void) tealiumMobileCompanionOverlayTriggeredInspectionForObject:(NSObject *)object {
    
    if (self.delegate){
        [self.delegate tealiumMobileCompanionRequestsEventDataSources:self forObject:object];
    }
    
}


@end
