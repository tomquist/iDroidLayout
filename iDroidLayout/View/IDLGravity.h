//
//  Gravity.h
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#define AXIS_SPECIFIED 0x0001
#define AXIS_PULL_BEFORE 0x0002
#define AXIS_PULL_AFTER 0x0004
#define AXIS_CLIP 0x0008
#define AXIS_X_SHIFT 0
#define AXIS_Y_SHIFT 4
#define HORIZONTAL_GRAVITY_MASK (AXIS_SPECIFIED | AXIS_PULL_BEFORE | AXIS_PULL_AFTER) << AXIS_X_SHIFT
#define VERTICAL_GRAVITY_MASK  (AXIS_SPECIFIED | AXIS_PULL_BEFORE | AXIS_PULL_AFTER) << AXIS_Y_SHIFT
#define RELATIVE_HORIZONTAL_GRAVITY_MASK (IDLViewContentGravityLeft | IDLViewContentGravityRight)

typedef enum IDLViewContentGravity {
    IDLViewContentGravityNone = 0x0000,
    IDLViewContentGravityTop = (AXIS_PULL_BEFORE|AXIS_SPECIFIED)<<AXIS_Y_SHIFT,
    IDLViewContentGravityBottom = (AXIS_PULL_AFTER|AXIS_SPECIFIED)<<AXIS_Y_SHIFT,
    IDLViewContentGravityLeft = (AXIS_PULL_BEFORE|AXIS_SPECIFIED)<<AXIS_X_SHIFT,
    IDLViewContentGravityRight = (AXIS_PULL_AFTER|AXIS_SPECIFIED)<<AXIS_X_SHIFT,
    IDLViewContentGravityCenterVertical = AXIS_SPECIFIED<<AXIS_Y_SHIFT,
    IDLViewContentGravityFillVertical = IDLViewContentGravityTop|IDLViewContentGravityBottom,
    IDLViewContentGravityCenterHorizontal = AXIS_SPECIFIED<<AXIS_X_SHIFT,
    IDLViewContentGravityFillHorizontal = IDLViewContentGravityLeft|IDLViewContentGravityRight,
    IDLViewContentGravityCenter = IDLViewContentGravityCenterVertical|IDLViewContentGravityCenterHorizontal,
    IDLViewContentGravityFill = IDLViewContentGravityFillVertical|IDLViewContentGravityFillHorizontal
} IDLViewContentGravity;

@interface IDLGravity : NSObject

+ (IDLViewContentGravity)gravityFromAttribute:(NSString *)gravityAttribute;
+ (void)applyGravity:(IDLViewContentGravity)gravity width:(CGFloat)w height:(CGFloat)h containerRect:(CGRect *)containerCGRect xAdj:(CGFloat)xAdj yAdj:(CGFloat)yAdj outRect:(CGRect *)outCGRect;
+ (void)applyGravity:(IDLViewContentGravity)gravity width:(CGFloat)w height:(CGFloat)h containerRect:(CGRect *)container outRect:(CGRect *)outRect;

@end
