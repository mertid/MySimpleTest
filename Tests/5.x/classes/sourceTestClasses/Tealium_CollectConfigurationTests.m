//
//  TealiumCollectTests.m
//  TealiumTests
//
//  Created by Jason Koo on 8/21/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TealiumDelegate.h"
#import "TEALTestHelper.h"
#import "Tealium+Collect.h"
#import "TEALConfiguration+Collect.h"
#import "Tealium+PrivateHeader.h"
#import "TEALSettings.h"
#import "TEALDispatch+PrivateHeader.h"
#import "TEALCollectDispatchService.h"
#import "TEALS2SLegacyDispatchService.h"

@interface Tealium_CollectConfigurationTests : XCTestCase <TealiumDelegate>

@property (nonatomic, strong) Tealium *library;
@property int queueCount;
@property int sentCount;
@property BOOL didFetch;

@end

@implementation Tealium_CollectConfigurationTests

- (void)setUp {
    [super setUp];
    self.didFetch = NO;
    self.queueCount = 0;
    self.sentCount = 0;
    //...
}

- (void)tearDown {
    self.library = nil;

    
    [super tearDown];
}

#pragma mark - HELPERS

- (void) enableLibraryWithConfiguration:(TEALConfiguration *)config {
    
    [Tealium destroyInstanceForKey:self.description];
    
    if (!config) {
        config = [TEALTestHelper liveConfig];
    }
    
    __block BOOL isReady = NO;
    
    __block BOOL initSuccess = NO;
    
    __block NSError *initError = nil;
    
    self.library = [Tealium newInstanceForKey:self.description
                                configuration:config
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       
                                       initSuccess = success;
                                       initError = error;
                                       

                                       isReady = YES;
                                       
                                   }];
    
    [self.library setDelegate:self];
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){}
    
    XCTAssertTrue(initSuccess, @"Library failed to finish initializing");
    
    XCTAssertTrue(!initError, @"Error encountered: %@", initError);

    
}

- (BOOL) collectDispatchServiceInArray:(NSArray*)array {
    
    for (id dispatchService in array){
        
        if ([dispatchService isKindOfClass:[TEALCollectDispatchService class]]){
            return true;
        }
        
    }
    
    return false;
}

- (BOOL) s2SLegacyDispatchServiceInArray:(NSArray*)array {
    
    for (id dispatchService in array){
        
        if ([dispatchService isKindOfClass:[TEALS2SLegacyDispatchService class]]){
            return true;
        }
        
    }
    
    return false;
}

- (void) fetchRemoteSettingsWithSettings:(TEALSettings *)settings {
    
    __block BOOL isReady = NO;
    
    [self.library fetchNewSettingsWithCompletion:^(BOOL success, NSError * _Nullable error) {
        
        isReady = YES;
        
    }];
    
    
    while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !isReady){};
}

#pragma mark - CONFIGURATION TESTS

- (void) testOverrideCollectDispatchURLWithVisitorID {
    
    TEALConfiguration *config = [TEALTestHelper configFromTestJSONFile:@"collect_ON"];
    
    NSString *checkString= @"https://datacloud.tealiumiq.com/vdata/i.gif?tealium_account=tealiummobile-tagbridge&tealium_profile=main&tealium_vid=83D8F6217A29466EBEEF4E97C5D9ADDF";

    config.overrideCollectDispatchURL = checkString;
    
    [self enableLibraryWithConfiguration:config];
    
    NSString *visitorID = [self.library.dataSources visitorIDCopy];

    NSString *finalString = [self.library.settings collectDispatchURLStringForVisitorID:visitorID];
    
    XCTAssertTrue([checkString isEqualToString:finalString], @"final dispatch url string:%@ did not match check string:%@", finalString, checkString);
    
}

- (void) testOverrideCollectDispatchURLWithNOVisitorID {
    
    TEALConfiguration *config = [TEALTestHelper configFromTestJSONFile:@"collect_ON"];
    
    config.overrideCollectDispatchURL = @"https://datacloud.tealiumiq.com/vdata/i.gif?tealium_account=tealiummobile-tagbridge&tealium_profile=main";
    
    [self enableLibraryWithConfiguration:config];
    
    NSString *visitorID = [self.library.dataSources visitorIDCopy];
    
    NSString *finalString = [self.library.settings collectDispatchURLStringForVisitorID:visitorID];
    
    NSMutableString *checkStringBase = [NSMutableString stringWithFormat:@"https://datacloud.tealiumiq.com/vdata/i.gif?tealium_account=tealiummobile-tagbridge&tealium_profile=main&tealium_vid="];
    
    NSString *checkString = [checkStringBase stringByAppendingString:visitorID];
    
    XCTAssertTrue([checkString isEqualToString:finalString], @"final dispatch url string:%@ did not match check string:%@", finalString, checkString);
    
}

#pragma mark - GENERAL TESTS

- (void) testCollectEnabledByPublishSettings {
    
    [self enableLibraryWithConfiguration:[TEALTestHelper configFromTestJSONFile:@"collect_ON"]];
    
    __block BOOL isNeverReady = NO;
    
    // Adding in a little time buffer to let module spin up
    
    [TEALTestHelper waitFor:&isNeverReady timeout:1.0];
    
    XCTAssertTrue([self.library.settings collectEnabled], @"Collect was not enabled by remote publish settings.");
    
    NSArray *dispatchServices = [self.library currentDispatchServices];
    
    XCTAssertTrue(self.didFetch, @"Fetch delegate never called.");
    
    XCTAssertTrue(dispatchServices.count == 1, @"Incorrect number of dispatch services were enabled: %@", dispatchServices);
    
    XCTAssertTrue([self collectDispatchServiceInArray:dispatchServices], @"Collect dispatch service NOT found in:%@", dispatchServices);
}

