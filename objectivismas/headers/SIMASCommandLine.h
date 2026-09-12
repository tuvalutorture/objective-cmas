//
//  SIMASCommandLine.h
//  objectivismas
//
//  Created by Xander Gomez on 9/9/26.
//  Copyright © 2026 Xander Gomez. All rights reserved.
//
//  windmill, windmill for the land
//  turn forever, hand in hand
//  take it all in
//  on your stride
//  it is ticking,
//  falling down
//  love forever, love is freely
//  turn forever, you and me
//  windmill, windmill for the land, is
//  everybody in?

#import <Foundation/Foundation.h>
#import "SIMASRuntime.h"

@interface SIMASCommandLine : NSObject {
    NSMutableDictionary *commands;
    NSMutableArray *userProgram;
}
+ (SIMASCommandLine*)newCommandLine;
- (void)addCommand:(SIMASOperation*)command forKey:(NSString*)key;
- (void)getCommand;
@end
