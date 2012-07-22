//
//  LayoutBridge.m
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLLayoutBridge.h"
#import "UIView+IDL_Layout.h"

@implementation IDLLayoutBridge

@synthesize resizeOnKeyboard = _resizeOnKeyboard;

- (void)dealloc {
	if (_resizeOnKeyboard) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
	[super dealloc];
}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)addSubview:(UIView *)view {
    [view retain];
    for (UIView *subviews in [self subviews]) {
        [subviews removeFromSuperview];
    }
    [super addSubview:view];
    [view release];
}

- (void)onLayoutWithFrame:(CGRect)frame didFrameChange:(BOOL)changed {
    UIView *firstChild = [self.subviews lastObject];
    if (firstChild != nil) {
        [firstChild layoutWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    }
}

- (void)onMeasureWithWidthMeasureSpec:(IDLLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(IDLLayoutMeasureSpec)heightMeasureSpec {
    [self measureChildrenWithWidthMeasureSpec:widthMeasureSpec heightMeasureSpec:heightMeasureSpec];
}

- (IDLLayoutParams *)generateDefaultLayoutParams {
    IDLLayoutParams *lp = [super generateDefaultLayoutParams];
    lp.width = IDLLayoutParamsSizeMatchParent;
    lp.height = IDLLayoutParamsSizeMatchParent;
    return lp;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!CGRectEqualToRect(self.frame, _lastFrame) || self.isLayoutRequested) {
        NSDate *methodStart = [NSDate date];
        _lastFrame = self.frame;
        IDLLayoutMeasureSpec widthMeasureSpec;
        IDLLayoutMeasureSpec heightMeasureSpec;
        widthMeasureSpec.size = self.frame.size.width;
        heightMeasureSpec.size = self.frame.size.height;
        widthMeasureSpec.mode = IDLLayoutMeasureSpecModeExactly;
        heightMeasureSpec.mode = IDLLayoutMeasureSpecModeExactly;
        [self measureWithWidthMeasureSpec:widthMeasureSpec heightMeasureSpec:heightMeasureSpec];
        [self layoutWithFrame:self.frame];
        NSDate *methodFinish = [NSDate date];
        NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
        NSLog(@"Relayout took %.2fms", executionTime*1000);
    }
}

- (void)willShowKeyboard:(NSNotification *)notification {
    CGRect keyboardFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect kbLocalFrame = [self convertRect:keyboardFrame fromView:self.window];
    NSLog(@"Show: %@", NSStringFromCGRect(kbLocalFrame));
    CGRect f = self.frame;
    f.size.height = kbLocalFrame.origin.y;
    self.frame = f;
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutSubviews];
    }];
}

- (void)willHideKeyboard:(NSNotification *)notification {
    CGRect keyboardFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect kbLocalFrame = [self convertRect:keyboardFrame fromView:self.window];
    NSLog(@"Hide: %@", NSStringFromCGRect(kbLocalFrame));
    CGRect f = self.frame;
    f.size.height = kbLocalFrame.origin.y;
    self.frame = f;
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutSubviews];
    }];
}

- (void)setResizeOnKeyboard:(BOOL)resizeOnKeyboard {
    if (resizeOnKeyboard && !_resizeOnKeyboard) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowKeyboard:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    } else if (!resizeOnKeyboard && _resizeOnKeyboard) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
    _resizeOnKeyboard = resizeOnKeyboard;
}

@end
