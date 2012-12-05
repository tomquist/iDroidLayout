//
//  IDLResourceManager.h
//  iDroidLayout
//
//  Created by Tom Quist on 01.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IDLResourceManager : NSObject

+ (IDLResourceManager *)currentResourceManager;

- (BOOL)isValidIdentifier:(NSString *)identifier;
- (NSString *)stringForIdentifier:(NSString *)identifierString;
- (NSURL *)layoutURLForIdentifier:(NSString *)identifierString;
- (UIImage *)imageForIdentifier:(NSString *)identifierString withCaching:(BOOL)withCaching;
- (UIImage *)imageForIdentifier:(NSString *)identifierString;
- (UIColor *)colorForIdentifier:(NSString *)identifierString;

@end
