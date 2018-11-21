//
//  XFCloudPushSdkHelper.m
//  JunPingAssistant
//
//  Created by 胡文峰 on 2018/10/24.
//  Copyright © 2018 xiaofutech. All rights reserved.
//

#import "XFCloudPushSdkHelper.h"

#import <XiaoFuTech/XiaoFuTech.h>
#import <CloudPushSDK/CloudPushSDK.h>

#import <UserNotifications/UserNotifications.h>
#import <notify.h>

@interface XFCloudPushSdkHelper () <UNUserNotificationCenterDelegate>
@property (nonatomic, assign) BOOL debugEnableX;
@property (nonatomic, assign) BOOL deviceTokenAlertShowX;
@property (nonatomic, copy) void (^onMessageReceivedBlock)(NSNotification *noti);
@end

static XFCloudPushSdkHelper *cloudPushSdkHelper = nil;
@implementation XFCloudPushSdkHelper

+ (void)debugEnable
{
    [XFCloudPushSdkHelper SharedCloudPushSdkHelper].debugEnableX = YES;
}

+ (void)deviceTokenAlertShow
{
    [XFCloudPushSdkHelper SharedCloudPushSdkHelper].deviceTokenAlertShowX = YES;
}

+ (void)setOnMessageReceived:(void (^)(NSNotification * _Nonnull))notification
{
    [XFCloudPushSdkHelper SharedCloudPushSdkHelper].onMessageReceivedBlock = notification;
}

+ (void)turnOnDebug
{
    [CloudPushSDK turnOnDebug];
}

+ (NSString *)getDeviceId {
    return [CloudPushSDK getDeviceId];
}

+ (void)autoInitWithOptions:(NSDictionary *)launchOptions callback:(XFCloudPushSdkCallback)callback
{
    /* SDK初始化 */
    [CloudPushSDK autoInit:^(CloudPushCallbackResult *res) {
        [[XFCloudPushSdkHelper SharedCloudPushSdkHelper] showSdkInitCallback:res];

        if (callback) {
            callback(res);
        }
    }];

    [[XFCloudPushSdkHelper SharedCloudPushSdkHelper] registerAppleApnsWithOptions:launchOptions];
}

+ (void)asyncInit:(NSString *)appKey appSecret:(NSString *)appSecret
          options:(NSDictionary *)launchOptions callback:(XFCloudPushSdkCallback)callback
{
    /* SDK初始化 */
    [CloudPushSDK asyncInit:appKey appSecret:appSecret callback:^(CloudPushCallbackResult *res) {
        [[XFCloudPushSdkHelper SharedCloudPushSdkHelper] showSdkInitCallback:res];

        if (callback) {
            callback(res);
        }
    }];

    [[XFCloudPushSdkHelper SharedCloudPushSdkHelper] registerAppleApnsWithOptions:launchOptions];
}

+ (NSString *)registerDevice:(NSData *)deviceToken withCallback:(XFCloudPushSdkCallback)callback
{
    NSString *token = [[[NSString stringWithFormat:@"%@", deviceToken]
                        stringByReplacingOccurrencesOfString:@" " withString:@""]
                       substringWithRange:NSMakeRange(1, 64)];
    if ([XFCloudPushSdkHelper SharedCloudPushSdkHelper].debugEnableX) {
        NSLog(@"[CloudPushSDK] APNS deviceToken：%@", token);
    }
    if ([XFCloudPushSdkHelper SharedCloudPushSdkHelper].deviceTokenAlertShowX) {
        [[XFCloudPushSdkHelper SharedCloudPushSdkHelper] showDeviceToken:token];
    }

    [CloudPushSDK registerDevice:deviceToken withCallback:^(CloudPushCallbackResult *res) {
        if ([XFCloudPushSdkHelper SharedCloudPushSdkHelper].debugEnableX) {
            if (res.success) {
                NSLog(@"[CloudPushSDK] Register deviceToken success.");
            } else {
                NSLog(@"[CloudPushSDK] Register deviceToken failed, error: %@", res.error);
            }
        }

        if (callback) {
            callback(res);
        }
    }];

    return token;
}

+ (void)sendNotificationAck:(NSDictionary *)userInfo
{
    [CloudPushSDK sendNotificationAck:userInfo];
}

+ (void)bindAccount:(NSString *)account withCallback:(XFCloudPushSdkCallback)callback
{
    [CloudPushSDK bindAccount:account withCallback:^(CloudPushCallbackResult *res) {
        if ([XFCloudPushSdkHelper SharedCloudPushSdkHelper].debugEnableX) {
            if (res.success) {
                NSLog(@"[CloudPushSDK] bindAccountSuccess!");
            } else {
                NSLog(@"[CloudPushSDK] bindAccountFailed!");
            }
        }

        if (callback) {
            callback(res);
        }
    }];
}

