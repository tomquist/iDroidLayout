//
//  FinitePool.m
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLFinitePool.h"

@implementation IDLFinitePool

- (void)dealloc {
	[_manager release];
    [_root release];
	[super dealloc];
}


- (id)initWithPoolableManager:(id<IDLPoolableManager>)manager {
	self = [super init];
	if (self != nil) {
		_manager = [manager retain];
        _limit = 0;
        _infinite = TRUE;
	}
	return self;
}

- (id)initWithPoolableManager:(id<IDLPoolableManager>)manager limit:(NSUInteger)limit {
    self = [super init];
    if (self) {
        _manager = [manager retain];
        _limit = limit;
        _infinite = (limit == 0);
    }
    return self;
}

- (id<IDLPoolable>)acquire {
    id<IDLPoolable> element;
    if (_root != nil) {
        element = [[_root retain] autorelease];
        [_root release];
        _root = [element.nextPoolable retain];
        _poolCount--;
    } else {
        element = _manager.newInstance;
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
        [_root release];
        _root = [element retain];
    }
    [_manager onReleasedElement:element];
}


@end
