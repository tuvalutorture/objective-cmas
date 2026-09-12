//
//  SIMASRuntime.m
//  objectivismas
//
//  Created by Xander Gomez on 9/6/26.
//  Copyright © 2026 Xander Gomez. All rights reserved.
//
//  I CAN'T SEE YOUR SOUL-SOUL THROUGH YOUR EYES
//  THE CRYING WALLS OF SLIDING ARCHITECTURE
//  KIDNAPPED BY THE LIKES OF PURE CONJECTURE
//  UPHOLSTERY-LOVING MEN
//  ALL DWELLING IN THE WELLS
//  KIDNAPPED BY THE LIKES OF PURE CONJECTURE
//  THEY'RE IN MY FUCKING WALLS HELP
//  I HAVE NOT SLEPT FOR 2 DAYS SINCE I STARTED WRITING THIS
//  THE CRYING WALLS OF SLIDING ARCHITECTURE ARE REAL
//  ---...---
//
//  SYSTEM OF A DOWN - THIS COCAINE MAKES ME FEEL LIKE I'M ON THIS SONG

#import "SIMASRuntime.h"
#import "SIMASFunction.h"

SIMASFUNC(labelNop) { return; }
SIMASFUNC(importNop) { return; }
SIMASFUNC(utiliseNop) { return; }

