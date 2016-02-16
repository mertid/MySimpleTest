//
//  TealiumPrivateAPITests.m
//  UIKitCatalog
//
//  Created by Jason Koo on 1/28/16.
//
//

#import <XCTest/XCTest.h>
#import "Tealium+PrivateHeader.h"
#import "TEALTestHelper.h"

@interface TealiumPrivateAPITests : XCTestCase<TealiumDelegate>

@property Tealium *library;
@property BOOL didFetch;
@end

@implementation TealiumPrivateAPITests

- (void)setUp {
    [super setUp];
    self.didFetch = NO;
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    self.library = nil;
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) useLibraryInstanceWithConfig:(TEALConfiguration *)config {
    
    NSString *testID = @"publicAPITests";
    
    [Tealium destroyInstanceForKey:testID];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"setupLiveInstance"];
    
    self.library = [Tealium newInstanceForKey:testID
                                configuration:config
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       
                                       if (error){
                                           NSLog(@"%s error:%@", __FUNCTION__, error);
                                       }
                                       
                                       [expectation fulfill];
                                       
                                   }];
    
    self.library.delegate = self;
    
    [self waitForExpectationsWithTimeout:2.0 handler:nil];
}

#pragma mark - ENABLE / DISABLE TESTS


- (void) testDisable {
    
    TEALConfiguration *config = [TEALTestHelper configFromTestJSONFile:@"library_OFF"];
    
    [self useLibraryInstanceWithConfig:config];
    
    BOOL didFinishedFetching = self.didFetch;
    
    [TEALTestHelper waitFor:&didFinishedFetching timeout:1.0];
        
    XCTAssertTrue(![self.library.dispatchManager isEnabled], @"Dispatch manager was not disabled");
    
    XCTAssertTrue([self.library currentDispatchServices].count == 0, @"Not all dispatch services were removed: %@", [self.library currentDispatchServices]);
    
}

#pragma mark - TEALIUM DELEGATE

- (void) tealium:(Tealium *)tealium didQueueDispatch:(TEALDispatch *)dispatch {
    
}

- (void) tealium:(Tealium *)tealium didSendDispatch:(TEALDispatch *)dispatch {
    
}

- (void) tealium:(Tealium *)tealium webViewIsReady:(id)webView {
    
}

- (void) tealiumInstanceDidUpdatePublishSettings:(Tealium *)tealium {
    
    self.didFetch = YES;
    
}

//- (void)testExample {
//    // This is an example of a functional test case.
//    // Use XCTAssert and related functions to verify your tests produce the correct results.
//}
//
//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
