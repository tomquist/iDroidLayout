//
//  UIView+IDLDrawable.h
//  iDroidLayout
//
//  Created by Tom Quist on 18.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDLDrawable.h"

@interface UIView (IDLDrawable)

@property (nonatomic, retain) IDLDrawable *backgroundDrawable;

- (void)onBackgroundDrawableChanged;

@end
