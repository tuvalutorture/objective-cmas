//
//  main.m
//  objectivismas
//
//  Created by Xander Gomez on 9/6/26.
//  Copyright 2026 Xander Gomez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIMASRuntime.h"
#import "SIMASStandardLibrary.h"

int main(int argc, const char * argv[]) {
    [[SIMASRuntime runtime] registerLibrary:[SIMASStandardLibrary class] withPrefix:@""];
    [[SIMASRuntime runtime] runFromString:@"utilising ./listeria.bundle as list; list michael; printc :3; set str three \"three\"; import ./fibonacci.simas; import ./point.simas; printc :3; writev ./slink.txt three; print three; write ./clink.txt \"microwave\"; read ./clink.txt spinalFluid; println; print spinalFluid;"];
    return 0;
}
