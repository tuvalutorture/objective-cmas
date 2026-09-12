//
//  SIMASVariable.h
//  objectivismas
//
//  Created by Xander Gomez on 9/6/26.
//  Copyright © 2026 Xander Gomez. All rights reserved.
//
//  go, now, if you want it
//  an otherworld awaits you
//  don't you give up on it
//  you bite the hand that feeds you
//
//  all alone, cold fields you wander
//  memories of it
//  cloud your sight
//  fills your dreams
//  disturbs your slumber
//  lost your way, a fallen knight...
//
//  hold now, aim is steady
//  an otherworld awaits you
//  one thousand years, you ready?
//  the otherworld, it takes you
//
//  go
//  into the sand and the dust in the sky
//  go now
//  there's no better plan
//  than to do or to die
//
//  free me,
//  pray to the fayth,
//  in the face of the light
//
//  feed me
//  fill me with sin
//  and get ready to fight

#import <Foundation/Foundation.h>

@class SIMASVariable;

@interface SIMASConversion : NSObject
+ (Class)sourceType; // change this to return whatever class your SOURCE should be, i.e. [SIMASNumber class]
+ (Class)targetType; // change this to return whatever class your DESTINATION should be, i.e. [SIMASString class]
+ (id)convert:(id)source; // returns nil if source is not of type sourceType, otherwise returns an autoreleased object of targetType
@end

@interface SIMASData : NSObject {
    id data;
}

+ (void)registerToRuntime; // registers itself to the runtime, calling initialiseConversions
+ (void)initialiseConversions; // override this to call addConversion with your default conversions. this is auto-called by registerToRuntime
+ (SIMASData*)dataWithData:(id)data;

+ (NSDictionary*)conversions;
+ (void)addConversion:(Class)type withConversionClass:(Class)conversionClass; // add a SIMASConversion subclass' class here
- (id)getConverted:(Class)type; // returns an autoreleased object converted to whatever target class, or errors if the class is invalid

- (id)data;
@end

@protocol SIMASDataType <NSObject> // fyi you're expected to both conform to the protocol AND extend the base class (if you want to participate in type conversion), this just gives things you *have* to implement yourself
+ (NSString*)name; // return whatever you call it, i.e. "num". this is the name that is also given to the runtime
- (BOOL)isEqualTo:(SIMASData*)object;
- (SIMASData*)copy;
+ (SIMASData*)fromString:(NSString*)string; // you HAVE to be able to make literals from strings, so like. yeah
- (NSString*)toString; // you also need to make into a string cause like, you need to print to the console n shit. or list serialisation
@end

@interface SIMASVariable : NSObject {
    SIMASData *data;
}
+ (SIMASVariable*)makeVariable:(NSString*)name; // convenience method to automatically make a variable and add it to the existing varmap (nil if exception), requires program to be running in runtime. automatically returns one if one exists of same name
+ (SIMASVariable*)findVariable:(NSString*)name;

- (void)setWithVariable:(SIMASVariable*)var;

- (void)setData:(id)newData asCopy:(BOOL)copy; // copies if YES, retains if NO
- (void)setData:(id)newData; // retains, not copies
- (id)data;

- (id)makePointer;
@end

@interface SIMASPointer : SIMASVariable {
    SIMASVariable *point;
}
- (id)initWithVar:(SIMASVariable*)var;
@end

@interface SIMASNumberBox : NSObject {
    @public double num; // this is just a wrapper class for a double, ngl
}
@end

@interface SIMASBooleanBox : NSObject {
    @public BOOL boolean;
}
@end

@interface SIMASBoolean : SIMASData <SIMASDataType>
+ (SIMASBoolean*)booleanWithNumber:(double)number;
+ (SIMASBoolean*)booleanWithString:(NSString*)str;
+ (SIMASBoolean*)booleanWithBoolean:(BOOL)boolean;

- (void)negate;

- (void)setBoolValue:(BOOL)boolValue;
- (BOOL)boolValue;
@end

@interface SIMASString : SIMASData <SIMASDataType>
+ (SIMASString*)stringWithNumber:(double)number;
+ (SIMASString*)stringWithString:(NSString*)str;
+ (SIMASString*)stringWithBoolean:(BOOL)boolean;

- (void)setStringValue:(NSString*)stringValue;
- (NSString*)stringValue;
@end

@interface SIMASNumber : SIMASData <SIMASDataType>
+ (SIMASNumber*)numberWithNumber:(double)number;
+ (SIMASNumber*)numberWithString:(NSString*)str;
+ (SIMASNumber*)numberWithBoolean:(BOOL)boolean;

- (SIMASBoolean*)greaterThan:(SIMASNumber*)number;
- (SIMASBoolean*)greaterThanOrEqualTo:(SIMASNumber*)number;
- (SIMASBoolean*)lessThan:(SIMASNumber*)number;
- (SIMASBoolean*)lessThanOrEqualTo:(SIMASNumber*)number;

- (void)setDoubleValue:(double)doubleValue;
- (double)doubleValue;
@end

@interface SIMASBooleanToSIMASNumber : SIMASConversion
@end

@interface SIMASBooleanToSIMASString : SIMASConversion
@end

@interface SIMASStringToSIMASNumber : SIMASConversion
@end

@interface SIMASStringToSIMASBoolean : SIMASConversion
@end

@interface SIMASNumberToSIMASString : SIMASConversion
@end

@interface SIMASNumberToSIMASBoolean : SIMASConversion
@end
