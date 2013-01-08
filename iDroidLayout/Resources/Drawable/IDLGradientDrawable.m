//
//  IDLGradientDrawable.m
//  iDroidLayout
//
//  Created by Tom Quist on 17.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLGradientDrawable.h"
#import "IDLDrawable+IDL_Internal.h"
#import "TBXML+IDL.h"
#import "NSDictionary+IDL_ResourceManager.h"

IDLGradientDrawableShape IDLGradientDrawableShapeFromString(NSString *string) {
    IDLGradientDrawableShape ret = IDLGradientDrawableShapeRectangle;
    if ([string isEqualToString:@"rectangle"]) {
        ret = IDLGradientDrawableShapeRectangle;
    } else if ([string isEqualToString:@"oval"]) {
        ret = IDLGradientDrawableShapeOval;
    } else if ([string isEqualToString:@"line"]) {
        ret = IDLGradientDrawableShapeLine;
    } else if ([string isEqualToString:@"ring"]) {
        ret = IDLGradientDrawableShapeRing;
    }
    return ret;
}

IDLGradientDrawableGradientType IDLGradientDrawableGradientTypeFromString(NSString *string) {
    IDLGradientDrawableGradientType ret = IDLGradientDrawableGradientTypeNone;
    if ([string length] == 0 || [string isEqualToString:@"linear"]) {
        ret = IDLGradientDrawableGradientTypeLinear;
    } else if ([string isEqualToString:@"radial"]) {
        ret = IDLGradientDrawableGradientTypeRadial;
    }
    return ret;
}

const IDLGradientDrawableCornerRadius IDLGradientDrawableCornerRadiusZero = {0,0,0,0};

BOOL IDLGradientDrawableCornerRadiusEqualsCornerRadius(IDLGradientDrawableCornerRadius r1, IDLGradientDrawableCornerRadius r2) {
    return r1.topLeft == r2.topLeft && r1.topRight == r2.topRight && r1.bottomLeft == r2.bottomLeft && r1.bottomRight == r2.bottomRight;
}

@interface IDLGradientDrawableConstantState ()

@property (nonatomic, retain) NSArray *colors;
@property (nonatomic, retain) NSArray *cgColors;
@property (nonatomic, assign) UIEdgeInsets padding;
@property (nonatomic, assign) BOOL hasPadding;
@property (nonatomic, assign) CGFloat strokeWidth;
@property (nonatomic, retain) UIColor *strokeColor;
@property (nonatomic, assign) CGFloat dashWidth;
@property (nonatomic, assign) CGFloat dashGap;

@property (nonatomic, assign) IDLGradientDrawableGradientType gradientType;
@property (nonatomic, assign) CGPoint relativeGradientCenter;
@property (nonatomic, assign) CGFloat gradientRadius;
@property (nonatomic, assign) BOOL gradientRadiusIsRelative;
@property (nonatomic, assign) IDLGradientDrawableShape shape;
@property (nonatomic, assign) IDLGradientDrawableCornerRadius corners;
@property (nonatomic, assign) CGSize size;

@property (nonatomic, assign) CGColorSpaceRef colorSpace;
@property (nonatomic, assign) CGGradientRef gradient;

@end

@implementation IDLGradientDrawableConstantState

- (void)dealloc {
    self.colors = nil;
    self.cgColors = nil;
    self.strokeColor = nil;
    if (_colorSpace != NULL) {
        CGColorSpaceRelease(_colorSpace);
        _colorSpace = NULL;
    }
    if (_gradient != NULL) {
        CGGradientRelease(_gradient);
        _gradient = NULL;
    }
    [super dealloc];
}

