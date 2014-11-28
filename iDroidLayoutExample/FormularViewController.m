//
//  FormularViewController.m
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FormularViewController.h"
#import "iDroidLayout.h"

@implementation FormularViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateAndroidStatus];
}

- (void)didPressSubmitButton {
    UIButton *submitButton = (UIButton *)[self.view findViewById:@"submitButton"];
    submitButton.selected = TRUE;
    UILabel *username = (UILabel *)[self.view findViewById:@"username"];
    UILabel *password = (UILabel *)[self.view findViewById:@"password"];
    UITextView *freeText = (UITextView *)[self.view findViewById:@"freeText"];
    [username resignFirstResponder];
    [password resignFirstResponder];
    [freeText resignFirstResponder];
    NSString *message = [NSString stringWithFormat:@"Username: %@\nPassword: %@\nText: %@", username.text, password.text, freeText.text];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)didPressToggleButton {
    UIView *androidView = [self.view findViewById:@"android"];
    if (androidView.visibility == IDLViewVisibilityVisible) {
        IDLLinearLayoutLayoutParams *lp = (IDLLinearLayoutLayoutParams *)androidView.layoutParams;
        if (lp.gravity == IDLViewContentGravityLeft) {
            lp.gravity = IDLViewContentGravityCenterHorizontal;
        } else if (lp.gravity == IDLViewContentGravityCenterHorizontal) {
            lp.gravity = IDLViewContentGravityRight;
        } else {
            lp.gravity = IDLViewContentGravityLeft;
            androidView.visibility = IDLViewVisibilityInvisible;
        }
        androidView.layoutParams = lp;
    } else if (androidView.visibility == IDLViewVisibilityInvisible) {
        androidView.visibility = IDLViewVisibilityGone;
    } else {
        androidView.visibility = IDLViewVisibilityVisible;
    }
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
    [self updateAndroidStatus];
}

- (void)updateAndroidStatus {
    UILabel *label = (UILabel *)[self.view findViewById:@"androidStatus"];
    UIView *androidView = [self.view findViewById:@"android"];
    NSString *visibility;
    switch (androidView.visibility) {
        case IDLViewVisibilityVisible:
            visibility = @"visible";
            break;
        case IDLViewVisibilityInvisible:
            visibility = @"invisible";
            break;
        case IDLViewVisibilityGone:
            visibility = @"gone";
            break;
    }
    NSString *gravity = @"";
    IDLLinearLayoutLayoutParams *lp = (IDLLinearLayoutLayoutParams *)androidView.layoutParams;
    switch (lp.gravity) {
        case IDLViewContentGravityLeft:
            gravity = @"left";
            break;
        case IDLViewContentGravityCenterHorizontal:
            gravity = @"center_horizontal";
            break;
        case IDLViewContentGravityRight:
            gravity = @"right";
            break;
        default:
            gravity = @"unknown";
            break;
    }
    
    label.text = [NSString stringWithFormat:@"andrdoid[visibility=%@,layout_gravity=%@]", visibility, gravity];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return TRUE;
}

@end
