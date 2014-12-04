//
//  ViewGroup.h
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDLLayoutParams.h"
#import "UIView+IDL_Layout.h"
#import "UIView+IDL_ViewGroup.h"

@interface IDLViewGroup : UIView

+ (IDLLayoutMeasureSpec)childMeasureSpecForMeasureSpec:(IDLLayoutMeasureSpec)spec padding:(CGFloat)padding childDimension:(CGFloat)childDimension;

- (instancetype)initWithAttributes:(NSDictionary *)attrs NS_DESIGNATED_INITIALIZER;

@end
