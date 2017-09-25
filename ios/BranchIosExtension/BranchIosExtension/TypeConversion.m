//
//  TypeConversion.m
//  GooglePlusIosExtension
//
//  Created by Aymeric Lamboley on 26/01/2015.
//  Copyright (c) 2015 DaVikingCode. All rights reserved.
//

#import "TypeConversion.h"

static TypeConversion* airTypeConversionInstance = nil;

@implementation TypeConversion

+ (TypeConversion*) sharedInstance
{
    if(airTypeConversionInstance == nil)
    {
        airTypeConversionInstance = [[TypeConversion alloc] init];
    }
    return airTypeConversionInstance;
}


- (FREResult) FREGetObject:(FREObject)object asString:(NSString**)value {
    
    FREResult result;
    uint32_t length = 0;
    const uint8_t* tempValue = NULL;
    
    result = FREGetObjectAsUTF8(object, &length, &tempValue);
    
    if (result != FRE_OK)
        return result;
    
    *value = [NSString stringWithUTF8String:(char *) tempValue];
    return FRE_OK;
}

- (FREResult) FREGetString:(NSString*) string asObject:(FREObject*) asString {
    
    if (string == nil)
        return FRE_INVALID_ARGUMENT;
    
    const char* utf8String = string.UTF8String;
    unsigned long length = strlen(utf8String);
    
    return FRENewObjectFromUTF8(length + 1, (uint8_t*) utf8String, asString);
}

- (FREResult) FREGetObject:(FREObject)object asSetOfStrings:(NSMutableSet**)value {
    
    FREResult result;
    uint32_t length;
    
    result = FREGetArrayLength( object, &length );
    if( result != FRE_OK ) return result;
    
    NSMutableSet * set = [NSMutableSet setWithCapacity:length];
    
    FREObject item;
    NSString* string;
    
    for( int i = 0; i < length; ++i )
    {
        result = FREGetArrayElementAt( object, i, &item );
        if( result != FRE_OK ) return result;
        
        result = [self FREGetObject:item asString:&string];
        if( result != FRE_OK ) return result;
        
        [set addObject:string];
    }
    
    *value = set;
    return FRE_OK;
}

+ (NSString *) ConvertNSDictionaryToJSONString:(NSDictionary *) dictionary {
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    
    NSString *JSONString;
    
    if (!jsonData)
        JSONString = [[NSString alloc] init];
    else {
        JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
        JSONString = [JSONString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    }
    
    return JSONString;
}

- (nullable NSString*) getStringProperty:(nonnull NSString*) propName object:(nonnull FREObject) object
{
    FREObject propValue;
    if( FREGetObjectProperty( object, (const uint8_t*) [propName UTF8String], &propValue, NULL ) != FRE_OK )
    {
        return nil;
    }
    NSString* result = nil;
    [self FREGetObject:propValue asString:&result];
    return result;
}

- (nullable NSArray*) getArrayProperty:(nonnull NSString*) propName object:(nonnull FREObject) object
{
    FREObject propArray;
    if( FREGetObjectProperty( object, (const uint8_t*) [propName UTF8String], &propArray, NULL ) != FRE_OK )
    {
        return nil;
    }
    
    uint32_t arrayLength;
    FREGetArrayLength( propArray, &arrayLength );
    
    NSMutableArray* mutableArray = [NSMutableArray arrayWithCapacity:arrayLength];
    
    for( uint32_t i = 0; i < arrayLength; i++ )
    {
        FREObject itemRaw;
        FREGetArrayElementAt( propArray, i, &itemRaw );
        
        NSString* item = nil;
        [self FREGetObject:itemRaw asString:&item];
        
        if(item != nil)
        {
            [mutableArray addObject:item];
        }
    }

    return mutableArray;
}

- (nullable NSDictionary*) getDictionaryFromJson:(nonnull NSString*) jsonString
{
    NSError* jsonError;
    NSData* objectData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:objectData
                                           options:NSJSONReadingMutableContainers
                                             error:&jsonError];
}

@end





