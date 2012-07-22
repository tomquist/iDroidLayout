//
//  RelativeLayout.h
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLViewGroup.h"
#import "IDLGravity.h"
#import "IDLDependencyGraph.h"
#import "IDLRelativeLayoutLayoutParams.h"

@interface IDLRelativeLayout : IDLViewGroup {
    IDLViewContentGravity _gravity;
    NSString *_ignoreGravity;
    NSMutableArray *_sortedVerticalChildren;
    NSMutableArray *_sortedHorizontalChildren;
    IDLDependencyGraph *_graph;
    UIView *_baselineView;
    CGRect _selfBounds;
    CGRect _contentBounds;
    
    BOOL _dirtyHierarchy;
    BOOL _hasBaselineAlignedChild;
}

@property (nonatomic, assign) IDLViewContentGravity gravity;
@property (nonatomic, copy) NSString *ignoreGravity;

@end
