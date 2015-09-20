//
//  SSXcodeGhostChecker.m
//  XcodeGhostChecker
//
//  Created by Steven on 15/9/20.
//  Copyright © 2015年 Neva. All rights reserved.
//

#import "SSXcodeGhostChecker.h"
#import <ZipArchive/ZipArchive.h>

// 解压缓存目录
#define SSXcodeGhostCheckerCacheDir             @"/tmp/SSXcodeGhostCheckerCacheDir"

// 获取资源路径
#define SSXcodeGhostCheckerGetPath(path)        [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:path]

// 反编译工具class-dump路径
#define SSXcodeGhostCheckerClassDumpPath        SSXcodeGhostCheckerGetPath(@"Resource.bundle/class-dump")

// 中毒的样本头文件
#define SSXcodeGhostCheckerSamplePath           SSXcodeGhostCheckerGetPath(@"Resource.bundle/XcodeGhostSimple.h")

// 已加壳的二进制class-dump调用返回的信息样本文件
#define SSXcodeGhostCheckerEncryptedSamplePath  SSXcodeGhostCheckerGetPath(@"Resource.bundle/XcodeGhostEncryptedSimple.text")

@interface SSXcodeGhostChecker()
@property (nonatomic, copy) SSXcodeGhostCheckerComplete complete;
@end

@implementation SSXcodeGhostChecker

+ (void)checkInfo:(SSXcodeGhostCheckerInfo *)info complete:(SSXcodeGhostCheckerComplete)complete;
{
    SSXcodeGhostChecker * checker = [[SSXcodeGhostChecker alloc] init];
    [checker checkInfo:info complete:complete];
}

- (void)checkInfo:(SSXcodeGhostCheckerInfo *)info complete:(SSXcodeGhostCheckerComplete)complete;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    
        NSString * binaryPath = [self unzipBinaryWithIPA:info.ipa];
        
        if (binaryPath == nil)
        {
            // 解压失败
            dispatch_sync(dispatch_get_main_queue(), ^{
                info.status = SSXcodeGhostCheckerStatusUnzipError;
                complete(info);
            });
            return;
        }

        NSData * dumpData = [self getDumpHeaderDataWithPath:binaryPath];
        
        // 判断是否已加壳
        // class-dump 处理加壳文件返回的数据样本
        NSData * EsimpleData = [NSData dataWithContentsOfFile:SSXcodeGhostCheckerEncryptedSamplePath];
        NSRange Erange = [dumpData rangeOfData:EsimpleData options:NSDataSearchBackwards range:NSMakeRange(0, dumpData.length)];
        if (Erange.location != NSNotFound && complete) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                info.status = SSXcodeGhostCheckerStatusEncrypted;
                complete(info);
            });
            return;
        }
        
        // 检测是否包含病毒样本头文件
        // 病毒样本头文件
        NSData * simpleData = [NSData dataWithContentsOfFile:SSXcodeGhostCheckerSamplePath];
        NSRange range = [dumpData rangeOfData:simpleData options:NSDataSearchBackwards range:NSMakeRange(0, dumpData.length)];
        if (complete)
        {
            // 回调
            BOOL has = range.location != NSNotFound;
            dispatch_sync(dispatch_get_main_queue(), ^{
                info.status = has ? SSXcodeGhostCheckerStatusPoisoning : SSXcodeGhostCheckerStatusSave;
                complete(info);
            });
        }
    });
    
}

- (NSString *)unzipBinaryWithIPA:(NSString *)IPA
{
    // TODO 解压文件优化，不要解压不相关文件
    ZipArchive* zip = [[ZipArchive alloc] init];
    NSString * cachPath = [SSXcodeGhostCheckerCacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", @(IPA.hash)]];
    if( [zip UnzipOpenFile:IPA] )
    {
        BOOL ret = [zip UnzipFileTo:cachPath overWrite:YES];
        if( NO == ret ) { return nil; }
        [zip UnzipCloseFile];
    }
    
    // 查找二进制文件
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * appDir = [cachPath stringByAppendingPathComponent:@"Payload"];
    NSDirectoryEnumerator * directoryEnumerator = [fileManager enumeratorAtPath:appDir];
    NSString * file = nil;
    while( file = [directoryEnumerator nextObject] )
    {
        file = [appDir stringByAppendingPathComponent:file];
        if( [[[file pathExtension] lowercaseString] isEqualToString:@"app"])
        {
            NSString * binaryName = [[file lastPathComponent] stringByDeletingPathExtension];
            NSString * binaryPath = [file stringByAppendingPathComponent:binaryName];
            if ([fileManager fileExistsAtPath:binaryPath])
            {
                // 找到二进制文件，返回
                return binaryPath;
            }
            else
            {
                return nil;
            }
        }
    }
    return nil;
}

- (NSData *)getDumpHeaderDataWithPath:(NSString *)path
{
    // 设置执行路径
    NSTask * task = [[NSTask alloc ]init];
    [task setLaunchPath:SSXcodeGhostCheckerClassDumpPath];
    
    // 设置参数
    NSArray * arguments = @[path];
    [task setArguments:arguments];
    
    // 设置输出管道
    NSPipe * pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    // 执行命令
    [task launch];
    
    // 读取输出
    return [[pipe fileHandleForReading] readDataToEndOfFile];
}

+ (void)clearCacheDir;
{
    [[NSFileManager defaultManager] removeItemAtPath:SSXcodeGhostCheckerCacheDir error:nil];
}


@end
