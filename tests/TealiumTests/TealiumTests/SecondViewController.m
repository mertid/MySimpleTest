//
//  SecondViewController.m
//  TealiumTests
//
//  Created by Jason Koo on 7/21/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "SecondViewController.h"
#import <Tealium/ObjC.h>

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Second View Controller";
    [self teal_setDataSources:@{@"test":@"executeTestCommand"}];
    self.iVarTestProperty = @"iVarTestValue";
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[self autotrackingEnableSwitch] setOn:self.teal_autotrackingEnabled];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
        
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
