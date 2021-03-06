
//
//  __x_FrameworkUITests.m
//  5.x+FrameworkUITests
//
//  Created by Jason Koo on 12/21/15.
//  Copyright © 2015 f. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface __x_FrameworkUITests : XCTestCase

@end


@implementation __x_FrameworkUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//- (void)testExample {
//    // Use recording to get started writing UI tests.
//    // Use XCTAssert and related functions to verify your tests produce the correct results.
//    
//    // Self measure block will not work as expected here.
//    
//    
//    XCUIApplication *app = [[XCUIApplication alloc] init];
//    [app.navigationBars[@"UIView"].buttons[@"UIKitCatalog"] tap];
//    
//    XCTAssert([app.tables count] == 1, @"Too many tables in the view.");
//    
//    XCUIElementQuery *tablesQuery = app.tables;
//    [tablesQuery.staticTexts[@"Activity Indicators"] tap];
//    [[app.navigationBars matchingIdentifier:@"Activity Indicators"].buttons[@"UIKitCatalog"] tap];
//    [tablesQuery.staticTexts[@"Alert Controller"] tap];
//    [tablesQuery.staticTexts[@"Simple"] tap];
//    [app.alerts[@"A Short Title Is Best"].collectionViews.buttons[@"OK"] tap];
//        
//}

- (void) testButtons {
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app.navigationBars[@"UIView"].buttons[@"UIKitCatalog"] tap];
    
    XCTAssert([app.tables count] == 1, @"Too many tables in the view.");

    XCUIElementQuery *tablesQuery2 = app.tables;
    XCUIElementQuery *tablesQuery = tablesQuery2;
    [tablesQuery.staticTexts[@"Buttons"] tap];
    
    XCUIElement *button = [[tablesQuery2 childrenMatchingType:XCUIElementTypeCell] elementBoundByIndex:0].buttons[@"Button"];
    [button tap];
    
    XCUIElement *button2 = [[[tablesQuery2 childrenMatchingType:XCUIElementTypeCell] elementBoundByIndex:1] childrenMatchingType:XCUIElementTypeButton].element;
    [button2 tap];
    
    XCUIElement *button3 = [[[tablesQuery2 childrenMatchingType:XCUIElementTypeCell] elementBoundByIndex:2] childrenMatchingType:XCUIElementTypeButton].element;
    [button3 tap];
    
    XCUIElement *xButtonButton = tablesQuery.buttons[@"X Button"];
    [xButtonButton tap];
    [[[tablesQuery2 childrenMatchingType:XCUIElementTypeCell] elementBoundByIndex:4].buttons[@"Button"] tap];
    [xButtonButton tap];
    [button3 tap];
    [button2 tap];
    [button tap];
    [[app.navigationBars matchingIdentifier:@"Buttons"].buttons[@"UIKitCatalog"] tap];
    
    XCTAssert([app.tables count] == 1, @"Too many tables in the view.");

}

@end
