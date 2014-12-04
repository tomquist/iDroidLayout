//
//  IDLLayoutViewController.h
//  iDroidLayout
//
//  Created by Tom Quist on 23.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDLLayoutBridge.h"

@interface IDLLayoutViewController : UIViewController

@property (nonatomic, strong) IDLLayoutBridge *view;

- (instancetype)initWithLayoutName:(NSString *)layoutNameOrNil bundle:(NSBundle *)layoutBundleOrNil;

@end
