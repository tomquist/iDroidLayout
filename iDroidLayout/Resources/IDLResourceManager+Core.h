//
//  IDLResourceManager+Core.h
//  iDroidLayout
//
//  Created by Tom Quist on 08.11.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IDLColorStateList;
@class IDLStyle;

@interface IDLResourceManager : NSObject

+ (instancetype)currentResourceManager;

- (BOOL)isValidIdentifier:(NSString *)identifier;
- (BOOL)invalidateCacheForBundle:(NSBundle *)bundle;

- (NSURL *)layoutURLForIdentifier:(NSString *)identifierString;
- (UIImage *)imageForIdentifier:(NSString *)identifierString withCaching:(BOOL)withCaching;
- (UIImage *)imageForIdentifier:(NSString *)identifierString;
- (UIColor *)colorForIdentifier:(NSString *)identifierString;
- (IDLColorStateList *)colorStateListForIdentifier:(NSString *)identifierString;
- (IDLStyle *)styleForIdentifier:(NSString *)identifierString;

/**
 * Changes the currently used resource manager. This can be used to change
 * the behaviour of resource resolution.
 */
+ (void)setCurrentResourceManager:(IDLResourceManager *)resourceManager;
+ (void)resetCurrentResourceManager;

@end
