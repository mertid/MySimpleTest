//
//  TEALDataQueue+PrivateHeaders.h
//  TealiumUtilities
//
//  Created by George Webster on 2/17/15.
//
//

#import "TEALDataQueue.h"

@interface TEALDataQueue (Private)

@property (nonatomic, strong) NSMutableArray *dataQueue;

@property (nonatomic) NSUInteger capacity;

@end