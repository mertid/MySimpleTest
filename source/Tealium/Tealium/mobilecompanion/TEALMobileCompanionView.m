//
//  TEALMobileCompanionView.m
//  Tealium
//
//  Created by Jason Koo on 8/27/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALMobileCompanionView.h"
#import "TEALMobileCompanionConstants.h"
#import "UIColor+TEALMobileCompanion.h"
#import "TEALImages.h"
#import "TEALMobileCompanionTriangle.h"
#import "TEALMobileCompanionContentSection.h"
#import "TEALMobileCompanionContentRow.h"

#ifdef TEAL_MODULE_AUTOTRACKING
#import "NSObject+TealiumAutotracking.h"
#endif

@interface TEALMobileCompanionView()

@property (nonatomic, strong) UIButton  *instanceCloseButton;
@property (nonatomic, strong) UIImageView *instanceMinimizedBackground;
@property (nonatomic, strong) UIButton *instanceMinimizeButton;
@property (nonatomic, strong) UIImageView *instanceContentArea;
@property (nonatomic, strong) UILabel *instanceTitleLabel;
@property (nonatomic, strong) UITableView *instanceContentTableView;
@property (nonatomic, strong) NSArray *instanceTabButtons;
@property (nonatomic, weak) UIButton *activeTabButton;

@property (nonatomic) BOOL isUILoaded;

@property (nonatomic, strong) TEALMobileCompanionTriangle *instanceResizeButton;


@end

@implementation TEALMobileCompanionView

#pragma mark - PUBLIC INSTANCE

