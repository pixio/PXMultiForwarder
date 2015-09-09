//
//  PXViewController.m
//  PXMultiForwarder
//
//  Created by Spencer Phippen on 09/09/2015.
//  Copyright (c) 2015 Spencer Phippen. All rights reserved.
//

#import "PXViewController.h"

#import "PXTopView.h"
#import "PXSmallView.h"
#import <PXMultiForwarder/PXMultiForwarder.h>

@implementation PXViewController

#pragma mark UIView Methods
- (void) loadView {
    [self setView:[[PXTopView alloc] init]];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [[[self allViews] button] addTarget:self action:@selector(buttonPushed:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark PXViewController Methods
- (PXTopView*) pxView {
    return (PXTopView*)[self view];
}

- (PXSmallView*) allViews {
    PXTopView* theView = [self pxView];
    return (PXSmallView*)[[PXMultiForwarder alloc] initWithObjects:[theView topView], [theView middleView], [theView bottomView], nil];
}

- (void) buttonPushed:(UIButton*)button {
    [[self allViews] makeRandomColor];
}

@end
