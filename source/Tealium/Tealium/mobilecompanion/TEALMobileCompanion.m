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

@interface TEALMobileCompanion() <TEALMobileCompanionViewDelegate>

@property (nonatomic, strong) NSString *instanceID;
@property (nonatomic, strong) TEALMobileCompanionView *customView;
@property (nonatomic, strong) TEALMobileCompanionTableViewController *tableViewController;

@end

@implementation TEALMobileCompanion

#pragma mark - PUBLIC INSTANCE

- (instancetype) initWithInstanceID:(NSString *)instanceID {
    self = [super init];
    if (self){
        
        _instanceID = instanceID;
        _tableViewController = [[TEALMobileCompanionTableViewController alloc] init];
        
    }
    return self;
}

- (void) addContent:(TEALMobileCompanionContent * )content forTitle:(NSString *)title {
    
    self.tableViewController.currentContent = content;
    [self refresh];
}

- (void) refresh {
    
    [self.customView redrawExpanded];
}

- (void) reveal {
    
    self.view.alpha = 0.0;
    
    [[self rootWindowController].view addSubview:self.view];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.view.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void) forceDismiss {
    
    [self.customView dismiss];
    
}

#pragma mark - PRIVATE INSTANCE

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
            [self.delegate tealiumMobileCompanionRequestsDataSources:self forObject:nil];
        }
    }
    if ([title isEqualToString:TEALMobileCompanionTabTitleElement]) {
        if (self.delegate){
            [self.delegate tealiumMobileCompanionRequestsDataSources:self forObject:nil];
        }
    }
    if ([title isEqualToString:TEALMobileCompanionTabTitleLogs]) {
        if (self.delegate){
            [self.delegate tealiumMobileCompanionRequestsDispatchLogs:self];
        }
    }
    
}

#pragma mark - DATA HELPERS

//- (TEALMobileCompanionContent *) contentForTitle:(NSString *)title {
//    
//    return self.tableViewController.contentData[title];
//}

@end