- (void) expand {
    
    if ([self areOpen]){
        return;
    }
    
    if (!self.isUILoaded) {
        [self addSubview:[self contentArea]];
        [self addSubview:[self closeButton]];
        [self addSubview:[self minimizeButton]];
        [self addSubview:[self titleLabel]];
        [self addSubview:[self contentTableView]];

    }
    
    self.isUILoaded = YES;
    
    __block typeof(self) __weak weakSelf = self;

    [UIView animateWithDuration:0.5
                     animations:^{

                         weakSelf.bounds = CGRectMake(0, 0, kMinWidth, kMinHeight);
                         
                         [self addTabButtonsToView:self];

                         [[weakSelf closeButton] setAlpha:1.0];
                         [[weakSelf minimizeButton] setAlpha:1.0];
                         [[weakSelf contentArea] setAlpha:1.0];
                         [[weakSelf contentTableView] setAlpha:1.0];
                         [[weakSelf resizeButton] setAlpha:1.0];
                         [[weakSelf titleLabel] setAlpha:1.0];
                         [weakSelf setTabButtonsToAlpha:1.0];
                         
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
                         [[weakSelf contentArea] setAlpha:0.0];
//                         [[weakSelf contentTableView] setAlpha:0.0];
                         [[weakSelf resizeButton] setAlpha:0.0];
                         [[weakSelf titleLabel] setAlpha:0.0];
                         [weakSelf setTabButtonsToAlpha:0.0];
                         
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
    
    self.backgroundColor = [UIColor teal_darkGrey];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 8;
    
    [self addSubview:[self minimizedBackground]];
    [self sendSubviewToBack:[self minimizedBackground]];
    [[self minimizedBackground] setFrame:self.bounds];

    [self disableAutotrackingOf:self];
    
    return self;
}

- (void) redrawExpanded{
    
    [[self contentTableView] reloadData];
    [self minimizeButton];
    [self contentArea];
    [self resizeButton];
    [self addTabButtonsToView:self];
}


#pragma mark - VIEW COMPONENTS

- (UIImageView*) minimizedBackground{
    
    if (!self.instanceMinimizedBackground){
        UIImage *image = [TEALImages tealiummobilecompanion_icon_png];
        UIImageView *imageview = [[UIImageView alloc]initWithImage:image];
        [self disableAutotrackingOf:imageview];
        self.instanceMinimizedBackground = imageview;
    }
    
    return self.instanceMinimizedBackground;

}

- (UIButton*) minimizeButton {
    
    if (!self.instanceMinimizeButton){
        
        UIButton *button = [[UIButton alloc] init];
        [button setTitle:@"_" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(minimize) forControlEvents:UIControlEventTouchUpInside];

        self.instanceMinimizeButton = button;
    }
    
    [self.instanceMinimizeButton setFrame:[self minimizeButtonRectInView:self]];
    
    return self.instanceMinimizeButton;
}



- (UIButton*) closeButton{
    
    if (!self.instanceCloseButton){
        
        self.instanceCloseButton = [[UIButton alloc] init];
        [self.instanceCloseButton setTitle:@"X" forState:UIControlStateNormal];
        [self.instanceCloseButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];

        [self disableAutotrackingOf:self.instanceCloseButton];
    }
    
    [self.instanceCloseButton setFrame:[self closeButtonRectInView:self]];
    
    return self.instanceCloseButton;
    
}

- (CGRect) closeButtonRectInView:(UIView*)view {
    return CGRectMake(0, 0, kSetCornerButtonW, kSetCornerButtonH);
}

- (UIView *) contentArea {
    if (!self.instanceContentArea) {
        self.instanceContentArea = [[UIImageView alloc] init];
        [self.instanceContentArea setBackgroundColor:[UIColor teal_blue]];
        [self disableAutotrackingOf:self.instanceContentArea];
    }
    
    [self.instanceContentArea setFrame:[self contentAreaRectInView:self]];
    
    return self.instanceContentArea;
}

- (UITableView *) contentTableView {
    
    if (!self.instanceContentTableView){
        self.instanceContentTableView = [[UITableView alloc] init];
        [self.instanceContentTableView setBackgroundColor:[UIColor whiteColor]];
        [self.instanceContentTableView setDelegate:self.tableViewDelegate];
        [self.instanceContentTableView setDataSource:self.tableViewDataSourceDelegate];
        self.instanceContentTableView.layer.cornerRadius = 8;
        self.instanceContentTableView.layer.masksToBounds = YES;
        [self.instanceContentTableView setSeparatorColor:[UIColor clearColor]];
        [self.instanceContentTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.instanceContentTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:TEALMobileCompanionCellID];
        
        [self disableAutotrackingOf:self.instanceContentTableView];
    }
    
    [self.instanceContentTableView setFrame:[self contentViewRectInView:self]];
    
    return self.instanceContentTableView;
}

- (UILabel *) titleLabel {
    
    if (!self.instanceTitleLabel) {
        self.instanceTitleLabel = [[UILabel alloc] init];
        UIFont *font = [UIFont systemFontOfSize:kMinFontSize];
        [self.instanceTitleLabel setFont:font];
        [self.instanceTitleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.instanceTitleLabel setBackgroundColor:[UIColor teal_darkGrey]];
        [self.instanceTitleLabel setTextColor:[UIColor whiteColor]];
        [self.instanceTitleLabel setText:NSLocalizedString(@"Tealium Mobile Companion", @"")];
        
        [self disableAutotrackingOf:self.instanceTitleLabel];
    }
    
    [self.instanceTitleLabel setFrame:[self titleLabelRectInView:self]];
    
    return self.instanceTitleLabel;
}

- (void) addTabButtonsToView:(UIView *)view {
    
    NSArray *tabs = [self tabButtons];
    
    CGFloat tabWidths = ((view.bounds.size.width - ( 2 * kSetInsetSmall)) / [tabs count]) ;
    
    for (unsigned int t = 0; t < [tabs count]; t++) {
        
        UIButton *tab = tabs[t];
        
        if ([tab isKindOfClass:([UIButton class])]) {
        
            CGRect newFrame = CGRectMake(kSetInsetSmall + (t * tabWidths), kSetHeaderHeight, tabWidths, kSetTabButtonH);
            
            [tab setFrame:newFrame];

            [view addSubview:tab];
        
        }
    }
}

- (void) setTabButtonsToAlpha:(CGFloat)alpha {
    
    for (UIButton *tab in [self tabButtons]) {
        tab.alpha = alpha;
    }
    
}

- (UIButton*) tabButtonWithTitle:(NSString*)title{
    
    // Formats button and adds it to the parentview
    UIButton *button = [[UIButton alloc] init];
    [button setBackgroundColor:[UIColor teal_liteGrey]];
    [button setTitleColor:[UIColor teal_darkGrey] forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:kMinFontSize]];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:@selector(selectTab:) forControlEvents:UIControlEventTouchUpInside];
    
    [self disableAutotrackingOf:button];
    
    return button;
}

