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

typedef NS_ENUM(NSInteger, LinearLayoutOrientation) {
    LinearLayoutOrientationHorizontal,
    LinearLayoutOrientationVertical
};

@interface IDLLinearLayout : IDLViewGroup

@property (nonatomic, assign) LinearLayoutOrientation orientation;
@property (nonatomic, assign) IDLViewContentGravity gravity;
@property (nonatomic, assign) float weightSum;

@end
