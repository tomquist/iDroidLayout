//
//  FinitePool.m
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLFinitePool.h"

@implementation IDLFinitePool {
    NSUInteger _limit;
    BOOL _infinite;
    NSUInteger _poolCount;
    
    id<IDLPoolableManager> _manager;
    id<IDLPoolable> _root;
}

- (instancetype)initWithPoolableManager:(id<IDLPoolableManager>)manager {
	self = [super init];
	if (self != nil) {
		_manager = manager;
        _limit = 0;
        _infinite = TRUE;
	}
	return self;
}

- (instancetype)initWithPoolableManager:(id<IDLPoolableManager>)manager limit:(NSUInteger)limit {
    self = [super init];
    if (self) {
        _manager = manager;
        _limit = limit;
        _infinite = (limit == 0);
    }
    return self;
}

- (id<IDLPoolable>)acquire {
    id<IDLPoolable> element;
    if (_root != nil) {
        element = _root;
        _root = element.nextPoolable;
        _poolCount--;
    } else {
        element = [_manager newInstance];
    }
    
    if (element != nil) {
        element.nextPoolable = nil;
        [_manager onAcquiredElement:element];
    }
    
    return element;
}


- (void)releaseElement:(id<IDLPoolable>)element {
    if (_infinite || _poolCount < _limit) {
        _poolCount++;
        element.nextPoolable = _root;
        _root = element;
    }
    [_manager onReleasedElement:element];
}


@end
