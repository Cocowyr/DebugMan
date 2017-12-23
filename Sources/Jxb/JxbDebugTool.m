//
//  JxbDebugTool.m
//  JxbHttpProtocol
//
//  Created by Peter Jin  on 15/11/12.
//  Copyright (c) 2015年 Mail:i@Jxb.name. All rights reserved.
//

#import "JxbDebugTool.h"
#import "JxbHttpProtocol.h"
#import "JxbMemoryHelper.h"

#define KB    (1024)
#define MB    (KB * 1024)
#define GB    (MB * 1024)

@interface JxbDebugTool()
@property (nonatomic, strong) UIWindow    *statusBar;
@end

@implementation JxbDebugTool

+ (instancetype)shareInstance
{
    static JxbDebugTool* tool;
    static dispatch_once_t  once;
    dispatch_once(&once, ^{
        tool = [[JxbDebugTool alloc] init];
    });
    return tool;
}

- (void)enable
{
   [NSURLProtocol registerClass:[JxbHttpProtocol class]];
}

- (void)disable
{
    [NSURLProtocol unregisterClass:[JxbHttpProtocol class]];
}

- (NSString *)bytesOfUsedMemory
{
    unsigned long long used = [JxbMemoryHelper bytesOfUsedMemory];
    return [self number2String:used];
}

- (NSString* )number2String:(int64_t)n
{
    if ( n < KB )
    {
        return [NSString stringWithFormat:@"%lldB", n];
    }
    else if ( n < MB )
    {
        return [NSString stringWithFormat:@"%.1fK", (float)n / (float)KB];
    }
    else if ( n < GB )
    {
        return [NSString stringWithFormat:@"%.1fM", (float)n / (float)MB];
    }
    else
    {
        return [NSString stringWithFormat:@"%.1fG", (float)n / (float)GB];
    }
}

- (void)showStatusBar
{
    if (self.statusBar) {
        return;
    }
    
    __weak typeof (self) wSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        wSelf.statusBar = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
        wSelf.statusBar.windowLevel = kDotzuWindowLevel + 1;
        wSelf.statusBar.hidden = NO;
        wSelf.statusBar.backgroundColor = [UIColor purpleColor];
        wSelf.statusBar.alpha = 0.5;
        [wSelf.statusBar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapStatusBar)]];
    });
}

- (void)hideStatusBar
{
    if (self.statusBar) {
        [self.statusBar removeFromSuperview];
        self.statusBar = nil;
    }
}

//MARK: - target action
- (void)tapStatusBar
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"tapStatusBar" object:nil];
}

@end
