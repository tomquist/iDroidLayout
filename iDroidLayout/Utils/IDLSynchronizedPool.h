//
//  SynchronizedPool.h
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDLPool.h"

@interface IDLSynchronizedPool : NSObject <IDLPool> {
    BOOL _hasBlockOwnership;
    id<IDLPool> _pool;
    id _lock;
}

- (instancetype)initWithPool:(id<IDLPool>)pool lock:(id)lock takeLockOwnership:(BOOL)takeLockOwnership;
- (instancetype)initWithPool:(id<IDLPool>)pool;

@end
