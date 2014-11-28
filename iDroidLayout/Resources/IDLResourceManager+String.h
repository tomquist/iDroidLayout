//
//  IDLResourceManager+String.h
//  iDroidLayout
//
//  Created by Tom Quist on 08.11.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//

#import "IDLResourceManager+Core.h"

@interface IDLResourceManager (String)

- (NSString *)stringForIdentifier:(NSString *)identifierString;

- (NSArray *)stringArrayForIdentifier:(NSString *)identifierString;

@end
