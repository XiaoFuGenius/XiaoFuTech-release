//
//  XFWeChatSdkExample.m
//  JunPingAssistant
//
//  Created by 胡文峰 on 2018/11/5.
//  Copyright © 2018 xiaofutech. All rights reserved.
//

#import "XFWeChatSdkExample.h"
#import "XFWeChatSdkHelper.h"

@interface XFWeChatSdkExample ()

@end

@implementation XFWeChatSdkExample

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)UpdateUserInfo
{
    //if ([XFWeChatSdkHelper RefreshTokenIsExpiresIn]) {
    //    isLogin = NO;
    //    [XFPromptWindow ShowMsg:JPLanguage(@"微信登录状态已过期，请重新登录")];
    //    return;
    //}
    //
    //NSDictionary *loginUserInfo = [XFWeChatSdkHelper LoginUserInfo];
    //NSLog(@"%@", loginUserInfo);

    /**可选操作
     已登录的情况下，每次启动app，确定网络连通后建议调用一次更新接口，以更新用户信息
     可采取后台调用的方式，即使调用失败，也不做任何处理
     */
    [XFWeChatSdkHelper UpdateUserInfo:^(XFWeChatSdkResponse status, NSDictionary * _Nonnull resp) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *msg = @"";
            if (XFWeChatSdkResponse_NotInstalled==status) {
                msg = @"微信客户端未安装";
            } else if (XFWeChatSdkResponse_UserCancel==status) {
                msg = @"用户取消";
            } else if (XFWeChatSdkResponse_Success!=status) {
                msg = @"其它错误";
            }
            NSLog(@"微信用户信息更新%@：%@，reason：%@", XFWeChatSdkResponse_Success==status?@"成功":@"失败", resp, msg);

            //NSDictionary *loginUserInfoX = [XFWeChatSdkHelper LoginUserInfo];
            //NSLog(@"%@", loginUserInfoX);
            if (XFWeChatSdkResponse_Success==status) {
                NSDictionary *info = resp[@"info"];

                NSDictionary *upInfo = @{@"openId":info[@"openid"],
                                         @"nickName":info[@"nickname"],
                                         @"photo":info[@"headimgurl"],
                                         @"type":@(1),
                                         @"sex":info[@"sex"]};

                NSLog(@"%@", upInfo);

                // 登出需要调用该方法，无回调...
                //[XFWeChatSdkHelper Logout];
            }
        });
    }];
}

- (void)SendAuthRequestToWXnd
{
    [XFWeChatSdkHelper SendAuthRequestToWX:^(XFWeChatSdkResponse status, NSDictionary * _Nonnull resp) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *msg = @"";
            if (XFWeChatSdkResponse_NotInstalled==status) {
                msg = @"微信客户端未安装";
            } else if (XFWeChatSdkResponse_UserCancel==status) {
                msg = @"用户取消";
            } else if (XFWeChatSdkResponse_Success!=status) {
                msg = @"其它错误";
            }
            NSLog(@"微信授权登录%@：%@，reason：%@", XFWeChatSdkResponse_Success==status?@"成功":@"失败", resp, msg);

            //NSDictionary *loginUserInfoX = [XFWeChatSdkHelper LoginUserInfo];
            //NSLog(@"%@", loginUserInfoX);
            if (XFWeChatSdkResponse_Success==status) {
                NSDictionary *info = resp[@"info"];

                NSDictionary *upInfo = @{@"openId":info[@"openid"],
                                         @"nickName":info[@"nickname"],
                                         @"photo":info[@"headimgurl"],
                                         @"type":@(1),
                                         @"sex":info[@"sex"]};

                NSLog(@"%@", upInfo);

                // 登出需要调用该方法，无回调...
                //[XFWeChatSdkHelper Logout];
            }
        });
    }];
}

- (void)SendMessageToWX_Url
{
    [XFWeChatSdkHelper SendMessageToWXScene:0 Title:@"小肤科技"
                                Description:@"分享给你一个来自未来的网站<小肤科技官网>"
                                 ThumbImage:[UIImage imageNamed:@"JP_DeviceLink_Device"]
                                    LinkUrl:@"https://www.xiaofutech.com"
                                     OnResp:^(XFWeChatSdkResponse status, NSDictionary * _Nonnull resp) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *msg = @"";
            if (XFWeChatSdkResponse_NotInstalled==status) {
                msg = @"微信客户端未安装";
            } else if (XFWeChatSdkResponse_UserCancel==status) {
                msg = @"用户取消";
            } else if (XFWeChatSdkResponse_Success!=status) {
                msg = @"其它错误";
            }
            NSLog(@"链接分享%@，reason：%@", XFWeChatSdkResponse_Success==status?@"成功":@"失败", msg);
        });
    }];
}

- (void)SendMessageToWX_Image
{
    NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"JP_Index_Function_FullFace"], 0.9f);
    [XFWeChatSdkHelper SendMessageToWXScene:0 ImageData:imageData
                                     OnResp:^(XFWeChatSdkResponse status, NSDictionary * _Nonnull resp) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *msg = @"";
            if (XFWeChatSdkResponse_NotInstalled==status) {
                msg = @"微信客户端未安装";
            } else if (XFWeChatSdkResponse_UserCancel==status) {
                msg = @"用户取消";
            } else if (XFWeChatSdkResponse_Success!=status) {
                msg = @"其它错误";
            }
            NSLog(@"图片分享%@，reason：%@", XFWeChatSdkResponse_Success==status?@"成功":@"失败", msg);
        });
    }];
}

@end
