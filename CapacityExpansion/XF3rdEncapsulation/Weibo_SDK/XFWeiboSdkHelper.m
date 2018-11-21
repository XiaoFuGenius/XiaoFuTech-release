//
//  XFWeiboSdkHelper.m
//  JunPingAssistant
//
//  Created by 胡文峰 on 2018/10/12.
//  Copyright © 2018 xiaofutech. All rights reserved.
//

#import "XFWeiboSdkHelper.h"

#import <XiaoFuTech/XiaoFuTech.h>

#import "WeiboSDK.h"
#import "XFNetworkingSdkHelper.h"

#define kATInfoKey_Weibo @"kWeiboSdkAccessTokenInfoKey"
#define kUserListKey_Weibo @"kWeiboSdkUserListKey"
#define kUserLoginUnionid_Weibo @"kWeiboSdkUserLoginUnionidKey"

@interface XFWeiboSdkHelper () <WeiboSDKDelegate, WBHttpRequestDelegate, WBMediaTransferProtocol>
@property (nonatomic, strong) NSString *appKey;
@property (nonatomic, strong) NSString *appSecret;
@property (nonatomic, strong) NSString *redirectURI;

@property (nonatomic, strong) NSDictionary *accessTokenInfo;
@property (nonatomic, strong) NSDictionary *userInfo;

@property (nonatomic, strong) WBMessageObject *msgObj;
@property (nonatomic, copy) XFWeiboSdkOnResp onResp;
@end

static XFWeiboSdkHelper *weiboSdkHelper = nil;
@implementation XFWeiboSdkHelper

#pragma mark - Public Methods
+ (BOOL)IsWeiboAppInstalled
{
    return [WeiboSDK isWeiboAppInstalled];
}

#pragma mark >>> Area O <<<
+ (NSDictionary *)LoginUserInfo
{
    if ([XFWeiboSdkHelper SharedWeiboSdkHelper].userInfo) {
        return [XFWeiboSdkHelper SharedWeiboSdkHelper].userInfo;
    }

    return [[XFWeiboSdkHelper SharedWeiboSdkHelper] loginUserInfo];
}

+ (void)UpdateUserInfo:(XFWeiboSdkOnResp)onResp
{
    [XFWeiboSdkHelper SharedWeiboSdkHelper].onResp = onResp;

    NSDictionary *accessTokenInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kATInfoKey_Weibo];
    if (accessTokenInfo) {
        [XFWeiboSdkHelper SharedWeiboSdkHelper].accessTokenInfo = accessTokenInfo;
    }
    [[XFWeiboSdkHelper SharedWeiboSdkHelper] flushUserInfo];
}

+ (void)Logout
{
    [[XFWeiboSdkHelper SharedWeiboSdkHelper] logout];
}

#pragma mark >>> Area Z <<<

+ (void)RegisterAppKey:(NSString *)appKey secret:(NSString *)secret debugEnable:(BOOL)debugEnable
{
    [XFWeiboSdkHelper SharedWeiboSdkHelper].appKey = appKey;
    [XFWeiboSdkHelper SharedWeiboSdkHelper].appSecret = secret;
    //weiboSdkHelper.redirectURI = @"http://";
    [XFWeiboSdkHelper SharedWeiboSdkHelper].redirectURI = @"https://api.weibo.com/oauth2/default.html";

    [WeiboSDK enableDebugMode:debugEnable];
    [WeiboSDK registerApp:[XFWeiboSdkHelper SharedWeiboSdkHelper].appKey];
}

+ (BOOL)HandleOpenURL:(NSURL *)url
{
    return [WeiboSDK handleOpenURL:url delegate:[XFWeiboSdkHelper SharedWeiboSdkHelper]];
}

