//
//  PXSmallView.m
//  PXMultiForwarder
//
//  Created by Spencer Phippen on 2015/09/09.
//  Copyright (c) 2015年 Spencer Phippen. All rights reserved.
//

#import "PXSmallView.h"

@implementation PXSmallView

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self)
        return nil;
    
    _button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_button setTitle:@"Color me" forState:UIControlStateNormal];
    
    [self addSubview:_button];
    
    return self;
}

- (void) layoutSubviews {
    [_button setFrame:[self bounds]];
}

- (void) makeRandomColor {
    double r = (double)arc4random() / UINT32_MAX;
    double g = (double)arc4random() / UINT32_MAX;
    double b = (double)arc4random() / UINT32_MAX;
    [self setBackgroundColor:[UIColor colorWithRed:r green:g blue:b alpha:1.0]];
}

@end
