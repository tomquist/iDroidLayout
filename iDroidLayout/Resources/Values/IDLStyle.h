//
//  IDLStyle.h
//  iDroidLayout
//
//  Created by Tom Quist on 09.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IDLStyle : NSObject

@property (nonatomic, readonly) IDLStyle *parentStyle;
@property (nonatomic, readonly) NSDictionary *attributes;

@end