NSString *formatEscapes(NSString* str) {
    NSMutableString *string = [[str mutableCopy] autorelease];
    NSArray *formats = [NSArray arrayWithObjects:@"\\\"", @"\"", @"\\n", @"\n", @"\\\t", @"\t", @"\\;", @";", @"\\r", @"\r", @"\\\\", @"\\", nil];
    for (int i = 0; i < [formats count]; i += 2) [string replaceOccurrencesOfString:[formats objectAtIndex:i] withString:[formats objectAtIndex:i + 1] options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    return string;
}

NSString *unformatEscapes(NSString* str) {
    NSMutableString *string = [[str mutableCopy] autorelease];
    NSArray *formats = [NSArray arrayWithObjects:@"\\\\", @"\\", @"\\\"", @"\"", @"\\n", @"\n", @"\\\t", @"\t", @"\\;", @";", @"\\r", @"\r", nil];
    for (int i = 0; i < [formats count]; i += 2) [string replaceOccurrencesOfString:[formats objectAtIndex:i + 1] withString:[formats objectAtIndex:i] options:NSLiteralSearch range:NSMakeRange(0, [string length])];
    return string;
}

static int countBackslashes(NSString* string) {
    if ([string length] < 1) return 0;
    int backSlashes = 0;
    for (int i = (int)[string length] - 1; i >= 0; i--) {
        if ([string characterAtIndex:i] == '\\') backSlashes++;
        else return backSlashes;
    }
    return backSlashes;
}

NSArray *tokeniseStringExcludingQuotes(NSString* str, NSCharacterSet* charSet) {
    NSMutableArray *objects = [[str componentsSeparatedByString:@"\""] mutableCopy];
    NSMutableArray *quoted = [NSMutableArray new];
    int *quoteIndexes = (int*)malloc([objects count] * sizeof(int));
    memset(quoteIndexes, 0, [objects count] * sizeof(int));
    int index = 0;
    BOOL isInQuotes = NO;
    while ([objects count]) {
        NSMutableString *string = [[objects objectAtIndex:0] mutableCopy];
        [objects removeObjectAtIndex:0];
        int backSlashes = 0; BOOL isEvenBackslashes = NO;
        if (![string length] && [objects count] && isInQuotes) {
            quoteIndexes[index] = 1;
            [objects removeObjectAtIndex:0];
        } else {
            while ([objects count]) {
                isEvenBackslashes = !((backSlashes = countBackslashes(string)) % 2);
                quoteIndexes[index] = isInQuotes;
                if (!isEvenBackslashes && backSlashes) {
                    [string appendString:@"\""];
                    [string appendString:[objects objectAtIndex:0]];
                    [objects removeObjectAtIndex:0];
                    continue;
                }
                break;
            }
            
            isInQuotes = NO;
        }
        isInQuotes = !isInQuotes;
        [quoted addObject:string];
        [string release];
        index += 1;
    }
    [objects release];
    objects = [NSMutableArray new];
    index = 0;
    while ([quoted count]) {
        NSString *string = [[quoted objectAtIndex:0] retain];
        [quoted removeObjectAtIndex:0];
        if (!quoteIndexes[index++]) {
            NSMutableArray *sliced = [[string componentsSeparatedByCharactersInSet:charSet] mutableCopy];
            for (int i = 0; i < [sliced count]; i++) {
                [sliced replaceObjectAtIndex:i withObject:[[sliced objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                if ([[sliced objectAtIndex:i] length] < 1) [sliced removeObjectAtIndex:i--];
            }
            if ([sliced count]) [objects addObjectsFromArray:sliced];
            [sliced release];
        } else {
            [objects addObject:string];
        }
        [string release];
    }
    free(quoteIndexes);
    return [objects autorelease];
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
    return newInstruction;
}

- (BOOL)isFunction:(SIMASFUNCTYPE)function {
    return self->operation->functionPointer == function;
}

- (void)execute {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    self->operation->functionPointer(self->operation->targetGetter(self->arguments), self->operation->selectorGetter(), self->arguments);
    [pool release];
}

+ (void)preprocessImports:(NSMutableArray*)instructions {
    BOOL moreImports = NO;
    NSMutableSet *imports = [NSMutableSet new];
    do {
        moreImports = NO;
        int count = (int)[instructions count];
        for (int i = 0; i < count; i++) {
            SIMASInstruction *current = [instructions objectAtIndex:i];
            if (current->operation->functionPointer == importNop) {
                NSString *name = [current->arguments objectAtIndex:0];
                if ([imports containsObject:name]) {
                    [SIMASRuntime throwException:@"ImportFailed" withReason:[NSString stringWithFormat:@"The file %@ has already been imported.", name] withInstruction:current];
                    [imports release];
                    return;
                }
                [imports addObject:name];
                NSString *data = [NSString stringWithContentsOfFile:name encoding:NSASCIIStringEncoding error:nil];
                if (!data) {
                    [SIMASRuntime throwException:@"ImportFailed" withReason:[NSString stringWithFormat:@"The file %@ failed to import.", name] withInstruction:current];
                    [imports release];
                    return;
                }
                NSAutoreleasePool *pool = [NSAutoreleasePool new];
                NSMutableArray *newInstructions = [self parseInstructionsFromString:data];
                [instructions removeObjectAtIndex:i];
                [instructions insertObjects:newInstructions atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(i, [newInstructions count])]];
                [pool release];
                moreImports = YES;
            }
        }
    } while (moreImports);
    [imports release];
}

+ (NSMutableDictionary*)preprocessLabels:(NSMutableArray*)instructions {
    int count = (int)[instructions count];
    NSMutableDictionary* labels = [[NSMutableDictionary new] autorelease];
    for (int i = 0; i < count; i++) {
        if (((SIMASInstruction*)[instructions objectAtIndex:i])->operation->functionPointer == labelNop) {
            NSString *name = [((SIMASInstruction*)[instructions objectAtIndex:i])->arguments objectAtIndex:0];
            if ([labels objectForKey:name]) {
                [SIMASRuntime throwException:@"DuplicateLabel" withReason:[NSString stringWithFormat:@"Label '%@' is already defined.", name] withInstruction:[instructions objectAtIndex:i]];
                return nil;
            }
            [labels setObject:[NSNumber numberWithInt:i] forKey:name];
        }
    }
    return labels;
}

+ (NSMutableArray*)parseInstructionsFromString:(NSString*)string {
    NSMutableArray *instructionStrings = [NSMutableArray new];
    NSMutableString *buffer = [string mutableCopy];
    while ([string length]) { // ah shit this ends up being essentially while true XD it works tho so fuck it we ball
        NSRange rangeOfInstruction = [buffer rangeOfString:@";"];
        if (rangeOfInstruction.location == NSNotFound) break;
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        NSMutableString *instruction = [[NSMutableString new] autorelease];
        while (rangeOfInstruction.location > 0 && [buffer characterAtIndex:(rangeOfInstruction.location - 1)] == '\\') {
            rangeOfInstruction.length = rangeOfInstruction.location + 1;
            rangeOfInstruction.location = 0;
            [instruction appendString:[buffer substringWithRange:rangeOfInstruction]];
            [buffer deleteCharactersInRange:rangeOfInstruction];
            rangeOfInstruction = [buffer rangeOfString:@";"];
        }
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
        NSMutableCharacterSet *characters = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
        [characters addCharactersInString:@";"];
        NSString *str = [[[instructionStrings objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAppendingString:@";"];
        if ([str length] && [str characterAtIndex:0] == '@') { [pool release]; continue; }
        NSArray *tokenised = tokeniseStringExcludingQuotes(str, characters);
        if ([tokenised count] && [[tokenised objectAtIndex:0] length])[tokens addObject:tokenised];
        [instructionStrings removeObjectAtIndex:0];
        [pool release];
    }
    [autorel release];
    [instructionStrings release];
    
    NSMutableArray *instructions = [[NSMutableArray new] autorelease];
    while ([tokens count]) {
        NSMutableArray *string = [[tokens objectAtIndex:0] mutableCopy]; // we love accidentally shadowing our own parameters, oh well, it works so /shrug
        [tokens removeObjectAtIndex:0];
        while ([string count] && [[[string objectAtIndex:0] lowercaseString] isEqualToString:@"please"]) [string removeObjectAtIndex:0];
        if (![string count]) { [string release]; continue; }
        SIMASOperation *operation;
        if ([[[string objectAtIndex:0] lowercaseString] isEqualToString:@"utilising"]) {
            if ([string count] == 3) [SIMASRuntime throwException:@"IllegalArgumentCount"
                                                       withReason:[NSString stringWithFormat:@"The provided instruction does not contain enough arguments (either 2 or 4, got 3) for instruction utilise."]
                                                  withSnideRemark:@"like... utilising it as WHAT, buddy? \"as\" and then jack shit doesn't tell me ANYTHING i need to know, after all"];
            NSString *libName = [string objectAtIndex:1];
            NSString *prefix = [string count] == 4 && [[[string objectAtIndex:2] lowercaseString] isEqualToString:@"as"] ? [string objectAtIndex:3] : @"";
            NSBundle *bundle = [NSBundle bundleWithPath:libName];
            if (bundle && ![[SIMASRuntime runtime] isExcepted]) [[SIMASRuntime runtime] loadLibrary:bundle withPrefix:[prefix lowercaseString]];
            [string release];
            if ([[SIMASRuntime runtime] isExcepted]) return nil;
            continue;
        }
        NSString *name = nil, *prefix = nil;
        if ((operation = [[[SIMASRuntime runtime]->registeredOperations objectForKey:@""] objectForKey:[[string objectAtIndex:0] lowercaseString]]) == nil) {
            NSMutableDictionary *prefixMap = [[SIMASRuntime runtime]->registeredOperations objectForKey:[[string objectAtIndex:0] lowercaseString]];
            if (!prefixMap || [string count] < 2 || (operation = [prefixMap objectForKey:[[string objectAtIndex:1] lowercaseString]]) == nil) {
                [SIMASRuntime throwException:@"IllegalInstruction" withReason:[NSString stringWithFormat:@"Instruction '%@' is not a recognised instruction by the SIMAS runtime.", [string objectAtIndex:0]]];
                [string release]; return nil;
            }
            prefix = [string objectAtIndex:0];
            [string removeObjectAtIndex:0];
        }
        name = [string objectAtIndex:0];
        [string removeObjectAtIndex:0];
        for (int i = 0; i < [string count]; i++) [string replaceObjectAtIndex:i withObject:formatEscapes([string objectAtIndex:i])];
        SIMASInstruction *instruction = [SIMASInstruction instructionFromOperation:operation withArguments:string];
        instruction->name = [name retain];
        instruction->prefix = [prefix retain];
        int argCount = (int)[string count];
        [string release];
        if (argCount > operation->maximumArguments && operation->maximumArguments >= 0) {
            [SIMASRuntime throwException:@"IllegalArgumentCount"
                              withReason:[NSString stringWithFormat:@"The provided instruction cointains too many arguments (maximum %d, got %d) for instruction %@", operation->maximumArguments, argCount, instruction->name]
                         withInstruction:instruction];
            return nil;
        } else if (argCount < operation->minimumArguments) {
            [SIMASRuntime throwException:@"IllegalArgumentCount"
                              withReason:[NSString stringWithFormat:@"The provided instruction does not contain enough arguments (minimum %d, got %d) for instruction %@", operation->minimumArguments, argCount, instruction->name]
                         withInstruction:instruction];
            return nil;
        }
        if (instruction == nil) continue;
        [instructions addObject:instruction];
    }
    return instructions;
}

- (NSString*)stringValue {
    NSMutableArray *tokens = [NSMutableArray new];
    NSMutableString *fullInstruction = [NSMutableString new];
    if (prefix) [tokens addObject:prefix];
    [tokens addObject:name];
    [tokens addObjectsFromArray:arguments];
    while ([tokens count]) {
        NSString *token = [tokens objectAtIndex:0];
        [tokens removeObjectAtIndex:0];
        BOOL wrapInQuotes = [[token componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] count] > 1;
        if (wrapInQuotes) [fullInstruction appendString:@"\""];
        [fullInstruction appendString:token];
        if (wrapInQuotes) [fullInstruction appendString:@"\""];
        
        if (![tokens count]) [fullInstruction appendString:@";"];
        else [fullInstruction appendString:@" "];
    }
    [tokens release];
    return [fullInstruction autorelease];
}

- (void)dealloc {
    [arguments release];
    [name release];
    [prefix release];
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

+ (SIMASProgram*)loadFromString:(NSString*)string {
    SIMASProgram *newProgram = [SIMASProgram new];
    newProgram->instructions = [[SIMASInstruction parseInstructionsFromString:string] retain];
    return [newProgram autorelease];
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

SIMASCLASSMETHOD(SIMASFunction)
SIMASCLASSMETHOD(SIMASStackFrame)

id getStackFrame(NSArray* args) {
    if (![[SIMASRuntime currentProgram]->stack count]) return nil;
    if (![[[SIMASRuntime currentProgram]->stack lastObject] isKindOfClass:[SIMASStackFrame class]]) return nil;
    return [[SIMASRuntime currentProgram]->stack lastObject];
}

static SIMASRuntime** theRealRuntime() { // secret scary illegal functionality nobody must know about because if they did then the runtime is fucked. not much better than a global var but shhhshhshshsh it's fine
    static SIMASRuntime* runtime = nil;
    return &runtime;
}

@implementation SIMASRuntime
- (id)init {
    self = [super init];
    if (self && *theRealRuntime() == nil) {
        *theRealRuntime() = self; // holy pointer dance batman
        registeredClasses = [NSMutableDictionary new];
        registeredTypes = [NSMutableDictionary new];
        registeredOperations = [NSMutableDictionary new];
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        [SIMASBoolean registerToRuntime]; // evil shitty code that automatically calls [SIMASRuntime runtime] would create infinite loop without theRealRuntime indirection and sentinel and kill the fucking stack before the runtime even spawns into existence
        [SIMASNumber registerToRuntime];
        [SIMASString registerToRuntime];
        SIMASOperation *thing;
        thing = [SIMASOperation makeWithFunction:importNop];
        [thing setArgRange:1 toMaximum:1];
        [self registerOperation:thing withName:@"import" withPrefix:@""];
        thing = [SIMASOperation makeWithFunction:labelNop];
        [thing setArgRange:1 toMaximum:1];
        [self registerOperation:thing withName:@"label" withPrefix:@""];
        thing = [SIMASOperation makeWithFunction:utiliseNop];
        [thing setArgRange:1 toMaximum:3];
        [self registerOperation:thing withName:@"utilising" withPrefix:@""];
        thing = [SIMASOperation makeWithFunction:SIMASGETFUNCTION([SIMASFunction class], @selector(registerFunction:)) withTargetGetter:SIMASCLASSMETHODNAME(SIMASFunction) andSelectorGetter:nullSelector];
        [thing setMinArgs:1];
        [self registerOperation:thing withName:@"fun" withPrefix:@""];
        thing = [SIMASOperation makeWithFunction:SIMASGETFUNCTION([SIMASStackFrame class], @selector(pushStackFrame:)) withTargetGetter:SIMASCLASSMETHODNAME(SIMASStackFrame) andSelectorGetter:nullSelector];
        [thing setMinArgs:1];
        [self registerOperation:thing withName:@"call" withPrefix:@""];
        thing = [SIMASOperation makeWithFunction:SIMASGETINSTANCEFUNCTION([SIMASStackFrame class], @selector(loopStackFrame:)) withTargetGetter:getStackFrame andSelectorGetter:nullSelector];
        [thing setMinArgs:1];
        [self registerOperation:thing withName:@"end" withPrefix:@""];
        thing = [SIMASOperation makeWithFunction:SIMASGETINSTANCEFUNCTION([SIMASStackFrame class], @selector(endStackFrame:)) withTargetGetter:getStackFrame andSelectorGetter:nullSelector];
        [thing setMaxArgs:3];
        [self registerOperation:thing withName:@"ret" withPrefix:@""];
        [pool release];
        return self;
    } else {
        [self release];
        return *theRealRuntime();
    }
}

+ (SIMASRuntime*)runtime {
    SIMASRuntime* runtime = *theRealRuntime();
    if (!runtime) runtime = [SIMASRuntime new];
    return runtime;
}

+ (SIMASProgram*)currentProgram {
    return [self runtime]->currentProgram;
}

+ (NSString*)userInput {
    fflush(stdout);
    return [[[[NSString alloc] initWithData:[[NSFileHandle fileHandleWithStandardInput] availableData] encoding:NSASCIIStringEncoding] autorelease] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}

+ (void)throwException:(NSString*)exception withReason:(NSString*)reason {
    SIMASRuntime *theRuntime = [SIMASRuntime runtime];
    SIMASProgram *program = [SIMASRuntime currentProgram];
    theRuntime->exceptionOccurred = YES;
    NSArray* instructions = program ? program->instructions : nil;
    SIMASInstruction *theInstruction = nil;
    if (program && [instructions count] > program->programCounter) theInstruction = [instructions objectAtIndex:program->programCounter];
    puts("");
    NSLog(@"A %@ exception occurred: %@", exception, reason);
    if (theInstruction) NSLog(@"Faulty code: %@", [theInstruction stringValue]);
}
+ (void)throwException:(NSString*)exception withReason:(NSString*)reason withInstruction:(SIMASInstruction*)instruction {
    SIMASRuntime *theRuntime = [SIMASRuntime runtime];
    theRuntime->exceptionOccurred = YES;
    NSLog(@"A %@ exception occurred: %@\nFaulty code: %@", exception, reason, [instruction stringValue]);
}
+ (void)throwException:(NSString *)exception withReason:(NSString *)reason withSnideRemark:(NSString*)remark {
    [self throwException:exception withReason:reason];
    NSLog(@"The person who wrote the code that triggered this exception to save you from your own stupidity would also like to say: %@.", remark);
}
+ (void)quitProgram {
    [SIMASRuntime runtime]->exceptionOccurred = YES; // shit way of doing it, but this flag does indeed kill the app so
}
- (void)loadLibrary:(NSBundle *)libraryBundle withPrefix:(NSString*)prefix {
    if ([[libraryBundle principalClass] conformsToProtocol:@protocol(SIMASLibrary)]) [libraryBundle load];
    else return;
    [self registerLibrary:[libraryBundle principalClass] withPrefix:prefix];
}
- (void)registerLibrary:(Class)libraryClass withPrefix:(NSString*)prefix {
    if (![libraryClass conformsToProtocol:@protocol(SIMASLibrary)]) return;
    if ([registeredClasses objectForKey:libraryClass]) return;
    [libraryClass registerToSIMAS:prefix];
    [registeredClasses setObject:prefix forKey:(id<NSCopying>)libraryClass];
}
- (void)registerOperation:(SIMASOperation*)operation withName:(NSString*)name withPrefix:(NSString*)prefix {
    prefix = [prefix lowercaseString];
    name = [name lowercaseString];
    NSMutableDictionary *dict = [registeredOperations objectForKey:prefix];
    if (!name || !prefix) return;
    if (!dict) [registeredOperations setObject:(dict = [[NSMutableDictionary new] autorelease]) forKey:prefix];
    if ([dict objectForKey:name]) return;
    [dict setObject:operation forKey:name];
}
- (void)registerType:(Class)type withName:(NSString*)name {
    if (!name) return;
    name = [name lowercaseString];
    if ([name isEqualToString:@"in"]) [SIMASRuntime throwException:@"ReservedNameException" withReason:@"Type name 'in' is reserved."];
    else if (![registeredTypes objectForKey:name]) [registeredTypes setObject:type forKey:name];
}
- (void)executeInstructions:(NSArray*)instructions {
    for (int i = 0, count = (int)[instructions count]; i < count; i++) {
        [[instructions objectAtIndex:i] execute];
        if (exceptionOccurred) break;
    }
}

- (void)runFromString:(NSString*)string {
    appPool = [NSAutoreleasePool new];
    currentProgram = [SIMASProgram loadFromString:string];
    if (exceptionOccurred) { exceptionOccurred = NO; [appPool release]; return; }
    [SIMASInstruction preprocessImports:currentProgram->instructions];
    currentProgram->labels = [[SIMASInstruction preprocessLabels:currentProgram->instructions] retain];
    if (exceptionOccurred) { exceptionOccurred = NO; [appPool release]; return; }
    for (currentProgram->programCounter = 0; currentProgram->programCounter < [currentProgram->instructions count]; currentProgram->programCounter++) {
        [[currentProgram->instructions objectAtIndex:currentProgram->programCounter] execute];
        if (exceptionOccurred) break;
    }
    [appPool release];
    currentProgram = nil;
    exceptionOccurred = NO;
}

- (BOOL)isExcepted { return exceptionOccurred; }
@end
