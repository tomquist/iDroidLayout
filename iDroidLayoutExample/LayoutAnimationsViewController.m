//
//  LayoutAnimationsViewController.m
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LayoutAnimationsViewController.h"
#import "iDroidLayout.h"

@implementation LayoutAnimationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *button = (UIButton *)[self.view findViewById:@"button"];
    [button addTarget:self action:@selector(didPressButton) forControlEvents:UIControlEventTouchUpInside];
    UILabel *textLabel = (UILabel *)[self.view findViewById:@"text"];
    UILabel *otherLabel = (UILabel *)[self.view findViewById:@"otherText"];
    textLabel.contentMode = UIViewContentModeCenter;
    otherLabel.contentMode = UIViewContentModeScaleToFill;
}

- (void)didPressButton {
    UILabel *textLabel = (UILabel *)[self.view findViewById:@"text"];
    if ([textLabel.text isEqualToString:@"Short text"]) {
        textLabel.text = @"Very long long text";
    } else {
        textLabel.text = @"Short text";
    }
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];        
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return TRUE;
}

@end
