//
//  DependencyGraph.h
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface IDLDependencyGraph : NSObject {
    NSMutableArray *_nodes;
    NSMutableDictionary *_keyNodes;
    NSMutableArray *_roots;
}

@property (nonatomic, readonly) NSMutableDictionary *keyNodes;

- (void)clear;
- (void)addView:(UIView *)view;
- (void)getSortedViews:(NSMutableArray *)sorted forRules:(NSArray *)rules;

@end
