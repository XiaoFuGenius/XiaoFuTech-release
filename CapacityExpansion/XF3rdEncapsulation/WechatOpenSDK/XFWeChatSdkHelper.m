//
//  XFWeChatSdkHelper.m
//  JunPingAssistant
//
//  Created by 胡文峰 on 2018/10/16.
//  Copyright © 2018 xiaofutech. All rights reserved.
//

#import "XFWeChatSdkHelper.h"

#import <XiaoFuTech/XiaoFuTech.h>
#import "XFNetworkingSdkHelper.h"

#import "WechatAuthSDK.h"
#import "WXApi.h"

#define kATInfoKey_WeChat @"kWeChatSdkAccessTokenInfoKey"
#define kUserListKey_WeChat @"kWeChatSdkUserListKey"
#define kUserLoginUnionid_WeChat @"kWeChatSdkUserLoginUnionidKey"

@interface XFWeChatSdkHelper () <WXApiDelegate>
@property (nonatomic, strong) NSString *appid;
@property (nonatomic, strong) NSString *appSecret;

@property (nonatomic, strong) NSDictionary *accessTokenInfo;
@property (nonatomic, strong) NSDictionary *userInfo;

@property (nonatomic, copy) XFWeChatSdkOnResp onResp;
@end

static XFWeChatSdkHelper *weChatSdkHelper = nil;
@implementation XFWeChatSdkHelper

#pragma mark - Public Methods
+ (BOOL)IsWXAppInstalled
{
    return [WXApi isWXAppInstalled];
}

#pragma mark >>> Area O <<<
+ (BOOL)RefreshTokenIsExpiresIn
{
    NSDictionary *dict = [XFWeChatSdkHelper SharedWeChatSdkHelper].accessTokenInfo;
    if (!dict) {
        dict = [[NSUserDefaults standardUserDefaults] objectForKey:kATInfoKey_WeChat];
        [XFWeChatSdkHelper SharedWeChatSdkHelper].accessTokenInfo = [dict copy];
    }

    if (!dict) {
        return YES;
    }

    NSTimeInterval RT_expires_in = [dict[@"RT_expires_in"] doubleValue];
    BOOL expires_in = YES;
    if ([[NSDate date] timeIntervalSince1970] < RT_expires_in*1000) {
        expires_in = NO;
    }

    return expires_in;
}

+ (NSDictionary *)LoginUserInfo
{
    if ([XFWeChatSdkHelper SharedWeChatSdkHelper].userInfo) {
        return [XFWeChatSdkHelper SharedWeChatSdkHelper].userInfo;
    }

    return [[XFWeChatSdkHelper SharedWeChatSdkHelper] loginUserInfo];
}

+ (void)UpdateUserInfo:(XFWeChatSdkOnResp)onResp
{
    if ([XFWeChatSdkHelper RefreshTokenIsExpiresIn]) {
        [XFWeChatSdkHelper ShowFailureResponse:XFWeChatSdkResponse_RTokenExpiresIn Info:nil ErrInfo:nil];
        return;
    }

    [XFWeChatSdkHelper SharedWeChatSdkHelper].onResp = onResp;
    [[XFWeChatSdkHelper SharedWeChatSdkHelper] updateAccessToken];
}

+ (void)Logout
{
    [[XFWeChatSdkHelper SharedWeChatSdkHelper] logout];
}

#pragma mark >>> Area Z <<<

+ (void)RegisterAppKey:(id)appKey secret:(id)secret
         universalLink:(id)universalLink debugEnable:(id)debugEnable
{
    [XFWeChatSdkHelper SharedWeChatSdkHelper].appid = appKey;
    [XFWeChatSdkHelper SharedWeChatSdkHelper].appSecret = secret;

    if (debugEnable) {
        [WXApi startLogByLevel:1 logBlock:^(NSString *log) {
            NSLog(@"%@", log);
        }];
    }
    [WXApi registerApp:[XFWeChatSdkHelper SharedWeChatSdkHelper].appid universalLink:universalLink];
}

+ (BOOL)HandleOpenURL:(NSURL *)url
{
    return [WXApi handleOpenURL:url delegate:[XFWeChatSdkHelper SharedWeChatSdkHelper]];
}

