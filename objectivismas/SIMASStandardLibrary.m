//
//  SIMASStandardLibrary.m
//  objectivismas
//
//  Created by Xander Gomez on 9/6/26.
//  Copyright © 2026 Xander Gomez. All rights reserved.
//

#import "SIMASStandardLibrary.h"
#import "SIMASRuntime.h"
#import "SIMASVariable.h"
#import "SIMASFunction.h"

SIMASFUNC(setVar) {
    NSString *name = [args objectAtIndex:1], *second = [args objectAtIndex:2];
    SIMASVariable *targetVar = [[SIMASRuntime currentProgram] locateVariable:name], *sourceVar = [[SIMASRuntime currentProgram] locateVariable:second];
    if (targetVar == nil) {
        if ([name characterAtIndex:0] == '$') return; // handle
        targetVar = [SIMASVariable new];
        [[SIMASRuntime currentProgram]->variables setObject:targetVar forKey:name];
    }
    if (!sourceVar) [targetVar setData:[(Class)[[SIMASRuntime runtime]->registeredTypes objectForKey:[[args objectAtIndex:0] lowercaseString]] fromString:second]];
    else [targetVar setData:[[sourceVar data] getConverted:(Class)[[SIMASRuntime runtime]->registeredTypes objectForKey:[[args objectAtIndex:0] lowercaseString]]]];
}

