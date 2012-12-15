//
//  IDLResourceStateList+IDL_Internal.h
//  iDroidLayout
//
//  Created by Tom Quist on 08.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "IDLResourceStateList.h"
#import "TBXML.h"
#import "IDLResourceStateItem.h"

@interface IDLResourceStateList (IDL_Internal)

@property (nonatomic, retain) NSArray *internalItems;

+ (IDLResourceStateItem *)createItemWithControlState:(UIControlState)controlState fromElement:(TBXMLElement *)element;

- (IDLResourceStateItem *)itemForControlState:(UIControlState)controlState;

@end
