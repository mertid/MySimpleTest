//
//  TEALMobileCompanionTableViewController.m
//  Tealium
//
//  Created by Jason Koo on 9/3/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALMobileCompanionTableViewController.h"
#import "TEALMobileCompanionConstants.h"
#import "TEALMobileCompanionContent.h"
#import "TEALMobileCompanionContentRow.h"
#import "TEALMobileCompanionContentSection.h"

@interface TEALMobileCompanionTableViewController ()

@end

@implementation TEALMobileCompanionTableViewController

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    NSInteger sections = [self.currentContent.headerTitles count];
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger rows = [[self.currentContent rowDataForSectionIndex:section] count];
    return rows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TEALMobileCompanionCellID forIndexPath:indexPath];
    
    // Configure the cell...
    
    TEALMobileCompanionContentRow *row = [self.currentContent rowDataForSectionIndex:indexPath.section][indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@", row.key, row.value];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
