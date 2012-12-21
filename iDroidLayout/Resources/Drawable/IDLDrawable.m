//
//  IDLDrawable.m
//  iDroidLayout
//
//  Created by Tom Quist on 16.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLDrawable.h"
#import "TBXML.h"
#import "IDLStateListDrawable.h"
#import "IDLLayerDrawable.h"
#import "IDLColorDrawable.h"
#import "IDLInsetDrawable.h"
#import "IDLBitmapDrawable.h"
#import "IDLNinePatchDrawable.h"

@implementation IDLDrawable

@synthesize state = _state;

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"state"];
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        [self addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self && [keyPath isEqualToString:@"state"]) {
        [self onStateChanged];
    }
}

- (void)onStateChanged {
    
}

- (CGSize)intrinsicSize {
    return CGSizeMake(-1, -1);
}

- (CGSize)minimumSize {
    CGSize size = self.intrinsicSize;
    size.width = MAX(size.width, 0);
    size.height = MAX(size.height, 0);
    return size;
}

- (void)drawOnLayer:(CALayer *)layer {
    
}

- (BOOL)isStateful {
    return FALSE;
}

- (UIImage *)renderToImageOfSize:(CGSize)imageSize {
    CALayer *layer = [[CALayer alloc] init];
    layer.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
    [self drawOnLayer:layer];
    UIGraphicsBeginImageContext(layer.bounds.size);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [layer release];
    return image;
}

- (void)inflateWithElement:(TBXMLElement *)element {
    
}

- (BOOL)hasPadding {
    return FALSE;
}

- (UIEdgeInsets)padding {
    return UIEdgeInsetsZero;
}

+ (IDLDrawable *)createFromXMLElement:(TBXMLElement *)element {
    IDLDrawable *drawable = nil;
    NSString *tagName = [TBXML elementName:element];
    if ([tagName isEqualToString:@"selector"]) {
        drawable = [[IDLStateListDrawable alloc] init];
    } else if ([tagName isEqualToString:@"layer-list"]) {
        drawable = [[IDLLayerDrawable alloc] init];
    } else if ([tagName isEqualToString:@"color"]) {
        drawable = [[IDLColorDrawable alloc] init];
    } else if ([tagName isEqualToString:@"bitmap"]) {
        drawable = [[IDLBitmapDrawable alloc] init];
    } else if ([tagName isEqualToString:@"inset"]) {
        drawable = [[IDLInsetDrawable alloc] init];
    } else if ([tagName isEqualToString:@"nine-patch"]) {
        drawable = [[IDLNinePatchDrawable alloc] init];
    }
    [drawable inflateWithElement:element];
    return [drawable autorelease];
}

+ (IDLDrawable *)createFromXMLData:(NSData *)data {
    if (data == nil) return nil;
    IDLDrawable *ret = nil;
    NSError *error = nil;
    TBXML *xml = [[TBXML newTBXMLWithXMLData:data error:&error] autorelease];
    if (error == nil) {
        ret = [self createFromXMLElement:xml.rootXMLElement];
    } else {
        NSLog(@"Could not parse drawable: %@", error);
    }
    return ret;
}

+ (IDLDrawable *)createFromXMLURL:(NSURL *)url {
    IDLDrawable *drawable = [self createFromXMLData:[NSData dataWithContentsOfURL:url]];
    if (drawable == nil) {
        NSLog(@"Drawable-Filepath: %@", [url absoluteString]);
    }
    return drawable;
}


@end
