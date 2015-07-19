//
//  LayoutBridge.m
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLLayoutBridge.h"
#import "UIView+IDL_Layout.h"
#import "IDLMarginLayoutParams.h"
#import "IDLLayoutInflater.h"
#import "IDLLayoutBridgeLayoutParams.h"

@implementation UIView (IDLLayoutBridge)

- (UIView *)findAndScrollToFirstResponder {
    UIView *ret = nil;
    if (self.isFirstResponder) {
        ret = self;
    }
    for (UIView *subView in self.subviews) {
        UIView *firstResponder = [subView findAndScrollToFirstResponder];
        if (firstResponder) {
            if ([self isKindOfClass:[UIScrollView class]]) {
                UIScrollView *sv = (UIScrollView *)self;
                CGRect r = [self convertRect:firstResponder.frame fromView:firstResponder];
                [sv scrollRectToVisible:r animated:FALSE];
                ret = self;
            } else {
                ret = firstResponder;
            }
            break;
        }
    }
    return ret;
}

@end

@implementation IDLLayoutBridge {
    CGRect _lastFrame;
    BOOL _resizeOnKeyboard;
    BOOL _scrollToTextField;
}

@synthesize resizeOnKeyboard = _resizeOnKeyboard;
@synthesize scrollToTextField = _scrollToTextField;

- (void)dealloc {
	if (_resizeOnKeyboard) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
    if (_scrollToTextField) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
        [center removeObserver:self name:UITextFieldTextDidEndEditingNotification object:nil];
        [center removeObserver:self name:UITextViewTextDidBeginEditingNotification object:nil];
        [center removeObserver:self name:UITextViewTextDidEndEditingNotification object:nil];
    }
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    UIView *lastChild = self.subviews.lastObject;
    IDLMarginLayoutParams *layoutParams = (IDLMarginLayoutParams *)lastChild.layoutParams;
    IDLLayoutMeasureSpec widthSpec;
    IDLLayoutMeasureSpec heightSpec;
    widthSpec.mode = IDLLayoutMeasureSpecModeUnspecified;
    widthSpec.size = size.width;
    heightSpec.mode = IDLLayoutMeasureSpecModeUnspecified;
    heightSpec.size = size.height;
    if (layoutParams.width == IDLLayoutParamsSizeMatchParent) {
        widthSpec.mode = IDLLayoutMeasureSpecModeExactly;
    }
    if (layoutParams.height == IDLLayoutParamsSizeMatchParent) {
        heightSpec.mode = IDLLayoutMeasureSpecModeExactly;
    }
    [self onMeasureWithWidthMeasureSpec:widthSpec heightMeasureSpec:heightSpec];
    return self.measuredSize;
}

- (void)addSubview:(UIView *)view {
    for (UIView *subviews in [self subviews]) {
        [subviews removeFromSuperview];
    }
    [super addSubview:view];
}

- (void)onLayoutWithFrame:(CGRect)frame didFrameChange:(BOOL)changed {
    UIView *firstChild = [self.subviews lastObject];
    if (firstChild != nil) {
        CGSize size = firstChild.measuredSize;
        IDLMarginLayoutParams *lp = (IDLMarginLayoutParams *)firstChild.layoutParams;
        UIEdgeInsets margin = lp.margin;
        [firstChild layoutWithFrame:CGRectMake(margin.left, margin.top, size.width, size.height)];
    }
}

- (void)onMeasureWithWidthMeasureSpec:(IDLLayoutMeasureSpec)widthMeasureSpec heightMeasureSpec:(IDLLayoutMeasureSpec)heightMeasureSpec {
    CGSize lastChildSize = CGSizeZero;
    UIView *lastChild = self.subviews.lastObject;
    if (lastChild.visibility != IDLViewVisibilityGone)
    {
        [self measureChildWithMargins:lastChild parentWidthMeasureSpec:widthMeasureSpec widthUsed:0 parentHeightMeasureSpec:heightMeasureSpec heightUsed:0];
        lastChildSize = lastChild.measuredSize;
        IDLLayoutParams *layoutParams = lastChild.layoutParams;
        if ([layoutParams isKindOfClass:[IDLMarginLayoutParams class]])
        {
            IDLMarginLayoutParams *marginParams = (IDLMarginLayoutParams *)layoutParams;
            lastChildSize.width += marginParams.margin.left + marginParams.margin.right;
            lastChildSize.height += marginParams.margin.top + marginParams.margin.bottom;
        }
    }
    IDLLayoutMeasuredDimension width;
    IDLLayoutMeasuredDimension height;
    width.state = IDLLayoutMeasuredStateNone;
    height.state = IDLLayoutMeasuredStateNone;
    UIEdgeInsets padding = self.padding;
    width.size = lastChildSize.width + padding.left + padding.right;
    height.size = lastChildSize.height + padding.top + padding.bottom;
    [self setMeasuredDimensionSize:IDLLayoutMeasuredSizeMake(width, height)];
}

