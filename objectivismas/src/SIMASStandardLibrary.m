//
//  SIMASStandardLibrary.m
//  objectivismas
//
//  Created by Xander Gomez on 9/6/26.
//  Copyright © 2026 Xander Gomez. All rights reserved.
//
//  In my eyes
//  Indisposed
//  In disguises no one knows
//  Hides the face
//  Lies the snake
//  And the sun in my disgrace
//  Boiling heat
//  Summer stench
//  Neath the black, the sky looks dead
//  Call my name
//  Through the cream
//  And I'll hear you scream again
//  Stuttering
//  Cold and damp
//  Steal the warm wind, tired friend
//  Times are gone
//  For honest men
//  Sometimes, far too long for snakes
//  In my shoes
//  Walking sleep
//  In my youth, I pray to keep
//  Heaven send
//  Hell away
//  No one sings like you anymore
//  can the sun just fucking collapse into a black hole already
//
//  soundgarden - black hole sun

#import "SIMASStandardLibrary.h"
#import "SIMASVariable.h"
#import "SIMASFunction.h"

static BOOL eatShitIfArgIsInput(NSArray *args, int arg) {
    if ([[[args objectAtIndex:arg] lowercaseString] isEqualToString:@"in"]) {
        [SIMASRuntime throwException:@"IllegalValue" withReason:@"You cannot assign a value to the 'in' variable."];
        return YES;
    }
    return NO;
}

typedef struct {
    SIMASVariable *firstVariable, *secondVariable;
    double firstOperand, secondOperand;
} SIMASNumberOperationSetup;

typedef struct {
    SIMASVariable *firstVariable, *secondVariable;
    BOOL firstOperand, secondOperand;
} SIMASBooleanOperationSetup;

@interface SIMASComparison : NSObject
+ (SIMASBooleanOperationSetup)setupOperation:(NSArray*)args;

+ (void)logicalOr:(NSArray*)args;
+ (void)logicalAnd:(NSArray*)args;
+ (void)logicalXor:(NSArray*)args;
+ (void)logicalNor:(NSArray*)args;
+ (void)logicalNand:(NSArray*)args;
@end

@implementation SIMASComparison
+ (SIMASBooleanOperationSetup)setupOperation:(NSArray*)args {
    SIMASBooleanOperationSetup setup;
    setup.firstVariable = nil;
    setup.secondVariable = nil;
    if (eatShitIfArgIsInput(args, 1)) return setup;
    SIMASVariable *first = [SIMASVariable findVariable:[args objectAtIndex:1]];
    if (first == nil) return setup; // error handling is downstream
    SIMASVariable *secondVar = [SIMASVariable findVariable:[args objectAtIndex:2]];
    BOOL firstOperand, secondOperand;
    if (secondVar == nil) secondOperand = [[args objectAtIndex:2] boolValue];
    else secondOperand = [[[secondVar data] getConverted:[SIMASBoolean class]] boolValue];
    firstOperand = [[[first data] getConverted:[SIMASBoolean class]] boolValue];
    setup.firstVariable = first;
    setup.secondVariable = secondVar;
    setup.firstOperand = firstOperand;
    setup.secondOperand = secondOperand;
    return setup;
}

+ (void)logicalOr:(NSArray*)args {
    SIMASBooleanOperationSetup setup = [self setupOperation:args];
    if (setup.firstVariable) [setup.firstVariable setData:[[SIMASBoolean booleanWithBoolean:(setup.firstOperand || setup.secondOperand)] getConverted:SIMASGETTYPEWITHARGUMENT(0)]];
}
+ (void)logicalAnd:(NSArray*)args {
    SIMASBooleanOperationSetup setup = [self setupOperation:args];
    if (setup.firstVariable) [setup.firstVariable setData:[[SIMASBoolean booleanWithBoolean:(setup.firstOperand && setup.secondOperand)] getConverted:SIMASGETTYPEWITHARGUMENT(0)]];
}
+ (void)logicalXor:(NSArray*)args {
    SIMASBooleanOperationSetup setup = [self setupOperation:args];
    if (setup.firstVariable) [setup.firstVariable setData:[[SIMASBoolean booleanWithBoolean:(setup.firstOperand != setup.secondOperand)] getConverted:SIMASGETTYPEWITHARGUMENT(0)]];
}
+ (void)logicalNor:(NSArray*)args {
    SIMASBooleanOperationSetup setup = [self setupOperation:args];
    if (setup.firstVariable) [setup.firstVariable setData:[[SIMASBoolean booleanWithBoolean:!(setup.firstOperand || setup.secondOperand)] getConverted:SIMASGETTYPEWITHARGUMENT(0)]];
}
+ (void)logicalNand:(NSArray*)args {
    SIMASBooleanOperationSetup setup = [self setupOperation:args];
    if (setup.firstVariable) [setup.firstVariable setData:[[SIMASBoolean booleanWithBoolean:!(setup.firstOperand && setup.secondOperand)] getConverted:SIMASGETTYPEWITHARGUMENT(0)]];
}
@end