+ (void)unbindAccount:(XFCloudPushSdkCallback)callback
{
    [CloudPushSDK unbindAccount:^(CloudPushCallbackResult *res) {
        if ([XFCloudPushSdkHelper SharedCloudPushSdkHelper].debugEnableX) {
            if (res.success) {
                NSLog(@"[CloudPushSDK] unbindAccountSuccess!");
            } else {
                NSLog(@"[CloudPushSDK] unbindAccountFailed!");
            }
        }

        if (callback) {
            callback(res);
        }
    }];
}

#pragma mark - Private Methods
- (void)showSdkInitCallback:(CloudPushCallbackResult *)res
{
    if (![XFCloudPushSdkHelper SharedCloudPushSdkHelper].debugEnableX) {
        return;
    }

    if (res.success) {
        NSLog(@"[CloudPushSDK] Push SDK init success, deviceId: %@.", [CloudPushSDK getDeviceId]);
        {/* Custom */
            NSString *deviceID = [CloudPushSDK getDeviceId];
            deviceID = [NSString stringWithFormat:@"%@|%@%@", deviceID, [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"], kAliPushType];
            NSLog(@"[CloudPushSDK] Push SDK init success, CustomDeviceId：%@", deviceID);
        }
    } else {
        NSLog(@"[CloudPushSDK] Push SDK init failed, error: %@", res.error);
    }
}

- (void)registerAppleApnsWithOptions:(NSDictionary *)launchOptions
{
    /* 注册苹果远程推送 */
    [self replyPushNotificationAuthorization];

    /* 注册阿里推送来的监听 */
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onMessageReceived:)
                                                 name:@"CCPDidReceiveMessageNotification"
                                               object:nil];

    /* 点击通知将App从关闭状态启动时，将通知打开回执上报 */
    [CloudPushSDK sendNotificationAck:launchOptions];
}

- (void)replyPushNotificationAuthorization {
    if (@available(iOS 10.0, *)) {

        /* iOS 10 推出了 UserNotifications 框架 */
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        NSSet *categories = nil;
        [center setNotificationCategories:categories];
        UNAuthorizationOptions options = UNAuthorizationOptionBadge | UNAuthorizationOptionSound |
        UNAuthorizationOptionAlert;

        XFWeakSelf(weakSelf);
        [center requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (weakSelf.debugEnableX) {
                if (granted) {
                    NSLog(@"[CloudPushSDK] iOS 10 request authorization succeeded!");
                } else {
                    NSLog(@"[CloudPushSDK] iOS 10 request authorization failed!");
                }
            }
        }];

        [[UIApplication sharedApplication] registerForRemoteNotifications];

    } else if (@available(iOS 8.0, *)) {

        /* iOS 10 之前，仅注册远程推送时需要取得用户权限，iOS 8 重新设计了权限请求 */
        UIUserNotificationType type = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];

    }
}

- (void)onMessageReceived:(NSNotification *)notification {
    //CCPSysMessage *message = [notification object];
    //NSString *title = [[NSString alloc] initWithData:message.title encoding:NSUTF8StringEncoding];
    //NSString *body = [[NSString alloc] initWithData:message.body encoding:NSUTF8StringEncoding];

    if (self.onMessageReceivedBlock) {
        self.onMessageReceivedBlock(notification);
    }

    //NSString *msg = [NSString stringWithFormat:@"Receive message title: %@, content: %@.", title, body];
    //[self showRemoteNotificationTitle:@"阿里内推" Msg:msg];
}

- (void)showDeviceToken:(NSString *)token
{
    [UIPasteboard generalPasteboard].string = token;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"deviceToken"
                                                        message:token
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *textField_0 = [alertView textFieldAtIndex:0];
    textField_0.placeholder = @"deviceToken";
    textField_0.text = token;

    //[alertView setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    //UITextField *textField_1 = [alertView textFieldAtIndex:1];
    //[textField_1 setSecureTextEntry:NO];
    //textField_1.placeholder = @"deviceToken";
    //textField_1.text = token;

    [alertView show];
}

#pragma mark >>> Custom Accessors <<<
+ (XFCloudPushSdkHelper *)SharedCloudPushSdkHelper
{
    return [[XFCloudPushSdkHelper alloc] init];
}

#pragma mark >>> Life Cycle <<<
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    @synchronized (self) {
        if (!cloudPushSdkHelper) {
            cloudPushSdkHelper = [super allocWithZone:zone];

            cloudPushSdkHelper.debugEnableX = NO;
            cloudPushSdkHelper.deviceTokenAlertShowX = NO;
        }
        return cloudPushSdkHelper;
    }

    //static dispatch_once_t onceToken;
    //dispatch_once(&onceToken, ^{
    //    cloudPushSdkHelper = [super allocWithZone:zone];
    //});
    //return cloudPushSdkHelper;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [XFCloudPushSdkHelper SharedCloudPushSdkHelper];
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [XFCloudPushSdkHelper SharedCloudPushSdkHelper];
}

@end
