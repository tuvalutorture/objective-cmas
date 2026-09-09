//
//  SIMASFunction.m
//  objectivismas
//
//  Created by Xander Gomez on 9/6/26.
//  Copyright © 2026 Xander Gomez. All rights reserved.
//
//  why don't you ask the kids at tiananmen square?
//  was fashion the reason why they were there?
//  THEY DISGUISE IT, HYPNOTISE IT
//  TELEVISION, MADE YOU BUY IT
//  i'm just sitting in my car and
//  waiting for my--
//  she's scared that i will take her away from there
//  dreams and her country left with no one there
//  MEZMERIZE THE SIMPLE MINDED
//  PROPOGANDA LEAVES US BLINDED
//  i'm just sitting in my car and
//  waiting for my damn chipotle burrito or something idk i'm tired as fuck man gimme a break

#import "SIMASFunction.h"
#import "SIMASRuntime.h"

@implementation SIMASFunction
+ (void)registerFunction:(NSArray*)args {
    SIMASProgram *program = [SIMASRuntime currentProgram];
    NSString *name = [args objectAtIndex:0];
    if ([program->stack count]) { [SIMASRuntime throwException:@"IllegalFunction" withReason:@"You cannot declare a function while inside of a function."]; return; }
    if ([name characterAtIndex:0] == '$') { [SIMASRuntime throwException:@"IllegalName" withReason:@"Names starting with '$' are reserved by the SIMAS runtime."]; return; }
    if ([program->functions objectForKey:name]) { [SIMASRuntime throwException:@"DuplicateName" withReason:[NSString stringWithFormat:@"Function %@ already exists.", name]]; return; }
    SIMASFunction *newFunc = [SIMASFunction new];
    newFunc->argumentCount = (int)[[args objectAtIndex:1] intValue] < 0 ? 0 : (int)[[args objectAtIndex:1] intValue];
    newFunc->name = name;
    newFunc->location = [SIMASRuntime currentProgram]->programCounter;
    while (((SIMASInstruction*)[program->instructions objectAtIndex:program->programCounter])->operation->functionPointer != (SIMASFUNCTYPE)[SIMASStackFrame instanceMethodForSelector:@selector(loopStackFrame:)]) {
        program->programCounter += 1;
        if (program->programCounter >= [program->instructions count]) {
            [SIMASRuntime throwException:@"EndlessFunction" withReason:[NSString stringWithFormat:@"Function %@ does not have a matching 'end fun' instruction.", name]];
            return;
        }
    }
    [program->functions setObject:newFunc forKey:name];
    [newFunc release];
}
@end

@implementation SIMASStackFrame
+ (void)pushStackFrame:(NSArray*)args {
    NSString *name = [args objectAtIndex:0];
    SIMASProgram *program = [SIMASRuntime currentProgram];
    SIMASFunction *function;
    if (!(function = [program->functions objectForKey:name])) { [SIMASRuntime throwException:@"IllegalFunction" withReason:[NSString stringWithFormat:@"Function %@ does not exist.", name]]; return; }
    if ([args count] != 1 + (function->argumentCount * 2)) {
        [SIMASRuntime throwException:@"IllegalArgumentCount" withReason:[NSString stringWithFormat:@"An improper number of arguments was passed to call to function %@ (expected %d, recieved %d)", name, 1 + (function->argumentCount * 2), (int)[args count]]];
        return;
    }
    SIMASStackFrame *stackFrame = [SIMASStackFrame new];
    NSMutableArray *newArgs = [NSMutableArray new];
    for (int i = 0; i < function->argumentCount; i++) {
        NSString *typeString = [[args objectAtIndex:i * 2 + 1] lowercaseString];
        NSString *nameString = [args objectAtIndex:i * 2 + 2];
        if ([typeString isEqualToString:@"v"]) {
            SIMASVariable *newVar = [SIMASVariable new];
            [newVar setData:[[[[program locateVariable:nameString] data] copy] autorelease]];
            [newArgs addObject:newVar];
            [newVar release];
        } else if ([typeString isEqualToString:@"p"]) {
            [newArgs addObject:[[program locateVariable:nameString] makePointer]];
        } else {
            if (![[SIMASRuntime runtime]->registeredTypes objectForKey:typeString]) { [SIMASRuntime throwException:@"NonexistentType" withReason:[NSString stringWithFormat:@"Type %@ does not exist, thus cannot be used to convert.", typeString]]; return; }
            SIMASVariable *newVar = [SIMASVariable new];
            [newVar setData:[[[SIMASRuntime runtime]->registeredTypes objectForKey:typeString] fromString:nameString]];
            [newArgs addObject:newVar];
            [newVar release];
        }
    }
    stackFrame->passedArgs = [newArgs copy];
    for (int i = 0, count = (int)[newArgs count]; i < count; i++) {
        [program->stack addObject:[newArgs lastObject]];
        [newArgs removeLastObject];
    }
    [newArgs release];
    stackFrame->function = function;
    [program->stack addObject:stackFrame];
    stackFrame->returnTo = program->programCounter;
    program->programCounter = function->location;
}
- (void)loopStackFrame:(NSArray*)args {
    [SIMASRuntime currentProgram]->programCounter = self->function->location;
}
- (void)endStackFrame:(NSArray*)args {
    SIMASProgram *program = [SIMASRuntime currentProgram];
    NSString *name = [NSString stringWithFormat:@"$%@", function->name];
    [program->variables removeObjectForKey:name];
    if ([args count] == 2) {
        SIMASVariable *newVar = [SIMASVariable new];
        NSString *type = [[args objectAtIndex:0] lowercaseString];
        if ([type isEqualToString:@"v"]) [newVar setData:[[[[program locateVariable:[args objectAtIndex:1]] data] copy] autorelease]];
        else {
            if (![[SIMASRuntime runtime]->registeredTypes objectForKey:type]) { [SIMASRuntime throwException:@"NonexistentType" withReason:[NSString stringWithFormat:@"Type %@ does not exist, thus cannot be used to convert.", type]]; return; }
            [newVar setData:[[[SIMASRuntime runtime]->registeredTypes objectForKey:type] fromString:[args objectAtIndex:1]]];
        }
        if ([newVar data]) [program->variables setObject:newVar forKey:name];
        [newVar release];
    }
    program->programCounter = returnTo;
    [program->stack removeLastObject];
    for (int i = 0; i < function->argumentCount; i++) [program->stack removeLastObject];
}

- (void)dealloc {
    [passedArgs release];
    [super dealloc];
}
@end
