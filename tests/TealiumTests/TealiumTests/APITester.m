//
//  APITester.m
//  TealiumTests
//
//  Created by Jason Koo on 7/17/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "APITester.h"
#import <Tealium/ObjC.h>
#import "ShowViewTableViewCell.h"

typedef NS_ENUM(NSUInteger, TealiumAPIMenuItem) {
    TealiumAPIMenuItemSendEvent = 0,
    TealiumAPIMenuItemSendView,
    TealiumAPIMenuItemShowView,
    TealiumAPIMenuItemFetchProfle,
    TealiumAPIMenuItemLogLastProfile,
    TealiumAPIMenuItemNumberOfItems
};

@implementation APITester


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"API Sampler";
    self.autotrackingViewEnabled = YES;
    
    [[Tealium sharedInstance] addRemoteCommandId:@"testCommand"
                                     description:nil
                                     targetQueue:dispatch_get_main_queue()
                                           block:^(TEALRemoteCommandResponse *response) {
                                               
                                               NSLog(@"%s Response Received: %@", __FUNCTION__, response);
                                           }];
    
    NSLog(@"%s BaselineData:%@", __FUNCTION__, [[Tealium sharedInstance] baselineDataSources]);
    
    NSLog(@"%s PersistentData:%@", __FUNCTION__, [[Tealium sharedInstance] persistentDataSources]);

}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDatasource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return TealiumAPIMenuItemNumberOfItems;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = nil;
    
    if (indexPath.row == TealiumAPIMenuItemShowView){
        cell = [tableView dequeueReusableCellWithIdentifier:@"autotrackingSwitchCell"];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"APIMenuCellIdentifier"];
    }
    
    
    if (cell) {
        switch (indexPath.row) {
            case TealiumAPIMenuItemSendEvent:
                cell.textLabel.text = @"Send Event";
                break;
            case TealiumAPIMenuItemSendView:
                cell.textLabel.text = @"Send View";
                break;
            case TealiumAPIMenuItemShowView:
            {
                cell.textLabel.text = @"Show View";
                ShowViewTableViewCell *showViewCell = (ShowViewTableViewCell*)cell;
                showViewCell.autotrackingSwitch.on = self.autotrackingViewEnabled;
                showViewCell.switchCompletion = ^(BOOL switchEnabled){
                    self.autotrackingViewEnabled = switchEnabled;
                };
            }
                break;
            case TealiumAPIMenuItemFetchProfle:
                cell.textLabel.text = @"Fetch Current Profile";
                break;
            case TealiumAPIMenuItemLogLastProfile:
                cell.textLabel.text = @"Log Last Loaded Profile";
                break;
                
            default:
                break;
        }
        
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.row) {
        case TealiumAPIMenuItemSendEvent:
            [self sendCollectEvent];
            break;
        case TealiumAPIMenuItemSendView:
            [self sendCollectView];
            break;
        case TealiumAPIMenuItemShowView:
            [self showView];
            break;
        case TealiumAPIMenuItemFetchProfle:
            [self fetchVisitorProfile];
            break;
        case TealiumAPIMenuItemLogLastProfile:
            [self accessLastLoadedVisitorProfile];
            break;
        default:
            break;
    }
}

- (void) showView {
    
    [self performSegueWithIdentifier:@"showView" sender:nil];
    
    
}

- (void) sendCollectView {
    
    NSDictionary *data = @{ @"custom_key" : @"custom_value_view"};
    
    [[Tealium sharedInstance] trackViewWithTitle:@"APITester" dataSources:data];
    
}

- (void) sendCollectEvent {
    
    NSDictionary *data = @{ @"custom_key" : @"custom_value_event"};
    
    [[Tealium sharedInstance] trackEventWithTitle:@"APITester" dataSources:data];

}

- (void) fetchVisitorProfile {
    
    [[Tealium sharedInstance] fetchVisitorProfileWithCompletion:^(TEALVisitorProfile *profile, NSError *error) {
        
        if (error) {
            NSLog(@"test app failed to receive profile with error: %@", [error localizedDescription]);
        } else {
            NSLog(@"test app received profile: %@", profile);
        }
        
    }];
}

- (void) accessLastLoadedVisitorProfile {
    
    TEALVisitorProfile *profile = [[Tealium sharedInstance] cachedVisitorProfileCopy];
    
    if (profile) {
        NSLog(@"last loaded profile: %@", profile);
    } else {
        NSLog(@"a valid profile has not been received yet.");
    }
}

- (void) presentTraceInputView {
    
}

- (void) joinTraceWithToken:(NSString *)token {
    
    [[Tealium sharedInstance] joinTraceWithToken:token];
//    [[Tealium sharedInstance] joinTraceWithToken:token];
}

- (void) leaveTrace {
    [[Tealium sharedInstance] leaveTrace];
}


#pragma mark - SEGUE

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showView"]) {
        if ([segue.destinationViewController respondsToSelector:@selector(teal_setAutotrackingEnabled:)]){
            [segue.destinationViewController teal_setAutotrackingEnabled:self.autotrackingViewEnabled];
        }
    }
    
}

@end