+ (void)SendAuthRequestToWB:(XFWeiboSdkOnResp)onResp
{
    XFWeiboSdkResponse response = [XFWeiboSdkHelper HelperStatusCheck];
    if (XFWeiboSdkResponse_Success != response) {
        [XFWeiboSdkHelper ShowFailureResponse:response Info:nil ErrInfo:nil];
        return;
    }

    //创建微博授权请求对象
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = [XFWeiboSdkHelper SharedWeiboSdkHelper].redirectURI;
    authRequest.scope = @"all";
    //authRequest.userInfo = @{@"SSO_From": NSStringFromClass([self class]),
    //                     @"Other_Info_1": [NSNumber numberWithInt:123],
    //                     @"Other_Info_2": @[@"obj1", @"obj2"],
    //                     @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};

    //保存回调block
    [XFWeiboSdkHelper SharedWeiboSdkHelper].onResp = onResp;

    //发送登录授权信息
    [WeiboSDK sendRequest:authRequest];
}

+ (void)SendMessageToWBShareToStory:(BOOL)shareToStory Text:(NSString *)text
                             Images:(NSArray<UIImage *> *)images OnResp:(XFWeiboSdkOnResp)onResp
{
    XFWeiboSdkResponse response = [XFWeiboSdkHelper HelperStatusCheck];
    if (XFWeiboSdkResponse_Success != response) {
        [XFWeiboSdkHelper ShowFailureResponse:response Info:nil ErrInfo:nil];
        return;
    }
    if (![text xf_NotNull] && (![images xf_NotNull] || images.count==0)) {
        [XFWeiboSdkHelper ShowFailureResponse:XFWeiboSdkResponse_ParamError Info:nil ErrInfo:nil];
        return;
    }

    //创建分享内容对象
    WBMessageObject *message = [WBMessageObject message];

    //文字分享
    if ([text xf_NotNull]) {
        message.text = text;
    }

    //图片分享
    if (images.count > 0) {
        WBImageObject *imageObj = [WBImageObject object];
        imageObj.isShareToStory = shareToStory;
        imageObj.delegate = [XFWeiboSdkHelper SharedWeiboSdkHelper];
        if (shareToStory) {
            [imageObj addImages:@[images.firstObject]];
        } else {
            [imageObj addImages:images];
        }
        message.imageObject = imageObj;
    }

    //保存分享内容对象
    [XFWeiboSdkHelper SharedWeiboSdkHelper].msgObj = message;

    //保存回调block
    [XFWeiboSdkHelper SharedWeiboSdkHelper].onResp = onResp;

    if (images.count==0) {
        //发送分享请求
        [[XFWeiboSdkHelper SharedWeiboSdkHelper] messageShare];
    }
}

+ (void)SendMessageToWBText:(NSString *)text Title:(NSString *)title Description:(NSString *)description
                 ThumbImage:(NSData *)thumbImage LinkUrl:(NSString *)linkUrl OnResp:(nonnull XFWeiboSdkOnResp)onResp
{
    XFWeiboSdkResponse response = [XFWeiboSdkHelper HelperStatusCheck];
    if (XFWeiboSdkResponse_Success != response) {
        [XFWeiboSdkHelper ShowFailureResponse:response Info:nil ErrInfo:nil];
        return;
    }
    if (![title xf_NotNull] && ![linkUrl xf_NotNull]) {
        [XFWeiboSdkHelper ShowFailureResponse:XFWeiboSdkResponse_ParamError Info:nil ErrInfo:nil];
        return;
    }
    if (thumbImage.length > 32*1024) {
        [XFWeiboSdkHelper ShowFailureResponse:XFWeiboSdkResponse_ParamError Info:nil ErrInfo:nil];
        return;
    }

    //创建分享内容对象
    WBMessageObject *message = [WBMessageObject message];

    //文字分享
    if ([text xf_NotNull]) {
        message.text = text;
    }

    //链接分享
    WBWebpageObject *webpage = [WBWebpageObject object];
    webpage.objectID = [NSString stringWithFormat:@"identifier_%lf", [[NSDate date] timeIntervalSince1970]];
    webpage.title = title;
    webpage.description = description;
    webpage.thumbnailData = thumbImage;
    webpage.webpageUrl = linkUrl;
    message.mediaObject = webpage;

    //保存分享内容对象
    [XFWeiboSdkHelper SharedWeiboSdkHelper].msgObj = message;

    //保存回调block
    [XFWeiboSdkHelper SharedWeiboSdkHelper].onResp = onResp;

    //发送分享请求
    [[XFWeiboSdkHelper SharedWeiboSdkHelper] messageShare];
}

