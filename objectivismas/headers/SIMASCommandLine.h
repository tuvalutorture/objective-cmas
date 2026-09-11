//
//  SIMASCommandLine.h
//  objectivismas
//
//  Created by Xander Gomez on 9/9/26.
//  Copyright © 2026 Xander Gomez. All rights reserved.
//

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
