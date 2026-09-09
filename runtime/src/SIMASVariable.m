//
//  SIMASVariable.m
//  objectivismas
//
//  Created by Xander Gomez on 9/6/26.
//  Copyright © 2026 Xander Gomez. All rights reserved.
//
//  desperate, i will crawl
//  waiting for so long
//  no love, there is no love
//  die for anyone
//  what the fuck has this program become
//  something's getting in the way
//  something's just about to break
//  i will try to find my place
//  in the arch of simas
//  as i burn another page
//  as i look the other way
//  i still try to find my place
//  in the code of simas

#import "SIMASVariable.h"
#import "SIMASRuntime.h"

@implementation SIMASConversion
+ (Class)sourceType { return nil; }
+ (Class)targetType { return nil; }
+ (id)convert:(SIMASData*)source { return [source isKindOfClass:[self sourceType]] ? source : nil; }
@end

@implementation SIMASData
+ (NSString*)name {
    return @"";
}

+ (void)initialiseConversions {
    return;
}

+ (SIMASData*)dataWithData:(id)data {
    SIMASData *newData = [[self class] new];
    newData->data = data;
    return [newData autorelease];
}

+ (NSMutableDictionary*)allowedConversions {
    static NSMutableDictionary* conversions = nil;
    if (conversions == nil) conversions = [NSMutableDictionary new]; // leaks technically but eh who the fuck cares, it'll die with the rest of the program at the end of the app lifecycle anyway
    return conversions;
}

+ (NSDictionary*)conversions {
    return [[self allowedConversions] objectForKey:self];
}

+ (void)registerToRuntime {
    [self initialiseConversions];
    [[SIMASRuntime runtime] registerType:self withName:[self name]];
}

+ (void)addConversion:(Class)type withConversionClass:(Class)conversionClass {
    NSMutableDictionary *classDict = [[self allowedConversions] objectForKey:self];
    if (!classDict) {
        classDict = [NSMutableDictionary new];
        [[self allowedConversions] setObject:classDict forKey:(id<NSCopying>)self];
        [classDict release];
    }
    if (![classDict objectForKey:type]) [classDict setObject:conversionClass forKey:(id<NSCopying>)type]; // shitty cast but it's legal and works but xcode bitches without it
}
- (id)getConverted:(Class)type {
    if (type == [self class]) return [[self copy] autorelease];
    Class conversion = [[[self class] conversions] objectForKey:type];
    if (!conversion && type != [self class]) [SIMASRuntime throwException:@"IllegalConversion" withReason:[NSString stringWithFormat:@"Conversion from type %@ to %@ is not allowed.", [[self class] name], [type name]]];
    return [conversion convert:self]; // it'll return nil so is fine
}

- (id)data { return self->data; }

- (void)dealloc {
	[data release];
	[super dealloc];
}
@end

@implementation SIMASVariable
+ (SIMASVariable*)makeVariable:(NSString*)name {
    SIMASVariable *newVar;
    if ((newVar = [[SIMASRuntime currentProgram] locateVariable:name])) return newVar;
    if ([name characterAtIndex:0] == '$' || [[SIMASRuntime runtime] isExcepted]) { [SIMASRuntime throwException:@"IllegalName" withReason:@"Names starting with '$' are reserved by the SIMAS runtime."]; return nil; }
    newVar = [[SIMASVariable new] autorelease];
    [[SIMASRuntime currentProgram]->variables setObject:newVar forKey:name];
    return newVar;
}

- (void)setWithVariable:(SIMASVariable*)var {
    [self setData:[[var->data copy] autorelease]];
}

- (void)setData:(id)newData asCopy:(BOOL)copy {
    if (self->data != newData) {
        [self->data release];
        self->data = copy ? [newData copy] : [newData retain];
    }
}
- (void)setData:(id)newData {
    [self setData:newData asCopy:NO];
}
- (id)data {
    return data;
}

- (id)makePointer {
    return [[[SIMASPointer alloc] initWithVar:self] autorelease];
}

- (void)dealloc {
	[data release];
	[super dealloc];
}
@end

@implementation SIMASPointer
- (id)initWithVar:(SIMASVariable*)var {
	self = [super init];
	if (self) {
		self->point = [var retain];
	}
	return self;
}
- (void)setWithVariable:(SIMASVariable *)var { [point setWithVariable:var]; }
- (void)setData:(id)newData { [point setData:newData]; }
- (id)data { return [point data]; }
- (id)makePointer { return [point makePointer]; }
- (void)dealloc {
	[point release];
	[super dealloc];
}
@end

@implementation SIMASNumberBox
@end

@implementation SIMASBooleanBox
@end

@implementation SIMASBoolean
- (id)init {
    self = [super init];
    if (self) self->data = [SIMASBooleanBox new];
    return self;
}

