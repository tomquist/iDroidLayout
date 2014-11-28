//
//  LayoutInflater.h
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "IDLViewFactory.h"

@interface IDLLayoutInflater : NSObject {
    id<IDLViewFactory> _viewFactory;
}

@property (nonatomic, strong) id<IDLViewFactory> viewFactory;
@property (nonatomic, weak) id actionTarget;

- (UIView *)inflateURL:(NSURL *)url intoRootView:(UIView *)rootView attachToRoot:(BOOL)attachToRoot;
- (UIView *)inflateResource:(NSString *)resource intoRootView:(UIView *)rootView attachToRoot:(BOOL)attachToRoot;

@end