+ (void)SendMessageToWBShareToStory:(BOOL)shareToStory Text:(NSString *)text
                           VideoUrl:(NSURL *)videoUrl OnResp:(XFWeiboSdkOnResp)onResp
{
    XFWeiboSdkResponse response = [XFWeiboSdkHelper HelperStatusCheck];
    if (XFWeiboSdkResponse_Success != response) {
        [XFWeiboSdkHelper ShowFailureResponse:response Info:nil ErrInfo:nil];
        return;
    }
    if (![videoUrl xf_NotNull]) {
        [XFWeiboSdkHelper ShowFailureResponse:XFWeiboSdkResponse_ParamError Info:nil ErrInfo:nil];
        return;
    }

    //创建分享内容对象
    WBMessageObject *message = [WBMessageObject message];

    //文字分享
    if ([text xf_NotNull]) {
        message.text = text;
    }

    //视频分享
    WBNewVideoObject *videoObject = [WBNewVideoObject object];
    videoObject.isShareToStory = shareToStory;
    videoObject.delegate = [XFWeiboSdkHelper SharedWeiboSdkHelper];
    [videoObject addVideo:videoUrl];
    message.videoObject = videoObject;

    //保存分享内容对象
    [XFWeiboSdkHelper SharedWeiboSdkHelper].msgObj = message;

    //保存回调block
    [XFWeiboSdkHelper SharedWeiboSdkHelper].onResp = onResp;
}

#pragma mark - Private Methods
- (void)messageShare
{
    WBMessageObject *message = self.msgObj;

    //创建发送对象实例
    WBSendMessageToWeiboRequest *msgRequest = [WBSendMessageToWeiboRequest requestWithMessage:message];

    ////创建微博授权请求对象
    //WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    //authRequest.redirectURI = [XFWeiboSdkHelper SharedWeiboSdkHelper].redirectURI;
    //authRequest.scope = @"all";
    //
    ////创建发送对象实例
    //WBSendMessageToWeiboRequest *msgRequest = [WBSendMessageToWeiboRequest
    //                                           requestWithMessage:message
    //                                           authInfo:authRequest access_token:nil];

    //发送分享信息
    [WeiboSDK sendRequest:msgRequest];

    //销毁分享内容对象
    self.msgObj = nil;
}

+ (XFWeiboSdkResponse)HelperStatusCheck
{
    if (![WeiboSDK isWeiboAppInstalled]) {
        return XFWeiboSdkResponse_NotInstalled;
    }

    if ([XFWeiboSdkHelper SharedWeiboSdkHelper].msgObj) {
        return XFWeiboSdkResponse_Sharing;
    }

    return XFWeiboSdkResponse_Success;
}

+ (void)ShowFailureResponse:(XFWeiboSdkResponse)response Info:(NSDictionary *)infoX ErrInfo:(NSDictionary *)errInfoX
{
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    NSMutableDictionary *errInfo = [NSMutableDictionary dictionary];

    if ([infoX xf_NotNull]) {
        [info setDictionary:infoX];
    }

    if ([errInfoX xf_NotNull]) {
        [errInfo setDictionary:errInfoX];
    } else {
        if (XFWeiboSdkResponse_Success != response) {
            [errInfo setDictionary:@{@"type":@(response),
                                     @"errCode":@(response),
                                     @"errStr":@""}];
        }
    }

    if ([XFWeiboSdkHelper SharedWeiboSdkHelper].onResp) {
        NSDictionary *respDic = @{@"info":info,
                                  @"err":errInfo};
        [XFWeiboSdkHelper SharedWeiboSdkHelper].onResp(response, respDic);
    }
}

