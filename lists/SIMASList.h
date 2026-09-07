//
//  SIMASList.h
//  listeria
//
//  Created by Xander Gomez on 9/6/26.
//  Copyright © 2026 Xander Gomez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../objectivismas/SIMASRuntime.h"
#import "../objectivismas/SIMASVariable.h"

@interface SIMASList : NSObject
+ (void)registerToSIMAS:(NSString*)prefix;
@end
