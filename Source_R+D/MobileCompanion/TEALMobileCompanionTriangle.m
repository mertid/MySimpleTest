//
//  TEALMobileCompanionTriangle.m
//  Popovers
//
//  Created by Jason Koo on 5/22/14.
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import "TEALMobileCompanionTriangle.h"

@implementation TEALMobileCompanionTriangle

- (instancetype) initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void) drawRect:(CGRect)rect {
    
    int border = self.bounds.size.width * .15;
    int edgeL = self.bounds.size.width * .6;
    CGPoint rCorner = CGPointMake(self.bounds.size.width - border, self.bounds.size.height - border);         // bottom-right
    CGPoint rEdge = CGPointMake(self.bounds.size.width - border, edgeL - border);   // top-right
    CGPoint bEdge = CGPointMake(edgeL - border, self.bounds.size.height - border); // bottom-left

//    CGPoint rCorner = CGPointMake(self.bounds.size.width - border, self.bounds.size.height - border);
//    CGPoint rEdge = CGPointMake(self.bounds.size.width - border, self.bounds.size.height - border - edgeL);
//    CGPoint bEdge = CGPointMake(self.bounds.size.width - border - edgeL, self.bounds.size.height - border);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:bEdge];
    [path addLineToPoint:rCorner];
    [path addLineToPoint:rEdge];
    [path closePath];
    [[UIColor whiteColor] set];
    [path fill];
}


@end