SIMASFUNC(consolePrint) {
    SIMASVariable *var = [[SIMASRuntime currentProgram] locateVariable:[args objectAtIndex:0]];
    if (!var || ![var data]) return;
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
SIMASSELECTORMETHOD(gte, @selector(greaterThan:))
SIMASSELECTORMETHOD(st, @selector(lessThan:))
SIMASSELECTORMETHOD(ste, @selector(lessThanOrEqualTo:))

SIMASFUNC(functionsOfComparison) {
    SIMASNumberOperationSetup setup = [SIMASNumber setupOperation:args];
    SIMASBoolean* (*function)(id, SEL, SIMASNumber*) = (SIMASBoolean*(*)(id, SEL, SIMASNumber*))[[setup.firstVariable data] methodForSelector:_cmd];
    SIMASNumber* operator2 = setup.secondVariable ? [[setup.secondVariable data] getConverted:[SIMASNumber class]] : [SIMASNumber numberWithNumber:setup.secondOperand];
    SIMASBoolean* boolean = function([setup.firstVariable data], _cmd, operator2);
    [setup.firstVariable setData:[boolean getConverted:[[SIMASRuntime runtime]->registeredTypes objectForKey:[[args objectAtIndex:0] lowercaseString]]]];
}

SIMASFUNC(equalityOfConst) {
    SIMASVariable *variable1 = [[SIMASRuntime currentProgram] locateVariable:[args objectAtIndex:1]];
    if (!variable1) return;
    Class type = [[SIMASRuntime runtime]->registeredTypes objectForKey:[[args objectAtIndex:0] lowercaseString]];
    SIMASData *variable2 = [type fromString:[args objectAtIndex:2]];
    [variable1 setData:[SIMASBoolean booleanWithBoolean:([[[variable1 data] getConverted:type] isEqualTo:variable2])]];
}

SIMASFUNC(inequalityOfConst) {
    SIMASVariable *variable1 = [[SIMASRuntime currentProgram] locateVariable:[args objectAtIndex:1]];
    if (!variable1) return;
    Class type = [[SIMASRuntime runtime]->registeredTypes objectForKey:[[args objectAtIndex:0] lowercaseString]];
    SIMASData *variable2 = [type fromString:[args objectAtIndex:2]];
    [variable1 setData:[SIMASBoolean booleanWithBoolean:!([[[variable1 data] getConverted:type] isEqualTo:variable2])]];
}

SIMASFUNC(equalityOfVars) {
    SIMASVariable *variable1 = [[SIMASRuntime currentProgram] locateVariable:[args objectAtIndex:1]];
    SIMASVariable *variable2 = [[SIMASRuntime currentProgram] locateVariable:[args objectAtIndex:2]];
    if (!variable1 || !variable2) return;
    Class type = [[SIMASRuntime runtime]->registeredTypes objectForKey:[[args objectAtIndex:0] lowercaseString]];
    [variable1 setData:[SIMASBoolean booleanWithBoolean:([[[variable1 data] getConverted:type] isEqualTo:[variable2 data]])]];
}

SIMASFUNC(inequalityOfVars) {
    SIMASVariable *variable1 = [[SIMASRuntime currentProgram] locateVariable:[args objectAtIndex:1]];
    SIMASVariable *variable2 = [[SIMASRuntime currentProgram] locateVariable:[args objectAtIndex:2]];
    if (!variable1 || !variable2) return;
    Class type = [[SIMASRuntime runtime]->registeredTypes objectForKey:[[args objectAtIndex:0] lowercaseString]];
    [variable1 setData:[SIMASBoolean booleanWithBoolean:!([[[variable1 data] getConverted:type] isEqualTo:[variable2 data]])]];
}

SIMASFUNC(varType) {
    SIMASVariable *variable1 = [[SIMASRuntime currentProgram] locateVariable:[args objectAtIndex:0]];
    NSString *name = variable1 ? [[variable1 class] name] : @"nil";
    SIMASVariable *variable2 = [[SIMASRuntime currentProgram] locateVariable:[args objectAtIndex:1]];
    if (variable2 == nil) {
        if ([[args objectAtIndex:1] characterAtIndex:0] == '$') return; // handle
        variable2 = [SIMASVariable new];
        [[SIMASRuntime currentProgram]->variables setObject:variable2 forKey:[args objectAtIndex:1]];
    }
    [variable2 setData:[SIMASString stringWithString:name]];
}

SIMASFUNC(conversion) {
    SIMASVariable *variable1 = [[SIMASRuntime currentProgram] locateVariable:[args objectAtIndex:0]];
    Class type = [[SIMASRuntime runtime]->registeredTypes objectForKey:[args objectAtIndex:1]];
    if (!variable1) return; // handle
    [variable1 setData:[[variable1 data] getConverted:type]];
}

SIMASFUNC(copying) {
    SIMASVariable *variable1 = [[SIMASRuntime currentProgram] locateVariable:[args objectAtIndex:0]];
    SIMASVariable *variable2 = [[SIMASRuntime currentProgram] locateVariable:[args objectAtIndex:1]];
    if (!variable1) return; // handle
    if (variable2 == nil) {
        if ([[args objectAtIndex:1] characterAtIndex:0] == '$') return; // handle
        variable2 = [SIMASVariable new];
        [[SIMASRuntime currentProgram]->variables setObject:variable2 forKey:[args objectAtIndex:1]];
    }
    [variable2 setData:[[[variable1 data] copy] autorelease]];
}

SIMASFUNC(pointationNotation) {
    SIMASVariable *variable1 = [[SIMASRuntime currentProgram] locateVariable:[args objectAtIndex:0]];
    NSString* name = [args objectAtIndex:1];
    if (!variable1 || [name characterAtIndex:0] == '$' || [[args objectAtIndex:0] characterAtIndex:0] == '$') return; // handle
    SIMASVariable *pointer = [[SIMASRuntime currentProgram] locateVariable:name];
    if (pointer) [[SIMASRuntime currentProgram]->variables removeObjectForKey:name];
    [[SIMASRuntime currentProgram]->variables setObject:[variable1 makePointer] forKey:name];
}

SIMASFUNC(negationProctation) {
    SIMASVariable *variable = [[SIMASRuntime currentProgram] locateVariable:[args objectAtIndex:0]];
    if (!variable) return; // handle
    [variable setData:[SIMASBoolean booleanWithBoolean:![[variable data] getConverted:[SIMASBoolean class]]]];
}

SIMASFUNC(jump) {
    NSNumber *jump = [[SIMASRuntime currentProgram]->labels objectForKey:[args objectAtIndex:0]];
    if (!jump) return; // handle
    [SIMASRuntime currentProgram]->programCounter = [jump intValue];
}

SIMASFUNC(jumpButConditionally) {
    NSNumber *jump = [[SIMASRuntime currentProgram]->labels objectForKey:[args objectAtIndex:0]];
    if (!jump) return; // handle
    SIMASVariable *condition = [[SIMASRuntime currentProgram] locateVariable:[args objectAtIndex:1]];
    if (!condition) return; // handle
    if ([[[condition data] getConverted:[SIMASBoolean class]] boolValue])[SIMASRuntime currentProgram]->programCounter = [jump intValue];
}

SIMASFUNC(jumpButConditionallyButNot) {
    NSNumber *jump = [[SIMASRuntime currentProgram]->labels objectForKey:[args objectAtIndex:0]];
    if (!jump) return; // handle
    SIMASVariable *condition = [[SIMASRuntime currentProgram] locateVariable:[args objectAtIndex:1]];
    if (!condition) return; // handle
    if (![[[condition data] getConverted:[SIMASBoolean class]] boolValue])[SIMASRuntime currentProgram]->programCounter = [jump intValue];
}

SIMASFUNC(ebook) {
    SIMASVariable *storage = [[SIMASRuntime currentProgram] locateVariable:[args objectAtIndex:1]];
    NSString *data = [NSString stringWithContentsOfFile:[args objectAtIndex:0] encoding:NSASCIIStringEncoding error:nil];
    if (!data) return; // handle
    if (storage == nil) {
        if ([[args objectAtIndex:1] characterAtIndex:0] == '$') return; // handle
        storage = [SIMASVariable new];
        [[SIMASRuntime currentProgram]->variables setObject:storage forKey:[args objectAtIndex:1]];
    }
    [storage setData:[SIMASString stringWithString:data]];
}

SIMASFUNC(macwrite) {
    [[args objectAtIndex:1] writeToFile:[args objectAtIndex:0] atomically:YES encoding:NSASCIIStringEncoding error:nil];
}

SIMASFUNC(macwritev2) {
    SIMASVariable *data = [[SIMASRuntime currentProgram] locateVariable:[args objectAtIndex:1]];
    if (!data) return; // handle
    [[[data data] toString] writeToFile:[args objectAtIndex:0] atomically:YES encoding:NSASCIIStringEncoding error:nil];
}

SIMASCLASSMETHOD(SIMASFunction)
SIMASCLASSMETHOD(SIMASStackFrame)

id getStackFrame(NSArray* args) {
    if (![[SIMASRuntime currentProgram]->stack count]) return nil;
    if (![[[SIMASRuntime currentProgram]->stack lastObject] isKindOfClass:[SIMASStackFrame class]]) return nil;
    return [[SIMASRuntime currentProgram]->stack lastObject];
}

@implementation SIMASStandardLibrary
+ (void)registerToSIMAS:(NSString*)prefix {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    SIMASRuntime *runtime = [SIMASRuntime runtime]; // yeee optimisation
    [runtime registerType:[SIMASBoolean class] withName:@"bool"];
    [runtime registerType:[SIMASNumber class] withName:@"num"];
    [runtime registerType:[SIMASString class] withName:@"str"];
    SIMASOperation *thing;
    thing = [SIMASOperation makeWithFunction:setVar];
    [thing setArgRange:3 toMaximum:3];
    [runtime registerOperation:thing withName:@"set" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:consolePrint];
    [thing setArgRange:1 toMaximum:1];
    [runtime registerOperation:thing withName:@"print" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:consolePrintc];
    [thing setArgRange:1 toMaximum:1];
    [runtime registerOperation:thing withName:@"printc" withPrefix:@""];
    [runtime registerOperation:[SIMASOperation makeWithFunction:consolePrintln] withName:@"println" withPrefix:@""];
    [runtime registerOperation:[SIMASOperation makeWithFunction:consolePrints] withName:@"prints" withPrefix:@""];
    
    thing = [SIMASOperation makeWithFunction:SIMASGETFUNCTION([SIMASNumber class], @selector(add:)) withTargetGetter:SIMASCLASSMETHODNAME(SIMASNumber) andSelectorGetter:nullSelector];
    [thing setArgRange:3 toMaximum:3];
    [runtime registerOperation:thing withName:@"add" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:SIMASGETFUNCTION([SIMASNumber class], @selector(subtract:)) withTargetGetter:SIMASCLASSMETHODNAME(SIMASNumber) andSelectorGetter:nullSelector];
    [thing setArgRange:3 toMaximum:3];
    [runtime registerOperation:thing withName:@"sub" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:SIMASGETFUNCTION([SIMASNumber class], @selector(multiply:)) withTargetGetter:SIMASCLASSMETHODNAME(SIMASNumber) andSelectorGetter:nullSelector];
    [thing setArgRange:3 toMaximum:3];
    [runtime registerOperation:thing withName:@"mul" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:SIMASGETFUNCTION([SIMASNumber class], @selector(divide:)) withTargetGetter:SIMASCLASSMETHODNAME(SIMASNumber) andSelectorGetter:nullSelector];
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
    
    thing = [SIMASOperation makeWithFunction:SIMASGETFUNCTION([SIMASBoolean class], @selector(logicalOr:)) withTargetGetter:SIMASCLASSMETHODNAME(SIMASBoolean) andSelectorGetter:nullSelector];
    [thing setArgRange:3 toMaximum:3];
    [runtime registerOperation:thing withName:@"or" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:SIMASGETFUNCTION([SIMASBoolean class], @selector(logicalNor:)) withTargetGetter:SIMASCLASSMETHODNAME(SIMASBoolean) andSelectorGetter:nullSelector];
    [thing setArgRange:3 toMaximum:3];
    [runtime registerOperation:thing withName:@"nor" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:SIMASGETFUNCTION([SIMASBoolean class], @selector(logicalXor:)) withTargetGetter:SIMASCLASSMETHODNAME(SIMASBoolean) andSelectorGetter:nullSelector];
    [thing setArgRange:3 toMaximum:3];
    [runtime registerOperation:thing withName:@"xor" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:SIMASGETFUNCTION([SIMASBoolean class], @selector(logicalAnd:)) withTargetGetter:SIMASCLASSMETHODNAME(SIMASBoolean) andSelectorGetter:nullSelector];
    [thing setArgRange:3 toMaximum:3];
    [runtime registerOperation:thing withName:@"and" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:SIMASGETFUNCTION([SIMASBoolean class], @selector(logicalNand:)) withTargetGetter:SIMASCLASSMETHODNAME(SIMASBoolean) andSelectorGetter:nullSelector];
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
    thing = [SIMASOperation makeWithFunction:pointationNotation];
    [thing setArgRange:2 toMaximum:2];
    [runtime registerOperation:thing withName:@"ptr" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:negationProctation];
    [thing setArgRange:1 toMaximum:1];
    [runtime registerOperation:thing withName:@"not" withPrefix:@""];
    
    thing = [SIMASOperation makeWithFunction:SIMASGETFUNCTION([SIMASFunction class], @selector(registerFunction:)) withTargetGetter:SIMASCLASSMETHODNAME(SIMASFunction) andSelectorGetter:nullSelector];
    [thing setMinArgs:1];
    [runtime registerOperation:thing withName:@"fun" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:SIMASGETFUNCTION([SIMASStackFrame class], @selector(pushStackFrame:)) withTargetGetter:SIMASCLASSMETHODNAME(SIMASStackFrame) andSelectorGetter:nullSelector];
    [thing setMinArgs:1];
    [runtime registerOperation:thing withName:@"call" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:SIMASGETINSTANCEFUNCTION([SIMASStackFrame class], @selector(loopStackFrame:)) withTargetGetter:getStackFrame andSelectorGetter:nullSelector];
    [thing setMinArgs:1];
    [runtime registerOperation:thing withName:@"end" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:SIMASGETINSTANCEFUNCTION([SIMASStackFrame class], @selector(endStackFrame:)) withTargetGetter:getStackFrame andSelectorGetter:nullSelector];
    [thing setMaxArgs:3];
    [runtime registerOperation:thing withName:@"ret" withPrefix:@""];

    thing = [SIMASOperation makeWithFunction:importNop];
    [thing setArgRange:1 toMaximum:1];
    [runtime registerOperation:thing withName:@"import" withPrefix:@""];
    thing = [SIMASOperation makeWithFunction:labelNop];
    [thing setArgRange:1 toMaximum:1];
    [runtime registerOperation:thing withName:@"label" withPrefix:@""];
    
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
    
    thing = [SIMASOperation makeWithFunction:utiliseNop];
    [thing setArgRange:1 toMaximum:3];
    [runtime registerOperation:thing withName:@"utilising" withPrefix:@""];
    
    [pool release];
}
@end