+ (NSString*)name {
	return @"bool";
}

+ (void)initialiseConversions {
    [self addConversion:[SIMASNumber class] withConversionClass:[SIMASBooleanToSIMASNumber class]];
    [self addConversion:[SIMASString class] withConversionClass:[SIMASBooleanToSIMASString class]];
}

+ (SIMASBoolean*)booleanWithNumber:(double)number {
    SIMASBoolean *boolean = [SIMASBoolean new];
    ((SIMASBooleanBox*)boolean->data)->boolean = number != 0;
    return [boolean autorelease];
}
+ (SIMASBoolean*)booleanWithString:(NSString*)str {
    SIMASBoolean *boolean = [SIMASBoolean new];
    ((SIMASBooleanBox*)boolean->data)->boolean = [str boolValue];
    return [boolean autorelease];
}
+ (SIMASBoolean*)booleanWithBoolean:(BOOL)boolean {
    SIMASBoolean *aboolean = [SIMASBoolean new];
    ((SIMASBooleanBox*)aboolean->data)->boolean = boolean;
    return [aboolean autorelease];
}

+ (SIMASBooleanOperationSetup)setupOperation:(NSArray*)args {
    SIMASBooleanOperationSetup setup;
    setup.firstVariable = nil;
    setup.secondVariable = nil;
    SIMASVariable *first = [[SIMASRuntime currentProgram] locateVariable:[args objectAtIndex:1]];
    if (first == nil) return setup; // error handling is downstream
    SIMASVariable *secondVar = [[SIMASRuntime currentProgram] locateVariable:[args objectAtIndex:2]];
    BOOL firstOperand, secondOperand;
    if (secondVar == nil) secondOperand = [[args objectAtIndex:2] boolValue];
    else secondOperand = [[[secondVar data] getConverted:[SIMASBoolean class]] boolValue];
    firstOperand = [[first data] boolValue];
    setup.firstVariable = first;
    setup.secondVariable = secondVar;
    setup.firstOperand = firstOperand;
    setup.secondOperand = secondOperand;
    return setup;
}

+ (void)logicalOr:(NSArray*)args {
    SIMASBooleanOperationSetup setup = [self setupOperation:args];
    [setup.firstVariable setData:[[SIMASBoolean booleanWithBoolean:(setup.firstOperand || setup.secondOperand)] getConverted:[[SIMASRuntime runtime]->registeredTypes objectForKey:[[args objectAtIndex:0] lowercaseString]]]]; // holy crap
}
+ (void)logicalAnd:(NSArray*)args {
    SIMASBooleanOperationSetup setup = [self setupOperation:args];
    [setup.firstVariable setData:[[SIMASBoolean booleanWithBoolean:(setup.firstOperand && setup.secondOperand)] getConverted:[[SIMASRuntime runtime]->registeredTypes objectForKey:[[args objectAtIndex:0] lowercaseString]]]]; // holy crap
}
+ (void)logicalXor:(NSArray*)args {
    SIMASBooleanOperationSetup setup = [self setupOperation:args];
    [setup.firstVariable setData:[[SIMASBoolean booleanWithBoolean:(setup.firstOperand != setup.secondOperand)] getConverted:[[SIMASRuntime runtime]->registeredTypes objectForKey:[[args objectAtIndex:0] lowercaseString]]]]; // holy crap
}
+ (void)logicalNor:(NSArray*)args {
    SIMASBooleanOperationSetup setup = [self setupOperation:args];
    [setup.firstVariable setData:[[SIMASBoolean booleanWithBoolean:!(setup.firstOperand || setup.secondOperand)] getConverted:[[SIMASRuntime runtime]->registeredTypes objectForKey:[[args objectAtIndex:0] lowercaseString]]]]; // holy crap
}
+ (void)logicalNand:(NSArray*)args {
    SIMASBooleanOperationSetup setup = [self setupOperation:args];
    [setup.firstVariable setData:[[SIMASBoolean booleanWithBoolean:!(setup.firstOperand && setup.secondOperand)] getConverted:[[SIMASRuntime runtime]->registeredTypes objectForKey:[[args objectAtIndex:0] lowercaseString]]]]; // holy crap
}

- (void)negate {
    [self setBoolValue:![self boolValue]];
}

- (void)setBoolValue:(BOOL)boolValue { ((SIMASBooleanBox*)self->data)->boolean = boolValue; }
- (BOOL)boolValue { return ((SIMASBooleanBox*)self->data)->boolean; }

- (SIMASData*)copy {
    SIMASBoolean* newBool = [SIMASBoolean new];
    [newBool setBoolValue:[self boolValue]];
    return newBool;
}

