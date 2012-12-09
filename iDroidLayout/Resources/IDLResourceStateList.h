//
//  IDLResourceStateList.h
//  iDroidLayout
//
//  Created by Tom Quist on 07.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IDLResourceStateList : NSObject

@property (nonatomic, readonly) NSArray *items;

+ (IDLResourceStateList *)createFromXMLData:(NSData *)data;
+ (IDLResourceStateList *)createFromXMLURL:(NSURL *)url;

@end