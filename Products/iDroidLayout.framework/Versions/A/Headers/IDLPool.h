//
//  IDLPool.h
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDLPoolable.h"

@protocol IDLPool <NSObject>

- (id<IDLPoolable>)acquire;

- (void)releaseElement:(id<IDLPoolable>) element;

@end
