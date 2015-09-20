//
//  SSXcodeGhostChecker.h
//  XcodeGhostChecker
//
//  Created by Steven on 15/9/20.
//  Copyright © 2015年 Neva. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSXcodeGhostCheckerInfo.h"

@class SSXcodeGhostChecker;

typedef void(^SSXcodeGhostCheckerComplete)(SSXcodeGhostCheckerInfo * info);

@interface SSXcodeGhostChecker : NSObject

+ (void)checkInfo:(SSXcodeGhostCheckerInfo *)info complete:(SSXcodeGhostCheckerComplete)complete;

+ (void)clearCacheDir;

@end
