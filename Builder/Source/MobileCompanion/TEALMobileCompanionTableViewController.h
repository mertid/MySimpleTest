//
//  TEALMobileCompanionTableViewController.h
//  Tealium
//
//  Created by Jason Koo on 9/3/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TEALMobileCompanionContent;

@interface TEALMobileCompanionTableViewController : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) TEALMobileCompanionContent *currentContent;

@end