- (BOOL)isEqualTo:(SIMASData*)object { return [[object getConverted:[SIMASBoolean class]] boolValue] == [self boolValue]; }
+ (SIMASData*)fromString:(NSString*)string { return [self booleanWithString:string]; }
- (NSString*)toString { return [self boolValue] ? @"true" : @"false"; }
@end

@implementation SIMASString
- (id)init {
    self = [super init];
    if (self) self->data = [NSMutableString new];
    return self;
}

+ (NSString*)name {
	return @"str";
}

+ (void)initialiseConversions {
    [self addConversion:[SIMASNumber class] withConversionClass:[SIMASStringToSIMASNumber class]];
    [self addConversion:[SIMASBoolean class] withConversionClass:[SIMASStringToSIMASBoolean class]];
}

+ (SIMASString*)stringWithNumber:(double)number {
    SIMASString *string = [SIMASString new];
    [(NSMutableString*)string->data setString:[[NSNumber numberWithDouble:number] stringValue]];
    return [string autorelease];
}
+ (SIMASString*)stringWithString:(NSString*)str {
    SIMASString *string = [SIMASString new];
    [(NSMutableString*)string->data setString:str];
    return [string autorelease];
}
+ (SIMASString*)stringWithBoolean:(BOOL)boolean {
    SIMASString *string = [SIMASString new];
    [(NSMutableString*)string->data setString:(boolean ? @"true" : @"false")];
    return [string autorelease];
}

- (void)setStringValue:(NSString*)stringValue { [self->data setString:stringValue]; }
- (NSString*)stringValue { return self->data; }
- (SIMASData*)copy {
    SIMASString* newStr = [SIMASString new];
    [newStr setStringValue:self->data];
    return newStr;
}

- (BOOL)isEqualTo:(SIMASData*)object { return [[[object getConverted:[SIMASString class]] stringValue] isEqualToString:[self stringValue]]; }
+ (SIMASData*)fromString:(NSString*)string { return [self stringWithString:string]; }
- (NSString*)toString { return self->data; }
@end

@implementation SIMASNumber
- (id)init {
    self = [super init];
    if (self) self->data = [SIMASNumberBox new]; 
    return self;
}

+ (NSString*)name {
	return @"num";
}

+ (void)initialiseConversions {
    [self addConversion:[SIMASBoolean class] withConversionClass:[SIMASNumberToSIMASBoolean class]];
    [self addConversion:[SIMASString class] withConversionClass:[SIMASNumberToSIMASString class]];
}

+ (SIMASNumber*)numberWithNumber:(double)number {
    SIMASNumber *theNumber = [SIMASNumber new];
    ((SIMASNumberBox*)theNumber->data)->num = number;
    return [theNumber autorelease];
}
+ (SIMASNumber*)numberWithString:(NSString*)str {
    SIMASNumber *theNumber = [SIMASNumber new];
    ((SIMASNumberBox*)theNumber->data)->num = [str doubleValue];
    return [theNumber autorelease];
}
+ (SIMASNumber*)numberWithBoolean:(BOOL)boolean {
    SIMASNumber *theNumber = [SIMASNumber new];
    ((SIMASNumberBox*)theNumber->data)->num = (double)boolean;
    return [theNumber autorelease];
}

+ (SIMASNumberOperationSetup)setupOperation:(NSArray*)args {
    SIMASNumberOperationSetup setup;
    setup.firstVariable = nil;
    setup.secondVariable = nil;
    SIMASVariable *first = [[SIMASRuntime currentProgram] locateVariable:[args objectAtIndex:1]];
    if (first == nil) return setup; // error handling downstream
    SIMASVariable *secondVar = [[SIMASRuntime currentProgram] locateVariable:[args objectAtIndex:2]];
    double firstOperand, secondOperand;
    if (secondVar == nil) secondOperand = [[args objectAtIndex:2] doubleValue];
    else secondOperand = [[[secondVar data] getConverted:[SIMASNumber class]] doubleValue];
    firstOperand = [[first data] doubleValue];
    setup.firstVariable = first;
    setup.secondVariable = secondVar;
    setup.firstOperand = firstOperand;
    setup.secondOperand = secondOperand;
    return setup;
}