- (void)showResponseTitle:(NSString *)title Msg:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark >>> WBMediaTransferProtocol <<<
- (void)wbsdk_TransferDidReceiveObject:(id)object
{
    //发送分享请求
    [self messageShare];
}

- (void)wbsdk_TransferDidFailWithErrorCode:(WBSDKMediaTransferErrorCode)errorCode andError:(NSError *)error
{
    [XFWeiboSdkHelper ShowFailureResponse:XFWeiboSdkResponse_ResponseError Info:nil ErrInfo:nil];
}

#pragma mark >>> WeiboSDKDelegate <<<
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request  // 收到一个来自微博客户端程序的请求
{
    NSLog(@"****************【XFWeiboSdkHelper】[didReceiveWeiboRequest]:%@", request);
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response  // 收到一个来自微博客户端程序的响应
{
    XFWeiboSdkResponse resp = 0==response.statusCode ? XFWeiboSdkResponse_Success : XFWeiboSdkResponse_ResponseError;
    if (-1==response.statusCode ||
        -2==response.statusCode ||
        -3==response.statusCode) {
        resp = (XFWeiboSdkResponse)response.statusCode;
    }

    NSDictionary *requestUserInfo = [response.requestUserInfo xf_checkNull];
    if (!requestUserInfo) {
        requestUserInfo = [NSDictionary dictionary];
    }
    NSDictionary *errInfo = @{@"statusCode":@(response.statusCode),
                              @"requestUserInfo":requestUserInfo};
    NSDictionary *info = [NSDictionary dictionary];

    if ([response isKindOfClass:WBAuthorizeResponse.class]) {

        //NSString *title = NSLocalizedString(@"认证结果", nil);
        //NSString *message = [NSString stringWithFormat:@"%@: %d\nresponse.userId: %@\nresponse.accessToken: %@\n%@: %@\n%@: %@",
        //                     NSLocalizedString(@"响应状态", nil), (int)response.statusCode,
        //                     [(WBAuthorizeResponse *)response userID],
        //                     [(WBAuthorizeResponse *)response accessToken],
        //                     NSLocalizedString(@"响应UserInfo数据", nil), response.userInfo,
        //                     NSLocalizedString(@"原请求UserInfo数据", nil), response.requestUserInfo];
        //[self showResponseTitle:title Msg:message];

        if (XFWeiboSdkResponse_Success == resp) {
            NSString *accessToken = [(WBAuthorizeResponse *)response accessToken];
            long expires_in = [[(WBAuthorizeResponse *)response expirationDate] timeIntervalSince1970]/1000 + 8*3600;
            NSString *refreshToken = [(WBAuthorizeResponse *)response refreshToken];
            NSString *userID = [(WBAuthorizeResponse *)response userID];
            NSLog(@"%@, %@, %@", accessToken, refreshToken, userID);

            self.accessTokenInfo = @{@"access_token":accessToken,
                                     @"expires_in":@(expires_in),
                                     @"refresh_token":refreshToken,
                                     @"userID":userID};

            [[NSUserDefaults standardUserDefaults] setObject:self.accessTokenInfo forKey:kATInfoKey_Weibo];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self flushUserInfo];
            
            return;
        } else {
            /// -3：用户拒绝授权，-1：用户取消
        }

    } else if ([response isKindOfClass:WBSendMessageToWeiboResponse.class]) {

        //NSString *title = NSLocalizedString(@"发送结果", nil);
        //NSString *message = [NSString stringWithFormat:@"%@: %d\n%@: %@\n%@: %@",
        //                     NSLocalizedString(@"响应状态", nil), (int)response.statusCode,
        //                     NSLocalizedString(@"响应UserInfo数据", nil), response.userInfo,
        //                     NSLocalizedString(@"原请求UserInfo数据", nil),response.requestUserInfo];
        //[self showResponseTitle:title Msg:message];

        if (XFWeiboSdkResponse_Success == resp) {
            WBSendMessageToWeiboResponse* sendMessageToWeiboResponse = (WBSendMessageToWeiboResponse*)response;
            NSString* accessToken = [sendMessageToWeiboResponse.authResponse accessToken];
            NSString* userID = [sendMessageToWeiboResponse.authResponse userID];
            NSLog(@"%@, %@", accessToken, userID);
        }

    }

    [XFWeiboSdkHelper ShowFailureResponse:resp Info:info ErrInfo:errInfo];
}

