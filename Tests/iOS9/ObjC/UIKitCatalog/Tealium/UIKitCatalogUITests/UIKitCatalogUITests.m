//
//  UIKitCatalogUITests.m
//  UIKitCatalogUITests
//
//  Created by Jason Koo on 12/22/15.
//
//

#import <XCTest/XCTest.h>

static NSString * const kTestString = @"test string";

@interface UIKitCatalogUITests : XCTestCase
@property (nonatomic) XCUIApplication *app;
@end

@implementation UIKitCatalogUITests

- (void) setUp {
    [super setUp];
    
    self.app = [[XCUIApplication alloc] init];
    // [self.app launch];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    //  [[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void) tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];

}


- (void) testActivityIndicatiors {
    XCUIApplication *app = self.app;
    [self launchApp:app];
      [app terminate];
    
}

#warning known bug with UITesting alert controller

//- (void)testAlertController {
//    XCUIApplication *app = self.app;
//    [self launchApp:app];
//    [self tapButtonInTable:@"Alert Controller" withApp:app];
//
//    XCUIElementQuery *tableQueryCells = app.tables.cells;
//    
//    for (int i = 0; i < tableQueryCells.count; i++){
//        [[tableQueryCells elementBoundByIndex:i] tap];
//        [app tap];
//
//    }
//    
//    
//    [self goBack];
//}


- (void) testButtons {
    XCUIApplication *app = self.app;
    [self launchApp:app];
    [self navigateButtonView:app];
    [app terminate];
    
}

- (void) testDatePicker {
    XCUIApplication *app = self.app;
    [self launchApp:app];
    [self navigateDatePickerView:app];
    [app terminate];
    
}

- (void) testImageView {
    XCUIApplication *app = self.app;
    [self launchApp:app];
    [self navigateImageView:app];
    [app terminate];
    
}

- (void) testPageControl {
    XCUIApplication *app = self.app;
    [self launchApp:app];
    [self navigatePageControlView:app];
    [app terminate];

}

- (void) testPickerView {
    XCUIApplication *app = self.app;
    [self launchApp:app];
    [self navigatePickerView:app];
    [app terminate];

}

- (void) testProgressViews {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [self launchApp:app];
    [self navigateProgressView:app];
    [app terminate];

}

- (void) testSegmentedControls {
    XCUIApplication *app = self.app;
    [self launchApp:app];
    [app terminate];
    
}

#warning slider UI adjustment is a known bug for Xcode 7.3
- (void) testSliders {
    XCUIApplication *app = self.app;
    [self launchApp:app];
    [self navigateSliderView:app];
    [app terminate];

}

- (void) testStackViews {
    XCUIApplication *app = self.app;
    [self launchApp:app];
    [self navigateStackView:app];
    [app terminate];
    
}

- (void) testSteppers {
    XCUIApplication *app = self.app;
    [self launchApp:app];
    [self navigateStepperView:app];
    [app terminate];
    
}

- (void) testSwitches {
    XCUIApplication *app = self.app;
    [self launchApp:app];
    [self navigateSwitchesView:app];
    [app terminate];
     
}

- (void) testTextFields {
    XCUIApplication *app = self.app;
    [self launchApp:app];
    [self navigateTextFieldView:app];
    [app terminate];

}

- (void) testTextView {
    XCUIApplication *app = self.app;
    [self launchApp:app];
    [self navigateTextView:app];
    [app terminate];

}

- (void) testWebView {
    XCUIApplication *app = self.app;
    [self launchApp:app];
    [self navigateWebView:app];
    [app terminate];

}

- (void) testSearch {
    XCUIApplication *app = self.app;
    [self launchApp:app];
    [self navigateSearchView:app];
    [app terminate];

}

- (void) testToolbars {
    XCUIApplication *app = self.app;
    [self launchApp:app];
    [self navigateToolBarView:app];
    [app terminate];

}

- (void) testMultiRuns {
    XCUIApplication *app = self.app;
    [self launchApp:app];
    [self navigateAllInUIKitCatalog:app numberOfRuns:5];
    [app terminate];

}

- (void) testBunchOfTaps {
    XCUIApplication *app = self.app;
    [self launchApp:app];
    [self tapAllButtonsInCurrentTable:app
                               goBack:YES];
    
}

