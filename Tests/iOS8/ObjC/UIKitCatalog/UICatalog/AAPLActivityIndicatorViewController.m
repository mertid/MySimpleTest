/*
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A view controller that demonstrates how to use UIActivityIndicatorView.
*/

#import "AAPLActivityIndicatorViewController.h"

@interface AAPLActivityIndicatorViewController()

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *grayStyleActivityIndicatorView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *tintedActivityIndicatorView;

@end


#pragma mark -

@implementation AAPLActivityIndicatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.accessibilityLabel = PerformanceLabelTableViewActivityIndicator;

    [self configureGrayActivityIndicatorView];
    [self configureTintedActivityIndicatorView];

    // When activity is done, use -[UIActivityIndicatorView stopAnimating].
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
#ifdef TargetTypeCompact
    [Tealium trackCallType:TealiumViewCall customData:@{@"extra_key":@"extra_value"} object:self];
#endif
#ifdef TargetTypeCollect
    NSString *title = [self teal_titleForDispatch];
    [TealiumCollect sendViewWithData:@{@"screen_name":title}];
#endif
}

#pragma mark - Configuration

- (void)configureGrayActivityIndicatorView {
    self.grayStyleActivityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;

    [self.grayStyleActivityIndicatorView startAnimating];
    
    self.grayStyleActivityIndicatorView.hidesWhenStopped = YES;
}

- (void)configureTintedActivityIndicatorView {
    self.tintedActivityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;

    self.tintedActivityIndicatorView.color = [UIColor aapl_applicationPurpleColor];

    [self.tintedActivityIndicatorView startAnimating];
}

@end
