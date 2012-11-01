//
//  RelativeLayoutLayoutParams.m
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLRelativeLayoutLayoutParams.h"

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

- (void) dealloc {
	[_rules release];
	[super dealloc];
}

- (BOOL)parseBoolean:(NSString *)string {
    return [string isEqualToString:@"true"] || [string isEqualToString:@"TRUE"] || [string isEqualToString:@"yes"] || [string isEqualToString:@"YES"] || [string boolValue];
}

- (id) initWithAttributes:(NSDictionary *)attrs {
	self = [super initWithAttributes:attrs];
	if (self != nil) {
		_leftOf = [attrs objectForKey:@"layout_toLeftOf"];
        _rightOf = [attrs objectForKey:@"layout_toRightOf"];
        _above = [attrs objectForKey:@"layout_above"];
        _below = [attrs objectForKey:@"layout_below"];
        _alignBaseline = [attrs objectForKey:@"layout_alignBaseline"];
        _alignLeft = [attrs objectForKey:@"layout_alignLeft"];
        _alignTop = [attrs objectForKey:@"layout_alignTop"];
        _alignRight = [attrs objectForKey:@"layout_alignRight"];
        _alignBottom = [attrs objectForKey:@"layout_alignBottom"];
        
        _alignParentLeft = [self parseBoolean:[attrs objectForKey:@"layout_alignParentLeft"]];
        _alignParentTop = [self parseBoolean:[attrs objectForKey:@"layout_alignParentTop"]];
        _alignParentRight = [self parseBoolean:[attrs objectForKey:@"layout_alignParentRight"]];
        _alignParentBottom = [self parseBoolean:[attrs objectForKey:@"layout_alignParentBottom"]];
        _centerInParent = [self parseBoolean:[attrs objectForKey:@"layout_centerInParent"]];
        _centerHorizontal = [self parseBoolean:[attrs objectForKey:@"layout_centerHorizontal"]];
        _centerVertical = [self parseBoolean:[attrs objectForKey:@"layout_centerVertical"]];
        
        NSNull *null = [NSNull null];
        _rules = [[NSArray alloc] initWithObjects:
                  (_leftOf==nil?null:_leftOf),
                  (_rightOf==nil?null:_rightOf),
                  (_above==nil?null:_above),
                  (_below==nil?null:_below),
                  (_alignBaseline==nil?null:_alignBaseline),
                  (_alignLeft==nil?null:_alignLeft),
                  (_alignTop==nil?null:_alignTop),
                  (_alignRight==nil?null:_alignRight),
                  (_alignBottom==nil?null:_alignBottom),
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
