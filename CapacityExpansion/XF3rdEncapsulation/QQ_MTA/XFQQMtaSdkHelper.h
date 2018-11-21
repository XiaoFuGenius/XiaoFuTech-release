//
//  XFQQMtaSdkHelper.h
//  JunPingAssistant
//
//  Created by 胡文峰 on 2018/10/19.
//  Copyright © 2018 xiaofutech. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XFQQMtaSdkHelper : NSObject

/**
 初始化并注册到 QQ_MTASdk
 @param appKey appid，必填
 @param secret appSecret，可为空
 @param debugEnable 日志开关
 注：pod 'QQ_MTA'
 */
+ (void)RegisterAppKey:(NSString *)appKey secret:(NSString *)secret debugEnable:(BOOL)debugEnable;

///可视化埋点代码
+ (BOOL)HandleAutoTrackURL:(NSURL *)url;

///应用时长统计
+ (void)TrackActiveBegin;
+ (void)TrackActiveEnd;

///页面追踪
+ (void)TrackPageViewBegin:(NSString*)page;
+ (void)TrackPageViewEnd:(NSString*)page;

///KeyValue普通事件统计
+ (void)TrackEvent_KV:(NSString *)event_id props:(NSDictionary *)args;

///KeyValue计时事件统计
+ (void)TrackEventStart_KV:(NSString *)event_id props:(NSDictionary *)args;
+ (void)TrackEventEnd_KV:(NSString *)event_id props:(NSDictionary *)args;

///Error事件统计
+ (void)TrackError:(NSString *)error;

///Crash事件统计
+ (void)TrackException:(NSException *)ex;

@end

NS_ASSUME_NONNULL_END
