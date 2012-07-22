//
//  Pools.h
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDLPoolable.h"
#import "IDLPoolableManager.h"
#import "IDLPool.h"

@interface IDLPools : NSObject

+ (id<IDLPool>)simplePoolForPoolableManager:(id<IDLPoolableManager>)poolableManager;
+ (id<IDLPool>)finitePoolWithLimit:(NSUInteger)limit forPoolableManager:(id<IDLPoolableManager>)poolableManager;
+ (id<IDLPool>)synchronizedPoolForPool:(id<IDLPool>)pool;
+ (id<IDLPool>)synchronizedPoolForPool:(id<IDLPool>)pool withLock:(id)lock takeLockOwnership:(BOOL)takeLockOwnership;

@end