@interface SIMASArithmetic : NSObject
+ (SIMASNumberOperationSetup)setupOperation:(NSArray*)args;

+ (void)add:(NSArray*)args;
+ (void)subtract:(NSArray*)args;
+ (void)multiply:(NSArray*)args;
+ (void)divide:(NSArray*)args;
@end

@implementation SIMASArithmetic
+ (SIMASNumberOperationSetup)setupOperation:(NSArray*)args {
    SIMASNumberOperationSetup setup;
    setup.firstVariable = nil;
    setup.secondVariable = nil;
    
    double firstOperand, secondOperand;
    if (eatShitIfArgIsInput(args, 1)) return setup;
    SIMASVariable *first = [SIMASVariable findVariable:[args objectAtIndex:1]];
    
    if (first == nil) return setup; // error handling downstream
    SIMASVariable *secondVar = [SIMASVariable findVariable:[args objectAtIndex:2]];
   
    if (secondVar == nil) secondOperand = [[args objectAtIndex:2] doubleValue];
    else secondOperand = [[[secondVar data] getConverted:[SIMASNumber class]] doubleValue];
    firstOperand = [[[first data] getConverted:[SIMASNumber class]] doubleValue];
    
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
@end

SIMASCLASSMETHOD(SIMASArithmetic)
SIMASCLASSMETHOD(SIMASComparison)

SIMASFUNC(setVar) {
    if (eatShitIfArgIsInput(args, 1)) return;
    NSString *name = [args objectAtIndex:1], *second = [args count] > 2 ? [args objectAtIndex:2] : nil;
    SIMASVariable *targetVar = [SIMASVariable makeVariable:name];
    if (!targetVar) return;
    if ([[[args objectAtIndex:0] lowercaseString] isEqualToString:@"in"]) {
        NSFileHandle *standardin = [NSFileHandle fileHandleWithStandardInput];
        [targetVar setData:[SIMASString stringWithString:formatEscapes([[[[NSString alloc] initWithData:[standardin availableData] encoding:NSASCIIStringEncoding] autorelease] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]])]];
        return;
    }
    if ([args count] < 3) [SIMASRuntime throwException:@"IllegalArgumentCount" withReason:[NSString stringWithFormat:@"The provided instruction does not contain enough arguments (must be 3, got 2) for instruction set."]];
    if (!SIMASGETTYPEWITHARGUMENT(0)) { [SIMASRuntime throwException:@"NonexistentType" withReason:[NSString stringWithFormat:@"Type %@ does not exist, thus cannot be used to convert.", [args objectAtIndex:0]]]; return; }
    SIMASVariable *sourceVar = [SIMASVariable findVariable:second];
    if (!sourceVar) [targetVar setData:[(Class)SIMASGETTYPEWITHARGUMENT(0) fromString:second]];
    else [targetVar setData:[[sourceVar data] getConverted:(Class)SIMASGETTYPEWITHARGUMENT(0)]];
}

SIMASFUNC(consolePrint) {
    SIMASVariable *var = SIMASGETVARIABLEWITHARGUMENT(0);
    if (!var) { [SIMASRuntime throwException:@"NonexistentVariable" withReason:[NSString stringWithFormat:@"Variable %@ does not exist, and the function which you are using it from does not implicitly create variables.", [args objectAtIndex:0]]]; return; }
    printf("%s", [[[var data] toString] UTF8String]);
}