#pragma mark >>> WBHttpRequestDelegate <<<
- (void)request:(WBHttpRequest *)request didFinishLoadingWithResult:(NSString *)result
{
    //[self showResponseTitle:NSLocalizedString(@"收到网络回调", nil) Msg:[NSString stringWithFormat:@"%@", result]];
}

- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error;
{
    //[self showResponseTitle:NSLocalizedString(@"请求异常", nil) Msg:[NSString stringWithFormat:@"%@", error]];
}

#pragma mark >>> WB Info Request <<<
/**
 说明文档：https://github.com/sinaweibosdk/weibo_ios_sdk

 错误1：error:redirect_uri_mismatch
 原因：未在开放平台的应用管理页的高级信息中填写回调地址；
 解决：登录[http://open.weibo.com]，选择[管理中心]->[我的应用]->["您的应用名"]->展开左侧[应用信息]
 ->[高级信息]->OAuth2.0 授权设置 右上角[编辑]->在框里填入回调地址即可；
 注：前期测试应用时随便填个公司主页即可.两个地址可以相同；或者，设定[redirect_uri] = http://

 错误2：sso package or sign error
 原因：新浪微博开放平台上申请的应用的< bundle identifier >与项目的< bundle identifier >不一致；
 解决：保证指定位置的< bundle identifier >保持一样即可；
 */

- (void)flushUserInfo
{
    NSString *access_token = self.accessTokenInfo[@"access_token"];
    NSString *uid = self.accessTokenInfo[@"userID"];
    NSString *openUrl = [NSString stringWithFormat:@"https://api.weibo.com/2/users/show.json?access_token=%@&uid=%@", access_token, uid];

    //NSString *url = @"https://api.weibo.com/2/users/counts.json";
    //NSDictionary *param = @{@"access_token":access_token,
    //                        @"uids":uid};
    //[WBHttpRequest requestWithURL:url httpMethod:@"GET" params:param delegate:self withTag:@"me"];
    //return;

    XFWeakSelf(weakSelf);
    [XFNetworkingSdkHelper GetHttpDataWithUrlStr:openUrl Dic:nil SuccessBlock:^(id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *dict = [(NSDictionary *)responseObject xf_checkNull];

            if (![dict.allKeys containsObject:@"id"]) {
                [XFWeiboSdkHelper ShowFailureResponse:XFWeiboSdkResponse_NullInfo Info:nil ErrInfo:nil];
                return;
            }

            weakSelf.userInfo = [[dict xf_checkNull] copy];

            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setDictionary:weakSelf.userInfo];
            [userInfo setObject:[NSData data] forKey:@"headimgData"];
            [weakSelf savedUserInfo:userInfo];

            //NSString *headimgurl = dict[@"avatar_large"];
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
            //            [XFWeiboSdkHelper ShowFailureResponse:XFWeiboSdkResponse_Success
            //                                             Info:[weakSelf.userInfo copy] ErrInfo:nil];
            //        });
            //    }];
            //
            //    return;
            //}

            [XFWeiboSdkHelper ShowFailureResponse:XFWeiboSdkResponse_Success
                                             Info:[weakSelf.userInfo copy] ErrInfo:nil];

            /**
             "id": 1404376560,
             "screen_name": "zaku",
             "name": "zaku",
             "province": "11",
             "city": "5",
             "location": "北京 朝阳区",
             "description": "人生五十年，乃如梦如幻；有生斯有死，壮士复何憾。",
             "url": "http://blog.sina.com.cn/zaku",
             "profile_image_url": "http://tp1.sinaimg.cn/1404376560/50/0/1",
             "domain": "zaku",
             "gender": "m",
             "followers_count": 1204,
             "friends_count": 447,
             "statuses_count": 2908,
             "favourites_count": 0,
             "created_at": "Fri Aug 28 00:00:00 +0800 2009",
             "following": false,
             "allow_all_act_msg": false,
             "geo_enabled": true,
             "verified": false,
             "status": {
             "created_at": "Tue May 24 18:04:53 +0800 2011",
             "id": 11142488790,
             "text": "我的相机到了。",
             "source": "<a href="http://weibo.com" rel="nofollow">新浪微博</a>",
             "favorited": false,
             "truncated": false,
             "in_reply_to_status_id": "",
             "in_reply_to_user_id": "",
             "in_reply_to_screen_name": "",
             "geo": null,
             "mid": "5610221544300749636",
             "annotations": [],
             "reposts_count": 5,
             "comments_count": 8
             },
             "allow_all_comment": true,
             "avatar_large": "http://tp1.sinaimg.cn/1404376560/180/0/1",
             "verified_reason": "",
             "follow_me": false,
             "online_status": 0,
             "bi_followers_count": 215
             */
        });
    } FailureBlock:^(id error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                [XFWeiboSdkHelper ShowFailureResponse:XFWeiboSdkResponse_NetworkError Info:nil ErrInfo:nil];
                return;
            }

            [XFWeiboSdkHelper ShowFailureResponse:XFWeiboSdkResponse_NetworkError Info:nil ErrInfo:nil];
        });
    }];
}

