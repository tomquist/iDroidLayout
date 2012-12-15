//
//  IDLStyle+IDL_Internal.h
//  iDroidLayout
//
//  Created by Tom Quist on 14.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLStyle.h"
#import "TBXML.h"

@interface IDLStyle (IDL_Internal)

+ (IDLStyle *)createFromXMLElement:(TBXMLElement *)element;

@end
