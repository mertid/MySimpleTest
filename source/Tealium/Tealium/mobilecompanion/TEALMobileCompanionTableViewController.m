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
    
    // TODO: Format cells
    
    if ([self.currentContent type] == TEALMobileCompanionContentTypeNormal) {
    
        TEALMobileCompanionContentRow *row = [self.currentContent rowDataForSectionIndex:indexPath.section][indexPath.row];
        
        cell.textLabel.text = row? [row keyValue]:nil;
        
    } else {
        
//        cell = [self toolCell:cell
//                 forIndexPath:indexPath
//                  inTableView:tableView];
        
    }
    
    return cell;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{

    NSArray *titles = [self.currentContent headerTitles];
    return titles? titles[section]:nil;

}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    static UILabel* sectionLabel;
    if (!sectionLabel) {
        sectionLabel = [[UILabel alloc]
                 initWithFrame:CGRectMake(0, 0, FLT_MAX, FLT_MAX)];
        sectionLabel.text = @"test";
    }
    
    sectionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    [sectionLabel sizeToFit];
    
    return sectionLabel.frame.size.height * 1.7;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static UILabel* label;
    if (!label) {
        label = [[UILabel alloc]
                 initWithFrame:CGRectMake(0, 0, FLT_MAX, FLT_MAX)];
        label.text = @"test";
    }
    
    label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [label sizeToFit];
    
    return label.frame.size.height * 1.7;
}

/**
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/**
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

/**
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/**
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/**
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - PRIVATE HELPER

//- (UITableViewCell*) toolCell:(UITableViewCell*)cell forIndexPath:(NSIndexPath*)indexPath inTableView:(UITableView*)tableView{
//    
//    if ((int)indexPath.row >= (int)[_currentContent all count]){
//        return nil;
//    }
//    
//        [cell.contentView setBackgroundColor:tableView.backgroundColor];
//        NSString *key = [_currentContentDict allKeys][indexPath.row];
//        
//        // match tableview width but keep cell.contentview height
//        CGFloat baseW = tableView.bounds.size.width;
//        CGFloat baseH = kTableviewHeight_tools;
//        CGFloat baseX = cell.contentView.frame.origin.x;
//        CGFloat baseY = cell.contentView.frame.origin.y;
//        CGRect rect = CGRectMake(baseX, baseY, baseW, baseH);
//        
//        // Background
//        UIView *bg = [[UIView alloc] initWithFrame:rect];
//        [bg setBackgroundColor:[UIColor whiteColor]];
//        bg.layer.cornerRadius = 8;
//        bg.layer.masksToBounds = YES;
//        [TealiumInternalConstants markAsTealiumObject:bg];
//        [cell.contentView addSubview:bg];
//        CGRect bgBounds = bg.bounds;
//        
//        // Title
//        CGFloat tx = 5; //bgBounds.size.width * 0.05;
//        CGFloat ty = 5; //bgBounds.size.height * 0.05;
//        CGFloat tw = bgBounds.size.width - tx;
//        CGFloat th = 16; //bgBounds.size.height * 0.1;
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tx, ty, tw, th)];
//        [label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:10]];
//        [label setText:key];
//        [TealiumInternalConstants markAsTealiumObject:label];
//        [bg addSubview:label];
//        
//        // Add button to tool view
//        CGFloat x = bgBounds.size.width * 0.4;
//        CGFloat y = bgBounds.size.height * 0.75;
//        CGFloat w = bgBounds.size.width - x - 5;
//        CGFloat h = kToolButtonMinHeight; //bgBounds.size.height * 0.15;
//        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
//        NSDictionary *dict = _currentContentDict[key];
//        NSNumber *tagNumber = dict[@"buttonTag"];
//        if (tagNumber)[button setTag:[tagNumber intValue]];
//        NSString *buttonTitle = dict[@"buttonTitle"];
//        if (buttonTitle) [button setTitle:buttonTitle forState:UIControlStateNormal];
//        [button.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:10]];
//        [button setBackgroundColor:[self colorFor:ColorBlue]];
//        [button addTarget:_delegate action:@selector(popupViewToolButtonTap:) forControlEvents:UIControlEventTouchUpInside];
//        [TealiumInternalConstants markAsTealiumObject:button];
//        [bg addSubview:button];
//        
//        // Description - squeezed between button and title
//        CGFloat dx = bgBounds.size.width * 0.05;
//        CGFloat dy = ty + th;
//        CGFloat dw = bgBounds.size.width - (2 * dx);
//        CGFloat dh = 50; //bgBounds.size.height - dy - y;
//        UITextView *tv = [[UITextView alloc] initWithFrame:CGRectMake(dx, dy, dw, dh)];
//        NSString *description = dict[@"description"];
//        [tv setEditable:NO];
//        [tv setBackgroundColor:[UIColor clearColor]];
//        [tv setFont:[UIFont fontWithName:@"Helvetica" size:10]];
//        [tv setText:description];
//        [tv setUserInteractionEnabled:NO];
//        [TealiumInternalConstants markAsTealiumObject:tv];
//        [bg addSubview:tv];
//    }
//    return cell;
//}



@end
