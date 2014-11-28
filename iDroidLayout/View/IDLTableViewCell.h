//
//  IDLTableViewCell.h
//  iDroidLayout
//
//  Created by Tom Quist on 22.07.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDLLayoutBridge.h"

@interface IDLTableViewCell : UITableViewCell {
    IDLLayoutBridge *__weak _layoutBridge;
}

@property (weak, nonatomic, readonly) IDLLayoutBridge *layoutBridge;

- (instancetype)initWithLayoutResource:(NSString *)resource reuseIdentifier:(NSString *)reuseIdentifier;
- (instancetype)initWithLayoutURL:(NSURL *)url reuseIdentifier:(NSString *)reuseIdentifier;

@end