- (void) testCollectDisableByPublishSettings {
    
    TEALConfiguration *config = [TEALTestHelper configFromTestHTMLFile:@"collect_OFF"];
    
    [self enableLibraryWithConfiguration:config];
    
    XCTAssertTrue(![self.library.settings collectEnabled],@"Collect enabled when should have been disabled");
    
    NSArray *dispatchServices = [self.library currentDispatchServices];
    
    XCTAssertTrue(![self collectDispatchServiceInArray:dispatchServices], @"Collect dispatch service found in:%@", dispatchServices);
}

- (void) testS2SEnabledByPublishSettings {
    
    [self enableLibraryWithConfiguration:[TEALTestHelper configFromTestJSONFile:@"all_options_ON"]];
    
    __block BOOL isNeverReady = NO;
    
    // Adding in a little time buffer to let module spin up
    
    [TEALTestHelper waitFor:&isNeverReady timeout:1.0];
    
    XCTAssertTrue([self.library.settings s2SLegacyEnabled], @"S2S was not enabled by remote publish settings.");
    
    NSArray *dispatchServices = [self.library currentDispatchServices];
    
    XCTAssertTrue([self s2SLegacyDispatchServiceInArray:dispatchServices], @"S2S dispatch service NOT found in:%@", dispatchServices);
}

- (void) testS2SDisableByPublishSettings {
    
    TEALConfiguration *config = [TEALTestHelper configFromTestHTMLFile:@"s2s_OFF"];
    
    [self enableLibraryWithConfiguration:config];
    
    XCTAssertTrue(![self.library.settings s2SLegacyEnabled],@"S2S Legacy enabled when should have been disabled");
    
    NSArray *dispatchServices = [self.library currentDispatchServices];
    
    XCTAssertTrue(![self s2SLegacyDispatchServiceInArray:dispatchServices], @"S2S Legacy dispatch service found in:%@", dispatchServices);
}


#pragma mark - TRACK TESTS

- (void) testTrackBatchEvents {
    
    [self enableLibraryWithConfiguration:[TEALTestHelper configFromTestJSONFile:@"batch_5"]];
    
    XCTAssertTrue([self.library currentDispatchServices].count > 0, @"Collect dispatch service not yet ready - %@", [self.library currentDispatchServices]);
    
    XCTestExpectation *e = [self expectationWithDescription:@"queueBatches"];
    XCTestExpectation *eSent = [self expectationWithDescription:@"sendBatches"];
    
    __block int finishedAddingDispatches = 0;
    __block int finishedSendingDispatches = 0;
    __block int batchLimit = 5;
    __block NSError *dispatchError;
    
    for (int i = 0; i < batchLimit; i++) {
        
        TEALDispatch *dispatch = [TEALDispatch dispatchForType:TEALDispatchTypeEvent withPayload:@{@"iteration":@(i)}];
        
        [self.library trackDispatch:dispatch
                         completion:^(TEALDispatchStatus status, TEALDispatch * _Nonnull dispatch, NSError * _Nullable error) {
                             
                             dispatchError = error;
                             
                             if (status == TEALDispatchStatusQueued){
                                 
                                 finishedAddingDispatches++;
                                 
                                 if (finishedAddingDispatches == batchLimit){
                                     
                                     [e fulfill];
                                 }
                             }
                             
                             if (status == TEALDispatchStatusSent){
                                 
                                 finishedSendingDispatches++;
                                 
                                 if (finishedAddingDispatches == batchLimit){
                                 
                                     [eSent fulfill];
                                 }
                             }
                             
                         }];
    }
    
    [self waitForExpectationsWithTimeout:1.0 handler:nil];
    
    XCTAssertTrue(self.didFetch, @"Override fetch settings did not occur.");
    
    XCTAssertTrue(!dispatchError, @"Dispatch error encountered: %@", dispatchError);
    
    XCTAssertTrue(finishedAddingDispatches == batchLimit - 1, @"%i dispatches were not added to the queue - queued: %i", batchLimit - 1, finishedAddingDispatches);
    
    XCTAssertTrue(finishedSendingDispatches == batchLimit, @"%i sent dispatch callbacks not recieved - received: %i", batchLimit, finishedSendingDispatches);
    
    XCTAssertTrue(self.queueCount == batchLimit - 1, @"%i events did not queue - instead: %i", (batchLimit -1), self.queueCount);
    
    XCTAssertTrue(self.sentCount == batchLimit, @"%i events did not send - instead: %i", batchLimit,self.sentCount);
    
    
}


#pragma mark - TEALIUM DELEGATE

- (void) tealiumInstanceDidUpdatePublishSettings:(Tealium *)tealium {
    
    self.didFetch = YES;
    
}

- (void) tealium:(Tealium *)tealium didQueueDispatch:(TEALDispatch *)dispatch {
    
    self.queueCount++;
    
}

- (void) tealium:(Tealium *)tealium didSendDispatch:(TEALDispatch *)dispatch {
    
    self.sentCount++;
}


@end
