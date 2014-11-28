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

@interface IDLFinitePool : NSObject <IDLPool> {
    NSUInteger _limit;
    BOOL _infinite;
    NSUInteger _poolCount;
    
    id<IDLPoolableManager> _manager;
    id<IDLPoolable> _root;
}

- (instancetype)initWithPoolableManager:(id<IDLPoolableManager>)manager;
- (instancetype)initWithPoolableManager:(id<IDLPoolableManager>)manager limit:(NSUInteger)limit;

@end
