//
//  IDLDrawable+IDL_Internal.h
//  iDroidLayout
//
//  Created by Tom Quist on 18.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import <iDroidLayout/iDroidLayout.h>
#import "TBXML.h"

@interface IDLDrawable (IDL_Internal)

- (void)inflateWithElement:(TBXMLElement *)element;
+ (IDLDrawable *)createFromXMLElement:(TBXMLElement *)element;

@end
