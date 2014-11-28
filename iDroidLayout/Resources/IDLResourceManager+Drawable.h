//
//  IDLResourceManager+Drawable.h
//  iDroidLayout
//
//  Created by Tom Quist on 08.11.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//

#import "IDLResourceManager+Core.h"

@class IDLDrawable;
@class IDLDrawableStateList;

@interface IDLResourceManager (Drawable)

- (IDLDrawableStateList *)drawableStateListForIdentifier:(NSString *)identifierString;
- (IDLDrawable *)drawableForIdentifier:(NSString *)identifier;

@end
