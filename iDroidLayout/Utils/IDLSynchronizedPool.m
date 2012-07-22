//
//  SynchronizedPool.m
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLSynchronizedPool.h"

@implementation IDLSynchronizedPool

- (void)dealloc {
	if (_hasBlockOwnership) {
        [_lock release];
    }
    [_pool release];
	[super dealloc];
}

- (id)initWithPool:(id<IDLPool>)pool lock:(id)lock takeLockOwnership:(BOOL)takeLockOwnership {
    self = [super init];
    if (self) {
        _pool = [pool retain];
        if (takeLockOwnership) {
            [lock retain];
        }
        _lock = lock;
        _hasBlockOwnership = takeLockOwnership;
    }
    return self;
}

- (id)initWithPool:(id<IDLPool>)pool {
	self = [self initWithPool:pool lock:self takeLockOwnership:FALSE];
	if (self != nil) {
        
	}
	return self;
}

- (id<IDLPoolable>)acquire {
    @synchronized(_lock) {
        return [_pool acquire];
    }
}

- (void)releaseElement:(id<IDLPoolable>)element {
    @synchronized(_lock) {
        return [_pool releaseElement:element];
    }
}

@end
