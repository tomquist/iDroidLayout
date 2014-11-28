//
//  IDLResourceStateList.h
//  iDroidLayout
//
//  Created by Tom Quist on 07.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IDLResourceStateList : NSObject

@property (weak, nonatomic, readonly) NSArray *items;

+ (instancetype)createFromXMLData:(NSData *)data;
+ (instancetype)createFromXMLURL:(NSURL *)url;

@end