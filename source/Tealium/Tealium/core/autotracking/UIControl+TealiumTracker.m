//
//  UIControl+TealiumTracker.m
//  UICatalog
//
//  Created by Jason Koo on 5/8/14.
//
//

#import "UIControl+TealiumTracker.h"
#import "TealiumInternalConstants.h"

@implementation UIControl (TealiumTracker)

static char const * const MobileCompanionRevealObserverKey = "TealiumMobileCompanionRevealObserverKey";

id (*oInitWithFrame)(id, SEL, CGRect r);
void (*oRemoveFromSuperView)(id, SEL);

+ (void)load {
    
    if ([TealiumInternalConstants isAnExcludedObject:self]){
        TEALIUMLOG(@"Obj excluded from autotracking system: %@", self);
        NSLog(@"%s: Obj excluded from autotracking system.", __FUNCTION__);
    } else {
        Method origMethod1 = class_getInstanceMethod(self, @selector(initWithFrame:));
        oInitWithFrame = (void *)method_getImplementation(origMethod1);
        if(!class_addMethod(self, @selector(initWithFrame:), (IMP)TealiumInitWithFrame, method_getTypeEncoding(origMethod1))) method_setImplementation(origMethod1, (IMP)TealiumInitWithFrame);
        
        Method origMethod2 = class_getInstanceMethod(self, @selector(removeFromSuperview));
        oRemoveFromSuperView = (void *)method_getImplementation(origMethod2);
        if(!class_addMethod(self, @selector(removeFromSuperview), (IMP)TealiumRemoveFromSuperview, method_getTypeEncoding(origMethod2)))
            method_setImplementation(origMethod2, (IMP)TealiumRemoveFromSuperview);

    }

}

- (instancetype) initWithOriginalFrame:(CGRect)frame {
    return oInitWithFrame(self, @selector(initWithFrame:), frame);
}

static id TealiumInitWithFrame(UIControl *self, SEL _cmd, CGRect r) {
    
    [self setMobileCompanionRevealObserver:nil];
    
    if ([self respondsToSelector:@selector(requestOverlay)]){
        BOOL isButton = [self respondsToSelector:@selector(sendActionsForControlEvents:)];
        BOOL isAction = [self respondsToSelector:@selector(action)];
        if (isButton || isAction){

            __weak UIControl *weakSelf = self;
            id observer = [[NSNotificationCenter defaultCenter] addObserverForName:TealiumNK_RevealMobileCompanion
                                                                            object:nil
                                                                             queue:[NSOperationQueue currentQueue]
                                                                        usingBlock:^(NSNotification *note) {
                                                              
                                                                            [weakSelf requestOverlay];
                                                                        }];
            [self setMobileCompanionRevealObserver:observer];
        }
    }
    return oInitWithFrame(self, _cmd, r);
}


- (void) requestOverlay{
    [[NSNotificationCenter defaultCenter] postNotificationName:TealiumNK_RequestOverlay object:self userInfo:nil];
}

- (void) hideOverlay:(NSNotification*)notification{
    UITapGestureRecognizer *inspectionGesture = [notification object];
    if (inspectionGesture)[self removeGestureRecognizer:inspectionGesture];
}


static void TealiumRemoveFromSuperview( UIControl *self, SEL _cmd) {
    
    id observer = [self mobileCompanionRevealObserver];
    if (observer != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer name:TealiumNK_RevealMobileCompanion object:nil];
        
        [self setMobileCompanionRevealObserver:nil];
    }

    oRemoveFromSuperView( self, _cmd );
}

- (void) setMobileCompanionRevealObserver:(id)mobileCompanionRevealObserver {
    
    objc_setAssociatedObject(self, MobileCompanionRevealObserverKey, mobileCompanionRevealObserver, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (id) mobileCompanionRevealObserver {
    
    return objc_getAssociatedObject(self, MobileCompanionRevealObserverKey);
}

@end
