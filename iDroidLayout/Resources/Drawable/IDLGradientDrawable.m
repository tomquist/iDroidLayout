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
    self.colorSpace = nil;
    self.gradient = nil;
    [super dealloc];
}

- (id)initWithState:(IDLGradientDrawableConstantState *)state {
    self = [super init];
    if (self) {
        if (state != nil) {
            NSArray *colors = [state.colors copy];
            self.colors = colors;
            [colors release];
            
            colors = [state.cgColors copy];
            self.cgColors = colors;
            [colors release];
            
            self.padding = state.padding;
            self.hasPadding = state.hasPadding;
            self.strokeWidth = state.strokeWidth;
            self.strokeColor = state.strokeColor;
            self.shape = state.shape;
            self.corners = state.corners;
            self.size = state.size;
            self.colorSpace = state.colorSpace;
            self.gradient = state.gradient;
        } else {
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            self.colorSpace = colorSpace;
            CGColorSpaceRelease(colorSpace);
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
        self.cgColors = cgColors;
        [cgColors release];
    }
    return _cgColors;
}

- (void)setColorSpace:(CGColorSpaceRef)colorSpace {
    if (_colorSpace != colorSpace) {
        if (_colorSpace != NULL) {
            CGColorSpaceRelease(_colorSpace);
        }
        if (colorSpace != NULL) {
            _colorSpace = CGColorSpaceRetain(colorSpace);
        }
    }
}

- (void)setGradient:(CGGradientRef)gradient {
    if (_gradient != gradient) {
        if (_gradient != NULL) {
            CGGradientRelease(_gradient);
        }
        if (gradient != NULL) {
            _gradient = CGGradientRetain(gradient);
        }
    }
}

- (CGGradientRef)currentGradient {
    if (self.gradient == nil) {
        CGGradientRef gradient = CGGradientCreateWithColors(self.colorSpace, (CFArrayRef)self.cgColors, NULL);
        self.gradient = gradient;
        CGGradientRelease(gradient);
    }
    return self.gradient;
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
    IDLGradientDrawableCornerRadius corners = self.internalConstantState.corners;
    CGContextBeginPath(context);
    switch (self.internalConstantState.shape) {
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
        default:
            break;
    }
}

- (void)drawInContext:(CGContextRef)context {
    CGRect rect = self.bounds;
    if ([self.internalConstantState.colors count] == 1) {
        [self createPathInContext:context forRect:rect];
        CGContextSetFillColorWithColor(context, [self.internalConstantState.colors[0] CGColor]);
        CGContextDrawPath(context, kCGPathFill);
    } else if ([self.internalConstantState.colors count] > 1) {
        [self createPathInContext:context forRect:rect];
        CGContextSaveGState(context);
        CGContextClip(context);
        CGGradientRef gradient = [self.internalConstantState currentGradient];
        CGContextDrawLinearGradient(context, gradient, rect.origin, CGPointMake(rect.origin.x, rect.origin.y + rect.size.height), 0);
        CGContextRestoreGState(context);
    }
    BOOL drawStroke = self.internalConstantState.strokeWidth > 0 && self.internalConstantState.strokeColor != nil;
    if (drawStroke) {
        [self createPathInContext:context forRect:rect];
        CGContextSetLineWidth(context, self.internalConstantState.strokeWidth);
        CGContextSetStrokeColorWithColor(context, [self.internalConstantState.strokeColor CGColor]);
        CGContextStrokePath(context);
    }
    OUTLINE_RECT(context, rect);
}

- (void)drawOnLayer:(CALayer *)layer {
    CALayer *sublayer;
    BOOL drawStroke = self.internalConstantState.strokeWidth > 0 && self.internalConstantState.strokeColor != nil;
    if ([self.internalConstantState.colors count] == 1) {
        CALayer *tmpSublayer = [CALayer layer];
        tmpSublayer.backgroundColor = [self.internalConstantState.colors[0] CGColor];
        [layer addSublayer:tmpSublayer];
        sublayer = tmpSublayer;
    } else {
        CAGradientLayer *tmpSublayer = [CAGradientLayer layer];
        tmpSublayer.frame = layer.bounds;
        NSArray *cgColors = self.internalConstantState.cgColors;
        [tmpSublayer setColors:cgColors];
        [layer addSublayer:tmpSublayer];
        sublayer = tmpSublayer;
    }
    if (self.internalConstantState.shape != IDLGradientDrawableShapeLine) {
        // Apply mask to layer
        CGMutablePathRef path = CGPathCreateMutable();
        CGRect rect = sublayer.bounds;
        IDLGradientDrawableCornerRadius corners = self.internalConstantState.corners;
        switch (self.internalConstantState.shape) {
            case IDLGradientDrawableShapeRectangle:
                CGPathMoveToPoint(path, NULL, rect.origin.x, rect.origin.y + corners.topLeft);
                CGPathAddLineToPoint(path, NULL, rect.origin.x, rect.origin.y + rect.size.height - corners.bottomLeft);
                if (corners.bottomLeft > 0) {
                    CGPathAddArc(path, NULL, rect.origin.x + corners.bottomLeft, rect.origin.y + rect.size.height - corners.bottomLeft, corners.bottomLeft, M_PI / 4, M_PI / 2, true);
                }
                CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width - corners.bottomRight, rect.origin.y + rect.size.height);
                if (corners.bottomRight > 0) {
                    CGPathAddArc(path, NULL, rect.origin.x + rect.size.width - corners.bottomRight, rect.origin.y + rect.size.height - corners.bottomRight, corners.bottomRight, M_PI / 2, 0.0f, true);
                }
                CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width, rect.origin.y + corners.topRight);
                if (corners.topRight > 0) {
                    CGPathAddArc(path, NULL, rect.origin.x + rect.size.width - corners.topRight, rect.origin.y + corners.topRight, corners.topRight, 0.0f, -M_PI / 2, true);
                }
                CGPathAddLineToPoint(path, NULL, rect.origin.x + corners.topLeft, rect.origin.y);
                if (corners.topLeft > 0) {
                    CGPathAddArc(path, NULL, rect.origin.x + corners.topLeft, rect.origin.y + corners.topLeft, corners.topLeft, - M_PI / 2, M_PI, true);
                }
                break;
            case IDLGradientDrawableShapeOval:
                CGPathAddEllipseInRect(path, NULL, rect);
                break;
            case IDLGradientDrawableShapeRing:
                
                break;
            default:
                break;
        }
        if (self.internalConstantState.shape != IDLGradientDrawableShapeRectangle || !IDLGradientDrawableCornerRadiusEqualsCornerRadius(corners, IDLGradientDrawableCornerRadiusZero)) {
            CAShapeLayer *mask = [[CAShapeLayer alloc] init];
            mask.fillColor = [[UIColor blackColor] CGColor];
            mask.frame = sublayer.bounds;
            mask.path = path;
            sublayer.mask = mask;
            [mask release];
        }
        if (drawStroke) {
            CAShapeLayer *strokeLayer = [[CAShapeLayer alloc] init];
            strokeLayer.strokeColor = [self.internalConstantState.strokeColor CGColor];
            strokeLayer.fillColor = [[UIColor clearColor] CGColor];
            strokeLayer.lineWidth = self.internalConstantState.strokeWidth;
            strokeLayer.frame = sublayer.bounds;
            strokeLayer.path = path;
            [sublayer addSublayer:strokeLayer];
            [strokeLayer release];
        }
        CGPathRelease(path);
        
    } else {
        
    }
}

