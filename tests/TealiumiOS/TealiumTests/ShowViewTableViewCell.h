//
//  ShowViewTableViewCell.h
//  TealiumTests
//
//  Created by Jason Koo on 7/21/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowViewTableViewCell : UITableViewCell

@property (nonatomic, copy) void (^switchCompletion)(BOOL switchEnabled);

@property (nonatomic, weak) IBOutlet UISwitch * autotrackingSwitch;

@end
