//
//  SIMASList.h
//  listeria
//
//  Created by Xander Gomez on 9/6/26.
//  Copyright © 2026 Xander Gomez. All rights reserved.
//
//  the flower pink on the tree, but if you pick it to see
//  will it be wild and free?
//  you say you wanted a piece
//  is it for sale or for lease?
//  oh, that's the easy police
//  (come on down)
//
//  and when I'm fallin' asleep
//  please give me somethin' to keep
//  me warm and kind of complete
//  long time to go without ya
//  try slow to know about ya
//  for now is my better
//  less time in forever
//  please, love, can I have a taste?
//  i just wanna lick your face
//  any other day and I would say
//  you're Atlantis manta ray

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
