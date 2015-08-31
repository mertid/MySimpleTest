//
//  TEALMobileCompanionView.m
//  Tealium
//
//  Created by Jason Koo on 8/27/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALMobileCompanionView.h"
#import "TEALMobileCompanionConstants.h"
#import "TEALImages.h"

#ifdef TEAL_MODULE_AUTOTRACKING
#import "NSObject+TealiumAutotracking.h"
#endif

@interface TEALMobileCompanionView()

@property (nonatomic, strong) UIButton  *currentCloseButton;
@property (nonatomic, strong) UIImageView *currentMinimizedBackground;
@property (nonatomic, strong) UIButton *currentMinimizeButton;

@end

@implementation TEALMobileCompanionView

#pragma mark - PUBLIC INSTANCE

- (void) expand {
    
    if ([self areOpen]){
        return;
    }
    
    [self addSubview:[self closeButton]];
    [self addSubview:[self minimizeButton]];
    
    __block typeof(self) __weak weakSelf = self;

    [UIView animateWithDuration:0.5
                     animations:^{

                         weakSelf.bounds = CGRectMake(0, 0, kMinWidth, kMinHeight);
                         
                         [[weakSelf closeButton] setAlpha:1.0];
                         [[weakSelf minimizeButton] setAlpha:1.0];
                         
                         [weakSelf minimizedBackground].alpha = 0.0;
                         
                         
                     } completion:^(BOOL finished) {
                         
                     }];

}

- (void) minimize {
    
    if (![self areOpen]) {
        return;
    }
    
    [self sendSubviewToBack:[self minimizedBackground]];
    
    __block typeof(self) __weak weakSelf = self;

    [UIView animateWithDuration:0.5
                     animations:^{
                         
                         weakSelf.bounds = CGRectMake(0, 0, kControllerWidth, kControllerHeight);
                         
                         [[weakSelf closeButton] setAlpha:0.0];
                         [[weakSelf minimizeButton] setAlpha:0.0];
                         
                         
                         [weakSelf minimizedBackground].alpha = 1.0;
                         [[weakSelf minimizedBackground] setFrame:weakSelf.bounds];

                         
                     } completion:^(BOOL finished) {
                         
                     }];
    
}

- (void) dismiss {
    
    __block typeof(self) __weak weakSelf = self;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                        
                         weakSelf.alpha = 0.0;
                         
                     } completion:^(BOOL finished) {
                         
                         [weakSelf.delegate tealiumMobileCompanionViewDismissed];
                         
                     }];
    
}

#pragma mark - PRIVATE INSTANCE

- (instancetype) init {

    CGFloat x = ([[UIScreen mainScreen] bounds].size.width * 0.5) - (kControllerWidth * 0.5);
    CGFloat y = ([[UIScreen mainScreen] bounds].size.height * 0.5) - (kControllerHeight * 0.5);
    
    self = [super initWithFrame:CGRectMake(x, y, kControllerWidth, kControllerHeight)];
    if (!self) return nil;
    
    self.backgroundColor = [TEALMobileCompanionView liteGrey];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 8;
    
    [self addSubview:[self minimizedBackground]];
    [self sendSubviewToBack:[self minimizedBackground]];
    [[self minimizedBackground] setFrame:self.bounds];

    [self disableAutotrackingOf:self];
    
    return self;
}

#warning MOVE THESE COLORS

+ (UIColor *) liteGrey {
    const float liteGrey = .5019;
    return [UIColor colorWithRed:liteGrey green:liteGrey blue:liteGrey alpha:1.0];
}

#pragma mark - VIEW COMPONENTS

- (UIImageView*) minimizedBackground{
    
    if (!self.currentMinimizedBackground){
        UIImage *image = [TEALImages tealiummobilecompanion_icon_png];
        UIImageView *imageview = [[UIImageView alloc]initWithImage:image];
        [self disableAutotrackingOf:imageview];
        self.currentMinimizedBackground = imageview;
    }
    
    return self.currentMinimizedBackground;

}

- (UIButton*) minimizeButton {
    
    if (!self.currentMinimizeButton){
        
        UIButton *button = [[UIButton alloc] init];
        [button setTitle:@"_" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(minimize) forControlEvents:UIControlEventTouchUpInside];

        self.currentMinimizeButton = button;
    }
    
    [self.currentMinimizeButton setFrame:[self minimizeButtonRectInView:self]];
    
    return self.currentMinimizeButton;
}

- (CGRect) minimizeButtonRectInView:(UIView*)view{
    return CGRectMake(view.bounds.size.width - kSetCornerButtonW, 0, kSetCornerButtonW, kSetCornerButtonH);
}

- (UIButton*) closeButton{
    
    if (!self.currentCloseButton){
        
        self.currentCloseButton = [[UIButton alloc] init];
        [self.currentCloseButton setTitle:@"X" forState:UIControlStateNormal];
        [self.currentCloseButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];

        [self disableAutotrackingOf:self.currentCloseButton];
    }
    
    [self.currentCloseButton setFrame:[self closeButtonRectInView:self]];
    
    return self.currentCloseButton;
    
}

- (CGRect) closeButtonRectInView:(UIView*)view{
    return CGRectMake(0, 0, kSetCornerButtonW, kSetCornerButtonH);
}

#pragma mark - HELPERS

- (BOOL) areOpen {
    
    if (self.bounds.size.width < kMinWidth ||
        self.bounds.size.height < kMinHeight)  {
        return NO;
    }
    
    return YES;
    
}

- (void) disableAutotrackingOf:(NSObject *)object {
    
#ifdef TEAL_MODULE_AUTOTRACKING
    [object teal_setAutotrackingEnabled:NO];
#endif
    
}
@end
