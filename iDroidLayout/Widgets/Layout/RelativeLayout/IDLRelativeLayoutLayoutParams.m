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

@implementation IDLRelativeLayoutLayoutParams

@synthesize rules = _rules;
@synthesize left = _left;
@synthesize right = _right;
@synthesize top = _top;
@synthesize bottom = _bottom;
@synthesize alignWithParent = _alignWithParent;


- (id) initWithAttributes:(NSDictionary *)attrs {
	self = [super initWithAttributes:attrs];
	if (self != nil) {
		NSString *leftOf = [attrs objectForKey:@"layout_toLeftOf"];
        NSString *rightOf = [attrs objectForKey:@"layout_toRightOf"];
        NSString *above = [attrs objectForKey:@"layout_above"];
        NSString *below = [attrs objectForKey:@"layout_below"];
        NSString *alignBaseline = [attrs objectForKey:@"layout_alignBaseline"];
        NSString *alignLeft = [attrs objectForKey:@"layout_alignLeft"];
        NSString *alignTop = [attrs objectForKey:@"layout_alignTop"];
        NSString *alignRight = [attrs objectForKey:@"layout_alignRight"];
        NSString *alignBottom = [attrs objectForKey:@"layout_alignBottom"];
        
        _alignParentLeft = BOOLFromString([attrs objectForKey:@"layout_alignParentLeft"]);
        _alignParentTop = BOOLFromString([attrs objectForKey:@"layout_alignParentTop"]);
        _alignParentRight = BOOLFromString([attrs objectForKey:@"layout_alignParentRight"]);
        _alignParentBottom = BOOLFromString([attrs objectForKey:@"layout_alignParentBottom"]);
        _centerInParent = BOOLFromString([attrs objectForKey:@"layout_centerInParent"]);
        _centerHorizontal = BOOLFromString([attrs objectForKey:@"layout_centerHorizontal"]);
        _centerVertical = BOOLFromString([attrs objectForKey:@"layout_centerVertical"]);
        
        NSNull *null = [NSNull null];
        _rules = [[NSArray alloc] initWithObjects:
                  (leftOf==nil?null:leftOf),
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
                  @(_centerVertical), nil];
	}
	return self;
}

@end
