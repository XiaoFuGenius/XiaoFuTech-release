//
//  XFWeiboSdkHelper.h
//  JunPingAssistant
//
//  Created by 胡文峰 on 2018/10/12.
//  Copyright © 2018 xiaofutech. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, XFWeiboSdkResponse) {
    XFWeiboSdkResponse_Success          = 0,  // 成功

    XFWeiboSdkResponse_UserCancel       = -1,  // 用户取消发送
    XFWeiboSdkResponse_SentFail         = -2,  // 发送失败
    XFWeiboSdkResponse_AuthDeny         = -3,  // 授权失败

    XFWeiboSdkResponse_NotInstalled     = -66,  // 未安装微博客户端
    XFWeiboSdkResponse_Sharing          = -67,  // 有分享正在进行中
    XFWeiboSdkResponse_ParamError       = -68,  // 输入参数错误

    XFWeiboSdkResponse_NetworkError     = -69,  // 网络请求错误
    XFWeiboSdkResponse_ResponseError    = -70,  // 除，0，-1，-2，-3，外的其它响应错误
    XFWeiboSdkResponse_NullInfo         = -71,  // 请求成功，但 用户信息 空
};

typedef void(^XFWeiboSdkOnResp)(XFWeiboSdkResponse status, NSDictionary *resp);

@interface XFWeiboSdkHelper : NSObject

+ (BOOL)IsWeiboAppInstalled;

#pragma mark - Area O
/**
 获取当前已登录的微信用户信息字典，本地
 */
+ (NSDictionary *)LoginUserInfo;

/**
 已登录的情况下，更新用户信息，此时AT未过期，建议每次启动APP之后，调用一次更新当前登录的用户的信息
 @param onResp 授权回调
 */
+ (void)UpdateUserInfo:(XFWeiboSdkOnResp)onResp;

/**
 退出当前登录
 */
+ (void)Logout;

#pragma mark - Area Z

/**
 初始化并注册到 WeiboSdk
 @param appKey appid，必填
 @param secret appSecret，可为空
 @param debugEnable 日志开关
 注：pod 'Weibo_SDK', :git => 'https://github.com/sinaweibosdk/weibo_ios_sdk.git'
 注2：修改 appKey & appSecret 时，注意同步修改 URLTypes 和 AppDelegate 中的值
 */
+ (void)RegisterAppKey:(NSString *)appKey secret:(NSString *)secret debugEnable:(BOOL)debugEnable;

/**
 处理微博客户端程序通过URL启动第三方应用时传递的数据
 需要在 application:openURL:sourceApplication:annotation:或者application:handleOpenURL中调用
 @param url 启动第三方应用的URL
 */
+ (BOOL)HandleOpenURL:(NSURL *)url;

/**
 未登录的情况下，发送微博授权登录请求
 @param onResp 授权回调
 */
+ (void)SendAuthRequestToWB:(XFWeiboSdkOnResp)onResp;

/**
 微博内容分享，文字+图片
 @param shareToStory 是否作为 微博故事 分享
 @param text 文字内容
 @param images 图片内容
 @param onResp 分享回调
 注1：text 和 image 不可同时为 nil
 注2：shareToStory = YES；分享仅会使用 images 中的第一张图片
 */
+ (void)SendMessageToWBShareToStory:(BOOL)shareToStory Text:(NSString *)text
                             Images:(NSArray<UIImage *> *)images OnResp:(XFWeiboSdkOnResp)onResp;

/**
 微博内容分享，文字+链接
 @param text 文字内容
 @param title 链接标题
 @param description 链接描述
 @param thumbImage 链接缩略图
 @param linkUrl 链接
 @param onResp 分享回调
 注：title，linkUrl 不能为 nil
 */
+ (void)SendMessageToWBText:(NSString *)text Title:(NSString *)title Description:(NSString *)description
                 ThumbImage:(NSData *)thumbImage LinkUrl:(NSString *)linkUrl OnResp:(XFWeiboSdkOnResp)onResp;

/**
 微博内容分享，文字+视频
 @param shareToStory 是否作为 微博故事 分享
 @param text 文字内容
 @param videoUrl 视频链接
 @param onResp 分享回调
 注：videoUrl 不能为 nil
 */
+ (void)SendMessageToWBShareToStory:(BOOL)shareToStory Text:(NSString *)text
                           VideoUrl:(NSURL *)videoUrl OnResp:(XFWeiboSdkOnResp)onResp;

@end

NS_ASSUME_NONNULL_END