- (id)initWithState:(IDLGradientDrawableConstantState *)state {
    self = [super init];
    if (self) {
        if (state != nil) {
            NSArray *colors = [[NSArray alloc] initWithArray:state.colors];
            self.colors = colors;
            [colors release];
            
            NSArray *cgColors = [[NSArray alloc] initWithArray:state.cgColors];
            self.cgColors = cgColors;
            [cgColors release];
            self.padding = state.padding;
            self.hasPadding = state.hasPadding;
            self.strokeWidth = state.strokeWidth;
            self.strokeColor = state.strokeColor;
            self.dashWidth = state.dashWidth;
            self.dashGap = state.dashGap;
            self.shape = state.shape;
            self.corners = state.corners;
            self.size = state.size;
            _colorSpace = CGColorSpaceRetain(state.colorSpace);
            _gradient = CGGradientRetain(state.gradient);
            self.relativeGradientCenter = state.relativeGradientCenter;
            self.gradientRadius = state.gradientRadius;
            self.gradientRadiusIsRelative = state.gradientRadiusIsRelative;
            self.gradientType = state.gradientType;
        } else {
            _colorSpace = CGColorSpaceCreateDeviceRGB();
        }

    }
    return self;
}

- (NSArray *)cgColors {
    if (_cgColors == nil) {
        NSMutableArray *cgColors = [[NSMutableArray alloc] initWithCapacity:[self.colors count]];
        for (UIColor *c in self.colors) {
            CGColorRef cgColor = [c CGColor];
            if (cgColor != NULL) {
                [cgColors addObject:(id)cgColor];
            }
        }
        _cgColors = cgColors;
    }
    return _cgColors;
}

- (CGGradientRef)currentGradient {
    if (_gradient == NULL) {
        _gradient = CGGradientCreateWithColors(self.colorSpace, (CFArrayRef)self.cgColors, NULL);
    }
    return _gradient;
}

@end

@interface IDLGradientDrawable ()

@property (nonatomic, retain) IDLGradientDrawableConstantState *internalConstantState;

@end

@implementation IDLGradientDrawable

- (void)dealloc {
    self.internalConstantState = nil;
    [super dealloc];
}

- (id)initWithState:(IDLGradientDrawableConstantState *)state {
    self = [super init];
    if (self) {
        IDLGradientDrawableConstantState *s = [[IDLGradientDrawableConstantState alloc] initWithState:state];
        self.internalConstantState = s;
        [s release];
    }
    return self;
}

- (id)init {
    return [self initWithState:nil];
}

- (void)createPathInContext:(CGContextRef)context forRect:(CGRect)rect {
    IDLGradientDrawableConstantState *state = self.internalConstantState;
    IDLGradientDrawableCornerRadius corners = state.corners;
    CGContextBeginPath(context);
    switch (state.shape) {
        case IDLGradientDrawableShapeRectangle:
            CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + corners.topLeft);
            CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height - corners.bottomLeft);
            if (corners.bottomLeft > 0) {
                CGContextAddArc(context, rect.origin.x + corners.bottomLeft, rect.origin.y + rect.size.height - corners.bottomLeft, corners.bottomLeft, M_PI / 4, M_PI / 2, true);
            }
            CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - corners.bottomRight, rect.origin.y + rect.size.height);
            if (corners.bottomRight > 0) {
                CGContextAddArc(context, rect.origin.x + rect.size.width - corners.bottomRight, rect.origin.y + rect.size.height - corners.bottomRight, corners.bottomRight, M_PI / 2, 0.0f, true);
            }
            CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + corners.topRight);
            if (corners.topRight > 0) {
                CGContextAddArc(context, rect.origin.x + rect.size.width - corners.topRight, rect.origin.y + corners.topRight, corners.topRight, 0.0f, -M_PI / 2, true);
            }
            CGContextAddLineToPoint(context, rect.origin.x + corners.topLeft, rect.origin.y);
            if (corners.topLeft > 0) {
                CGContextAddArc(context, rect.origin.x + corners.topLeft, rect.origin.y + corners.topLeft, corners.topLeft, - M_PI / 2, M_PI, true);
            }
            break;
        case IDLGradientDrawableShapeOval:
            CGContextAddEllipseInRect(context, rect);
            break;
        case IDLGradientDrawableShapeRing:
            
            break;
        case IDLGradientDrawableShapeLine: {
            CGFloat y = CGRectGetMidY(rect);
            CGContextMoveToPoint(context, rect.origin.x, y);
            CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, y);
            break;
        }
        default:
            break;
    }
}

