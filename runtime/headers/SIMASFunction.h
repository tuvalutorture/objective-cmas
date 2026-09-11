//
//  SIMASFunction.h
//  objectivismas
//
//  Created by Xander Gomez on 9/6/26.
//  Copyright © 2026 Xander Gomez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SIMASFunction : NSObject {
@public
    int argumentCount, location;
    NSString *name;
}
+ (void)registerFunction:(NSArray*)args;
@end

@interface SIMASStackFrame : NSObject {
    @public SIMASFunction *function;
    @protected NSArray *passedArgs; int returnTo;
}
+ (void)pushStackFrame:(NSArray*)args;
- (void)loopStackFrame:(NSArray*)args;
- (void)endStackFrame:(NSArray*)args;
@end
