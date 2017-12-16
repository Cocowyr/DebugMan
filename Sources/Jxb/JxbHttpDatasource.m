//
//  JxbHttpDatasource.m
//  JxbHttpProtocol
//
//  Created by Peter on 15/11/13.
//  Copyright © 2015年 Peter. All rights reserved.
//

#import "JxbHttpDatasource.h"
#import "NSURLRequest+Identify.h"
#import "NSURLResponse+Data.h"
#import "NSURLSessionTask+Data.h"
#import "JxbDebugTool.h"

@implementation JxbHttpDatasource

+ (instancetype)shareInstance
{
    static JxbHttpDatasource* tool;
    static dispatch_once_t  once;
    dispatch_once(&once, ^{
        tool = [[JxbHttpDatasource alloc] init];
    });
    return tool;
}

- (id)init
{
    self = [super init];
    if (self) {
        _httpModels = [NSMutableArray array];
        _httpModelRequestIds = [NSMutableArray array];
    }
    return self;
}

- (void)addHttpRequset:(JxbHttpModel*)model
{
    //host过滤, 忽略大小写
    for (NSString *host in [JxbDebugTool shareInstance].ignoredHosts) {
        if ([[model.url.absoluteString lowercaseString] containsString:[host lowercaseString]]) {
            return;
        }
    }
    
    if (self.httpModels.count >= [JxbDebugTool shareInstance].maxLogsCount) {
        if ([self.httpModels count] > 0) {
            [self.httpModels removeObjectAtIndex:0];
        }
    }
    [self.httpModels addObject:model];

    if (self.httpModelRequestIds.count >= [JxbDebugTool shareInstance].maxLogsCount) {
        if ([self.httpModelRequestIds count] > 0) {
            [self.httpModelRequestIds removeObjectAtIndex:0];
        }
    }
    if (model.requestId && [model.requestId length] > 0) {
        [self.httpModelRequestIds addObject:model.requestId];
    }
}

- (void)reset
{
    [self.httpModels removeAllObjects];
    [self.httpModelRequestIds removeAllObjects];
}

- (void)remove:(JxbHttpModel *)model
{
    if ([self.httpModels containsObject:model]) {
        [self.httpModels removeObject:model];
    }

    if ([self.httpModelRequestIds containsObject:model.requestId]) {
        [self.httpModelRequestIds removeObject:model.requestId];
    }
}

@end
