//
//  NSDictionary+IDL_ResourceManager.h
//  iDroidLayout
//
//  Created by Tom Quist on 02.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDLColorStateList.h"

@interface NSDictionary (IDL_ResourceManager)

- (UIColor *)colorFromIDLValueForKey:(NSString *)key;
- (IDLColorStateList *)colorStateListFromIDLValueForKey:(NSString *)key;

@end
