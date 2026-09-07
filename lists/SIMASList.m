//
//  SIMASList.m
//  listeria
//
//  Created by Xander Gomez on 9/6/26.
//  Copyright © 2026 Xander Gomez. All rights reserved.
//

#import "SIMASList.h"

SIMASFUNC(function) {
    NSLog(@"i microwave chicken nuggy");
}

@implementation SIMASList
+ (void)registerToSIMAS:(NSString *)prefix {
    [[SIMASRuntime runtime] registerOperation:[SIMASOperation makeWithFunction:function] withName:@"michael" withPrefix:prefix];
}
@end
