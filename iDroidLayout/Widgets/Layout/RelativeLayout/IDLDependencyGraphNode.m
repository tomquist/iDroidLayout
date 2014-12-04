//
//  DependencyGraphNode.m
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLDependencyGraphNode.h"
#import "IDLPools.h"

#define POOL_LIMIT 100

@interface IDLSimplePoolableManager : NSObject<IDLPoolableManager> {
    Class _class;
}

@end

@implementation IDLSimplePoolableManager

- (instancetype)initWithClass:(Class)class {
    self = [super init];
    if (self) {
        _class = class;
    }
    return self;
}

- (id<IDLPoolable>)newInstance {
    return [[_class alloc] init];
}

- (void)onAcquiredElement:(id<IDLPoolable>)element {
    
}

- (void)onReleasedElement:(id<IDLPoolable>)element {
    
}

@end

@implementation IDLDependencyGraphNode

@synthesize nextPoolable = _next;
@synthesize isPooled = _isPooled;
@synthesize view = _view;
@synthesize dependents = _dependents;
@synthesize dependencies = _dependencies;

+ (id<IDLPool>)pool {
    static id<IDLPool> Pool;
    if (Pool == nil) {
        id<IDLPoolableManager> poolableManager = [[IDLSimplePoolableManager alloc] initWithClass:[IDLDependencyGraphNode class]];
        Pool = [IDLPools synchronizedPoolForPool:[IDLPools finitePoolWithLimit:POOL_LIMIT forPoolableManager:poolableManager]];
    }
    return Pool;
}



- (instancetype) init {
	self = [super init]; 
	if (self != nil) {
        _dependents = [[NSMutableSet alloc] init];
        _dependencies = [[NSMutableDictionary alloc] init];
	}
	return self;
}

+ (IDLDependencyGraphNode *)acquireView:(UIView *)view {
    IDLDependencyGraphNode *node = [[IDLDependencyGraphNode pool] acquire];
    node.view = view;
    return node;
}

- (void)releaseNode {
    self.view = nil;
    [_dependents removeAllObjects];
    [_dependencies removeAllObjects];
    [[IDLDependencyGraphNode pool] releaseElement:self];
}

@end