- (NSArray *) tabButtons {
    
    if (!self.instanceTabButtons) {
        
        UIButton *overView = [self tabButtonWithTitle:[self overViewTitle]];
        UIButton *view = [self tabButtonWithTitle:[self viewTitle]];
        UIButton *element = [self tabButtonWithTitle:[self elementTitle]];
        UIButton *log = [self tabButtonWithTitle:[self logTitle]];
        UIButton *tools = [self tabButtonWithTitle:[self toolsTitle]];
        
        self.instanceTabButtons = @[overView, view, element, log, tools];
    }
    
    return self.instanceTabButtons;
}

- (void) selectTab:(UIButton *)button {
    
        NSLog(@"%s ", __FUNCTION__);
    for (UIButton *tab in [self tabButtons]) {
        if (tab != button) {
            [tab setBackgroundColor:[UIColor teal_liteGrey]];
        }
        else {
            [tab setBackgroundColor:[UIColor teal_blue]];
        }
    }
    
    NSString *tabTitle = [self titleForTabButton:button];
    
    if (self.delegate) {
        [self.delegate tealiumMobileCompanionViewRequestsDataForTabTitle:tabTitle];
    }
        
}


- (TEALMobileCompanionTriangle *) resizeButton {
    if (!self.instanceResizeButton){
        self.instanceResizeButton = [[TEALMobileCompanionTriangle alloc] init];
        [self disableAutotrackingOf:self.instanceResizeButton];
    }
    
    [self.instanceResizeButton setFrame:[self resizeButtonRectInView:self]];
    
    return self.instanceResizeButton;
}

#pragma mark - VIEW RECTS

- (CGRect) minimizeButtonRectInView:(UIView*)view{
    return CGRectMake(view.bounds.size.width - kSetCornerButtonW, 0, kSetCornerButtonW, kSetCornerButtonH);
}

- (CGRect) contentAreaRectInView:(UIView*)view{
    int contentAreaH = (view.bounds.size.height - kSetHeaderHeight - kSetTabButtonH) - kSetInsetLarge - kSetInsetSmall;
    CGRect contentAreaF = CGRectMake(0, kSetHeaderHeight+kSetTabButtonH, view.bounds.size.width, contentAreaH);
    return contentAreaF;
}

- (CGRect) contentViewRectInView:(UIView*)view{
    return CGRectMake(view.bounds.origin.x + kSetInsetSmall, kSetHeaderHeight + kSetTabButtonH +kSetInsetSmall, view.bounds.size.width - ( 2 * kSetInsetSmall), view.bounds.size.height - kSetHeaderHeight - kSetTabButtonH - kSetInsetLarge - ( 3 * kSetInsetSmall));
}

- (CGRect) tabButtonsAreaRectInView:(UIView*)view{
    return CGRectMake(view.bounds.origin.x + kSetInsetSmall, kSetHeaderHeight, view.bounds.size.width - (2*kSetInsetSmall), kSetTabButtonH);
}

- (CGRect) titleLabelRectInView:(UIView*)view{
    return CGRectMake((view.bounds.size.width - kMinTitleLabelW) * .5, 0, kMinTitleLabelW, kSetHeaderHeight);
}

- (CGRect) resizeButtonRectInView:(UIView*)view{
    // Resize triangle
    return CGRectMake(view.bounds.size.width - kSetCornerButtonW, view.bounds.size.height - kSetCornerButtonH, kSetCornerButtonW, kSetCornerButtonH);
}

#pragma mark - HELPERS

- (BOOL) areOpen {
    
    if (self.bounds.size.width < kMinWidth ||
        self.bounds.size.height < kMinHeight)  {
        return NO;
    }
    
    return YES;
    
}

- (NSString *) titleForTabButton:(UIButton *) button {
    return [button titleForState:UIControlStateNormal];
}

- (NSString *) overViewTitle {
    return [self tabTitle:@"Overview"];
}

- (NSString *) viewTitle {
    return [self tabTitle:@"View"];
}

- (NSString *) elementTitle {
    return [self tabTitle:@"Element"];
}

- (NSString *) logTitle {
    return [self tabTitle:@"Log"];
}

- (NSString *) toolsTitle {
    return [self tabTitle:@"Tools"];
}

- (NSString *) tabTitle:(NSString *)title {
    return NSLocalizedString(title, @"");
}

- (void) disableAutotrackingOf:(NSObject *)object {
    
#ifdef TEAL_MODULE_AUTOTRACKING
    [object teal_setAutotrackingEnabled:NO];
#endif
    
}


@end
