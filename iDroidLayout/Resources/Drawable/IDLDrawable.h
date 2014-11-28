//
//  IDLDrawable.h
//  iDroidLayout
//
//  Created by Tom Quist on 16.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

FOUNDATION_EXPORT NSUInteger const IDLDrawableMaxLevel;

@class IDLDrawableConstantState;
@protocol IDLDrawableDelegate;

@interface IDLDrawable : NSObject <NSCopying>

@property (nonatomic, readonly) CGSize minimumSize;
@property (nonatomic, readonly) CGSize intrinsicSize;
@property (nonatomic, assign) UIControlState state;
@property (nonatomic, assign) CGRect bounds;
@property (nonatomic, readonly) NSUInteger level;

@property (nonatomic, readonly) IDLDrawable *currentDrawable;
@property (nonatomic, readonly, getter = isStateful) BOOL stateful;
@property (nonatomic, readonly) BOOL hasPadding;
@property (nonatomic, readonly) UIEdgeInsets padding;
@property (nonatomic, readonly) IDLDrawableConstantState *constantState;

@property (nonatomic, weak) id<IDLDrawableDelegate> delegate;

- (void)drawInContext:(CGContextRef)context;

- (UIImage *)renderToImage;
- (BOOL)setLevel:(NSUInteger)level;

+ (IDLDrawable *)createFromXMLData:(NSData *)data;
+ (IDLDrawable *)createFromXMLURL:(NSURL *)url;

@end

@interface IDLDrawableConstantState : NSObject

@end

@protocol IDLDrawableDelegate <NSObject>
@required
- (void)drawableDidInvalidate:(IDLDrawable *)drawable;

@end