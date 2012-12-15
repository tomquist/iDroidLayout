//
//  IDLDrawableStateList.h
//  iDroidLayout
//
//  Created by Tom Quist on 08.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLResourceStateList.h"
#import "IDLDrawableStateItem.h"
#import "IDLColorStateList.h"

@interface IDLDrawableStateList : IDLResourceStateList

- (UIImage *)imageForControlState:(UIControlState)controlState defaultImage:(UIImage *)defaultImage;
- (UIImage *)imageForControlState:(UIControlState)controlState;

+ (IDLDrawableStateList *)createFromXMLData:(NSData *)data;
+ (IDLDrawableStateList *)createFromXMLURL:(NSURL *)url;
+ (IDLDrawableStateList *)createWithSingleDrawableIdentifier:(NSString *)imageIdentifier;
+ (IDLDrawableStateList *)createFromColorStateList:(IDLColorStateList *)colorStateList;

@end
