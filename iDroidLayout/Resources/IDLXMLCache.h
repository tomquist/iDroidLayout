//
//  IDLXMLCache.h
//  iDroidLayout
//
//  Created by Tom Quist on 06.01.13.
//  Copyright (c) 2013 Tom Quist. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"

@interface IDLXMLCache : NSObject

+ (IDLXMLCache *)sharedInstance;

- (TBXML *)xmlForUrl:(NSURL *)url error:(NSError **)error;
- (void)purge;

@end
