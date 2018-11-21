//
//  XFUserRightsHelper.h
//  XiaoFuDemo
//
//  Created by xiaofutech on 2018/7/9.
//  Copyright © 2018年 xiaofutech. All rights reserved.
//

#import <Foundation/Foundation.h>

// Privacy classify 分类
typedef NS_ENUM(NSUInteger, XFUserPrivacyType){
    XFUserPrivacyType_None                  = 0,
    XFUserPrivacyType_LocationServices      = 1,    // 定位服务
    XFUserPrivacyType_Contacts              = 2,    // 通讯录
    XFUserPrivacyType_Calendars             = 3,    // 日历
    XFUserPrivacyType_Reminders             = 4,    // 提醒事项
    XFUserPrivacyType_Photos                = 5,    // 照片
    XFUserPrivacyType_BluetoothSharing      = 6,    // 蓝牙共享 - #暂不可用
    XFUserPrivacyType_Microphone            = 7,    // 麦克风
    XFUserPrivacyType_SpeechRecognition     = 8,    // 语音识别 >= iOS10
    XFUserPrivacyType_Camera                = 9,    // 相机
    XFUserPrivacyType_Health                = 10,   // 健康 >= iOS8.0
    XFUserPrivacyType_HomeKit               = 11,   // 家庭 >= iOS8.0 - #暂不可用
    XFUserPrivacyType_MediaAndAppleMusic    = 12,   // 媒体与Apple Music >= iOS9.3
    XFUserPrivacyType_MotionAndFitness      = 13,   // 运动与健身 - #暂不可用
};

// Privacy Status 状态
typedef NS_ENUM(NSInteger, XFUserAuthorizationStatus) {
    XFUserAuthorizationStatus_ErrorParam                = 0,
    XFUserAuthorizationStatus_NotSupport                = 1,

    XFUserAuthorizationStatus_NotDetermined             = 2,
    XFUserAuthorizationStatus_Restricted                = 3,
    XFUserAuthorizationStatus_Denied                    = 4,
    XFUserAuthorizationStatus_Authorized                = 5,

    XFUserAuthorizationStatus_LocAuthorizedWhenInUse    = 6,
    XFUserAuthorizationStatus_LocAuthorizedAlways       = 7,
};

typedef void (^XFUserRightsCallBack)(BOOL authorized, XFUserAuthorizationStatus status, NSError *error);

@interface XFUserRightsHelper : NSObject

+ (NSString *)XF_StringForPrivacyType:(XFUserPrivacyType)privacyType;
+ (NSString *)XF_StringForAuthorizationStatus:(XFUserAuthorizationStatus)authorizationStatus;

/**
 检查某个权限的授权状态
 @param request 是否请求用户授权
 @param type 用户权限类型
 @param param 补充参数：
  1.XFUserPrivacyType_LocationServices -> @{@"LocAlways":@(NO)}
  2.XFUserPrivacyType_Health -> @{@"HKObjectType":objectType}
 @param completion 检测结果回调
 备注：调用前应该在Info.plist文件中添加相应权限，部分类别还需要在Capabilities打开相应开关；
 */
+ (void)XF_StatusCheckAndRequest:(BOOL)request PrivacyType:(XFUserPrivacyType)type
                           Param:(NSDictionary *)param Completion:(XFUserRightsCallBack)completion;

/**
 检测设备摄像头是否可用
 @param isRear 是否检测后置摄像头，NO-检测前置摄像头
 @return 检测结果
 */
+ (BOOL)XF_CameraIsAvailableIsRear:(BOOL)isRear;

@end
