//
//  TBXML+IDL.h
//  iDroidLayout
//
//  Created by Tom Quist on 18.12.12.
//  Copyright (c) 2012 Tom Quist. All rights reserved.
//

#import "TBXML.h"

@interface TBXML (IDL)

+ (NSMutableDictionary *)attributesFromXMLElement:(TBXMLElement *)element reuseDictionary:(NSMutableDictionary *)dict;

@end
