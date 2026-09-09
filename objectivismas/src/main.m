//
//  main.m
//  objectivismas
//
//  Created by Xander Gomez on 9/6/26.
//  Copyright 2026 Xander Gomez. All rights reserved.
//
//  the bigger the lie, the further it goes
//  it's all fun and games til the overthrow
//  when it gets inside
//  and it starts to grow
//  and say goodbye, cause that's the deathblow
//  i'm not giving up
//  that easy
//  i'm not giving up
//  my mind
//  cause the more that you try, the more that they need
//  there's nowhere to hide
//  when they break out the guillot- wait no i'm being told my line is "sigsegv"?
//  well fuck you buddy, we're doing starset today. no, man, come on, just let me have one song
//  no dude i swear just this one i'll do all the other bits properly i swear
//  thank you
//  as i was saying
//  the bigger the lie, the further it goes
//  it's all fun and games til the overthrow
//  when it gets inside
//  and it starts to grow
//  and say goodbye, cause that's the deathblow
//  i'm not giving up
//  that easy
//  i'm not giving up
//  my mind
//  cause the more that you try, the more that they need
//  there's nowhere to hide
//  when they break out the guillotine

#import <Foundation/Foundation.h>
#import "SIMASRuntime.h"
#import "SIMASStandardLibrary.h"
#import "SIMASList.h"

int main(int argc, const char * argv[]) {
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    [[SIMASRuntime runtime] registerLibrary:[SIMASStandardLibrary class] withPrefix:@""];
    [[SIMASRuntime runtime] registerLibrary:[SIMASListLibrary class] withPrefix:@"List"];
    if (argc > 1) {
        for (int i = 1; i < argc; i++) {
            NSAutoreleasePool *programPool = [NSAutoreleasePool new];
            NSString *programName = [NSString stringWithUTF8String:argv[i]];
            NSString *program = [NSString stringWithContentsOfFile:programName encoding:NSASCIIStringEncoding error:nil];
            if (!program) { NSLog(@"Failed to load program %@! Skipping.", programName); continue; }
            [[SIMASRuntime runtime] runFromString:program];
            [programPool release];
        }
    } else {
        [[SIMASRuntime runtime] runFromString:@"printc \"were you expecting a command line?\n\"; printc \"it's unimplemented\\; check back later :) (or input a file as an argument)\n\";"];
    }
    [pool release];
    return 0;
}
