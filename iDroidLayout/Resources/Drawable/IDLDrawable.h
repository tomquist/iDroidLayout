//
//  IDLDrawable.h
//  iDroidLayout
//
//  Created by Tom Quist on 16.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface IDLDrawable : NSObject

@property (nonatomic, readonly) CGSize minimumSize;
@property (nonatomic, readonly) CGSize intrinsicSize;
@property (nonatomic, assign) UIControlState state;
@property (nonatomic, readonly) IDLDrawable *currentDrawable;
@property (nonatomic, readonly, getter = isStateful) BOOL stateful;
@property (nonatomic, readonly) BOOL hasPadding;
@property (nonatomic, readonly) UIEdgeInsets padding;

- (void)drawOnLayer:(CALayer *)layer;

- (void)onStateChanged;

- (UIImage *)renderToImageOfSize:(CGSize)imageSize;

+ (IDLDrawable *)createFromXMLData:(NSData *)data;
+ (IDLDrawable *)createFromXMLURL:(NSURL *)url;

@end