SIMASFUNC(consolePrintc) {
    printf("%s", [[args objectAtIndex:0] UTF8String]);
}

SIMASFUNC(consolePrints) {
    printf(" ");
}

SIMASFUNC(consolePrintln) {
    printf("\n");
}

SIMASCLASSMETHOD(SIMASNumber)
SIMASCLASSMETHOD(SIMASBoolean)

SIMASSELECTORMETHOD(gt, @selector(greaterThan:))
SIMASSELECTORMETHOD(gte, @selector(greaterThanOrEqualTo:))
SIMASSELECTORMETHOD(st, @selector(lessThan:))
SIMASSELECTORMETHOD(ste, @selector(lessThanOrEqualTo:))

SIMASFUNC(functionsOfComparison) {
    if (eatShitIfArgIsInput(args, 1)) return;
    SIMASNumberOperationSetup setup = [SIMASArithmetic setupOperation:args];
    if (!SIMASGETTYPEWITHARGUMENT(0)) { [SIMASRuntime throwException:@"NonexistentType" withReason:[NSString stringWithFormat:@"Type %@ does not exist, thus cannot be used to convert.", [args objectAtIndex:0]]]; return; }
    if (!setup.firstVariable) { [SIMASRuntime throwException:@"NonexistentVariable" withReason:[NSString stringWithFormat:@"Variable %@ does not exist, and the function which you are using it from does not implicitly create variables.", [args objectAtIndex:1]]]; return; }
    SIMASBoolean* (*function)(id, SEL, SIMASNumber*) = (SIMASBoolean*(*)(id, SEL, SIMASNumber*))[[setup.firstVariable data] methodForSelector:_cmd];
    SIMASNumber* operator2 = setup.secondVariable ? [[setup.secondVariable data] getConverted:[SIMASNumber class]] : [SIMASNumber numberWithNumber:setup.secondOperand];
    SIMASBoolean* boolean = function([setup.firstVariable data], _cmd, operator2);
    [setup.firstVariable setData:[boolean getConverted:SIMASGETTYPEWITHARGUMENT(0)]];
}

SIMASFUNC(negationProctation) {
    if (eatShitIfArgIsInput(args, 0)) return;
    SIMASVariable *variable = SIMASGETVARIABLEWITHARGUMENT(0);
    if (!variable) { [SIMASRuntime throwException:@"NonexistentVariable" withReason:[NSString stringWithFormat:@"Variable %@ does not exist, and the function which you are using it from does not implicitly create variables.", [args objectAtIndex:0]]]; return; }
    [variable setData:[SIMASBoolean booleanWithBoolean:![[variable data] getConverted:[SIMASBoolean class]]]];
}

SIMASFUNC(equalityOfConst) {
    if (eatShitIfArgIsInput(args, 1)) return;
    SIMASVariable *variable1 = SIMASGETVARIABLEWITHARGUMENT(1);
    if (!variable1) { [SIMASRuntime throwException:@"NonexistentVariable" withReason:[NSString stringWithFormat:@"Variable %@ does not exist, and the function which you are using it from does not implicitly create variables.", [args objectAtIndex:1]]]; return; }
    Class type = SIMASGETTYPEWITHARGUMENT(0);
    if (!type) { [SIMASRuntime throwException:@"NonexistentType" withReason:[NSString stringWithFormat:@"Type %@ does not exist, thus cannot be used to convert.", [args objectAtIndex:0]]]; return; }
    SIMASData *variable2 = [type fromString:[args objectAtIndex:2]];
    [variable1 setData:[SIMASBoolean booleanWithBoolean:([[[variable1 data] getConverted:type] isEqualTo:variable2])]];
}

SIMASFUNC(inequalityOfConst) {
    if (eatShitIfArgIsInput(args, 1)) return;
    equalityOfConst(self, _cmd, args);
    negationProctation(self, _cmd, [NSArray arrayWithObject:[args objectAtIndex:1]]);
}

