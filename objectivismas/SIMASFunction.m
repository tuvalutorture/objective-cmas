//
//  SIMASFunction.m
//  objectivismas
//
//  Created by Xander Gomez on 9/6/26.
//  Copyright © 2026 Xander Gomez. All rights reserved.
//

#import "SIMASFunction.h"
#import "SIMASRuntime.h"

@implementation SIMASFunction
+ (void)registerFunction:(NSArray*)args {
    SIMASProgram *program = [SIMASRuntime currentProgram];
    NSString *name = [args objectAtIndex:0];
    if ([name characterAtIndex:0] == '$' || [program->functions objectForKey:name]) return; // handle
    SIMASFunction *newFunc = [SIMASFunction new];
    newFunc->argumentCount = (int)[[args objectAtIndex:1] intValue] < 0 ? 0 : (int)[[args objectAtIndex:1] intValue];
    newFunc->name = name;
    newFunc->location = [SIMASRuntime currentProgram]->programCounter;
    while (((SIMASInstruction*)[program->instructions objectAtIndex:program->programCounter])->operation->functionPointer != (SIMASFUNCTYPE)[SIMASStackFrame instanceMethodForSelector:@selector(endStackFrame:)]) {
        if (((SIMASInstruction*)[program->instructions objectAtIndex:program->programCounter])->operation->functionPointer == (SIMASFUNCTYPE)[SIMASFunction methodSignatureForSelector:_cmd]) return; // handle f-in-f
        program->programCounter += 1;
        if (program->programCounter > [program->instructions count]) return; // handle
    }
    program->programCounter += 1;
    [program->functions setObject:newFunc forKey:name];
    [newFunc release];
}
@end

@implementation SIMASStackFrame
+ (void)pushStackFrame:(NSArray*)args {
    NSString *name = [args objectAtIndex:0];
    SIMASProgram *program = [SIMASRuntime currentProgram];
    SIMASFunction *function;
    if (!(function = [program->functions objectForKey:name]) && [args count] != 1 + (function->argumentCount * 2)) return; // handle collision / improper arg count
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
            SIMASVariable *newVar = [SIMASVariable new];
            [newVar setData:[[[SIMASRuntime runtime]->registeredTypes objectForKey:typeString] fromString:nameString]];
            [newArgs addObject:newVar];
            [newVar release];
        }
    }
    stackFrame->passedArgs = [newArgs copy];
    for (int i = 0; i < [newArgs count]; i++) {
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
        if ([[[args objectAtIndex:0] lowercaseString] isEqualToString:@"v"]) [newVar setData:[[[[program locateVariable:[args objectAtIndex:1]] data] copy] autorelease]];
        else [newVar setData:[[[SIMASRuntime runtime]->registeredTypes objectForKey:[[args objectAtIndex:0] lowercaseString]] fromString:[args objectAtIndex:1]]];
        if ([newVar data])[program->variables setObject:newVar forKey:name];
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
