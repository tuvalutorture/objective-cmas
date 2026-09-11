//
//  SIMASList.h
//  listeria
//
//  Created by Xander Gomez on 9/6/26.
//  Copyright © 2026 Xander Gomez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SIMASRuntime.h"
#import "SIMASVariable.h"

@interface SIMASList : SIMASData <SIMASDataType>
- (void)appendObject:(SIMASData*)newObject;
- (void)replaceObject:(int)index withObject:(SIMASData*)newObject;
- (void)deleteObject:(int)index;
- (SIMASData*)retrieveObject:(int)index;
- (int)count;
@end

@interface SIMASListLibrary : NSObject <SIMASLibrary>
+ (void)registerToSIMAS:(NSString*)prefix;
@end
