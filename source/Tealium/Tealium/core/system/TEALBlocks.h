//
//  TEALBlocks.h
//  TealiumUtilities
//
//  Created by George Webster on 2/11/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

typedef void (^TEALVoidBlock)(void);

typedef void (^TEALBooleanBlock)(BOOL successful);

typedef void (^TEALErrorBlock)(NSError * _Nullable error);

typedef void (^TEALBooleanCompletionBlock)(BOOL success, NSError * _Nullable error);

typedef void (^TEALDictionaryCompletionBlock)(NSDictionary * _Nullable dataDictionary, NSError * _Nullable error);

typedef void (^TEALURLResponseBlock)(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError);

typedef void (^TEALURLTaskResponseBlock)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable connectionError);

typedef void (^TEALHTTPResponseBlock)(NSHTTPURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError);

typedef void (^TEALHTTPResponseJSONBlock)(NSHTTPURLResponse * _Nullable response, NSDictionary * _Nullable data, NSError * _Nullable connectionError);
