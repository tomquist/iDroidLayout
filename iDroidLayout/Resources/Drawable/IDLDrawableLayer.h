//
//  IDLDrawableLayer.h
//  iDroidLayout
//
//  Created by Tom Quist on 30.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <iDroidLayout/IDLDrawable.h>

@interface IDLDrawableLayer : CALayer <IDLDrawableDelegate>

@property (nonatomic, retain) IDLDrawable *drawable;

@end
