//
//  TEALMainMenuController.m
//  Performance_UICatalog
//
//  Created by George Webster on 12/1/14.
//  Copyright (c) 2014 f. All rights reserved.
//

#import "TEALMainMenuController.h"

@implementation TEALMainMenuController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.accessibilityLabel = PerformanceLabelTableViewMainMenu;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSString *title = [self teal_titleForDispatch];

    NSDictionary *payload = @{@"screen_name":title};
    
#ifdef TargetTypeCompact
    [Tealium trackCallType:TealiumViewCall customData:payload object:self];
#endif
#ifdef TargetTypeCollect
    [TealiumCollect sendViewWithData:payload];
#endif
}

@end
