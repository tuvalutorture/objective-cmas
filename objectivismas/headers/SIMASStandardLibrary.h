//
//  SIMASStandardLibrary.h
//  objectivismas
//
//  Created by Xander Gomez on 9/6/26.
//  Copyright © 2026 Xander Gomez. All rights reserved.
//
//  let me let you go
//  we're dead inside
//  and dead below
//  be my holy ghost
//  the only one
//  who never knows
//  the way you haunt me
//  threw it away at the bitter end
//  you left a hole
//  where a heart had been
//  let me go
//  and put it back
//  to where it goes
//  in silos

#import <Foundation/Foundation.h>
#import "SIMASRuntime.h"

@interface SIMASStandardLibrary : NSObject <SIMASLibrary>
+ (void)registerToSIMAS:(NSString*)prefix;
@end
