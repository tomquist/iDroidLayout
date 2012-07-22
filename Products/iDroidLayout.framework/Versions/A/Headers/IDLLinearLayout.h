//
//  LinearLayout.h
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLViewGroup.h"
#import "IDLLinearLayoutLayoutParams.h"
#import "IDLGravity.h"

#define MAX_ASCENT_DESCENT_INDEX_CENTER_VERTICAL 0
#define MAX_ASCENT_DESCENT_INDEX_TOP 1
#define MAX_ASCENT_DESCENT_INDEX_BOTTOM 2
#define MAX_ASCENT_DESCENT_INDEX_FILL 3
#define VERTICAL_GRAVITY_COUNT 4

typedef enum LinearLayoutOrientation {
    LinearLayoutOrientationHorizontal,
    LinearLayoutOrientationVertical
} LinearLayoutOrientation;

@interface IDLLinearLayout : IDLViewGroup {
    LinearLayoutOrientation _orientation;
    IDLViewContentGravity _gravity;
    CGFloat _totalLength;
    
    /**
     * Whether the children of this layout are baseline aligned.  Only applicable
     * if _orientation is horizontal.
     */
    BOOL _baselineAligned;
    int _maxAscent[VERTICAL_GRAVITY_COUNT];
    int _maxDescent[VERTICAL_GRAVITY_COUNT];
    NSInteger _baselineAlignedChildIndex;
    CGFloat _baselineChildTop;
    BOOL _useLargestChild;
    float _weightSum;
}

@property (nonatomic, assign) LinearLayoutOrientation orientation;
@property (nonatomic, assign) IDLViewContentGravity gravity;
@property (nonatomic, assign) float weightSum;

@end
