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

- (NSString *)stringFromIDLValueForKey:(NSString *)key;
- (UIColor *)colorFromIDLValueForKey:(NSString *)key;
- (IDLColorStateList *)colorStateListFromIDLValueForKey:(NSString *)key;
- (CGFloat)dimensionFromIDLValueForKey:(NSString *)key;
- (CGFloat)dimensionFromIDLValueForKey:(NSString *)key defaultValue:(CGFloat)defaultValue;
- (float)fractionValueFromIDLValueForKey:(NSString *)key;
- (float)fractionValueFromIDLValueForKey:(NSString *)key defaultValue:(CGFloat)defaultValue;
- (BOOL)isFractionIDLValueForKey:(NSString *)key;

@end
