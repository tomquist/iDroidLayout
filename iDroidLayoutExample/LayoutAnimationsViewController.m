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
    UILabel *otherLabel = (UILabel *)[self.view findViewById:@"otherText"];
    otherLabel.contentMode = UIViewContentModeScaleToFill;
}

- (void)didPressButton {
    UILabel *textLabel = (UILabel *)[self.view findViewById:@"text"];
    if ([textLabel.text isEqualToString:@"Short text"]) {
        textLabel.text = @"Very long long text";
    } else {
        textLabel.text = @"Short text";
    }
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];        
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return TRUE;
}

@end