SIMASFUNC(equalityOfVars) {
    if (eatShitIfArgIsInput(args, 1)) return;
    SIMASVariable *variable1 = SIMASGETVARIABLEWITHARGUMENT(1);
    SIMASVariable *variable2 = [SIMASVariable findVariable:[args objectAtIndex:2]];
    if (!variable1 || !variable2) {
        [SIMASRuntime throwException:@"NonexistentVariable" withReason:[NSString stringWithFormat:@"Variable %@ does not exist, and the function which you are using it from does not implicitly create variables.", [args objectAtIndex:(variable1 != nil) + 1]]];
        return;
    }
    Class type = SIMASGETTYPEWITHARGUMENT(0);
    if (!type) [SIMASRuntime throwException:@"NonexistentType" withReason:[NSString stringWithFormat:@"Type %@ does not exist, thus cannot be used to convert.", [args objectAtIndex:0]]];
    else [variable1 setData:[SIMASBoolean booleanWithBoolean:([[[variable1 data] getConverted:[[variable2 data] class]] isEqualTo:[variable2 data]])]];
}

SIMASFUNC(inequalityOfVars) {
    if (eatShitIfArgIsInput(args, 1)) return;
    equalityOfVars(self, _cmd, args);
    negationProctation(self, _cmd, [NSArray arrayWithObject:[args objectAtIndex:1]]);
}

SIMASFUNC(varType) {
    SIMASVariable *variable1 = SIMASGETVARIABLEWITHARGUMENT(0);
    NSString *name = variable1 ? [[variable1 class] name] : @"nil";
    [[SIMASVariable makeVariable:[args objectAtIndex:1]] setData:[SIMASString stringWithString:name]];
}

SIMASFUNC(conversion) {
    if (eatShitIfArgIsInput(args, 0)) return;
    SIMASVariable *variable1 = SIMASGETVARIABLEWITHARGUMENT(0);
    Class type = SIMASGETTYPEWITHARGUMENT(1);
    if (!variable1) { [SIMASRuntime throwException:@"NonexistentVariable" withReason:[NSString stringWithFormat:@"Variable %@ does not exist, and the function which you are using it from does not implicitly create variables.", [args objectAtIndex:0]]]; return; }
    if (!type) [SIMASRuntime throwException:@"NonexistentType" withReason:[NSString stringWithFormat:@"Type %@ does not exist, thus cannot be used to convert.", [args objectAtIndex:0]]];
    else [variable1 setData:[[variable1 data] getConverted:type]];
}

SIMASFUNC(copying) {
    if (eatShitIfArgIsInput(args, 1)) return;
    SIMASVariable *variable1 = SIMASGETVARIABLEWITHARGUMENT(0);
    if (!variable1) { [SIMASRuntime throwException:@"NonexistentVariable" withReason:[NSString stringWithFormat:@"Variable %@ does not exist, and the function which you are using it from does not implicitly create variables.", [args objectAtIndex:0]]]; return; }
    [[SIMASVariable makeVariable:[args objectAtIndex:1]] setData:[[[variable1 data] copy] autorelease]];
}

SIMASFUNC(pointationNotation) {
    if (eatShitIfArgIsInput(args, 0)) return;
    SIMASVariable *variable1 = SIMASGETVARIABLEWITHARGUMENT(0);
    NSString* name = [args objectAtIndex:1];
    if (!variable1 || [name characterAtIndex:0] == '$' || [[args objectAtIndex:0] characterAtIndex:0] == '$') { [SIMASRuntime throwException:@"IllegalName" withReason:@"Variable names cannot start with '$' (reserved)."]; return; }
    if ([[[args objectAtIndex:1] lowercaseString] isEqualToString:@"in"]) { [SIMASRuntime throwException:@"IllegalName" withReason:@"Variable names cannot be 'in' (reserved)."]; return; }
    SIMASVariable *pointer = [SIMASVariable findVariable:name];
    if (pointer) [[SIMASRuntime currentProgram]->variables removeObjectForKey:name];
    [[SIMASRuntime currentProgram]->variables setObject:[variable1 makePointer] forKey:name];
}

