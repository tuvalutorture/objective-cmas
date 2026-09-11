//
//  SIMASList.m
//  listeria
//
//  Created by Xander Gomez on 9/6/26.
//  Copyright © 2026 Xander Gomez. All rights reserved.
//

#import "SIMASList.h"

SIMASList *boilerplate(NSArray *args) {
    SIMASVariable *list = SIMASGETVARIABLEWITHARGUMENT(0);
    if (!list) { [SIMASRuntime throwException:@"NonexistentList" withReason:[NSString stringWithFormat:@"List %@ does not exist.", [args objectAtIndex:0]]]; return nil; }
    if (![[list data] isKindOfClass:[SIMASList class]]) { [SIMASRuntime throwException:@"IllegalType" withReason:[NSString stringWithFormat:@"Variable %@ is not a list.", [args objectAtIndex:0]]]; return nil; }
    return [list data];
}

SIMASFUNC(newList) {
    if ([[args objectAtIndex:0] characterAtIndex:0] == '$') { [SIMASRuntime throwException:@"IllegalName" withReason:@"List names cannot start with '$' (reserved)."]; return; }
    if (SIMASGETVARIABLEWITHARGUMENT(0)) { [SIMASRuntime throwException:@"DuplicateName" withReason:[NSString stringWithFormat:@"List or variable %@ already exists.", [args objectAtIndex:0]]]; return; }
    SIMASVariable *newList = [SIMASVariable new];
    [newList setData:[SIMASList new]];
    [[SIMASRuntime currentProgram]->variables setObject:[newList autorelease] forKey:[args objectAtIndex:0]];
}

SIMASFUNC(appv) {
    SIMASList *target = boilerplate(args);
    if (!target) return;
    for (int i = 2; i < [args count]; i++) {
        SIMASData *var = [args objectAtIndex:i];
        if (!var) { [SIMASRuntime throwException:@"NonexistentVariable" withReason:[NSString stringWithFormat:@"Variable %@ does not exist, and the function which you are using it from does not implicitly create variables.", [args objectAtIndex:i]]]; return; }
        [target appendObject:[var copy]];
    }
}

SIMASFUNC(appc) {
    SIMASList *target = boilerplate(args);
    if (!target) return;
    Class type = SIMASGETTYPEWITHARGUMENT(1);
    if (!type) { [SIMASRuntime throwException:@"NonexistentType" withReason:[NSString stringWithFormat:@"Type %@ does not exist, thus cannot be used to create a variable.", [args objectAtIndex:1]]]; return; }
    for (int i = 2; i < [args count]; i++) [target appendObject:[type fromString:[args objectAtIndex:i]]];
}

SIMASFUNC(upv) {
    SIMASList *target = boilerplate(args);
    if (!target) return;
    int index;
    if (SIMASGETVARIABLEWITHARGUMENT(1)) index = (int)((SIMASNumberBox*)[[[SIMASGETVARIABLEWITHARGUMENT(1) data] getConverted:[SIMASNumber class]] data])->num;
    else index = [[args objectAtIndex:1] intValue];
    if (index > [target count] || index < 1) { [SIMASRuntime throwException:@"IllegalIndex" withReason:[NSString stringWithFormat:@"Index %d is not a valid index of list %@. (max %d, minimum 1)", index, [args objectAtIndex:0], [target count]]]; return; }
    index -= 1;
    SIMASData *var = [SIMASGETVARIABLEWITHARGUMENT(3) data];
    if (!var) { [SIMASRuntime throwException:@"NonexistentVariable" withReason:[NSString stringWithFormat:@"Variable %@ does not exist, and the function which you are using it from does not implicitly create variables.", [args objectAtIndex:3]]]; return; }
    if ([[SIMASRuntime runtime] isExcepted]) return;
    [target replaceObject:index withObject:[var copy]];
}

