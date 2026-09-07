//
//  SIMASRuntime.h
//  objectivismas
//
//  Created by Xander Gomez on 9/6/26.
//  Copyright © 2026 Xander Gomez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIMASVariable.h"

#define SIMASFUNC(name) void name(id self, SEL _cmd, NSArray* args)
#define SIMASFUNCTYPE void (*)(id, SEL, NSArray*)
#define SIMASSELECTORMETHOD(selector, sel) SEL _simas_selector_get_##selector() { return sel; } // sel is the @selector, selector is the name (like add, @selector(add:))
#define SIMASSELECTORMETHODNAME(selector) _simas_selector_get_##selector // must be paired with one of the above declared
#define SIMASCLASSMETHOD(theClass) id _simas_class_get_##theClass(NSArray *arr) { return [theClass class]; }
#define SIMASCLASSMETHODNAME(theClass) _simas_class_get_##theClass // must be paired with one of the above declared
#define SIMASGETFUNCTION(object, selector) (SIMASFUNCTYPE)[object methodForSelector:selector]
#define SIMASGETINSTANCEFUNCTION(object, selector) (SIMASFUNCTYPE)[object instanceMethodForSelector:selector]

void labelNop(id, SEL, NSArray*);
void importNop(id, SEL, NSArray*);
void utiliseNop(id, SEL, NSArray*);

@interface SIMASOperation : NSObject {
@public
    void (*functionPointer)(id, SEL, NSArray*); // used so you can either do a standard C func OR pass in an objc method, if using the two other function pointers
    id (*targetGetter)(NSArray*); // optional
    SEL (*selectorGetter)(void); // optional, but reccommended if using targetGetter
    int minimumArguments;
    int maximumArguments;
}
+ (SIMASOperation*)makeWithFunction:(void (*)(id, SEL, NSArray*))func;
+ (SIMASOperation*)makeWithFunction:(void (*)(id, SEL, NSArray*))func withTargetGetter:(id (*)(NSArray*))target andSelectorGetter:(SEL (*)(void))selector;
- (void)setMaxArgs:(int)maximum;
- (void)setMinArgs:(int)minimum;
- (void)setArgRange:(int)minimum toMaximum:(int)maximum;
@end

@interface SIMASInstruction : NSObject {
@public
    SIMASOperation *operation;
    NSArray *arguments;
}
+ (id)instructionFromOperation:(SIMASOperation*)op;
+ (id)instructionFromOperation:(SIMASOperation*)op withArguments:(NSArray*)arguments;

- (void)execute;
@end

@interface SIMASProgram : NSObject {
@public
    NSMutableArray *instructions;
    NSMutableArray *stack;
    NSMutableDictionary *variables;
    NSMutableDictionary *functions;
    NSMutableDictionary *labels;
    int programCounter;
}

- (SIMASVariable*)locateVariable:(NSString*)name;
@end

@interface SIMASRuntime : NSObject {
    SIMASProgram *currentProgram;
@public
    NSMutableSet *registeredClasses;
    NSMutableDictionary *registeredOperations;
    NSMutableDictionary *registeredTypes; // types like num, bool, str are the keys, the classes are the values
}

+ (SIMASRuntime*)runtime;
+ (SIMASProgram*)currentProgram;
// there must be a class method named "registerToSIMAS:". this removes itself on program end. prefix may not be nil, but may be "" if you want it to be root-level (no prefix). the prefix is provided for you in the "utilising" (utilising [bundle] as [prefix]). you can, theoretically, ignore the passed prefix, but it's reccommended to register your things with the user prefix (unless none is provided, then do whatever)
- (void)loadLibrary:(NSBundle*)libraryBundle withPrefix:(NSString*)prefix; // loads a library from a bundle, for the "utilising" thing
- (void)registerLibrary:(Class)libraryClass withPrefix:(NSString*)prefix;
- (void)registerOperation:(SIMASOperation*)operation withName:(NSString*)name withPrefix:(NSString*)prefix;
- (void)registerType:(Class)type withName:(NSString*)name;
- (void)runFromString:(NSString*)string;
@end

static inline SEL nullSelector() { return NULL; }
static inline id nullTarget(NSArray* arr) { return nil; }