- (IDLLayoutParams *)generateDefaultLayoutParams {
    IDLLayoutBridgeLayoutParams *lp = [[IDLLayoutBridgeLayoutParams alloc] initWithWidth:IDLLayoutParamsSizeMatchParent height:IDLLayoutParamsSizeMatchParent];
    lp.width = IDLLayoutParamsSizeMatchParent;
    lp.height = IDLLayoutParamsSizeMatchParent;
    return lp;
}

-(IDLLayoutParams *)generateLayoutParamsFromLayoutParams:(IDLLayoutParams *)layoutParams {
    return [[IDLLayoutBridgeLayoutParams alloc] initWithLayoutParams:layoutParams];
}

- (IDLLayoutParams *)generateLayoutParamsFromAttributes:(NSDictionary *)attrs {
    return [[IDLLayoutBridgeLayoutParams alloc] initWithAttributes:attrs];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!CGRectEqualToRect(self.frame, _lastFrame) || self.isLayoutRequested) {
#ifdef DEBUG
        CFTimeInterval methodStart = CACurrentMediaTime();
#endif
        _lastFrame = self.frame;
        IDLLayoutMeasureSpec widthMeasureSpec;
        IDLLayoutMeasureSpec heightMeasureSpec;
        widthMeasureSpec.size = self.frame.size.width;
        heightMeasureSpec.size = self.frame.size.height;
        widthMeasureSpec.mode = IDLLayoutMeasureSpecModeExactly;
        heightMeasureSpec.mode = IDLLayoutMeasureSpecModeExactly;
        [self measureWithWidthMeasureSpec:widthMeasureSpec heightMeasureSpec:heightMeasureSpec];
        [self layoutWithFrame:self.frame];
#ifdef DEBUG
        NSTimeInterval methodFinish = CACurrentMediaTime();
        NSTimeInterval executionTime = methodFinish - methodStart;
        NSLog(@"Relayout took %.2fms", executionTime*1000);
#endif
    }
}

- (void)willShowKeyboard:(NSNotification *)notification {
    CGRect keyboardFrame = [(notification.userInfo)[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect kbLocalFrame = [self convertRect:keyboardFrame fromView:self.window];
    NSLog(@"Show: %@", NSStringFromCGRect(kbLocalFrame));
    CGRect f = self.frame;
    f.size.height = kbLocalFrame.origin.y;
    self.frame = f;
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        [self layoutIfNeeded];
        
    }];
}

- (void)didShowKeyboard:(NSNotification *)notification {

}

- (void)willHideKeyboard:(NSNotification *)notification {
    CGRect keyboardFrame = [(notification.userInfo)[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect kbLocalFrame = [self convertRect:keyboardFrame fromView:self.window];
    NSLog(@"Hide: %@", NSStringFromCGRect(kbLocalFrame));
    CGRect f = self.frame;
    f.size.height = kbLocalFrame.origin.y;
    self.frame = f;
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)didBeginEditing:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        [self findAndScrollToFirstResponder];        
    }];
}

- (void)didEndEditing:(NSNotification *)notification {
    
}

- (void)setScrollToTextField:(BOOL)scrollToTextField {
    if (scrollToTextField && !_scrollToTextField) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(didBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
        [center addObserver:self selector:@selector(didEndEditing:) name:UITextFieldTextDidEndEditingNotification object:nil];
        [center addObserver:self selector:@selector(didBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
        [center addObserver:self selector:@selector(didEndEditing:) name:UITextViewTextDidEndEditingNotification object:nil];
    } else if (!scrollToTextField && _scrollToTextField) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self name:UITextFieldTextDidBeginEditingNotification object:nil];
        [center removeObserver:self name:UITextFieldTextDidEndEditingNotification object:nil];
        [center removeObserver:self name:UITextViewTextDidBeginEditingNotification object:nil];
        [center removeObserver:self name:UITextViewTextDidEndEditingNotification object:nil];
    }
    _scrollToTextField = scrollToTextField;
}

- (void)setResizeOnKeyboard:(BOOL)resizeOnKeyboard {
    if (resizeOnKeyboard && !_resizeOnKeyboard) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(willShowKeyboard:) name:UIKeyboardWillShowNotification object:nil];
        [center addObserver:self selector:@selector(didShowKeyboard:) name:UIKeyboardDidShowNotification object:nil];
        [center addObserver:self selector:@selector(willHideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    } else if (!resizeOnKeyboard && _resizeOnKeyboard) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [center removeObserver:self name:UIKeyboardDidShowNotification object:nil];
        [center removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
    _resizeOnKeyboard = resizeOnKeyboard;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"layout"]) {
        NSString *pathExtension = [value pathExtension];
        if ([pathExtension length] == 0) {
            pathExtension = @"xml";
        }
        NSURL *url = [[NSBundle mainBundle] URLForResource:[value stringByDeletingPathExtension] withExtension:pathExtension];
        if (url != nil) {
            IDLLayoutInflater *inflater = [[IDLLayoutInflater alloc] init];
            [inflater inflateURL:url intoRootView:self attachToRoot:TRUE];
        }
    } else {
        [super setValue:value forUndefinedKey:key];
    }
}

@end
