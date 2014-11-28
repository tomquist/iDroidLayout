//
//  IDLStringArray.m
//  iDroidLayout
//
//  Created by Tom Quist on 15.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLStringArray.h"
#import "IDLResourceManager.h"

@interface IDLStringArray ()

@property (nonatomic, strong) NSMutableArray *content;
@property (nonatomic, assign) CFMutableBitVectorRef resolvedInfo;

@end

@implementation IDLStringArray

- (void)dealloc {
    CFRelease(_resolvedInfo);
}

- (instancetype)initWithArray:(NSArray *)array {
    self = [super init];
    if (self) {
        self.content = [array mutableCopy];
        _resolvedInfo = CFBitVectorCreateMutable(CFAllocatorGetDefault(), [array count]);
        CFBitVectorSetCount(_resolvedInfo, [array count]);
    }
    return self;
}

- (NSUInteger)count {
    return  [self.content count];
}

- (id)objectAtIndex:(NSUInteger)index {
    id value = [self.content objectAtIndex:index];
    if (value == [NSNull null]) {
        value = nil;
    }
    if (!CFBitVectorGetBitAtIndex(_resolvedInfo, index)) {
        IDLResourceManager *resMgr = [IDLResourceManager currentResourceManager];
        if ([resMgr isValidIdentifier:value]) {
            value = [resMgr stringForIdentifier:value];
            if (value == nil) {
                [self.content replaceObjectAtIndex:index withObject:[NSNull null]];
            } else {
                [self.content replaceObjectAtIndex:index withObject:value];
            }
        }
        CFBitVectorFlipBitAtIndex(_resolvedInfo, index);
    }
    return value;
}

@end
