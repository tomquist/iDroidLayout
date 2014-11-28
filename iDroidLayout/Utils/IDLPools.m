//
//  Pools.m
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLPools.h"
#import "IDLFinitePool.h"
#import "IDLSynchronizedPool.h"

@implementation IDLPools

+ (id<IDLPool>)simplePoolForPoolableManager:(id<IDLPoolableManager>)poolableManager {
    return [[IDLFinitePool alloc] initWithPoolableManager:poolableManager];
}

+ (id<IDLPool>)finitePoolWithLimit:(NSUInteger)limit forPoolableManager:(id<IDLPoolableManager>)poolableManager {
    return [[IDLFinitePool alloc] initWithPoolableManager:poolableManager limit:limit];
}

+ (id<IDLPool>)synchronizedPoolForPool:(id<IDLPool>)pool {
    return [[IDLSynchronizedPool alloc] initWithPool:pool];
}

+ (id<IDLPool>)synchronizedPoolForPool:(id<IDLPool>)pool withLock:(id)lock takeLockOwnership:(BOOL)takeLockOwnership {
    return [[IDLSynchronizedPool alloc] initWithPool:pool lock:lock takeLockOwnership:takeLockOwnership];
}

@end
