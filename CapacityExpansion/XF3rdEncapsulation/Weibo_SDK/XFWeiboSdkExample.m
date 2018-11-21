//
//  XFWeiboSdkExample.m
//  JunPingAssistant
//
//  Created by 胡文峰 on 2018/11/5.
//  Copyright © 2018 xiaofutech. All rights reserved.
//

#import "XFWeiboSdkExample.h"
#import "XFWeiboSdkHelper.h"

@interface XFWeiboSdkExample ()

@end

@implementation XFWeiboSdkExample

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
    NSDictionary *loginUserInfo = [XFWeiboSdkHelper LoginUserInfo];
    NSLog(@"%@", loginUserInfo);

    /**可选操作
     已登录的情况下，每次启动app，确定网络连通后建议调用一次更新接口，以更新用户信息
     可采取后台调用的方式，即使调用失败，也不做任何处理
     */
    [XFWeiboSdkHelper UpdateUserInfo:^(XFWeiboSdkResponse status, NSDictionary * _Nonnull resp) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *msg = @"";
            if (XFWeiboSdkResponse_NotInstalled==status) {
                msg = @"微博客户端未安装";
            } else if (XFWeiboSdkResponse_UserCancel==status) {
                msg = @"用户取消";
            } else if (XFWeiboSdkResponse_Success!=status) {
                msg = @"其它错误";
            }
            NSLog(@"微博用户信息更新%@：%@，reason：%@", 0==status?@"成功":@"失败", resp, msg);

            //NSDictionary *loginUserInfoX = [XFWeiboSdkHelper LoginUserInfo];
            //NSLog(@"%@", loginUserInfoX);
            if (XFWeiboSdkResponse_Success==status) {
                NSDictionary *info = resp[@"info"];
                int sex = [info[@"gender"] isEqualToString:@"m"]?1:2;
                NSDictionary *upInfo = @{@"uid":info[@"id"],
                                         @"nickName":info[@"screen_name"],
                                         @"photo":info[@"avatar_large"],
                                         @"type":@(2),
                                         @"sex":@(sex)};
                NSLog(@"%@", upInfo);

                // 登出需要调用该方法，无回调...
                //[XFWeiboSdkHelper Logout];
            }
        });
    }];
}

- (void)SendAuthRequestToWB
{
    [XFWeiboSdkHelper SendAuthRequestToWB:^(XFWeiboSdkResponse status, NSDictionary * _Nonnull resp) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *msg = @"";
            if (XFWeiboSdkResponse_NotInstalled==status) {
                msg = @"微博客户端未安装";
            } else if (XFWeiboSdkResponse_UserCancel==status) {
                msg = @"用户取消";
            } else if (XFWeiboSdkResponse_Success!=status) {
                msg = @"其它错误";
            }
            NSLog(@"微博授权登录%@：%@，reason：%@", 0==status?@"成功":@"失败", resp, msg);

            //NSDictionary *loginUserInfoX = [XFWeiboSdkHelper LoginUserInfo];
            //NSLog(@"%@", loginUserInfoX);
            if (XFWeiboSdkResponse_Success==status) {
                NSDictionary *info = resp[@"info"];
                int sex = [info[@"gender"] isEqualToString:@"m"]?1:2;
                NSDictionary *upInfo = @{@"uid":info[@"id"],
                                         @"nickName":info[@"screen_name"],
                                         @"photo":info[@"avatar_large"],
                                         @"type":@(2),
                                         @"sex":@(sex)};
                NSLog(@"%@", upInfo);

                // 登出需要调用该方法，无回调...
                //[XFWeiboSdkHelper Logout];
            }
        });
    }];
}

- (void)SendMessageToWBText
{
    NSString *linkUrl = @"https://www.xiaofutech.com";
    //linkUrl = @"http://weibo.com/p/1001603849727862021333?rightmod=1&wvr=6&mod=noticeboard";
    NSData *thumbImage = UIImageJPEGRepresentation([UIImage imageNamed:@"JP_DeviceLink_Device"], 0.9f);
    [XFWeiboSdkHelper SendMessageToWBText:@"[文字+链接分享]" Title:@"小肤科技"
                              Description:@"小肤科技\n分享给你一个来自未来的网站<小肤科技官网>"
                               ThumbImage:thumbImage LinkUrl:linkUrl
                                   OnResp:^(XFWeiboSdkResponse status, NSDictionary * _Nonnull resp) {
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *msg = @"";
                if (XFWeiboSdkResponse_NotInstalled==status) {
                    msg = @"微博客户端未安装";
                } else if (XFWeiboSdkResponse_UserCancel==status) {
                    msg = @"用户取消";
                } else if (XFWeiboSdkResponse_Success!=status) {
                    msg = @"其它错误";
                }
                NSLog(@"微博[文字+链接分享]%@，reason：%@", 0==status?@"成功":@"失败", msg);
            });
        });
    }];
}

- (void)SendMessageToWBShareToStory_Image
{
    UIImage *image1 = [UIImage imageNamed:@"JP_Index_Function_FullFace"];
    UIImage *image2 = [UIImage imageNamed:@"JP_Index_Function_FullFace"];
    UIImage *image3 = [UIImage imageNamed:@"JP_Index_Function_FullFace"];
    NSArray *images = @[image1, image2, image3];

    [XFWeiboSdkHelper SendMessageToWBShareToStory:YES Text:@"[文字+图片分享]" Images:images
                                           OnResp:^(XFWeiboSdkResponse status, NSDictionary * _Nonnull resp) {
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *msg = @"";
                if (XFWeiboSdkResponse_NotInstalled==status) {
                    msg = @"微博客户端未安装";
                } else if (XFWeiboSdkResponse_UserCancel==status) {
                    msg = @"用户取消";
                } else if (XFWeiboSdkResponse_Success!=status) {
                    msg = @"其它错误";
                }
                NSLog(@"微博[文字+图片分享]%@，reason：%@", 0==status?@"成功":@"失败", msg);
            });
        });
    }];
}

- (void)SendMessageToWBShareToStory_Video
{
    NSURL *videoUrl = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"apm" ofType:@"mov"]];
    [XFWeiboSdkHelper SendMessageToWBShareToStory:NO Text:@"[文字+视频分享]" VideoUrl:videoUrl
                                           OnResp:^(XFWeiboSdkResponse status, NSDictionary * _Nonnull resp) {
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *msg = @"";
                if (XFWeiboSdkResponse_NotInstalled==status) {
                    msg = @"微博客户端未安装";
                } else if (XFWeiboSdkResponse_UserCancel==status) {
                    msg = @"用户取消";
                } else if (XFWeiboSdkResponse_Success!=status) {
                    msg = @"其它错误";
                }
                NSLog(@"微博[文字+视频分享]%@，reason：%@", 0==status?@"成功":@"失败", msg);
            });
        });
    }];
}

@end