//- (void) testMultiLaunch {
//
//    NSLog(@"%s Launch 1", __FUNCTION__);
//
//    for (int x = 1; x <= 100; x++) {
//
//        [self setUp];
//
//        NSLog(@"%s Launch %d", __FUNCTION__, x);
//
//        sleep(1);
//
//        [self tearDown];
//
//    }
//
//}

#pragma mark Navigate View Helpers

- (void)navigateAllInUIKitCatalog:(XCUIApplication *)app numberOfRuns:(int)runs {
    
    for (int i = 0; i <= runs; i++){
        [self navigateActivityView:app];
        [self navigateButtonView:app];
        [self navigateDatePickerView:app];
        [self navigateImageView:app];
        [self navigatePageControlView:app];
        [self navigatePickerView:app];
        [self navigateProgressView:app];
        [self navigateSegmentControlView:app];
        [self navigateSliderView:app];
        [self navigateStackView:app];
        [self navigateStepperView:app];
        [self navigateSwitchesView:app];
        [self navigateTextFieldView:app];
        [self navigateTextView:app];
        [self navigateWebView:app];
        [self navigateSearchView:app];
        [self navigateToolBarView:app];
        
    }
}

- (void) navigateActivityView: (XCUIApplication *)app {
    [self tapButtonInTable:@"Activity Indicators" withApp:app];
    sleep(1);
    [self goBack];
    
}

- (void) navigateButtonView: (XCUIApplication *)app {
    [self tapButtonInTable:@"Buttons" withApp:app];
    [self tapAllButtonsInCurrentTable:app goBack:NO];
    [self goBack];
    
}

- (void) navigateDatePickerView:(XCUIApplication *)app {
    [self tapButtonInTable:@"Date Picker" withApp:app];
    
    XCUIElementQuery *datePickers = app.datePickers.pickerWheels;
    for (int i=0; i < datePickers.count; i++ ) {
        [[datePickers elementBoundByIndex:i] swipeUp];
        
    }
    sleep(2);
    [self goBack];
    
}

- (void) navigatePageControlView: (XCUIApplication *)app {
    [self tapButtonInTable:@"Page Control" withApp:app];
    [self goBack];
    
}

- (void) navigateImageView: (XCUIApplication *)app {
    [self tapButtonInTable:@"Image View" withApp:app];
    sleep(5);
    [self goBack];
    
}

- (void) navigateProgressView: (XCUIApplication *)app {
    [self tapButtonInTable:@"Progress Views" withApp:app];
    sleep(5);
    [self goBack];
    
}

- (void) navigatePickerView: (XCUIApplication *)app {
    [self tapButtonInTable:@"Picker View" withApp:app];
    XCUIElementQuery *pickerWheels = app.pickerWheels;
    for (int i=0; i < pickerWheels.count; i++ ) {
        [[pickerWheels elementBoundByIndex:i] adjustToPickerWheelValue:@"100"];
        
    }
    sleep(1);
    [self goBack];
    
}

- (void) navigateSegmentControlView: (XCUIApplication *)app {
    [self tapButtonInTable:@"Segmented Controls" withApp:app];
    
    XCUIElementQuery *tablesQuery2 = app.tables;
    XCUIElementQuery *cells = tablesQuery2.cells;
    for (int i = 0; i < cells.count; i++){
        XCUIElementQuery *segmentControl = [[tablesQuery2 childrenMatchingType:XCUIElementTypeCell] elementBoundByIndex:i].segmentedControls.buttons;
        [self tapAllSegmentsInSegmentedController:segmentControl];
        
    }
    
    [self goBack];
    
}

- (void) navigateSliderView: (XCUIApplication *)app {
    [self tapButtonInTable:@"Sliders" withApp:app];
    // Currently a known bug.
    // XCUIElement *slider1 = app.sliders[@"Default Slider"];
    //  [slider1 adjustToNormalizedSliderPosition:.9];
    
    [self goBack];
    
}

- (void) navigateSwitchesView: (XCUIApplication *)app {
    [self tapButtonInTable:@"Switches" withApp:app];
    [self tapAllButtonsInCurrentTable:app goBack:NO];
    [self goBack];
    
}

