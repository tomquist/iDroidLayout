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
    UIButton *submitButton = (UIButton *)[self.view findViewById:@"submitButton"];
    [submitButton addTarget:self action:@selector(didPressSubmitButton) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didPressSubmitButton {
    UILabel *username = (UILabel *)[self.view findViewById:@"username"];
    UILabel *password = (UILabel *)[self.view findViewById:@"password"];
    UITextView *freeText = (UITextView *)[self.view findViewById:@"freeText"];
    [username resignFirstResponder];
    [password resignFirstResponder];
    [freeText resignFirstResponder];
    NSString *message = [NSString stringWithFormat:@"Username: %@\nPassword: %@\nText: %@", username.text, password.text, freeText.text];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return TRUE;
}

@end
