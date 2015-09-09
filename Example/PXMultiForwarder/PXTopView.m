//
//  PXTopView.m
//  PXMultiForwarder
//
//  Created by Spencer Phippen on 2015/09/09.
//  Copyright (c) 2015年 Spencer Phippen. All rights reserved.
//

#import "PXTopView.h"

@implementation PXTopView

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self)
        return nil;
    
    _topView = [[PXSmallView alloc] init];
    _middleView = [[PXSmallView alloc] init];
    _bottomView = [[PXSmallView alloc] init];
    
    [self addSubview:_topView];
    [self addSubview:_middleView];
    [self addSubview:_bottomView];
    
    [self setBackgroundColor:[UIColor whiteColor]];
    
    return self;
}

- (void) layoutSubviews {
    const CGRect entireArea = [self bounds];
    CGRect workingArea = entireArea;
    
    CGRect topFrame = CGRectZero;
    CGRect middleFrame = CGRectZero;
    CGRect bottomFrame = CGRectZero;

    const CGFloat fieldHeight = round(workingArea.size.height / 3.0);
    CGRectDivide(workingArea, &topFrame, &workingArea, fieldHeight, CGRectMinYEdge);
    CGRectDivide(workingArea, &middleFrame, &bottomFrame, fieldHeight, CGRectMinYEdge);
    
    [_topView setFrame:topFrame];
    [_middleView setFrame:middleFrame];
    [_bottomView setFrame:bottomFrame];
}

@end