+ (void)SendAuthRequestToWX:(XFWeChatSdkOnResp)onResp
{
    XFWeChatSdkResponse response = [XFWeChatSdkHelper HelperStatusCheck];
    if (XFWeChatSdkResponse_Success != response) {
        [XFWeChatSdkHelper ShowFailureResponse:response Info:nil ErrInfo:nil];
        return;
    }

    //创建微信授权请求对象
    SendAuthReq *sendReq = [[SendAuthReq alloc] init];
    sendReq.scope = @"snsapi_userinfo";
    sendReq.state = @"com.xiaofutech.JunPingAssistant.WeChatAuthState";

    //发送登录授权信息
    [WXApi sendReq:sendReq completion:nil];

    //保存回调block
    [XFWeChatSdkHelper SharedWeChatSdkHelper].onResp = onResp;
}

+ (void)SendMessageToWXScene:(int)scene Title:(NSString *)title Description:(NSString *)description
                  ThumbImage:(UIImage *)thumbImage LinkUrl:(NSString *)linkUrl OnResp:(nonnull XFWeChatSdkOnResp)onResp
{
    XFWeChatSdkResponse response = [XFWeChatSdkHelper HelperStatusCheck];
    if (XFWeChatSdkResponse_Success != response) {
        [XFWeChatSdkHelper ShowFailureResponse:response Info:nil ErrInfo:nil];
        return;
    }

    //创建分享内容对象
    WXMediaMessage *mediaMsg = [WXMediaMessage message];
    mediaMsg.title = title;//分享标题
    mediaMsg.description = description;//分享描述
    [mediaMsg setThumbImage:thumbImage];//分享图片,使用SDK的setThumbImage方法可压缩图片大小

    WXWebpageObject *webObj = [WXWebpageObject object];
    webObj.webpageUrl = linkUrl;//分享链接
    mediaMsg.mediaObject = webObj;

    //创建发送对象实例
    SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc] init];
    sendReq.bText = NO;//不使用文本信息
    sendReq.scene = scene;//0 = 好友列表 1 = 朋友圈 2 = 收藏
    sendReq.message = mediaMsg;

    //发送分享信息
    [WXApi sendReq:sendReq completion:nil];

    //保存回调block
    [XFWeChatSdkHelper SharedWeChatSdkHelper].onResp = onResp;
}

+ (void)SendMessageToWXScene:(int)scene ImageData:(NSData *)imageData OnResp:(nonnull XFWeChatSdkOnResp)onResp
{
    XFWeChatSdkResponse response = [XFWeChatSdkHelper HelperStatusCheck];
    if (XFWeChatSdkResponse_Success != response) {
        [XFWeChatSdkHelper ShowFailureResponse:response Info:nil ErrInfo:nil];
        return;
    }

    //创建分享内容对象
    WXMediaMessage *mediaMsg = [WXMediaMessage message];

    WXImageObject *imgObj = [WXImageObject object];
    imgObj.imageData = imageData;
    mediaMsg.mediaObject = imgObj;

    UIImage *thumbImage = [[UIImage imageWithData:imageData] xf_imageAutoSize:CGSizeMake(99, 99)];
    //mediaMsg.thumbData = UIImageJPEGRepresentation(thumbImage, 0.9f);
    [mediaMsg setThumbImage:thumbImage];

    //创建发送对象实例
    SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc] init];
    sendReq.bText = NO;//不使用文本信息
    sendReq.scene = scene;//0 = 好友列表 1 = 朋友圈 2 = 收藏
    sendReq.message = mediaMsg;

    //发送分享信息
    [WXApi sendReq:sendReq completion:nil];

    //保存回调block
    [XFWeChatSdkHelper SharedWeChatSdkHelper].onResp = onResp;
}

#pragma mark - Private Methods
+ (XFWeChatSdkResponse)HelperStatusCheck
{
    if (![WXApi isWXAppInstalled]) {
        return XFWeChatSdkResponse_NotInstalled;
    }

    if (![WXApi isWXAppSupportApi]) {
        return XFWeChatSdkResponse_ApiNotSupported;
    }

    return XFWeChatSdkResponse_Success;
}

+ (void)ShowFailureResponse:(XFWeChatSdkResponse)response Info:(NSDictionary *)infoX ErrInfo:(NSDictionary *)errInfoX
{
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    NSMutableDictionary *errInfo = [NSMutableDictionary dictionary];

    if ([infoX xf_NotNull]) {
        [info setDictionary:infoX];
    }

    if ([errInfoX xf_NotNull]) {
        [errInfo setDictionary:errInfoX];
    } else {
        if (XFWeChatSdkResponse_Success != response) {
            [errInfo setDictionary:@{@"type":@(response),
                                     @"errCode":@(response),
                                     @"errStr":@""}];
        }
    }

    if ([XFWeChatSdkHelper SharedWeChatSdkHelper].onResp) {
        NSDictionary *respDic = @{@"info":info,
                                  @"err":errInfo};
        [XFWeChatSdkHelper SharedWeChatSdkHelper].onResp(response, respDic);
    }
}

