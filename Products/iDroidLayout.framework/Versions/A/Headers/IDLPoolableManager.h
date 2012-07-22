//
//  PoolableManager.h
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDLPoolable.h"

@protocol IDLPoolableManager <NSObject>

- (id<IDLPoolable>)newInstance;

- (void)onAcquiredElement:(id<IDLPoolable>)element;
- (void)onReleasedElement:(id<IDLPoolable>)element;

@end
