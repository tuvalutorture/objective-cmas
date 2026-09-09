//
//  SIMASStandardLibrary.h
//  objectivismas
//
//  Created by Xander Gomez on 9/6/26.
//  Copyright © 2026 Xander Gomez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIMASRuntime.h"

@interface SIMASStandardLibrary : NSObject <SIMASLibrary>
+ (void)registerToSIMAS:(NSString*)prefix;
@end