SIMASFUNC(jump) {
    NSNumber *jump = [[SIMASRuntime currentProgram]->labels objectForKey:[args objectAtIndex:0]];
    if (!jump) { [SIMASRuntime throwException:@"NonexistentLabel" withReason:[NSString stringWithFormat:@"Label %@ does not exist, and hence cannot be jumped to.", [args objectAtIndex:0]]]; return; }
    [SIMASRuntime currentProgram]->programCounter = [jump intValue];
}

SIMASFUNC(jumpButConditionally) {
    NSNumber *jump = [[SIMASRuntime currentProgram]->labels objectForKey:[args objectAtIndex:0]];
    if (!jump) { [SIMASRuntime throwException:@"NonexistentLabel" withReason:[NSString stringWithFormat:@"Label %@ does not exist, and hence cannot be jumped to.", [args objectAtIndex:0]]]; return; }
    SIMASVariable *condition = SIMASGETVARIABLEWITHARGUMENT(1);
    if (!condition) { [SIMASRuntime throwException:@"NonexistentVariable" withReason:[NSString stringWithFormat:@"Variable %@ does not exist, and the function which you are using it from does not implicitly create variables.", [args objectAtIndex:1]]]; return; }
    if ([[[condition data] getConverted:[SIMASBoolean class]] boolValue])[SIMASRuntime currentProgram]->programCounter = [jump intValue];
}

SIMASFUNC(jumpButConditionallyButNot) {
    NSNumber *jump = [[SIMASRuntime currentProgram]->labels objectForKey:[args objectAtIndex:0]];
    if (!jump) { [SIMASRuntime throwException:@"NonexistentLabel" withReason:[NSString stringWithFormat:@"Label %@ does not exist, and hence cannot be jumped to.", [args objectAtIndex:0]]]; return; }
    SIMASVariable *condition = SIMASGETVARIABLEWITHARGUMENT(1);
    if (!condition) { [SIMASRuntime throwException:@"NonexistentVariable" withReason:[NSString stringWithFormat:@"Variable %@ does not exist, and the function which you are using it from does not implicitly create variables.", [args objectAtIndex:1]]]; return; }
    if (![[[condition data] getConverted:[SIMASBoolean class]] boolValue])[SIMASRuntime currentProgram]->programCounter = [jump intValue];
}

SIMASFUNC(ebook) {
    if (eatShitIfArgIsInput(args, 1)) return;
    NSString *data = [NSString stringWithContentsOfFile:[args objectAtIndex:0] encoding:NSASCIIStringEncoding error:nil];
    if (!data) { [SIMASRuntime throwException:@"ReadError" withReason:[NSString stringWithFormat:@"File %@ failed to read.", [args objectAtIndex:0]]]; return; }
    [[SIMASVariable makeVariable:[args objectAtIndex:1]] setData:[SIMASString stringWithString:data]];
}

SIMASFUNC(macwrite) {
    [[args objectAtIndex:1] writeToFile:[args objectAtIndex:0] atomically:YES encoding:NSASCIIStringEncoding error:nil];
}

SIMASFUNC(macwritev2) {
    SIMASVariable *data = SIMASGETVARIABLEWITHARGUMENT(1);
    if (!data) { [SIMASRuntime throwException:@"NonexistentVariable" withReason:[NSString stringWithFormat:@"Variable %@ does not exist, and the function which you are using it from does not implicitly create variables.", [args objectAtIndex:1]]]; return; }
    [[[data data] toString] writeToFile:[args objectAtIndex:0] atomically:YES encoding:NSASCIIStringEncoding error:nil];
}

SIMASFUNC(quit) {
    [SIMASRuntime quitProgram];
}

SIMASFUNC(xchg) {
    if (eatShitIfArgIsInput(args, 0) || eatShitIfArgIsInput(args, 1)) return;
    SIMASVariable *var1 = SIMASGETVARIABLEWITHARGUMENT(0), *var2 = SIMASGETVARIABLEWITHARGUMENT(1);
    if (!var1) { [SIMASRuntime throwException:@"NonexistentVariable" withReason:[NSString stringWithFormat:@"Variable %@ does not exist, and the function which you are using it from does not implicitly create variables.", [args objectAtIndex:0]]]; return; }
    if (!var2) { [SIMASRuntime throwException:@"NonexistentVariable" withReason:[NSString stringWithFormat:@"Variable %@ does not exist, and the function which you are using it from does not implicitly create variables.", [args objectAtIndex:1]]]; return; }
    SIMASData *temp = [[var2 data] retain];
    [var2 setData:[var1 data]];
    [var1 setData:temp];
    [temp release];
}

