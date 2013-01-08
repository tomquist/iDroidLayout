//
//  IDLClipDrawable.h
//  iDroidLayout
//
//  Created by Tom Quist on 07.01.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//

#import <iDroidLayout/iDroidLayout.h>

typedef enum IDLClipDrawableOrientation {
    IDLClipDrawableOrientationNone = 0,
    IDLClipDrawableOrientationHorizontal = 1,
    IDLClipDrawableOrientationVertical = 2
} IDLClipDrawableOrientation;

@interface IDLClipDrawable : IDLDrawable <IDLDrawableDelegate>

@end

@interface IDLClipDrawableConstantState : IDLDrawableConstantState

@end
