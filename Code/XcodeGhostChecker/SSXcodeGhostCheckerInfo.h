//
//  SSXcodeGhostCheckerInfo.h
//  XcodeGhostChecker
//
//  Created by Steven on 15/9/21.
//  Copyright © 2015年 Neva. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SSXcodeGhostCheckerStatusNull = 0,  ///< Default.
    SSXcodeGhostCheckerStatusSave,      ///< App is save.
    SSXcodeGhostCheckerStatusPoisoning, ///< Include XcodeGhost.
    SSXcodeGhostCheckerStatusEncrypted, ///< This file is encrypted.
    SSXcodeGhostCheckerStatusUnzipError,///< Unzip error.
} SSXcodeGhostCheckerStatus;

@interface SSXcodeGhostCheckerInfo : NSObject

@property (nonatomic, copy) NSString * ipa;

@property (nonatomic, assign) SSXcodeGhostCheckerStatus status;

@end