#pragma mark >>> WXApiDelegate <<<
- (void)onReq:(BaseReq *)req
{
    NSLog(@"******************************【XFWeChatSdkHelper】[onReq]:%@", req);
}

- (void)onResp:(BaseResp *)resp
{
    XFWeChatSdkResponse response = 0==resp.errCode ? XFWeChatSdkResponse_Success : XFWeChatSdkResponse_ResponseError;
    if (-2==resp.errCode ||
        -4==resp.errCode) {
        response = (XFWeChatSdkResponse)resp.errCode;
    }

    NSDictionary *errInfo = @{@"type":@(resp.type),
                              @"errCode":@(resp.errCode),
                              @"errStr":[resp.errStr xf_NotNull]?resp.errStr:@""};
    NSDictionary *info = [NSDictionary dictionary];

    // 全局搜索$ : BaseResp $获取resp类型；
    if ([resp isKindOfClass:[SendAuthResp class]]) {

        NSString *state = ((SendAuthResp *)resp).state;
        NSString *lang = ((SendAuthResp *)resp).lang;
        NSString *country = ((SendAuthResp *)resp).country;
        info = @{@"state":[state xf_NotNull]?state:@"",
                 @"lang":[lang xf_NotNull]?lang:@"",
                 @"country":[country xf_NotNull]?country:@""};

        if (0==resp.errCode) {
            NSString *code = ((SendAuthResp *)resp).code;
            [self requestAccessTokenWithAuthCode:code Info:info ErrInfo:errInfo];
            return;
        }  else {
            // -4：用户拒绝授权，-2：用户取消
        }

    } else if ([resp isKindOfClass:[SendMessageToWXResp class]]) {

        NSString *lang = ((SendMessageToWXResp *)resp).lang;
        NSString *country = ((SendMessageToWXResp *)resp).country;
        info = @{@"lang":[lang xf_NotNull]?lang:@"",
                 @"country":[country xf_NotNull]?country:@""};

    }

    [XFWeChatSdkHelper ShowFailureResponse:response Info:info ErrInfo:errInfo];
}

#pragma mark >>> WX Info Request <<<
/**
 说明文档：https://open.weixin.qq.com/cgi-bin/showdocument?action=dir_list&t=resource/res_list&verify=1&id=open1419317851&token=&lang=zh_CN
 */
- (void)requestAccessTokenWithAuthCode:(NSString *)code
                                  Info:(NSDictionary *)info
                               ErrInfo:(NSDictionary *)errInfo
{
    NSString *openUrl = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", self.appid, self.appSecret, code];

    XFWeakSelf(weakSelf);
    [XFNetworkingSdkHelper GetHttpDataWithUrlStr:openUrl Dic:nil SuccessBlock:^(id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *dict = [(NSDictionary *)responseObject xf_checkNull];

            if (![dict[@"access_token"] xf_NotNull]) {
                [XFWeChatSdkHelper ShowFailureResponse:XFWeChatSdkResponse_NullInfo Info:nil ErrInfo:nil];
                return;
            }

            NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970]/1000;
            NSTimeInterval AT_expires_in = timestamp + 7200 -10;  // 预留10s
            NSTimeInterval RT_expires_in = timestamp + 30*24*3600 -10;  // 预留10s

            NSMutableDictionary *accessTokenInfo = [NSMutableDictionary dictionary];
            [accessTokenInfo setDictionary:dict];
            [accessTokenInfo setObject:@(AT_expires_in) forKey:@"AT_expires_in"];
            [accessTokenInfo setObject:@(RT_expires_in) forKey:@"RT_expires_in"];

            weakSelf.accessTokenInfo = [accessTokenInfo copy];
            [[NSUserDefaults standardUserDefaults] setObject:[accessTokenInfo copy] forKey:kATInfoKey_WeChat];
            [[NSUserDefaults standardUserDefaults] synchronize];

            /**
             "access_token":"ACCESS_TOKEN",
             "expires_in":7200,
             "refresh_token":"REFRESH_TOKEN",
             "openid":"OPENID",
             "scope":"SCOPE",
             "unionid":"o6_bmasdasdsad6_2sgVt7hMZOPfL"
             */
            [weakSelf flushUserInfo];
        });
    } FailureBlock:^(id error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                [XFWeChatSdkHelper ShowFailureResponse:XFWeChatSdkResponse_NetworkError Info:nil ErrInfo:nil];
                return;
            }

            [XFWeChatSdkHelper ShowFailureResponse:XFWeChatSdkResponse_NetworkError Info:nil ErrInfo:nil];
        });
    }];
}

