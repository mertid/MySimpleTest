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
@property BOOL shouldQueueAll;
@property BOOL shouldDropAll;
@property BOOL dispatchProcessed;
@property NSDictionary *dispatchPayload;
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

//- (void) useLibraryInstanceWithConfig:(TEALConfiguration *)config {
//    
//    NSString *testID = @"privateAPITests";
//    
//    [Tealium destroyInstanceForKey:testID];
//    
//    XCTestExpectation *expectation = [self expectationWithDescription:@"setupLiveInstance"];
//    
//    self.library = [Tealium newInstanceForKey:testID
//                                configuration:config
//                                   completion:^(BOOL success, NSError * _Nullable error) {
//                                       
//                                       if (error){
//                                           NSLog(@"%s error:%@", __FUNCTION__, error);
//                                       }
//                                       
//                                       [expectation fulfill];
//                                       
//                                   }];
//    
//    self.library.delegate = self;
//    
//    [self waitForExpectationsWithTimeout:1.0 handler:nil];
//}

#pragma mark - CLASS TESTS

- (void) testSuppressForQueueSize {
    
    // limit greater than current - Should suppress
    XCTAssertTrue([Tealium suppressForQueueSize:10
                               currentQueueSize:1]);
    
    // sizes equal - Should NOT suppress
    XCTAssertFalse([Tealium suppressForQueueSize:1
                                currentQueueSize:1]);
    
    // current greater than limit - Should NOT suppress
    XCTAssertFalse([Tealium suppressForQueueSize:1
                                currentQueueSize:10]);
    
}

- (void) testDispatchManagerShouldDispatchDelegateProcessing {
    
    // TODO: Read configuration from json file: dispatch_permitted_scenarios
    
    // TODO: Loop through all test scenarios
    
//    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:@"stub"
//                                                                    profile:@"stub"
//                                                                environment:@"stub"];
//    TEALSettings *settings = [[TEALSettings alloc] initWithConfiguration:config];
//    TEALDispatchManager *dispatchManager = [[TEALDispatchManager alloc] initWithInstanceID:@"stub"
//                                                                                  delegate:self];
//    
//    TEALURLSessionManager *urlSessionManager = [[TEALURLSessionManager alloc] initWithConfiguration:__fill_in__];
//    
//    NSArray id<TEALDispatchService> * dispatchServices = @[@"__fill_in___"];
//    
//    NSError *error = nil;
//    
//    BOOL dispatchPermissable = [Tealium dispatchPermissableBasedOnSettings:settings
//                                                           dispatchManager:dispatchManager
//                                                         urlSessionManager:urlSessionManager
//                                                          dispatchServices:dispatchServices error:error];
    
    // TODO: check that dispatchPermissable matches scenario expected 'dispath_permitted' bool value
    
    
}

#pragma mark - TRACK TESTS

//- (void) testTrackDictionaryIsTrullyACopy {
//    
//    // Spin up an instance of tealium
//    TEALConfiguration *config = [TEALConfiguration configurationWithAccount:@"test" profile:@"test" environment:@"test"];
//    Tealium *tealium = [Tealium newInstanceForKey:@"test" configuration:config];
//    self.shouldQueueAll = YES;
//    
//    // create a mutable dictionary with test keys from file source
//    NSDictionary *trackData = [TEALTestHelper dictionaryFromJSONFile:@"tealium_track_data"];
//    NSArray *keys = [trackData allKeys];
//    
//    // Iterate over every test option in file
//    for (int i  = 0; i < [keys count]; i++) {
//     
//        NSString *key = keys[i];
//        NSDictionary *sourceOriginal = trackData[key];
//        NSMutableDictionary *source = [NSMutableDictionary dictionaryWithDictionary:sourceOriginal];
//
//        BOOL processed = self.dispatchProcessed;
//        
//        // Make a track call
//        [tealium trackEventWithTitle:@"testEvent" dataSources:source];
//        
//        // wait for dispatch callback with modified payload
//        [TEALTestHelper waitFor:&processed timeout:1.0];
//        
//        // TODO: Modify the mutable dictionary originally passed in
//        
//        
//        // Check dispatch payload did not change
//        
//        
//    }
//    
//
//    
//    
//}

#pragma mark - TEALIUM DELEGATE

- (BOOL) tealium:(Tealium *)tealium shouldQueueDispatch:(TEALDispatch *)dispatch {

    self.dispatchPayload = dispatch.payload;
    self.dispatchProcessed = YES;
    
    return self.shouldQueueAll;

}

- (void) tealium:(Tealium *)tealium didQueueDispatch:(TEALDispatch *)dispatch {
    
}

- (void) tealium:(Tealium *)tealium didSendDispatch:(TEALDispatch *)dispatch {
    
}

- (void) tealium:(Tealium *)tealium webViewIsReady:(id)webView {
    
}

- (void) tealiumInstanceDidUpdatePublishSettings:(Tealium *)tealium {
    
    self.didFetch = YES;
    
}

@end