SIMASFUNC(upc) {
    SIMASList *target = boilerplate(args);
    if (!target) return;
    int index;
    if (SIMASGETVARIABLEWITHARGUMENT(1)) {
        SIMASNumberBox *data = [[[SIMASGETVARIABLEWITHARGUMENT(1) data] getConverted:[SIMASNumber class]] data];
        if (!data) return;
        index = (int)((SIMASNumberBox*)data)->num;
    } else index = [[args objectAtIndex:1] intValue];
    if (index > [target count] || index < 1) { [SIMASRuntime throwException:@"IllegalIndex" withReason:[NSString stringWithFormat:@"Index %d is not a valid index of list %@. (max %d, minimum 1)", index, [args objectAtIndex:0], [target count]]]; return; }
    Class type = SIMASGETTYPEWITHARGUMENT(2);
    if (!type) { [SIMASRuntime throwException:@"NonexistentType" withReason:[NSString stringWithFormat:@"Type %@ does not exist, thus cannot be used to create a variable.", [args objectAtIndex:1]]]; return; }
    index -= 1;
    [target replaceObject:index withObject:[type fromString:[args objectAtIndex:3]]];
}

SIMASFUNC(del) {
    SIMASList *target = boilerplate(args);
    if (!target) return;
    int index;
    if (SIMASGETVARIABLEWITHARGUMENT(1)) {
        SIMASNumberBox *data = [[[SIMASGETVARIABLEWITHARGUMENT(1) data] getConverted:[SIMASNumber class]] data];
        if (!data) return;
        index = (int)((SIMASNumberBox*)data)->num;
    } else index = [[args objectAtIndex:1] intValue];
    if (index > [target count] || index < 1) { [SIMASRuntime throwException:@"IllegalIndex" withReason:[NSString stringWithFormat:@"Index %d is not a valid index of list %@. (max %d, minimum 1)", index, [args objectAtIndex:0], [target count]]]; return; }
    index -= 1;
    [target deleteObject:index];
}

SIMASFUNC(acc) {
    SIMASList *target = boilerplate(args);
    if (!target) return;
    int index;
    if (SIMASGETVARIABLEWITHARGUMENT(1)) {
        SIMASNumberBox *data = [[[SIMASGETVARIABLEWITHARGUMENT(1) data] getConverted:[SIMASNumber class]] data];
        if (!data) return;
        index = (int)((SIMASNumberBox*)data)->num;
    } else index = [[args objectAtIndex:1] intValue];
    if ([[SIMASRuntime runtime] isExcepted]) return;
    if (index > [target count] || index < 1) {
        [SIMASRuntime throwException:@"IllegalIndex" withReason:[NSString stringWithFormat:@"Index %d is not a valid index of list %@. (max %d, minimum 1)", index, [args objectAtIndex:0], [target count]]];
        return;
    }
    index -= 1;
    for (int i = 2; i < [args count]; i++) {
        SIMASVariable *var = [SIMASVariable makeVariable:[args objectAtIndex:i]];
        [var setData:[[target data] objectAtIndex:index] asCopy:YES];
    }
}

SIMASFUNC(showList) {
    SIMASList *target = boilerplate(args);
    if (!target) return;
    printf("%s", [[target toString] UTF8String]);
}

SIMASFUNC(dump) {
    SIMASList *target = boilerplate(args);
    if (!target) return;
    [[target toString] writeToFile:[args objectAtIndex:0] atomically:YES encoding:NSASCIIStringEncoding error:nil];
}

SIMASFUNC(loadList) {
    SIMASVariable *list = SIMASGETVARIABLEWITHARGUMENT(0);
    if (list == nil) {
        newList(self, _cmd, args);
        if (!(list = SIMASGETVARIABLEWITHARGUMENT(0))) return;
        if ([[SIMASRuntime runtime] isExcepted]) return;
    }
    if (![[list data] isKindOfClass:[SIMASList class]]) { [SIMASRuntime throwException:@"IllegalType" withReason:[NSString stringWithFormat:@"Variable %@ is not a list.", [args objectAtIndex:0]]]; return; }
    NSString *data = [NSString stringWithContentsOfFile:[args objectAtIndex:0] encoding:NSASCIIStringEncoding error:nil];
    if (!data) { [SIMASRuntime throwException:@"ReadError" withReason:[NSString stringWithFormat:@"File %@ failed to read.", [args objectAtIndex:0]]]; return; }
    SIMASList *sacrificial = (SIMASList*)[SIMASList fromString:data];
    if ([[SIMASRuntime runtime] isExcepted]) return;
    [list setData:sacrificial];
}

