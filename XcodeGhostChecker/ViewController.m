//
//  ViewController.m
//  XcodeGhostChecker
//
//  Created by Steven on 15/9/20.
//  Copyright © 2015年 Neva. All rights reserved.
//

#import "ViewController.h"
#import "SSXcodeGhostChecker.h"

@interface ViewController()

@property (weak) IBOutlet NSTextField *pathField;

@property (unsafe_unretained) IBOutlet NSTextView *outputTextView;

@property (weak) IBOutlet NSProgressIndicator *indicatorView;

- (IBAction)onBrowseTouch:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];
}

- (IBAction)onBrowseTouch:(id)sender
{
    self.indicatorView.hidden = NO;
    [self.indicatorView startAnimation:nil];
    self.outputTextView.string = @"";
    
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:TRUE];
    [panel setCanChooseDirectories:TRUE];
    [panel setAllowsMultipleSelection:TRUE];
    [panel setAllowsOtherFileTypes:FALSE];
    [panel setAllowedFileTypes:@[@"ipa", @"IPA"]];
    
    
    if ([panel runModal] == NSModalResponseOK)
    {
        // 遍历出文件
        NSMutableArray * fileList = [NSMutableArray array];
        NSFileManager * fileManager = [NSFileManager defaultManager];
        BOOL isDirectory;
        for (NSURL * url in [panel URLs]) {
            if ([fileManager fileExistsAtPath:url.path isDirectory:&isDirectory])
            {
                if (isDirectory)
                {
                    [fileList addObjectsFromArray:[self recursiveFileList:url.path]];
                }
                else
                {
                    [fileList addObject:url.path];
                }
            }
        }
        
        __block NSUInteger count = fileList.count;
        
        if (count == 0)
        {
            self.indicatorView.hidden = YES;
            [self.indicatorView stopAnimation:nil];
            return;
        }
        
        // 检测XcodeGhost病毒，更新显示
        NSMutableString * str = [NSMutableString string];
        for (NSString * file in fileList)
        {
            [str appendString:file];
            if (str != fileList.lastObject)
            {
                [str appendString:@"; "];
            }
            
            SSXcodeGhostCheckerInfo * info = [[SSXcodeGhostCheckerInfo alloc] init];
            info.ipa = file;
            __weak ViewController * weakSelf = self;
            [SSXcodeGhostChecker checkInfo:info complete:^(SSXcodeGhostCheckerInfo *info)
            {
                // 更新界面
                __strong ViewController * strongSelf = weakSelf;
                strongSelf.outputTextView.string = [strongSelf.outputTextView.string stringByAppendingString:[self getOutputStringWithInfo:info].string];
                
                // 停止等待指示
                count--;
                if (count <= 0)
                {
                    strongSelf.indicatorView.hidden = YES;
                    [strongSelf.indicatorView stopAnimation:nil];
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                        // 清除缓存
                        [SSXcodeGhostChecker clearCacheDir];
                    });
                }
            }];
        }
        self.pathField.stringValue = str;
    }
}

- (NSAttributedString *)getOutputStringWithInfo:(SSXcodeGhostCheckerInfo *)info
{
    // TODO 文字颜色不出来
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Path: %@\nResult: ", info.ipa]];
    
    NSColor * color = [NSColor grayColor];
    NSString * str = nil;
    switch (info.status)
    {
        case SSXcodeGhostCheckerStatusNull:
            str = @"未处理";
            color = [NSColor grayColor];
            break;
        case SSXcodeGhostCheckerStatusSave:
            str = @"安全";
            color = [NSColor greenColor];
            break;
        case SSXcodeGhostCheckerStatusPoisoning:
            str = @"中毒";
            color = [NSColor redColor];
            break;
        case SSXcodeGhostCheckerStatusEncrypted:
            str = @"来自AppStore的ipa，已经加壳，不能检测";
            color = [NSColor yellowColor];
            break;
        default: break;
    }
    str = [str stringByAppendingString:@"\n\n"];
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:str attributes:@{NSForegroundColorAttributeName: color}]];
    return string;
}

// 递归获取目录下的所有ipa文件
- (NSArray *)recursiveFileList:(NSString *)dir
{
    NSMutableArray * fileList = [NSMutableArray array];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSDirectoryEnumerator * directoryEnumerator = [fileManager enumeratorAtPath:dir];
    NSString * file = nil;
    BOOL isDirectory;
    while( file = [directoryEnumerator nextObject] )
    {
        file = [dir stringByAppendingPathComponent:file];
        if( [[[file pathExtension] lowercaseString] isEqualToString:@"ipa"])
        {
            if ([fileManager fileExistsAtPath:file isDirectory:&isDirectory])
            {
                if (isDirectory)
                {
                    [fileList addObjectsFromArray:[self recursiveFileList:file]];
                }
                else
                {
                    [fileList addObject:file];
                }
            }
        }
    }
    return [NSArray arrayWithArray:fileList];
}

@end