- (void)drawInContext:(CGContextRef)context {
    CGRect rect = self.bounds;
    IDLGradientDrawableConstantState *state = self.internalConstantState;
    if (state.shape != IDLGradientDrawableShapeLine) {
        if ([state.colors count] == 1) {
            [self createPathInContext:context forRect:rect];
            CGContextSetFillColorWithColor(context, [state.colors[0] CGColor]);
            CGContextDrawPath(context, kCGPathFill);
        } else if ([state.colors count] > 1) {
            [self createPathInContext:context forRect:rect];
            CGContextSaveGState(context);
            CGContextClip(context);
            
            if (state.gradientType == IDLGradientDrawableGradientTypeLinear) {
                CGGradientRef gradient = [state currentGradient];
                CGContextDrawLinearGradient(context, gradient, rect.origin, CGPointMake(rect.origin.x, rect.origin.y + rect.size.height), 0);
            } else if (state.gradientType == IDLGradientDrawableGradientTypeRadial) {
                CGGradientRef gradient = [state currentGradient];
                CGPoint relativeCenterPoint = state.relativeGradientCenter;
                CGPoint centerPoint = CGPointMake(rect.origin.x + rect.size.width * relativeCenterPoint.x, rect.origin.y + rect.size.height * relativeCenterPoint.y);
                CGFloat radius = state.gradientRadius;
                if (state.gradientRadiusIsRelative) {
                    radius *= MIN(rect.size.width, rect.size.height);
                }
                CGContextDrawRadialGradient(context, gradient, centerPoint, 0, centerPoint, radius, kCGGradientDrawsAfterEndLocation);
            }
            CGContextRestoreGState(context);
        }
    }
    BOOL drawStroke = state.strokeWidth > 0 && state.strokeColor != nil;
    if (drawStroke) {
        [self createPathInContext:context forRect:rect];
        CGContextSetLineWidth(context, state.strokeWidth);
        if (state.dashWidth > 0.f) {
            CGFloat lengths[2] = {state.dashWidth, state.dashGap};
            CGContextSetLineDash(context, 0, lengths, 2);
        }
        CGContextSetStrokeColorWithColor(context, [state.strokeColor CGColor]);
        CGContextStrokePath(context);
    }
    OUTLINE_RECT(context, rect);
}

