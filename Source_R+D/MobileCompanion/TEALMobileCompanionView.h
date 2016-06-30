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
- (void) tealiumMobileCompanionViewRequestsDataForTabTitle:(NSString *)title;

@end

@interface TEALMobileCompanionView : UIView

@property (nonatomic, weak) id<TEALMobileCompanionViewDelegate> delegate;
@property (nonatomic, weak) id<UITableViewDelegate> tableViewDelegate;
@property (nonatomic, weak) id<UITableViewDataSource> tableViewDataSourceDelegate;

- (void) expand;

- (void) minimize;

- (void) dismiss;

- (void) redrawExpanded;

@end
