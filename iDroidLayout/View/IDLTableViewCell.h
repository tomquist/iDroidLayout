//
//  IDLTableViewCell.h
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDLLayoutBridge.h"

@interface IDLTableViewCell : UITableViewCell

@property (weak, nonatomic, readonly) IDLLayoutBridge *layoutBridge;

- (instancetype)initWithLayoutResource:(NSString *)resource reuseIdentifier:(NSString *)reuseIdentifier NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithLayoutURL:(NSURL *)url reuseIdentifier:(NSString *)reuseIdentifier NS_DESIGNATED_INITIALIZER;

- (CGFloat)requiredHeightInView:(UIView *)view;

@end