- (void)inflateWithElement:(TBXMLElement *)element {
    [super inflateWithElement:element];
    IDLGradientDrawableConstantState *state = self.internalConstantState;
    NSMutableDictionary *attrs = [TBXML attributesFromXMLElement:element reuseDictionary:nil];
    NSString *shape = [attrs objectForKey:@"shape"];
    state.shape = IDLGradientDrawableShapeFromString(shape);
    
    TBXMLElement *child = element->firstChild;
    while (child != NULL) {
        NSString *name = [TBXML elementName:child];
        if ([name isEqualToString:@"gradient"]) {
            attrs = [TBXML attributesFromXMLElement:child reuseDictionary:attrs];
            UIColor *startColor = [attrs colorFromIDLValueForKey:@"startColor"];
            UIColor *centerColor = [attrs colorFromIDLValueForKey:@"centerColor"];
            UIColor *endColor = [attrs colorFromIDLValueForKey:@"endColor"];
            if (centerColor != nil) {
                state.colors = @[startColor?startColor:[UIColor blackColor], centerColor, endColor?endColor:[UIColor blackColor]];
            } else {
                state.colors = @[startColor?startColor:[UIColor blackColor], endColor?endColor:[UIColor blackColor]];
            }
            
            state.gradientType = IDLGradientDrawableGradientTypeFromString([attrs objectForKey:@"type"]);
            
            if (state.gradientType == IDLGradientDrawableGradientTypeRadial) {
                
                if ([attrs objectForKey:@"gradientRadius"] == nil) {
                    state.gradientRadius = 1;
                    state.gradientRadiusIsRelative = TRUE;
                } else {
                    if ([attrs isFractionIDLValueForKey:@"gradientRadius"]) {
                        state.gradientRadiusIsRelative = TRUE;
                        state.gradientRadius = [attrs fractionValueFromIDLValueForKey:@"gradientRadius"];
                    } else {
                        state.gradientRadiusIsRelative = FALSE;
                        state.gradientRadius = [attrs dimensionFromIDLValueForKey:@"gradientRadius"];
                    }
                }
                
                CGPoint gradientCenter = CGPointMake(.5f, .5f);
                NSString *centerX = [attrs objectForKey:@"centerX"];
                if (centerX != nil) {
                    gradientCenter.x = [centerX floatValue];
                }
                NSString *centerY = [attrs objectForKey:@"centerY"];
                if (centerY != nil) {
                    gradientCenter.y = [centerY floatValue];
                }
                state.relativeGradientCenter = gradientCenter;
            }
            
        } else if ([name isEqualToString:@"padding"]) {
            attrs = [TBXML attributesFromXMLElement:child reuseDictionary:attrs];
            UIEdgeInsets padding = UIEdgeInsetsZero;
            padding.left = [[attrs objectForKey:@"left"] floatValue];
            padding.top = [[attrs objectForKey:@"top"] floatValue];
            padding.right = [[attrs objectForKey:@"right"] floatValue];
            padding.bottom = [[attrs objectForKey:@"bottom"] floatValue];
            state.padding = padding;
            state.hasPadding = TRUE;
        } else if ([name isEqualToString:@"corners"]) {
            IDLGradientDrawableCornerRadius radius =  IDLGradientDrawableCornerRadiusZero;
            attrs = [TBXML attributesFromXMLElement:child reuseDictionary:attrs];
            radius.topLeft = radius.topRight = radius.bottomLeft = radius.bottomRight = [[attrs objectForKey:@"radius"] floatValue];
            NSString *topLeftRadius = [attrs objectForKey:@"topLeftRadius"];
            NSString *topRightRadius = [attrs objectForKey:@"topRightRadius"];
            NSString *bottomLeftRadius = [attrs objectForKey:@"bottomLeftRadius"];
            NSString *bottomRightRadius = [attrs objectForKey:@"bottomRightRadius"];
            if (topLeftRadius != nil) radius.topLeft = [topLeftRadius floatValue];
            if (topRightRadius != nil) radius.topRight = [topRightRadius floatValue];
            if (bottomLeftRadius != nil) radius.bottomLeft = [bottomLeftRadius floatValue];
            if (bottomRightRadius != nil) radius.bottomRight = [bottomRightRadius floatValue];
            state.corners = radius;
        } else if ([name isEqualToString:@"solid"]) {
            attrs = [TBXML attributesFromXMLElement:child reuseDictionary:attrs];
            UIColor *color = [attrs colorFromIDLValueForKey:@"color"];
            if (color == nil) {
                color = [UIColor blackColor];
            }
            state.colors = @[color];
        } else if ([name isEqualToString:@"size"]) {
            attrs = [TBXML attributesFromXMLElement:child reuseDictionary:attrs];
            CGSize size = CGSizeZero;
            size.width = [attrs dimensionFromIDLValueForKey:@"width" defaultValue:-1.f];
            size.height = [attrs dimensionFromIDLValueForKey:@"height" defaultValue:-1.f];
            state.size = size;
        } else if ([name isEqualToString:@"stroke"]) {
            attrs = [TBXML attributesFromXMLElement:child reuseDictionary:attrs];
            state.strokeWidth = [attrs dimensionFromIDLValueForKey:@"width"];
            state.strokeColor = [attrs colorFromIDLValueForKey:@"color"];
            state.dashWidth = [attrs dimensionFromIDLValueForKey:@"dashWidth"];
            if (state.dashWidth != 0.f) {
                state.dashGap = [attrs dimensionFromIDLValueForKey:@"dashGap"];
            }
        }
        child = child->nextSibling;
    }
}

- (UIEdgeInsets)padding {
    return self.internalConstantState.padding;
}

- (BOOL)hasPadding {
    return self.internalConstantState.hasPadding;
}

- (CGSize)intrinsicSize {
    return self.internalConstantState.size;
}

- (IDLDrawableConstantState *)constantState {
    return self.internalConstantState;
}

@end
