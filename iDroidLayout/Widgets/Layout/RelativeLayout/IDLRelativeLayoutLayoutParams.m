//
//  RelativeLayoutLayoutParams.m
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLRelativeLayoutLayoutParams.h"
#import "UIView+IDL_Layout.h"

@interface IDLRelativeLayoutLayoutParams ()

@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat bottom;

@end

@implementation IDLRelativeLayoutLayoutParams {
    BOOL _alignParentLeft;
    BOOL _alignParentTop;
    BOOL _alignParentRight;
    BOOL _alignParentBottom;
    BOOL _centerInParent;
    BOOL _centerHorizontal;
    BOOL _centerVertical;
}

@synthesize rules = _rules;
@synthesize left = _left;
@synthesize right = _right;
@synthesize top = _top;
@synthesize bottom = _bottom;
@synthesize alignWithParent = _alignWithParent;


- (instancetype) initWithAttributes:(NSDictionary *)attrs {
	self = [super initWithAttributes:attrs];
	if (self != nil) {
		NSString *leftOf = attrs[@"layout_toLeftOf"];
        NSString *rightOf = attrs[@"layout_toRightOf"];
        NSString *above = attrs[@"layout_above"];
        NSString *below = attrs[@"layout_below"];
        NSString *alignBaseline = attrs[@"layout_alignBaseline"];
        NSString *alignLeft = attrs[@"layout_alignLeft"];
        NSString *alignTop = attrs[@"layout_alignTop"];
        NSString *alignRight = attrs[@"layout_alignRight"];
        NSString *alignBottom = attrs[@"layout_alignBottom"];
        
        _alignParentLeft = BOOLFromString(attrs[@"layout_alignParentLeft"]);
        _alignParentTop = BOOLFromString(attrs[@"layout_alignParentTop"]);
        _alignParentRight = BOOLFromString(attrs[@"layout_alignParentRight"]);
        _alignParentBottom = BOOLFromString(attrs[@"layout_alignParentBottom"]);
        _centerInParent = BOOLFromString(attrs[@"layout_centerInParent"]);
        _centerHorizontal = BOOLFromString(attrs[@"layout_centerHorizontal"]);
        _centerVertical = BOOLFromString(attrs[@"layout_centerVertical"]);
        
        NSNull *null = [NSNull null];
        _rules = @[(leftOf==nil?null:leftOf),
                  (rightOf==nil?null:rightOf),
                  (above==nil?null:above),
                  (below==nil?null:below),
                  (alignBaseline==nil?null:alignBaseline),
                  (alignLeft==nil?null:alignLeft),
                  (alignTop==nil?null:alignTop),
                  (alignRight==nil?null:alignRight),
                  (alignBottom==nil?null:alignBottom),
                  @(_alignParentLeft),
                  @(_alignParentTop),
                  @(_alignParentRight),
                  @(_alignParentBottom),
                  @(_centerInParent),
                  @(_centerHorizontal),
                  @(_centerVertical)];
	}
	return self;
}

@end
