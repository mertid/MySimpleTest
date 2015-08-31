//
//  TEALMobileCompanion.m
//  Tealium
//
//  Created by Jason Koo on 8/27/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALMobileCompanion.h"
#import "TEALMobileCompanionView.h"

@interface TEALMobileCompanion() <TEALMobileCompanionViewDelegate>

@property (nonatomic, strong) NSString *instanceID;
@property (nonatomic, strong) TEALMobileCompanionView *customView;

@end

@implementation TEALMobileCompanion

#pragma mark - PUBLIC INSTANCE

- (instancetype) initWithInstanceID:(NSString *)instanceID {
    self = [super init];
    if (self){
        
        _instanceID = instanceID;
        
    }
    return self;
}

- (void) reveal {
    
    [[self rootWindowController].view addSubview:self.view];
    
    

}

#pragma mark - PRIVATE INSTANCE

- (UIView *) view {
    
    if (!self.customView){
        self.customView = [[TEALMobileCompanionView alloc] init];
        [self.customView setDelegate:self];
    }
    
    [self.customView addGestureRecognizer:[self panGestureRecognizers]];
    [self.customView addGestureRecognizer:[self tapGestureRecognizers]];
    
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

- (void) open:(UITapGestureRecognizer *) recognizer {
    
    [self.customView expand];
    
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
@end