SIMASFUNC(lengthOfList) {
    SIMASList *target = boilerplate(args);
    if (!target) return;
    [[SIMASVariable makeVariable:[args objectAtIndex:1]] setData:[SIMASNumber numberWithNumber:[target count]]];
}

SIMASFUNC(listCopy) {
    SIMASList *target = boilerplate(args);
    if (!target) return;
    SIMASVariable *dest = SIMASGETVARIABLEWITHARGUMENT(1);
    if (!dest) {
        if ([[args objectAtIndex:1] characterAtIndex:0] == '$') { [SIMASRuntime throwException:@"IllegalName" withReason:@"List names cannot start with '$' (reserved)."]; return; }
        dest = [SIMASVariable new];
        [[SIMASRuntime currentProgram]->variables setObject:[dest autorelease] forKey:[args objectAtIndex:1]];
    }
    SIMASList *sacrificial = (SIMASList*)[target copy];
    if ([[SIMASRuntime runtime] isExcepted]) return;
    [dest setData:sacrificial];
    [sacrificial release];
}

SIMASFUNC(makeAlias) {
    SIMASVariable *list = SIMASGETVARIABLEWITHARGUMENT(0);
    if (!list) { [SIMASRuntime throwException:@"NonexistentList" withReason:[NSString stringWithFormat:@"List %@ does not exist.", [args objectAtIndex:0]]]; return; }
    if (![[list data] isKindOfClass:[SIMASList class]]) { [SIMASRuntime throwException:@"IllegalType" withReason:[NSString stringWithFormat:@"Variable %@ is not a list.", [args objectAtIndex:0]]]; return; }
    [[SIMASRuntime currentProgram]->variables setObject:[list makePointer] forKey:[args objectAtIndex:0]];
}

@implementation SIMASList
- (id)init {
    self = [super init];
    if (self) self->data = [NSMutableArray new];
    return self;
}

- (void)appendObject:(SIMASData*)newObject {
    [[self data] addObject:newObject];
}

- (void)replaceObject:(int)index withObject:(SIMASData*)newObject {
    [[self data] replaceObjectAtIndex:index withObject:newObject];
}

- (void)deleteObject:(int)index {
    [[self data] removeObjectAtIndex:index];
}

- (SIMASData*)retrieveObject:(int)index {
    return [[self data] objectAtIndex:index];
}

- (int)count {
    return (int)[(NSMutableArray*)self->data count];
}

- (SIMASData*)getConverted:(Class)type {
    if ([[[self class] conversions] objectForKey:type]) return [super getConverted:type];
    if (![self count]) return nil;
    return [[self retrieveObject:0] getConverted:type];
}

- (BOOL)isEqualTo:(SIMASData*)object {
    if (![object isKindOfClass:[self class]]) { [SIMASRuntime throwException:@"IllegalComparison" withReason:[NSString stringWithFormat:@"Lists may not be compared to anything except lists, comparison is of type %@", [[object class] name]]]; return NO; }
    if ([self count] != [(SIMASList*)object count]) return NO;
    for (int i = 0, count = (int)[(NSMutableArray*)self->data count]; i < count; i++) {
        if (![[self retrieveObject:i] isEqualTo:[(SIMASList*)object retrieveObject:i]]) return NO;
    }
    return YES;
}

+ (NSString*)name {
    return @"list";
}

- (SIMASData*)copy {
    SIMASList *newList = [SIMASList new];
    for (int i = 0, count = (int)[(NSMutableArray*)self->data count]; i < count; i++) [newList->data addObject:[[self->data objectAtIndex:i] copy]];
    return newList;
}

