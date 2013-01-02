//
//  NSObject+IDL_KVOObserver.m
//  iDroidLayout
//
//  Created by Tom Quist on 21.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "NSObject+IDL_KVOObserver.h"
#import <objc/runtime.h>

@interface IDLKVOObserver : NSObject

@property (readwrite, retain) NSString *identifier;
@property (readwrite, copy) IDLKVOObserverBlock observerBlock;
@property (readwrite, assign) id object;
@property (readwrite, retain) NSArray *keyPaths;

@end

@implementation IDLKVOObserver

@synthesize identifier = _identifier;
@synthesize observerBlock = _observerBlock;
@synthesize keyPaths = _keyPaths;
@synthesize object = _object;

- (void)dealloc {
    for (NSString *keyPath in self.keyPaths) {
        [self.object removeObserver:self forKeyPath:keyPath];
    }
    self.identifier = nil;
    self.observerBlock = nil;
    self.keyPaths = nil;
    [super dealloc];
}

- (id)initWithIdentifier:(NSString *)identifier object:(id)obj keyPaths:(NSArray *)keyPaths options:(NSKeyValueObservingOptions)options observerBlock:(IDLKVOObserverBlock)block {
    self = [super init];
    if (self) {
        self.identifier = identifier;
        self.object = obj;
        self.keyPaths = keyPaths;
        self.observerBlock = block;
        for (NSString *keyPath in keyPaths) {
            [obj addObserver:self forKeyPath:keyPath options:options context:nil];
        }
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    self.observerBlock(keyPath, object, change);
}

@end


@interface NSObject ()

@property (nonatomic, readonly) NSMutableDictionary *idl_kvoObservers;

@end

@implementation NSObject (IDL_KVOObserver)

static char idl_kvoObserversKey;

- (NSMutableDictionary *)idl_kvoObservers {
    @synchronized(self) {
        NSMutableDictionary *array = objc_getAssociatedObject(self, &idl_kvoObserversKey);
        if (array == nil) {
            array = [[[NSMutableDictionary alloc] init] autorelease];
            objc_setAssociatedObject(self,
                                     &idl_kvoObserversKey,
                                     array,
                                     OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        return array;
    }
}

- (void)idl_removeObserverWithIdentifier:(NSString *)identifier {
    NSMutableDictionary *observers = [self idl_kvoObservers];
    [observers removeObjectForKey:identifier];
}

- (void)idl_addObserver:(IDLKVOObserverBlock)observer withIdentifier:(NSString *)identifier forKeyPaths:(NSArray *)keyPaths options:(NSKeyValueObservingOptions)options {
    IDLKVOObserver *observerObject = [[IDLKVOObserver alloc] initWithIdentifier:identifier object:self keyPaths:keyPaths options:options observerBlock:observer];
    [[self idl_kvoObservers] setObject:observerObject forKey:identifier];
    [observerObject release];
}

- (BOOL)idl_hasObserverWithIdentifier:(NSString *)identifier {
    NSMutableDictionary *observers = [self idl_kvoObservers];
    return [observers objectForKey:identifier] != nil;
}

@end
