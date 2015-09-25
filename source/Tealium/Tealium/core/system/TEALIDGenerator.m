//
//  TEALIDGenerator.m
//  Tealium
//
//  Created by Jason Koo on 8/27/15.
//  Copyright (c) 2015 Tealium Inc. All rights reserved.
//

#import "TEALIDGenerator.h"
#import <CommonCrypto/CommonCrypto.h>
#import <objc/runtime.h>

char const * const TEALKVOTealiumID =  "com.tealium.kvo.tealiumid";

@implementation TEALIDGenerator

static UIViewController *_rootController;

#pragma mark - PUBLIC CLASS

+ (NSString*) tealiumIdForObject:(id)object {
    
    if (![object isKindOfClass:([UIView class])] &&
        ![object isKindOfClass:([UIViewController class])]){
        return nil;
    }
    
    NSString *tealiumID = [TEALIDGenerator priorTealiumIDForObject:object];
    
    if (!tealiumID) {
        
        NSString *roadMap = [TEALIDGenerator roadMapFor:object];
        NSString *hash = [TEALIDGenerator sha1:roadMap];
        if (hash){
            [TEALIDGenerator assignTealiumId:hash toObject:object];
            tealiumID = hash;
        }
    }
    
    return tealiumID;
}


#pragma mark - PRIVATE HELPERS

+ (void) assignTealiumId:(NSString*)tealiumId toObject:(id)obj{
    if (!tealiumId || obj){
        return;
    }
    
    objc_setAssociatedObject(obj, TEALKVOTealiumID, tealiumId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSString *) priorTealiumIDForObject:(UIView *)object {
    
    id raw = objc_getAssociatedObject(object, TEALKVOTealiumID);
    if (![raw isKindOfClass:([NSString class])]) {
        return nil;
    }
    
    NSString *tealiumID = (NSString *)raw;
    return tealiumID;
}

+ (NSString*) roadMapFor:(UIView*)v{
    // super view scan method
    
    id vp;
    id np;
    BOOL keepScanning = YES;
    
    NSString *path = nil;
    if ([v respondsToSelector:@selector(view)]){
        vp = [v performSelector:@selector(view)];
        path = [NSString stringWithFormat:@"%@%@:%@", NSStringFromClass([v class]), [TEALIDGenerator titleForObject:v], NSStringFromClass([vp class])];
    } else {
        path = [NSString stringWithFormat:@"%@%@", NSStringFromClass([v class]), [TEALIDGenerator titleForObject:v]];
        vp = v;
    }
    
    
    while (keepScanning){
        if ([vp respondsToSelector:@selector(superview)]){
            
            np = [vp superview];
            
            if (np != vp &&
                np != NULL){
                path = [NSString stringWithFormat:@"%lu:%@%@:%@",
                        (unsigned long)[[np subviews] indexOfObject:vp],
                        NSStringFromClass([vp class]), [TEALIDGenerator titleForObject:np],
                        path];
                vp = np;
            } else keepScanning = NO;
            
            
            if (!keepScanning){
                path = [NSString stringWithFormat:@"%@:%@",
                        NSStringFromClass([vp class]),
                        path];
            }
        } else keepScanning = NO;
    }
    return path;
}

+ (NSString *)sha1:(NSString *)string {
    //Requires commoncrypto framework
    
    if (![string isKindOfClass:[NSString class]]) { return nil;}
    
    const char *cStr = [string UTF8String];
    unsigned char result[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cStr, (unsigned int)strlen(cStr), result);
    NSString *s = [NSString  stringWithFormat:
                   @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   result[0], result[1], result[2],result[3], result[4], result[5],
                   result[6], result[7], result[8],result[9], result[10], result[11]
                   ];
    
    NSString *t = [s substringToIndex:6];
    return t;
}

+ (NSString*) titleForObject:(id)obj{
    NSString *title = nil;
    if ([obj respondsToSelector:@selector(title)]){
        title = [obj title];
    }
    if ([obj respondsToSelector:@selector(textLabel)]){
        UILabel *label = [obj textLabel];
        title = [label text];
    }
    if ([obj respondsToSelector:@selector(titleForState:)]){
        title = [obj titleForState:UIControlStateNormal];
    }
    
    if (title){
        title = [NSString stringWithFormat:@":%@", title];
        return title;
    }
    return @"";
}

+ (id) rootController{
    if (!_rootController){
        NSArray *array = [UIApplication sharedApplication].windows;
        if ([array count] > 0) {
            UIWindow *window = [array objectAtIndex:0];
            _rootController = [window rootViewController];
        }
    }
    return _rootController;
}


@end
