//
//  LayoutInflater.m
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLLayoutInflater.h"
#import "UIView+IDL_Layout.h"
#import "UIView+IDL_ViewGroup.h"
#import "TBXML.h"
#import "IDLLayoutParams.h"
#import "IDLBaseViewFactory.h"

@implementation IDLLayoutInflater

@synthesize viewFactory = _viewFactory;

+ (NSMutableDictionary *)attributesFromXMLElement:(TBXMLElement *)element reuseDictionary:(NSMutableDictionary *)dict {
    if (dict == nil) {
        dict = [NSMutableDictionary dictionaryWithCapacity:20];
    } else {
        [dict removeAllObjects];
    }
    [TBXML iterateAttributesOfElement:element withBlock:^(TBXMLAttribute *attribute, NSString *attributeName, NSString *attributeValue) {
        NSRange prefixRange = [attributeName rangeOfString:@":"];
        if (prefixRange.location != NSNotFound) {
            attributeName = [attributeName substringFromIndex:(prefixRange.location+1)];
        }
        [dict setObject:attributeValue forKey:attributeName];
    }];
    return dict;
}

- (void)dealloc {
    [_viewFactory release];
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        _viewFactory = [[IDLBaseViewFactory alloc] init];
    }
    return self;
}

- (UIView *)createViewFromTag:(NSString *)name withAttributes:(NSDictionary *)attrs intoParentView:(UIView *)parent {
    if ([name isEqualToString:@"view"]) {
        name = [attrs objectForKey:@"class"];
    }
    UIView *ret = nil;
    @try {
        ret = [self.viewFactory onCreateViewWithName:name attributes:attrs];
    }
    @catch (NSException *exception) {
        NSLog(@"Warning!!!!! Class for view with name %@ does not exist. Creating UIView instead.", name);
        ret = [self.viewFactory onCreateViewWithName:@"UIView" attributes:attrs];
    }
    return ret;
}

- (void)rInflateWithXmlElement:(TBXMLElement *)element parentView:(UIView *)parentView attributes:(NSMutableDictionary *)attrs finishInflate:(BOOL)finishInflate {
    do {
        NSString *tagName = [TBXML elementName:element];
        NSMutableDictionary *childAttrs = [IDLLayoutInflater attributesFromXMLElement:element reuseDictionary:attrs];
        UIView *view = [self createViewFromTag:tagName withAttributes:childAttrs intoParentView:parentView];
        IDLLayoutParams *layoutParams = nil;
        if ([parentView respondsToSelector:@selector(generateLayoutParamsFromAttributes:)]) {
            layoutParams = [parentView generateLayoutParamsFromAttributes:attrs];
        } else {
            layoutParams = [parentView generateDefaultLayoutParams];
        }
        view.layoutParams = layoutParams;
        if (element->firstChild != NULL) {
            [self rInflateWithXmlElement:element->firstChild parentView:view attributes:attrs finishInflate:true];
        }
        [parentView addView:view];
    } while ((element = element->nextSibling));
    if (finishInflate) [parentView onFinishInflate];
}

- (UIView *)inflateParser:(TBXML *)parser intoRootView:(UIView *)rootView attachToRoot:(BOOL)attachToRoot {
    TBXMLElement *rootElement = parser.rootXMLElement;
    NSMutableDictionary *attrs = [IDLLayoutInflater attributesFromXMLElement:rootElement reuseDictionary:nil];
    UIView *temp = [self createViewFromTag:[TBXML elementName:rootElement] withAttributes:attrs intoParentView:rootView];
    
    if (rootView != nil) {
        IDLLayoutParams *layoutParams = nil;
        if ([rootView respondsToSelector:@selector(generateLayoutParamsFromAttributes:)]) {
            layoutParams = [rootView generateLayoutParamsFromAttributes:attrs];
        } else {
            layoutParams = [rootView generateDefaultLayoutParams];
        }
        temp.layoutParams = layoutParams;
    }
    if (rootElement->firstChild != NULL) {
        [self rInflateWithXmlElement:rootElement->firstChild parentView:temp attributes:attrs finishInflate:TRUE];
    }
    if (attachToRoot && rootView != nil) {
        [rootView addSubview:temp];
    }
    return temp;
}

- (UIView *)inflateURL:(NSURL *)url intoRootView:(UIView *)rootView attachToRoot:(BOOL)attachToRoot {
    NSError *error = nil;
    TBXML *xml = [[TBXML newTBXMLWithXMLData:[NSData dataWithContentsOfURL:url] error:&error] autorelease];
    if (error) {
        NSLog(@"%@ %@", [error localizedDescription], [error userInfo]);
        return nil;
    }
    return [self inflateParser:xml intoRootView:rootView attachToRoot:attachToRoot];
}

- (UIView *)inflateResource:(NSString *)resource intoRootView:(UIView *)rootView attachToRoot:(BOOL)attachToRoot {
    NSError *error = nil;
    TBXML *xml = [[TBXML newTBXMLWithXMLFile:resource error:&error] autorelease];
    if (error) {
        NSLog(@"%@ %@", [error localizedDescription], [error userInfo]);
        return nil;
    }
    return [self inflateParser:xml intoRootView:rootView attachToRoot:attachToRoot];
}

@end
