//
//  DependencyGraphNode.h
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "IDLPoolable.h"

@interface IDLDependencyGraphNode : NSObject<IDLPoolable> {
    UIView *_view;
    NSMutableSet *_dependents;
    NSMutableDictionary *_dependencies;
    
    IDLDependencyGraphNode *_next;
    BOOL _isPooled;
}

@property (nonatomic, strong) UIView *view;
@property (nonatomic, readonly) NSMutableSet *dependents;
@property (nonatomic, readonly) NSMutableDictionary *dependencies;

- (void)releaseNode;
+ (IDLDependencyGraphNode *)acquireView:(UIView *)view;

@end
