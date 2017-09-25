//
//  TypeConversion.h
//  GooglePlusIosExtension
//
//  Created by Aymeric Lamboley on 26/01/2015.
//  Copyright (c) 2015 DaVikingCode. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlashRuntimeExtensions.h"

@interface TypeConversion : NSObject

+ (nonnull TypeConversion*) sharedInstance;

- (FREResult) FREGetObject:(FREObject)object asString:(NSString**)value;
- (FREResult) FREGetString:(NSString*)string asObject:(FREObject*)asString;
- (FREResult) FREGetObject:(FREObject)object asSetOfStrings:(NSMutableSet**)value;

+ (NSString *) ConvertNSDictionaryToJSONString:(NSDictionary *) dictionary;

- (nullable NSString*) getStringProperty:(nonnull NSString*) propName object:(nonnull FREObject) object;
- (nullable NSArray*) getArrayProperty:(nonnull NSString*) propName object:(nonnull FREObject) object;
- (nullable NSDictionary*) getDictionaryFromJson:(nonnull NSString*) jsonString;

@end