+ (void)add:(NSArray*)args {
    SIMASNumberOperationSetup setup = [self setupOperation:args];
    [setup.firstVariable setData:[[SIMASNumber numberWithNumber:(setup.firstOperand + setup.secondOperand)] getConverted:[[SIMASRuntime runtime]->registeredTypes objectForKey:[[args objectAtIndex:0] lowercaseString]]]]; // holy crap
}
+ (void)subtract:(NSArray*)args {
    SIMASNumberOperationSetup setup = [self setupOperation:args];
    [setup.firstVariable setData:[[SIMASNumber numberWithNumber:(setup.firstOperand - setup.secondOperand)] getConverted:[[SIMASRuntime runtime]->registeredTypes objectForKey:[[args objectAtIndex:0] lowercaseString]]]]; // holy crap
}
+ (void)multiply:(NSArray*)args {
    SIMASNumberOperationSetup setup = [self setupOperation:args];
    [setup.firstVariable setData:[[SIMASNumber numberWithNumber:(setup.firstOperand * setup.secondOperand)] getConverted:[[SIMASRuntime runtime]->registeredTypes objectForKey:[[args objectAtIndex:0] lowercaseString]]]]; // holy crap
}
+ (void)divide:(NSArray*)args {
    SIMASNumberOperationSetup setup = [self setupOperation:args];
    if (setup.secondOperand == 0) [SIMASRuntime throwException:@"DivisionByZero" withReason:@"Division by zero is not allowed." withSnideRemark:@"man you are one stupid motherfucker innit? did the american education system fail you THAT hard holy shit 😂"];
    else [setup.firstVariable setData:[[SIMASNumber numberWithNumber:(setup.firstOperand / setup.secondOperand)] getConverted:[[SIMASRuntime runtime]->registeredTypes objectForKey:[[args objectAtIndex:0] lowercaseString]]]]; // holy crap
}

- (SIMASBoolean*)greaterThan:(SIMASNumber*)number { return [SIMASBoolean booleanWithBoolean:([self doubleValue] > [number doubleValue])]; }
- (SIMASBoolean*)greaterThanOrEqualTo:(SIMASNumber*)number { return [SIMASBoolean booleanWithBoolean:([self doubleValue] >= [number doubleValue])]; }
- (SIMASBoolean*)lessThan:(SIMASNumber*)number { return [SIMASBoolean booleanWithBoolean:([self doubleValue] < [number doubleValue])]; }
- (SIMASBoolean*)lessThanOrEqualTo:(SIMASNumber*)number { return [SIMASBoolean booleanWithBoolean:([self doubleValue] <= [number doubleValue])]; }

- (void)setDoubleValue:(double)doubleValue { ((SIMASNumberBox*)self->data)->num = doubleValue; }
- (double)doubleValue { return ((SIMASNumberBox*)self->data)->num;}
- (SIMASData*)copy {
    SIMASNumber *newNum = [SIMASNumber new];
    [newNum setDoubleValue:[self doubleValue]];
    return newNum;
}

- (BOOL)isEqualTo:(SIMASData*)object { return [[object getConverted:[SIMASNumber class]] doubleValue] == [self doubleValue]; }
+ (SIMASData*)fromString:(NSString *)string { return [self numberWithString:string]; }
- (NSString*)toString { return [[NSNumber numberWithDouble:[self doubleValue]] stringValue]; }
@end

@implementation SIMASBooleanToSIMASNumber
+ (Class)sourceType { return [SIMASBoolean class]; }
+ (Class)targetType { return [SIMASNumber class]; }
+ (id)convert:(SIMASData*)source {
    if ([super convert:source] == nil) return nil;
    return [SIMASNumber numberWithBoolean:((SIMASBooleanBox*)[source data])->boolean];
}
@end

@implementation SIMASBooleanToSIMASString
+ (Class)sourceType { return [SIMASBoolean class]; }
+ (Class)targetType { return [SIMASString class]; }
+ (id)convert:(SIMASData*)source {
    if ([super convert:source] == nil) return nil;
    return [SIMASString stringWithBoolean:((SIMASBooleanBox*)[source data])->boolean];
}
@end

@implementation SIMASStringToSIMASNumber
+ (Class)sourceType { return [SIMASString class]; }
+ (Class)targetType { return [SIMASNumber class]; }
+ (id)convert:(SIMASData*)source {
    if ([super convert:source] == nil) return nil;
    return [SIMASNumber numberWithString:[source data]];
}
@end

@implementation SIMASStringToSIMASBoolean
+ (Class)sourceType { return [SIMASString class]; }
+ (Class)targetType { return [SIMASBoolean class]; }
+ (id)convert:(SIMASData*)source {
    if ([super convert:source] == nil) return nil;
    return [SIMASBoolean booleanWithString:[source data]];
}
@end

@implementation SIMASNumberToSIMASString
+ (Class)sourceType { return [SIMASNumber class]; }
+ (Class)targetType { return [SIMASString class]; }
+ (id)convert:(SIMASData*)source {
    if ([super convert:source] == nil) return nil;
    return [SIMASString stringWithNumber:((SIMASNumberBox*)[source data])->num];
}
@end

@implementation SIMASNumberToSIMASBoolean
+ (Class)sourceType { return [SIMASNumber class]; }
+ (Class)targetType { return [SIMASBoolean class]; }
+ (id)convert:(SIMASData*)source {
    if ([super convert:source] == nil) return nil;
    return [SIMASBoolean booleanWithNumber:((SIMASNumberBox*)[source data])->num];
}
@end
