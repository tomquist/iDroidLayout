//
//  FrameLayoutLayoutParams.h
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLMarginLayoutParams.h"
#import "IDLGravity.h"

@interface IDLFrameLayoutLayoutParams : IDLMarginLayoutParams

@property (nonatomic, assign) IDLViewContentGravity gravity;

@end