#pragma mark >>> 用户信息，本地处理 <<<
- (void)savedUserInfo:(NSDictionary *)userInfo
{
    self.userInfo = userInfo;
    long unionid = [userInfo[@"id"] longValue];

    NSDictionary *localList = [[NSUserDefaults standardUserDefaults] objectForKey:kUserListKey_Weibo];
    NSMutableDictionary *userList = [NSMutableDictionary dictionary];
    if (localList) {
        [userList setDictionary:localList];
    }
    [userList setObject:userInfo forKey:@(unionid).stringValue];
    [[NSUserDefaults standardUserDefaults] setObject:[userList copy] forKey:kUserListKey_Weibo];

    [[NSUserDefaults standardUserDefaults] setObject:@(unionid)
                                              forKey:kUserLoginUnionid_Weibo];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary *)loginUserInfo
{
    long unionid = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserLoginUnionid_Weibo] longValue];
    if (0==unionid) {
        return nil;
    }

    NSDictionary *localList = [[NSUserDefaults standardUserDefaults] objectForKey:kUserListKey_Weibo];
    if (!localList) {
        return nil;
    }

    NSDictionary *loginUserInfo = [localList objectForKey:@(unionid).stringValue];

    return loginUserInfo;
}

- (void)logout
{
    long unionid = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserLoginUnionid_Weibo] longValue];
    if (0==unionid) {
        return;
    }

    // 本地 移除用户唯一识别码
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserLoginUnionid_Weibo];
    [[NSUserDefaults standardUserDefaults] synchronize];

    NSString *access_token = self.accessTokenInfo[@"access_token"];
    [WeiboSDK logOutWithToken:access_token delegate:self withTag:@"user1"];
}

#pragma mark >>> Custom Accessors <<<
+ (XFWeiboSdkHelper *)SharedWeiboSdkHelper
{
    return [[XFWeiboSdkHelper alloc] init];
}

#pragma mark >>> Life Cycle <<<
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    @synchronized (self) {
        if (!weiboSdkHelper) {
            weiboSdkHelper = [super allocWithZone:zone];
        }
        return weiboSdkHelper;
    };

    //static dispatch_once_t onceToken;
    //dispatch_once(&onceToken, ^{
    //    weiboSdkHelper = [super allocWithZone:zone];
    //});
    //return weiboSdkHelper;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [XFWeiboSdkHelper SharedWeiboSdkHelper];
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [XFWeiboSdkHelper SharedWeiboSdkHelper];
}

@end