+ (SIMASData*)fromString:(NSString *)string {
    NSString *things = [string substringWithRange:NSMakeRange(1, [string length] - 2)];
    NSArray *array = tokeniseStringExcludingQuotes(things, [NSCharacterSet punctuationCharacterSet]);
    if ([string characterAtIndex:0] != '[' || [string characterAtIndex:([string length] - 1)] != ']' || !([array count] % 2)) {
        [SIMASRuntime throwException:@"IllegalListString" withReason:[NSString stringWithFormat:@"String %@ does not meet the format for a list.", string]];
        return nil;
    }
    
    SIMASList *newData = [SIMASList new];
    for (int i = 0, count = (int)[array count]; i < count; i++) {
        Class type = [[SIMASRuntime runtime]->registeredTypes objectForKey:[array objectAtIndex:i]];
        if (!type) { [SIMASRuntime throwException:@"NonexistentType" withReason:[NSString stringWithFormat:@"Type %@ does not exist, thus cannot be used to build a list.", [array objectAtIndex:i]]]; return nil; }
        [newData->data addObject:[type fromString:[array objectAtIndex:(i + 1)]]];
    }
    return [newData autorelease];
}
- (NSString*)toString {
    NSMutableString *string = [NSMutableString new];
    NSMutableArray *args = [NSMutableArray arrayWithArray:[self data]];
    [string appendString:@"["];
    while ([args count]) {
        BOOL isString = [[args objectAtIndex:0] class] == [SIMASString class];
        [string appendString:[[[args objectAtIndex:0] class] name]];
        [string appendString:@","];
        if (isString) [string appendString:@"\""];
        [string appendString:(isString ? unformatEscapes([[args objectAtIndex:0] toString]) : [[args objectAtIndex:0] toString])];
        if (isString) [string appendString:@"\""];
        [args removeObjectAtIndex:0];
        if ([args count]) [string appendString:@","];
        else [string appendString:@"]"];
    }
    return [string autorelease];
}
@end

@implementation SIMASListLibrary
+ (void)registerToSIMAS:(NSString *)prefix {
    SIMASRuntime* runtime = [SIMASRuntime runtime];
    [runtime registerType:[SIMASList class] withName:@"list"];
    SIMASOperation *thing;
    
    thing = [SIMASOperation makeWithFunction:newList];
    [thing setArgRange:1 toMaximum:1];
    [runtime registerOperation:thing withName:@"new" withPrefix:prefix];

    thing = [SIMASOperation makeWithFunction:appv];
    [thing setMinArgs:3];
    [runtime registerOperation:thing withName:@"appv" withPrefix:prefix];
    
    thing = [SIMASOperation makeWithFunction:appc];
    [thing setMinArgs:3];
    [runtime registerOperation:thing withName:@"appc" withPrefix:prefix];
    
    thing = [SIMASOperation makeWithFunction:upv];
    [thing setArgRange:4 toMaximum:4];
    [runtime registerOperation:thing withName:@"upv" withPrefix:prefix];
    
    thing = [SIMASOperation makeWithFunction:upc];
    [thing setArgRange:4 toMaximum:4];
    [runtime registerOperation:thing withName:@"upc" withPrefix:prefix];
    
    thing = [SIMASOperation makeWithFunction:del];
    [thing setArgRange:2 toMaximum:2];
    [runtime registerOperation:thing withName:@"del" withPrefix:prefix];
    
    thing = [SIMASOperation makeWithFunction:acc];
    [thing setMinArgs:3];
    [runtime registerOperation:thing withName:@"acc" withPrefix:prefix];
    
    thing = [SIMASOperation makeWithFunction:showList];
    [thing setArgRange:1 toMaximum:1];
    [runtime registerOperation:thing withName:@"show" withPrefix:prefix];
    
    thing = [SIMASOperation makeWithFunction:dump];
    [thing setArgRange:2 toMaximum:2];
    [runtime registerOperation:thing withName:@"dump" withPrefix:prefix];
    
    thing = [SIMASOperation makeWithFunction:loadList];
    [thing setArgRange:2 toMaximum:2];
    [runtime registerOperation:thing withName:@"load" withPrefix:prefix];
    
    thing = [SIMASOperation makeWithFunction:lengthOfList];
    [thing setArgRange:2 toMaximum:2];
    [runtime registerOperation:thing withName:@"len" withPrefix:prefix];
    
    thing = [SIMASOperation makeWithFunction:listCopy];
    [thing setArgRange:2 toMaximum:2];
    [runtime registerOperation:thing withName:@"copy" withPrefix:prefix];
    
    thing = [SIMASOperation makeWithFunction:makeAlias];
    [thing setArgRange:2 toMaximum:2];
    [runtime registerOperation:thing withName:@"alias" withPrefix:prefix];
}
@end
