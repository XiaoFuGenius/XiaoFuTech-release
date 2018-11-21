//
//  XFWeChatSdkHelper.h
//  JunPingAssistant
//
//  Created by 胡文峰 on 2018/10/16.
//  Copyright © 2018 xiaofutech. All rights reserved.
//

#import <Foundation/Foundation.h>


// 关于 微信分享，微信版本6.7.2+，分享取消将不会有失败的回调； https://open.weixin.qq.com/cgi-bin/announce?action=getannouncement&key=11534138374cE6li&version=&lang=zh_CN&token=

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, XFWeChatSdkResponse) {
    XFWeChatSdkResponse_Success             = 0,  // 成功

    XFWeChatSdkResponse_UserCancel          = -2,  // 用户取消发送
    XFWeChatSdkResponse_AuthDeny            = -4,  // 授权失败

    XFWeChatSdkResponse_NotInstalled        = -66,  // 未安装微信客户端
    XFWeChatSdkResponse_ApiNotSupported       = -67,  // WXApi不支持
    XFWeChatSdkResponse_ParamError          = -68,  // 输入参数错误

    XFWeChatSdkResponse_NetworkError        = -69,  // 网络请求错误
    XFWeChatSdkResponse_ResponseError       = -70,  // 除，0，-1，外的其它响应错误
    XFWeChatSdkResponse_NullInfo            = -71,  // 请求成功，但 用户信息 空

    XFWeChatSdkResponse_RTokenExpiresIn     = -72,  // refresh_token已过期
};

typedef void(^XFWeChatSdkOnResp)(XFWeChatSdkResponse status, NSDictionary *resp);

@interface XFWeChatSdkHelper : NSObject

+ (BOOL)IsWXAppInstalled;

#pragma mark - Area O
/**
 已授权的情况下，RT是否过期，若已过期，则应退出登录，或调用 SendAuthRequestToWX: 方法
 */
+ (BOOL)RefreshTokenIsExpiresIn;

/**
 获取当前已登录的微信用户信息字典，本地
 */
+ (NSDictionary *)LoginUserInfo;

/**
 已登录的情况下，更新用户信息，此时RT未过期，建议每次启动APP之后，调用一次更新当前登录的用户的信息
 @param onResp 授权回调
 */
+ (void)UpdateUserInfo:(XFWeChatSdkOnResp)onResp;

/**
 退出当前登录
 */
+ (void)Logout;

#pragma mark - Area Z

/**
 初始化并注册到 WeChatSdk
 @param appKey appid，必填
 @param secret appSecret，可为空
 @param debugEnable 日志开关
 注：pod 'WechatOpenSDK'
 注2：修改 appKey & appSecret 时，注意同步修改 URLTypes 和 AppDelegate 中的值
 */
+ (void)RegisterAppKey:(NSString *)appKey secret:(NSString *)secret debugEnable:(BOOL)debugEnable;

/**
 处理微信通过URL启动App时传递的数据
 需要在 application:openURL:sourceApplication:annotation:或者application:handleOpenURL中调用。
 @param url 微信启动第三方应用时传递过来的URL
 @return 成功返回YES，失败返回NO。
 */
+ (BOOL)HandleOpenURL:(NSURL *)url;

/**
 未登录的情况下，发送微信授权登录请求
 @param onResp 授权回调
 */
+ (void)SendAuthRequestToWX:(XFWeChatSdkOnResp)onResp;

/**
 链接 url 分享
 @param scene 0<好友列表>，1<朋友圈>，2<收藏>
 @param title 分享标题
 @param description 分享内容描述
 @param thumbImage 分享缩略图
 @param linkUrl 分享l链接
 @param onResp 分享回调
 */
+ (void)SendMessageToWXScene:(int)scene Title:(NSString *)title Description:(NSString *)description
                  ThumbImage:(UIImage *)thumbImage LinkUrl:(NSString *)linkUrl OnResp:(XFWeChatSdkOnResp)onResp;

/**
 图片 image 分享
 @param scene 0<好友列表>，1<朋友圈>，2<收藏>
 @param imageData 分享图片数据
 @param onResp 分享回调
 */
+ (void)SendMessageToWXScene:(int)scene ImageData:(NSData *)imageData OnResp:(XFWeChatSdkOnResp)onResp;

@end

NS_ASSUME_NONNULL_END
