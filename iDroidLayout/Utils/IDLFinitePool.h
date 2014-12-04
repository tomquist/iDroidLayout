//
//  FinitePool.h
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDLPool.h"
#import "IDLPoolableManager.h"

@interface IDLFinitePool : NSObject <IDLPool>

- (instancetype)initWithPoolableManager:(id<IDLPoolableManager>)manager NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithPoolableManager:(id<IDLPoolableManager>)manager limit:(NSUInteger)limit NS_DESIGNATED_INITIALIZER;

@end
