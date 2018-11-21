//
//  XFCloudPushSdkHelper.h
//  JunPingAssistant
//
//  Created by 胡文峰 on 2018/10/24.
//  Copyright © 2018 xiaofutech. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define kAliPushType @".PushType" // 可选，@".Release" 或 @".Develop"
typedef void(^XFCloudPushSdkCallback)(id res);

@interface XFCloudPushSdkHelper : NSObject

#pragma mark - 配置修改 & 信息获取
/**
 输出日志
 */
+ (void)debugEnable;

/**
 显示苹果APNS服务器返回的，已转换的deviceToken，用于推送通知测试
 */
+ (void)deviceTokenAlertShow;

/**
 阿里推送通知
 @param notification 通知内容
 注：CCPDidReceiveMessageNotification
 */
+ (void)setOnMessageReceived:(void (^)(NSNotification *noti))notification;

/**
 打开 Ali CloudPushSDK 内部调试日志
 */
+ (void)turnOnDebug;

/**
 获取本机的deviceId (deviceId为推送系统的设备标识)
 @return deviceId
 */
+ (NSString *)getDeviceId;

#pragma mark - Sdk 初始化
/**
 Sdk 自动初始化...项目需要导入 AliyunEmasServices-Info.plist 文件
 @param launchOptions launchOptions
 @param callback 初始化完成回调
 注：{
 source 'https://github.com/CocoaPods/Specs.git'
 source 'https://github.com/aliyun/aliyun-specs.git'
 pod 'AlicloudPush', '~> 1.9.8'
 }
 注2：在 AppDelegate 的 方法 - (BOOL)application: didFinishLaunchingWithOptions: 中调用
 */
+ (void)autoInitWithOptions:(NSDictionary *)launchOptions callback:(nullable XFCloudPushSdkCallback)callback;


/**
 Sdk 手动初始化...需要 appKey 和 appSecret
 @param appKey key
 @param appSecret secret
 @param launchOptions launchOptions
 @param callback 初始化完成回调
 注：{
 source 'https://github.com/CocoaPods/Specs.git'
 source 'https://github.com/aliyun/aliyun-specs.git'
 pod 'AlicloudPush', '~> 1.9.8'
 }
 注2：在 AppDelegate 的 方法 - (BOOL)application: didFinishLaunchingWithOptions: 中调用
 */
+ (void)asyncInit:(NSString *)appKey
        appSecret:(NSString *)appSecret
          options:(NSDictionary *)launchOptions
         callback:(nullable XFCloudPushSdkCallback)callback;

/**
 向阿里云推送注册该设备的deviceToken
 @param deviceToken 苹果APNs服务器返回的deviceToken
 @param callback 注册完成回调
 @return 已转换的 deviceToken 字符串
 注：在 AppDelegate 的 方法 - (void)application: didRegisterForRemoteNotificationsWithDeviceToken: 中调用
 */
+ (NSString *)registerDevice:(NSData *)deviceToken
                withCallback:(nullable XFCloudPushSdkCallback)callback;

/**
 返回推送通知ACK到服务器
 @param userInfo 通知相关信息
 注：在 AppDelegate 的 方法 - (void)application: didReceiveRemoteNotification: 中调用
 */
+ (void)sendNotificationAck:(NSDictionary *)userInfo;

#pragma mark - 注册以实现唯一识别 设备/用户
/**
 绑定账号
 @param account 账号名
 @param callback 绑定完成回调
 */
+ (void)bindAccount:(NSString *)account
       withCallback:(nullable XFCloudPushSdkCallback)callback;

/**
 解绑账号
 @param callback 解绑完成回调
 */
+ (void)unbindAccount:(nullable XFCloudPushSdkCallback)callback;

@end

NS_ASSUME_NONNULL_END
