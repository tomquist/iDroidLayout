//
//  NSObject+IDL_KVOObserver.h
//  iDroidLayout
//
//  Created by Tom Quist on 21.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^IDLKVOObserverBlock)(NSString* keyPath, id object, NSDictionary *change);

@interface NSObject (IDL_KVOObserver)

- (void)idl_addObserver:(IDLKVOObserverBlock)observer withIdentifier:(NSString *)identifier forKeyPaths:(NSArray *)keyPaths options:(NSKeyValueObservingOptions)options;
- (void)idl_removeObserverWithIdentifier:(NSString *)identifier;
- (BOOL)idl_hasObserverWithIdentifier:(NSString *)identifier;

@end
