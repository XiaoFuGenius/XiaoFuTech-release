//
//  XFQQMtaSdkHelper.m
//  JunPingAssistant
//
//  Created by 胡文峰 on 2018/10/19.
//  Copyright © 2018 xiaofutech. All rights reserved.
//

#import "XFQQMtaSdkHelper.h"
#import "MTA.h"
#import "MTAConfig.h"
#import "MTAAutoTrack.h"

@interface XFQQMtaSdkHelper ()
@property (nonatomic, strong) NSString *appid;
@property (nonatomic, strong) NSString *appSecret;
@end

static XFQQMtaSdkHelper *qqMtaHelper = nil;
@implementation XFQQMtaSdkHelper

#pragma mark - Public Methods
+ (void)RegisterAppKey:(NSString *)appKey secret:(NSString *)secret debugEnable:(BOOL)debugEnable
{
    [XFQQMtaSdkHelper SharedQQMtaSdkHelper].appid = appKey;
    [XFQQMtaSdkHelper SharedQQMtaSdkHelper].appSecret = secret;

    [MTAConfig getInstance].debugEnable = debugEnable;  // 启动前设置有效
    [[MTAConfig getInstance] setSmartReporting:YES];
    [[MTAConfig getInstance] setReportStrategy:MTA_STRATEGY_INSTANT];

    [MTA startWithAppkey:[XFQQMtaSdkHelper SharedQQMtaSdkHelper].appid];
}

+ (BOOL)HandleAutoTrackURL:(NSURL *)url
{
    return [MTAAutoTrack handleAutoTrackURL:url];
}

#pragma mark >>> 应用时长统计 <<<
+ (void)TrackActiveBegin
{
    [MTA trackActiveBegin];
}
+ (void)TrackActiveEnd
{
    [MTA trackActiveEnd];
}

#pragma mark >>> 页面追踪 <<<
+ (void)TrackPageViewBegin:(NSString *)page
{
    [MTA trackPageViewBegin:page];
}
+ (void)TrackPageViewEnd:(NSString *)page
{
    [MTA trackPageViewEnd:page];
}

#pragma mark >>> KeyValue事件统计 <<<
+ (void)TrackEvent_KV:(NSString *)event_id props:(NSDictionary *)args
{
    [MTA trackCustomKeyValueEvent:event_id props:args];
}

#pragma mark >>> KeyValue计时事件统计 <<<
+ (void)TrackEventStart_KV:(NSString *)event_id props:(NSDictionary *)args
{
    [MTA trackCustomKeyValueEventBegin:event_id props:args];
}
+ (void)TrackEventEnd_KV:(NSString *)event_id props:(NSDictionary *)args
{
    [MTA trackCustomKeyValueEventEnd:event_id props:args];
}

#pragma mark >>> Error事件统计 <<<
+ (void)TrackError:(NSString *)error
{
    [MTA trackError:error];
}

#pragma mark >>> Crash事件统计 <<<
+ (void)TrackException:(NSException *)ex
{
    [MTA trackException:ex];
}

#pragma mark - Private Methods
#pragma mark >>> Custom Accessors <<<
+ (XFQQMtaSdkHelper *)SharedQQMtaSdkHelper
{
    return [[XFQQMtaSdkHelper alloc] init];
}

#pragma mark >>> Life Cycle <<<
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    @synchronized (self) {
        if (!qqMtaHelper) {
            qqMtaHelper = [super allocWithZone:zone];
        }
        return qqMtaHelper;
    }

    //static dispatch_once_t onceToken;
    //dispatch_once(&onceToken, ^{
    //    qqMtaHelper = [super allocWithZone:zone];
    //});
    //return qqMtaHelper;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [XFQQMtaSdkHelper SharedQQMtaSdkHelper];
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [XFQQMtaSdkHelper SharedQQMtaSdkHelper];
}

@end