- (void)updateAccessToken
{
    NSString *refresh_tokenX = self.accessTokenInfo[@"refresh_token"];
    NSString *openUrl = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=%@&grant_type=refresh_token&refresh_token=%@", self.appid, refresh_tokenX];

    XFWeakSelf(weakSelf);
    [XFNetworkingSdkHelper GetHttpDataWithUrlStr:openUrl Dic:nil SuccessBlock:^(id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{

            NSDictionary *dict = [(NSDictionary *)responseObject xf_checkNull];

            NSString *access_token = dict[@"access_token"];
            NSString *refresh_token = dict[@"refresh_token"];

            if (![access_token xf_NotNull] || ![refresh_token xf_NotNull]) {
                [XFWeChatSdkHelper ShowFailureResponse:XFWeChatSdkResponse_NullInfo Info:nil ErrInfo:nil];
                return;
            }

            NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970]/1000;
            NSTimeInterval AT_expires_in = timestamp + 7200 -10;  // 预留10s
            long expires_in = [dict[@"expires_in"] longValue];
            NSString *openid = [dict[@"openid"] xf_NotNull]?dict[@"openid"]:@"";
            NSString *scope = [dict[@"scope"] xf_NotNull]?dict[@"scope"]:@"";

            NSMutableDictionary *accessTokenInfo = [NSMutableDictionary dictionary];
            [accessTokenInfo setDictionary:weakSelf.accessTokenInfo];
            [accessTokenInfo setObject:access_token forKey:@"access_token"];
            [accessTokenInfo setObject:refresh_token forKey:@"refresh_token"];
            [accessTokenInfo setObject:@(AT_expires_in) forKey:@"AT_expires_in"];
            [accessTokenInfo setObject:@(expires_in) forKey:@"expires_in"];
            [accessTokenInfo setObject:openid forKey:@"openid"];
            [accessTokenInfo setObject:scope forKey:@"scope"];

            weakSelf.accessTokenInfo = [accessTokenInfo copy];
            [[NSUserDefaults standardUserDefaults] setObject:[accessTokenInfo copy] forKey:kATInfoKey_WeChat];
            [[NSUserDefaults standardUserDefaults] synchronize];

            /**
             "access_token":"ACCESS_TOKEN",
             "expires_in":7200,
             "refresh_token":"REFRESH_TOKEN",
             "openid":"OPENID",
             "scope":"SCOPE"
             */
            [weakSelf flushUserInfo];
        });
    } FailureBlock:^(id error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                [XFWeChatSdkHelper ShowFailureResponse:XFWeChatSdkResponse_NetworkError Info:nil ErrInfo:nil];
            }

            [XFWeChatSdkHelper ShowFailureResponse:XFWeChatSdkResponse_NetworkError Info:nil ErrInfo:nil];
        });
    }];
}

