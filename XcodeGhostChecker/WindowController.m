//
//  WindowController.m
//  XcodeGhostChecker
//
//  Created by Steven on 15/9/21.
//  Copyright © 2015年 Neva. All rights reserved.
//

#import "WindowController.h"

@interface WindowController() <NSWindowDelegate>

@end

@implementation WindowController

- (BOOL)windowShouldClose:(id)sender;
{
    exit(0);
    return YES;
}

@end
