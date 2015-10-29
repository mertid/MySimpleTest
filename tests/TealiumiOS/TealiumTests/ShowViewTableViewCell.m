//
//  ShowViewTableViewCell.m
//  TealiumTests
//
//  Created by Jason Koo on 7/21/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "ShowViewTableViewCell.h"

@implementation ShowViewTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)toggleAutotracking:(id)sender {
    BOOL isEnabled = [[self autotrackingSwitch] isOn];
    if (self.switchCompletion){
        self.switchCompletion(isEnabled);
    }
}


@end