- (void)inflateWithElement:(TBXMLElement *)element {
    [super inflateWithElement:element];
    NSMutableDictionary *attrs = [TBXML attributesFromXMLElement:element reuseDictionary:nil];
    NSString *shape = [attrs objectForKey:@"shape"];
    self.internalConstantState.shape = IDLGradientDrawableShapeFromString(shape);
    
    TBXMLElement *child = element->firstChild;
    while (child != NULL) {
        NSString *name = [TBXML elementName:child];
        if ([name isEqualToString:@"gradient"]) {
            attrs = [TBXML attributesFromXMLElement:child reuseDictionary:attrs];
            UIColor *startColor = [attrs colorFromIDLValueForKey:@"startColor"];
            UIColor *centerColor = [attrs colorFromIDLValueForKey:@"centerColor"];
            UIColor *endColor = [attrs colorFromIDLValueForKey:@"endColor"];
            if (centerColor != nil) {
                self.internalConstantState.colors = @[startColor?startColor:[UIColor blackColor], centerColor, endColor?endColor:[UIColor blackColor]];
            } else {
                self.internalConstantState.colors = @[startColor?startColor:[UIColor blackColor], endColor?endColor:[UIColor blackColor]];
            }
        } else if ([name isEqualToString:@"padding"]) {
            attrs = [TBXML attributesFromXMLElement:child reuseDictionary:attrs];
            UIEdgeInsets padding = UIEdgeInsetsZero;
            padding.left = [[attrs objectForKey:@"left"] floatValue];
            padding.top = [[attrs objectForKey:@"top"] floatValue];
            padding.right = [[attrs objectForKey:@"right"] floatValue];
            padding.bottom = [[attrs objectForKey:@"bottom"] floatValue];
            self.internalConstantState.padding = padding;
            self.internalConstantState.hasPadding = TRUE;
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
            self.internalConstantState.corners = radius;
        } else if ([name isEqualToString:@"solid"]) {
            attrs = [TBXML attributesFromXMLElement:child reuseDictionary:attrs];
            UIColor *color = [attrs colorFromIDLValueForKey:@"color"];
            if (color == nil) {
                color = [UIColor blackColor];
            }
            self.internalConstantState.colors = @[color];
        } else if ([name isEqualToString:@"size"]) {
            attrs = [TBXML attributesFromXMLElement:child reuseDictionary:attrs];
            CGSize size = CGSizeZero;
            size.width = [attrs dimensionFromIDLValueForKey:@"width" defaultValue:-1.f];
            size.height = [attrs dimensionFromIDLValueForKey:@"height" defaultValue:-1.f];
            self.internalConstantState.size = size;
        } else if ([name isEqualToString:@"stroke"]) {
            attrs = [TBXML attributesFromXMLElement:child reuseDictionary:attrs];
            self.internalConstantState.strokeWidth = [attrs dimensionFromIDLValueForKey:@"width"];
            self.internalConstantState.strokeColor = [attrs colorFromIDLValueForKey:@"color"];
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
