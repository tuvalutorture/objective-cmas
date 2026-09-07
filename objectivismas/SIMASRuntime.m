//
//  SIMASRuntime.m
//  objectivismas
//
//  Created by Xander Gomez on 9/6/26.
//  Copyright © 2026 Xander Gomez. All rights reserved.
//

#import "SIMASRuntime.h"
#import "SIMASStandardLibrary.h"
#include <ctype.h>

SIMASFUNC(labelNop) {
    return;
}

SIMASFUNC(importNop) {
    return;
}

SIMASFUNC(utiliseNop) {
    return;
}

NSString *formatEscapes(NSString* str) {
    NSMutableString *string = [[str mutableCopy] autorelease];
    NSArray *formats = [NSArray arrayWithObjects:@"\\\"", @"\"", @"\\n", @"\n", @"\\;", @";", @"\\r", @"\r", @"\\\\", @"\\", nil];
    for (int i = 0; i < [formats count]; i += 2) [string replaceOccurrencesOfString:[formats objectAtIndex:i] withString:[formats objectAtIndex:i + 1] options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    return string;
}

NSArray *tokeniseStringExcludingQuotes(NSString* str) {
    NSMutableArray *unprocessedComponents = [[NSMutableArray new] autorelease];
    NSMutableArray *indiciesWithQuotes = [[NSMutableArray new] autorelease];
    NSMutableString *fullString = [[str mutableCopy] autorelease], *quotes = [[NSMutableString new] autorelease], *finalString = [[NSMutableString new] autorelease];
    int currentIndex = 0;
    while ([fullString length]) {
        NSRange range = [fullString rangeOfString:@"\""];
        if (range.location == NSNotFound) { [unprocessedComponents addObject:fullString]; break; }
        NSMutableString *firstString = [[NSMutableString new] autorelease];
        NSMutableString *currentString = firstString;
        int stage = 0;
        
    quotesLoop:
        while (range.location - 1 < [fullString length] && range.location - 1 >= 0 && [fullString characterAtIndex:range.location - 1] == '\\') {
            range.length = range.location + 1;
            range.location = 0;
            [currentString appendString:[fullString substringWithRange:range]];
            [fullString deleteCharactersInRange:range];
            range = [fullString rangeOfString:@"\""];
            if (range.location == NSNotFound) break;
        }
        
        range.length = range.location;
        if (range.length == NSNotFound) range.length = [fullString length];
        range.location = 0;
        if ([fullString length] < range.location) return nil;
        [currentString appendString:[fullString substringWithRange:range]];
        if (range.length < [fullString length]) range.length += 1;
        if ([fullString length] < range.location) return nil;
        [fullString deleteCharactersInRange:range];
        [unprocessedComponents addObject:currentString];
    
        switch (stage) {
            case 0: goto firstStage;
            case 1: goto secondStage;
            case 2: goto thirdStage;
        }
        
    firstStage:
        range = [fullString rangeOfString:@"\""];
        currentString = quotes;
        currentIndex += 1;
        stage += 1;
        goto quotesLoop;
        
    secondStage:
        [indiciesWithQuotes addObject:[NSNumber numberWithInteger:currentIndex]];
        range = [fullString rangeOfString:@"\""];
        currentString = finalString;
        currentIndex += 1;
        stage += 1;
        goto quotesLoop;
        
    thirdStage:
        continue;
    }
    
    NSMutableArray *processed = [NSMutableArray new];
    currentIndex = 0;
    while ([unprocessedComponents count]) {
        if ([indiciesWithQuotes count] && currentIndex == [[indiciesWithQuotes objectAtIndex:0] intValue]) {
            [indiciesWithQuotes removeObjectAtIndex:0];
            [processed addObject:[unprocessedComponents objectAtIndex:0]];
        } else {
            NSMutableArray *sliced = [[[unprocessedComponents objectAtIndex:0] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] mutableCopy];
            for (int i = 0; i < [sliced count]; i++) {
                if ([[sliced objectAtIndex:i] length] < 1) [sliced removeObjectAtIndex:i--];
            }
            if ([sliced count]) [processed addObjectsFromArray:sliced];
            [sliced release];
        }
        [unprocessedComponents removeObjectAtIndex:0];
        currentIndex += 1;
    }
    return [processed autorelease];
}

@implementation SIMASOperation
- (id)init {
    self = [super init];
    if (self) {
        self->maximumArguments = -1;
    }
    return self;
}
+ (SIMASOperation*)makeWithFunction:(void (*)(id, SEL, NSArray*))func {
    SIMASOperation *newOp = [SIMASOperation new];
    newOp->functionPointer = func;
    newOp->targetGetter = nullTarget;
    newOp->selectorGetter = nullSelector;
    return [newOp autorelease];
}
+ (SIMASOperation*)makeWithFunction:(void (*)(id, SEL, NSArray*))func withTargetGetter:(id (*)(NSArray*))target andSelectorGetter:(SEL (*)(void))selector {
    SIMASOperation *newOp = [SIMASOperation makeWithFunction:func];
    newOp->targetGetter = target;
    newOp->selectorGetter = selector;
    return newOp;
}
- (void)setMaxArgs:(int)maximum { maximumArguments = maximum; }
- (void)setMinArgs:(int)minimum { minimumArguments = minimum; }
- (void)setArgRange:(int)minimum toMaximum:(int)maximum { minimumArguments = minimum; maximumArguments = maximum; };
@end

@implementation SIMASInstruction
+ (id)instructionFromOperation:(SIMASOperation*)op {
    SIMASInstruction *newInstruction = [SIMASInstruction new];
    newInstruction->operation = op;
    return [newInstruction autorelease];
}
+ (id)instructionFromOperation:(SIMASOperation*)op withArguments:(NSArray*)arguments {
    SIMASInstruction *newInstruction = [self instructionFromOperation:op];
    newInstruction->arguments = [arguments copy];
    if (([newInstruction->arguments count] > op->maximumArguments && op->maximumArguments != -1) || [newInstruction->arguments count] < op->minimumArguments) return nil; // error handle
    return newInstruction;
}

- (void)execute {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    self->operation->functionPointer(self->operation->targetGetter(self->arguments), self->operation->selectorGetter(), self->arguments);
    [pool release];
}

- (void)dealloc {
    [arguments release];
    [super dealloc];
}
@end

@implementation SIMASProgram
- (id)init {
    self = [super init];
    if (self) {
        self->functions = [NSMutableDictionary new];
        self->instructions = [NSMutableArray new];
        self->labels = [NSMutableDictionary new];
        self->stack = [NSMutableArray new];
        self->variables = [NSMutableDictionary new];
    }
    return self;
}

- (SIMASVariable*)locateVariable:(NSString*)name { // methods which call this should handle nil
    if ([name characterAtIndex:0] == '$') {
        NSString *cut = [name substringFromIndex:1];
        if (isnumber([cut characterAtIndex:0]) && [cut characterAtIndex:0] != '0') {
            int stackIndex = [cut intValue];
            if ([stack count] - 1 - stackIndex < 0) return nil;
            return [stack objectAtIndex:([stack count] - 1 - stackIndex)];
        }
        else return [variables objectForKey:name];
    } else return [variables objectForKey:name];
}

+ (SIMASProgram*)loadFromString:(NSString*)string {
    SIMASProgram *newProgram = [SIMASProgram new];
    NSMutableArray *instructionStrings = [NSMutableArray new];
    NSMutableString *buffer = [string mutableCopy];
    while ([string length]) {
        NSRange rangeOfInstruction = [buffer rangeOfString:@";"];
        if (rangeOfInstruction.location == NSNotFound) break;
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        NSMutableString *instruction = [[NSMutableString new] autorelease];
    checkLiteral: // used to force a while-like state without writing a clunky while loop
        if (rangeOfInstruction.location > 0 && [buffer characterAtIndex:(rangeOfInstruction.location - 1)] == '\\') {
            rangeOfInstruction.length = rangeOfInstruction.location + 1;
            rangeOfInstruction.location = 0;
            [instruction appendString:[buffer substringWithRange:rangeOfInstruction]];
            [buffer deleteCharactersInRange:rangeOfInstruction];
            rangeOfInstruction = [buffer rangeOfString:@";"];
        } else goto sliceString;
        goto checkLiteral;
    sliceString:
        rangeOfInstruction.length = rangeOfInstruction.location;
        rangeOfInstruction.location = 0;
        if ([buffer length] < rangeOfInstruction.length) { [pool release]; break; }
        [instruction appendString:[buffer substringWithRange:rangeOfInstruction]];
        if ([buffer length] >= rangeOfInstruction.length + 1) rangeOfInstruction.length += 1;
        [buffer deleteCharactersInRange:rangeOfInstruction];
        [instructionStrings addObject:instruction];
        [pool release];
    }
    [buffer release];
    
    NSMutableArray *tokens = [NSMutableArray new];
    NSAutoreleasePool *autorel = [NSAutoreleasePool new];
    while ([instructionStrings count]) {
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        NSArray *tokenised = tokeniseStringExcludingQuotes([instructionStrings objectAtIndex:0]);
        if ([tokenised count] && [[tokenised objectAtIndex:0] length] && [[tokenised objectAtIndex:0] characterAtIndex:0] != '@')[tokens addObject:tokenised];
        [instructionStrings removeObjectAtIndex:0];
        [pool release];
    }
    [autorel release];
    [instructionStrings release];
    
    while ([tokens count]) {
        NSMutableArray *string = [[tokens objectAtIndex:0] mutableCopy];
        [tokens removeObjectAtIndex:0];
        while ([string count] && [[[string objectAtIndex:0] lowercaseString] isEqualToString:@"please"]) [string removeObjectAtIndex:0];
        if (![string count]) { [string release]; continue; }
        SIMASOperation *operation;
        if ([[[string objectAtIndex:0] lowercaseString] isEqualToString:@"utilising"]) {
            NSString *libName = [string objectAtIndex:1];
            NSString *prefix = [string count] == 4 && [[[string objectAtIndex:2] lowercaseString] isEqualToString:@"as"] ? [string objectAtIndex:3] : nil;
            NSBundle *bundle = [NSBundle bundleWithPath:libName];
            if (bundle) [[SIMASRuntime runtime] loadLibrary:bundle withPrefix:prefix];
            [string release];
            continue;
        }
        
        if ((operation = [[[SIMASRuntime runtime]->registeredOperations objectForKey:@""] objectForKey:[[string objectAtIndex:0] lowercaseString]]) == nil) {
            NSMutableDictionary *prefixMap = [[SIMASRuntime runtime]->registeredOperations objectForKey:[[string objectAtIndex:0] lowercaseString]];
            if (!prefixMap || [string count] < 2 || (operation = [prefixMap objectForKey:[[string objectAtIndex:1] lowercaseString]]) == nil) { [string release]; continue; }
            [string removeObjectAtIndex:0];
        }
        [string removeObjectAtIndex:0];
        if ([string count] > operation->maximumArguments || [string count] < operation->minimumArguments) { [string release]; continue; }
        for (int i = 0; i < [string count]; i++) [string replaceObjectAtIndex:i withObject:formatEscapes([string objectAtIndex:i])];
        SIMASInstruction *instruction = [SIMASInstruction instructionFromOperation:operation withArguments:string];
        [string release];
        if (instruction == nil) continue;
        [newProgram->instructions addObject:instruction];
    }
    return newProgram;
}

- (void)preprocesImports {
    BOOL moreImports = NO;
    NSMutableSet *imports = [NSMutableSet new];
    do {
        moreImports = NO;
        int count = (int)[instructions count];
        for (int i = 0; i < count; i++) {
            SIMASInstruction *current = [instructions objectAtIndex:i];
            if (current->operation->functionPointer == importNop) {
                NSString *name = [current->arguments objectAtIndex:0];
                if ([imports containsObject:name]) continue;
                [imports addObject:name];
                NSString *data = [NSString stringWithContentsOfFile:name encoding:NSASCIIStringEncoding error:nil];
                if (!data) continue;
                SIMASProgram *program = [SIMASProgram loadFromString:data];
                [instructions insertObjects:program->instructions atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(i, [program->instructions count])]];
                [program release];
                moreImports = YES;
            }
        }
    } while (moreImports);
}