- (void)flushUserInfo
{
    NSString *access_token = self.accessTokenInfo[@"access_token"];
    NSString *openid = self.accessTokenInfo[@"openid"];
    NSString *openUrl = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@", access_token, openid];

    XFWeakSelf(weakSelf);
    [XFNetworkingSdkHelper GetHttpDataWithUrlStr:openUrl Dic:nil SuccessBlock:^(id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{

            NSDictionary *dict = [(NSDictionary *)responseObject xf_checkNull];

            NSString *unionid = dict[@"unionid"];
            if (![unionid xf_NotNull]) {
                [XFWeChatSdkHelper ShowFailureResponse:XFWeChatSdkResponse_NullInfo Info:nil ErrInfo:nil];
                return;
            }
            weakSelf.userInfo = [[dict xf_checkNull] copy];

            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setDictionary:weakSelf.userInfo];
            [userInfo setObject:[NSData data] forKey:@"headimgData"];
            [weakSelf savedUserInfo:userInfo];

            //NSString *headimgurl = dict[@"headimgurl"];
            //if ([headimgurl xf_NotNull]) {
            //    UIImageView *imageView = [UIImageView new];
            //    [XFImageHelper DownloadImageFillView:imageView PlaceholderImage:nil Url:headimgurl
            //                               Completed:^(UIImageView *imageView, UIImage *image) {
            //        dispatch_async(dispatch_get_main_queue(), ^{
            //            NSMutableDictionary *userInfoX = [NSMutableDictionary dictionary];
            //            [userInfoX setDictionary:weakSelf.userInfo];
            //            [userInfoX setObject:UIImageJPEGRepresentation(image, 1.0f) forKey:@"headimgData"];
            //            [weakSelf savedUserInfo:userInfoX];
            //
            //            [XFWeChatSdkHelper ShowFailureResponse:XFWeChatSdkResponse_Success
            //                                              Info:[weakSelf.userInfo copy] ErrInfo:nil];
            //        });
            //    }];
            //
            //    return;
            //}

            [XFWeChatSdkHelper ShowFailureResponse:XFWeChatSdkResponse_Success
                                              Info:[weakSelf.userInfo copy] ErrInfo:nil];

            /**
             "openid":"OPENID",
             "nickname":"NICKNAME",
             "sex":1,
             "province":"PROVINCE",
             "city":"CITY",
             "country":"COUNTRY",
             "headimgurl": "ht tp://wx.qlogo.cn/mmopen/g3MonUZtNHkdmzicIlibx6iaFqAc56vxLSUfpb6n5WKSYVY0ChQKkiaJSgQ1dZuTOgvLLrhJbERQQ4eMsv84eavHiaiceqxibJxCfHe/0",
             "privilege":[
             "PRIVILEGE1",
             "PRIVILEGE2"
             ],
             "unionid": " o6_bmasdasdsad6_2sgVt7hMZOPfL"
             */
        });
    } FailureBlock:^(id error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                [XFWeChatSdkHelper ShowFailureResponse:XFWeChatSdkResponse_NetworkError Info:nil ErrInfo:nil];
                return;
            }

            [XFWeChatSdkHelper ShowFailureResponse:XFWeChatSdkResponse_NetworkError Info:nil ErrInfo:nil];
        });
    }];
}

#pragma mark >> 用户信息，本地处理 <<
- (void)savedUserInfo:(NSDictionary *)userInfo
{
    self.userInfo = [userInfo copy];
    NSString *unionid = userInfo[@"unionid"];

    NSDictionary *localList = [[NSUserDefaults standardUserDefaults] objectForKey:kUserListKey_WeChat];
    NSMutableDictionary *userList = [NSMutableDictionary dictionary];
    if (localList) {
        [userList setDictionary:localList];
    }
    [userList setObject:userInfo forKey:unionid];
    [[NSUserDefaults standardUserDefaults] setObject:[userList copy] forKey:kUserListKey_WeChat];

    [[NSUserDefaults standardUserDefaults] setObject:unionid
                                              forKey:kUserLoginUnionid_WeChat];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary *)loginUserInfo
{
    NSString *unionid = [[NSUserDefaults standardUserDefaults] objectForKey:kUserLoginUnionid_WeChat];
    if (![unionid xf_NotNull]) {
        return nil;
    }

    NSDictionary *localList = [[NSUserDefaults standardUserDefaults] objectForKey:kUserListKey_WeChat];
    if (!localList) {
        return nil;
    }

    NSDictionary *loginUserInfo = [localList objectForKey:unionid];
    return loginUserInfo;
}

- (void)logout
{
    NSString *unionid = [[NSUserDefaults standardUserDefaults] objectForKey:kUserLoginUnionid_WeChat];
    if (![unionid xf_NotNull]) {
        return;
    }

    // 本地 移除用户唯一识别码
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserLoginUnionid_WeChat];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark >>> Custom Accessors <<<
+ (XFWeChatSdkHelper *)SharedWeChatSdkHelper
{
    return [[XFWeChatSdkHelper alloc] init];
}

#pragma mark >>> Life Cycle <<<
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    @synchronized (self) {
        if (!weChatSdkHelper) {
            weChatSdkHelper = [super allocWithZone:zone];
        }
        return weChatSdkHelper;
    }

    //static dispatch_once_t onceToken;
    //dispatch_once(&onceToken, ^{
    //    weChatSdkHelper = [super allocWithZone:zone];
    //});
    //return weChatSdkHelper;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [XFWeChatSdkHelper SharedWeChatSdkHelper];
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [XFWeChatSdkHelper SharedWeChatSdkHelper];
}

@end
