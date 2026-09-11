//
//  SIMASCommandLine.m
//  objectivismas
//
//  Created by Xander Gomez on 9/9/26.
//  Copyright © 2026 Xander Gomez. All rights reserved.
//

#import "SIMASCommandLine.h"
#import "SIMASRuntime.h"

@implementation SIMASCommandLine
+ (NSString*)userInput {
    return [[[[NSString alloc] initWithData:[[NSFileHandle fileHandleWithStandardInput] availableData] encoding:NSASCIIStringEncoding] autorelease] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
}

+ (SIMASCommandLine*)newCommandLine {
    SIMASCommandLine *cmdline = [SIMASCommandLine new];
    
    return cmdline;
}
@end