- (void)preprocessLabels {
    int count = (int)[instructions count];
    for (int i = 0; i < count; i++) {
        if (((SIMASInstruction*)[instructions objectAtIndex:i])->operation->functionPointer == labelNop) {
            NSString *name = [((SIMASInstruction*)[instructions objectAtIndex:i])->arguments objectAtIndex:0];
            if ([labels objectForKey:name]) return; // handle
            [labels setObject:[NSNumber numberWithInt:i] forKey:name];
        }
    }
}

- (void)dealloc {
    [self->functions release];
    [self->instructions release];
    [self->labels release];
    [self->stack release];
    [self->variables release];
    [super dealloc];
}
@end

@implementation SIMASRuntime
- (id)init {
    self = [super init];
    if (self) {
        registeredTypes = [NSMutableDictionary new];
        registeredOperations = [NSMutableDictionary new];
    }
    return self;
}
+ (SIMASRuntime*)runtime {
    static SIMASRuntime* runtime = nil;
    if (runtime == nil) runtime = [SIMASRuntime new];
    return runtime;
}
+ (SIMASProgram*)currentProgram {
    return [self runtime]->currentProgram;
}
- (void)loadLibrary:(NSBundle *)libraryBundle withPrefix:(NSString*)prefix {
    if ([[libraryBundle principalClass] respondsToSelector:@selector(registerToSIMAS:)]) [libraryBundle load];
    else return;
    [self registerLibrary:[libraryBundle principalClass] withPrefix:prefix];
}
- (void)registerLibrary:(Class)libraryClass withPrefix:(NSString*)prefix {
    if (![libraryClass respondsToSelector:@selector(registerToSIMAS:)]) return;
    if ([registeredClasses containsObject:libraryClass]) return;
    [libraryClass registerToSIMAS:prefix];
    [registeredClasses addObject:libraryClass];
}
- (void)registerOperation:(SIMASOperation*)operation withName:(NSString*)name withPrefix:(NSString*)prefix {
    NSMutableDictionary *dict = [registeredOperations objectForKey:prefix];
    if (!name || !prefix) return;
    if (!dict) [registeredOperations setObject:(dict = [[NSMutableDictionary new] autorelease]) forKey:prefix];
    if ([dict objectForKey:name]) return;
    [dict setObject:operation forKey:name];
}
- (void)registerType:(Class)type withName:(NSString*)name {
    if (!name) return;
    if ([registeredTypes objectForKey:name]) return;
    [registeredTypes setObject:type forKey:name];
}

- (void)runFromString:(NSString*)string {
    currentProgram = [SIMASProgram loadFromString:string];
    [currentProgram preprocesImports];
    [currentProgram preprocessLabels];
    for (currentProgram->programCounter = 0; currentProgram->programCounter < [currentProgram->instructions count]; currentProgram->programCounter++) {
        [[currentProgram->instructions objectAtIndex:currentProgram->programCounter] execute];
    }
    [currentProgram release];
    currentProgram = nil;
}
@end