@implementation SIMASStandardLibrary
+ (void)registerToSIMAS:(NSString*)prefix {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    SIMASRuntime *runtime = [SIMASRuntime runtime]; // yeee optimisation
    SIMASOperation *thing;
    thing = [SIMASOperation makeWithFunction:setVar];
    [thing setArgRange:2 toMaximum:3];
    [runtime registerOperation:thing withName:@"set" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:consolePrint];
    [thing setArgRange:1 toMaximum:1];
    [runtime registerOperation:thing withName:@"print" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:consolePrintc];
    [thing setArgRange:1 toMaximum:1];
    [runtime registerOperation:thing withName:@"printc" withPrefix:@""];
    [runtime registerOperation:[SIMASOperation makeWithFunction:consolePrintln] withName:@"println" withPrefix:@""];
    [runtime registerOperation:[SIMASOperation makeWithFunction:consolePrints] withName:@"prints" withPrefix:@""];
    
    thing = [SIMASOperation makeWithFunction:SIMASGETFUNCTION([SIMASArithmetic class], @selector(add:)) withTargetGetter:SIMASCLASSMETHODNAME(SIMASArithmetic) andSelectorGetter:nullSelector];
    [thing setArgRange:3 toMaximum:3];
    [runtime registerOperation:thing withName:@"add" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:SIMASGETFUNCTION([SIMASArithmetic class], @selector(subtract:)) withTargetGetter:SIMASCLASSMETHODNAME(SIMASArithmetic) andSelectorGetter:nullSelector];
    [thing setArgRange:3 toMaximum:3];
    [runtime registerOperation:thing withName:@"sub" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:SIMASGETFUNCTION([SIMASArithmetic class], @selector(multiply:)) withTargetGetter:SIMASCLASSMETHODNAME(SIMASArithmetic) andSelectorGetter:nullSelector];
    [thing setArgRange:3 toMaximum:3];
    [runtime registerOperation:thing withName:@"mul" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:SIMASGETFUNCTION([SIMASArithmetic class], @selector(divide:)) withTargetGetter:SIMASCLASSMETHODNAME(SIMASArithmetic) andSelectorGetter:nullSelector];
    [thing setArgRange:3 toMaximum:3];
    [runtime registerOperation:thing withName:@"div" withPrefix:@""];
    
    thing = [SIMASOperation makeWithFunction:functionsOfComparison withTargetGetter:nullTarget andSelectorGetter:SIMASSELECTORMETHODNAME(gt)];
    [thing setArgRange:3 toMaximum:3];
    [runtime registerOperation:thing withName:@"gt" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:functionsOfComparison withTargetGetter:nullTarget andSelectorGetter:SIMASSELECTORMETHODNAME(gte)];
    [thing setArgRange:3 toMaximum:3];
    [runtime registerOperation:thing withName:@"gte" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:functionsOfComparison withTargetGetter:nullTarget andSelectorGetter:SIMASSELECTORMETHODNAME(st)];
    [thing setArgRange:3 toMaximum:3];
    [runtime registerOperation:thing withName:@"st" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:functionsOfComparison withTargetGetter:nullTarget andSelectorGetter:SIMASSELECTORMETHODNAME(ste)];
    [thing setArgRange:3 toMaximum:3];
    [runtime registerOperation:thing withName:@"ste" withPrefix:@""];
    
    thing = [SIMASOperation makeWithFunction:SIMASGETFUNCTION([SIMASComparison class], @selector(logicalOr:)) withTargetGetter:SIMASCLASSMETHODNAME(SIMASComparison) andSelectorGetter:nullSelector];
    [thing setArgRange:3 toMaximum:3];
    [runtime registerOperation:thing withName:@"or" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:SIMASGETFUNCTION([SIMASComparison class], @selector(logicalNor:)) withTargetGetter:SIMASCLASSMETHODNAME(SIMASComparison) andSelectorGetter:nullSelector];
    [thing setArgRange:3 toMaximum:3];
    [runtime registerOperation:thing withName:@"nor" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:SIMASGETFUNCTION([SIMASComparison class], @selector(logicalXor:)) withTargetGetter:SIMASCLASSMETHODNAME(SIMASComparison) andSelectorGetter:nullSelector];
    [thing setArgRange:3 toMaximum:3];
    [runtime registerOperation:thing withName:@"xor" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:SIMASGETFUNCTION([SIMASComparison class], @selector(logicalAnd:)) withTargetGetter:SIMASCLASSMETHODNAME(SIMASComparison) andSelectorGetter:nullSelector];
    [thing setArgRange:3 toMaximum:3];
    [runtime registerOperation:thing withName:@"and" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:SIMASGETFUNCTION([SIMASComparison class], @selector(logicalNand:)) withTargetGetter:SIMASCLASSMETHODNAME(SIMASComparison) andSelectorGetter:nullSelector];
    [thing setArgRange:3 toMaximum:3];
    [runtime registerOperation:thing withName:@"nand" withPrefix:@""];
    
    thing = [SIMASOperation makeWithFunction:equalityOfConst withTargetGetter:nullTarget andSelectorGetter:nullSelector];
    [thing setArgRange:3 toMaximum:3];
    [runtime registerOperation:thing withName:@"eqc" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:equalityOfVars withTargetGetter:nullTarget andSelectorGetter:nullSelector];
    [thing setArgRange:3 toMaximum:3];
    [runtime registerOperation:thing withName:@"eqv" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:inequalityOfConst withTargetGetter:nullTarget andSelectorGetter:nullSelector];
    [thing setArgRange:3 toMaximum:3];
    [runtime registerOperation:thing withName:@"neqc" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:inequalityOfVars withTargetGetter:nullTarget andSelectorGetter:nullSelector];
    [thing setArgRange:3 toMaximum:3];
    [runtime registerOperation:thing withName:@"neqv" withPrefix:@""];
    
    thing = [SIMASOperation makeWithFunction:varType];
    [thing setArgRange:2 toMaximum:2];
    [runtime registerOperation:thing withName:@"type" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:conversion];
    [thing setArgRange:2 toMaximum:2];
    [runtime registerOperation:thing withName:@"conv" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:copying];
    [thing setArgRange:2 toMaximum:2];
    [runtime registerOperation:thing withName:@"copy" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:xchg];
    [thing setArgRange:2 toMaximum:2];
    [runtime registerOperation:thing withName:@"xchg" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:pointationNotation];
    [thing setArgRange:2 toMaximum:2];
    [runtime registerOperation:thing withName:@"ptr" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:negationProctation];
    [thing setArgRange:1 toMaximum:1];
    [runtime registerOperation:thing withName:@"not" withPrefix:@""];
    
    thing = [SIMASOperation makeWithFunction:jump];
    [thing setArgRange:1 toMaximum:1];
    [runtime registerOperation:thing withName:@"jump" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:jumpButConditionally];
    [thing setArgRange:2 toMaximum:2];
    [runtime registerOperation:thing withName:@"jumpv" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:jumpButConditionallyButNot];
    [thing setArgRange:2 toMaximum:2];
    [runtime registerOperation:thing withName:@"jumpnv" withPrefix:@""];

    thing = [SIMASOperation makeWithFunction:ebook];
    [thing setArgRange:2 toMaximum:2];
    [runtime registerOperation:thing withName:@"read" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:macwrite];
    [thing setArgRange:2 toMaximum:2];
    [runtime registerOperation:thing withName:@"write" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:macwritev2];
    [thing setArgRange:2 toMaximum:2];
    [runtime registerOperation:thing withName:@"writev" withPrefix:@""];
    
    thing = [SIMASOperation makeWithFunction:quit];
    [thing setMaxArgs:0];
    [runtime registerOperation:thing withName:@"quit" withPrefix:@""];
    
    [pool release];
}
@end