- (void) navigateStackView: (XCUIApplication *)app{
    [self tapButtonInTable:@"Stack Views" withApp:app];
    [app.buttons[@"Plus Button"] tap];
    [self goBack];
    
}

- (void) navigateStepperView: (XCUIApplication *)app {
    [self tapButtonInTable:@"Steppers" withApp:app];
    [self tapAllButtonsInCurrentTable:app goBack:NO];
    [self goBack];
    
}

- (void) navigateTextFieldView: (XCUIApplication *)app{
    [self tapButtonInTable:@"Text Fields" withApp:app];
    XCUIElementQuery *tablesQuery = app.tables;
    [self tapAndTypeAllCellsInTable:tablesQuery forApplication:app];
    [self goBack];
    
}

- (void) navigateTextView:(XCUIApplication *)app{
    [self tapButtonInTable:@"Text View" withApp:app];
    [self goBack];
    
}

- (void) navigateWebView: (XCUIApplication *)app {
    [self tapButtonInTable:@"Web View" withApp:app];
    [self goBack];
    
}

-(void) navigateSearchView: (XCUIApplication *)app {
    [self tapButtonInTable:@"Search" withApp:app];
    [self tapButtonInTable: @"Default" withApp:app];
    
    XCUIElement *searchField = app.searchFields.element;
    [self tapElementAndTypeText:searchField];
    [self goBack];
    
    [self tapButtonInTable:@"Custom" withApp:app];
    [self tapElementAndTypeText:searchField];
    [self goBack];
    
    [self tapButtonInTable:@"Present Over Navigation Bar" withApp:app];
    [app.buttons[@"Search Navigation Button"] tap];
    [searchField typeText:kTestString];
    [app.buttons[@"Cancel"] tap];
    [self goBack];
    
    [self tapButtonInTable:@"Search Bar Embedded in Navigation Bar" withApp:app];
    [self tapElementAndTypeText:searchField];
    [self goBack];
    
    [self tapButtonInTable:@"Results in Searched Controller" withApp:app];
    [self tapElementAndTypeText:searchField];
    [app.buttons[@"Cancel"] tap];
    [self goBack];
    [self goBack];
    
}


- (void) navigateToolBarView: (XCUIApplication *)app {
    [self tapButtonInTable:@"Toolbars" withApp:app];
    [self goBack];
    
}

#pragma mark - Test Helper Methods

- (void) tapAndTypeAllCellsInTable:(XCUIElementQuery *)table forApplication:(XCUIApplication *)app {
    
    XCUIElementQuery *cells = table.cells;
    
    for (int i = 0; i < cells.count; i++){
        XCUIElement *textField = [[table childrenMatchingType:XCUIElementTypeCell] elementBoundByIndex:i];
        [self tapElementAndTypeText:textField];
        
    }
}


- (void) tapAllButtonsInCurrentTable:(XCUIApplication *)app
                              goBack:(BOOL)back {
    
    XCUIElementQuery *tablesQuery2 = app.tables;
    XCUIElementQuery *cells = tablesQuery2.cells;
    for (int i = 0; i < cells.count; i++){
        
        [[[tablesQuery2 childrenMatchingType:XCUIElementTypeCell] elementBoundByIndex:i] tap];
        if (back) {
            [self goBack];
        
        }
    }
}


- (void) goBack {
    XCUIApplication *app = self.app;
    [[app.buttons elementBoundByIndex: 0] tap];

}


- (void) tapAllSegmentsInSegmentedController:(XCUIElementQuery *)segmentedControls{
    for (int i=0 ; i < segmentedControls.count; i++){
        [[segmentedControls elementBoundByIndex:i] tap];

    }
}

- (void) launchApp:(XCUIApplication *)app {
    [app launch];
    sleep(2);
    [[app.buttons elementBoundByIndex:0]tap];
    
}

- (void) tapElementAndTypeText: (XCUIElement *)element {
    [element tap];
    [element typeText:kTestString];

}

- (void) tapButtonInTable:(NSString *)buttonTitle withApp:(XCUIApplication *)app {
    XCUIElementQuery *tablesQuery = app.tables;
    [tablesQuery.staticTexts[buttonTitle] tap];
    
}

@end
