//
//  XFUserRightsHelper.m
//  XiaoFuDemo
//
//  Created by xiaofutech on 2018/7/9.
//  Copyright © 2018年 xiaofutech. All rights reserved.
//

#import "XFUserRightsHelper.h"

#import <CoreLocation/CoreLocation.h>
#import <LocalAuthentication/LocalAuthentication.h>
//#import <Contacts/Contacts.h>
//#import <AddressBookUI/AddressBookUI.h>
//#import <EventKit/EventKit.h>
#import <Photos/Photos.h>
#import <CoreBluetooth/CoreBluetooth.h>
//#import <AVFoundation/AVFoundation.h>
//#import <Speech/Speech.h>
//#import <HealthKit/HealthKit.h>
////#import <HomeKit/HomeKit.h>
//#import <StoreKit/StoreKit.h>
////#import <CoreMotion/CoreMotion.h>

@interface XFUserRightsHelper ()<CLLocationManagerDelegate, CBCentralManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locManager;
@property (nonatomic, assign) BOOL locAlways;
@property (nonatomic, copy) XFUserRightsCallBack locCompletion;

@property (nonatomic, strong) CBCentralManager *bleManager;
@property (nonatomic, copy) XFUserRightsCallBack bleCompletion;
@end

static XFUserRightsHelper *userRightsHelper;
@implementation XFUserRightsHelper

#pragma mark - Public Methods

+ (NSString *)XF_StringForPrivacyType:(XFUserPrivacyType)privacyType {
    if (privacyType == XFUserPrivacyType_LocationServices) {
        return @"LocationServices";
    } else if (privacyType == XFUserPrivacyType_Contacts) {
        return @"Contacts";
    } else if (privacyType == XFUserPrivacyType_Calendars) {
        return @"Calendars";
    } else if (privacyType == XFUserPrivacyType_Reminders) {
        return @"Reminders";
    } else if (privacyType == XFUserPrivacyType_Photos) {
        return @"Photos";
    } else if (privacyType == XFUserPrivacyType_BluetoothSharing) {
        return @"BluetoothSharing";
    } else if (privacyType == XFUserPrivacyType_Microphone) {
        return @"Microphone";
    } else if (privacyType == XFUserPrivacyType_SpeechRecognition) {
        return @"SpeechRecognition";
    } else if (privacyType == XFUserPrivacyType_Camera) {
        return @"Camera";
    } else if (privacyType == XFUserPrivacyType_Health) {
        return @"Health";
    } else if (privacyType == XFUserPrivacyType_HomeKit) {
        return @"HomeKit";
    } else if (privacyType == XFUserPrivacyType_MediaAndAppleMusic) {
        return @"Media And AppleMusic";
    } else if (privacyType == XFUserPrivacyType_MotionAndFitness) {
        return @"Motion And Fitness";
    } else {
        return @"";
    }
}

+ (NSString *)XF_StringForAuthorizationStatus:(XFUserAuthorizationStatus)authorizationStatus {
    if (authorizationStatus == XFUserAuthorizationStatus_ErrorParam) {
        return @"ErrorParam";
    } else if (authorizationStatus == XFUserAuthorizationStatus_NotSupport) {
        return @"NotSupport";
    } else if (authorizationStatus == XFUserAuthorizationStatus_NotDetermined) {
        return @"NotDetermined";
    } else if (authorizationStatus == XFUserAuthorizationStatus_Restricted) {
        return @"Restricted";
    } else if (authorizationStatus == XFUserAuthorizationStatus_Denied) {
        return @"Denied";
    } else if (authorizationStatus == XFUserAuthorizationStatus_Authorized) {
        return @"Authorized";
    } else if (authorizationStatus == XFUserAuthorizationStatus_LocAuthorizedWhenInUse) {
        return @"LocAuthorizedWhenInUse";
    } else if (authorizationStatus == XFUserAuthorizationStatus_LocAuthorizedAlways) {
        return @"LocAuthorizedAlways";
    } else {
        return @"";
    }
}

+ (void)XF_StatusCheckAndRequest:(BOOL)request PrivacyType:(XFUserPrivacyType)type
                           Param:(NSDictionary *)param Completion:(XFUserRightsCallBack)completion {
    switch (type) {
        case XFUserPrivacyType_None:{
            break;
        }
        case XFUserPrivacyType_LocationServices:{
            if ([param.allKeys containsObject:@"LocAlways"] &&
                [param[@"LocAlways"] isKindOfClass:[NSNumber class]]) {
                if (completion) {
                    completion(NO, XFUserAuthorizationStatus_ErrorParam, nil);
                }
                return;
            }

            BOOL always = [param[@"LocAlways"] intValue];
            [XFUserRightsHelper XF_LocationServicesRightsCheckAndRequest:request
                                                                  Always:always Completion:completion];
            break;
        }
        case XFUserPrivacyType_Contacts:{
//            [XFUserRightsHelper XF_ContactsRightsCheckAndRequest:request Completion:completion];
            break;
        }
        case XFUserPrivacyType_Calendars:{
//            [XFUserRightsHelper XF_CalendarsRightsCheckAndRequest:request Completion:completion];
            break;
        }
        case XFUserPrivacyType_Reminders:{
//            [XFUserRightsHelper XF_RemindersRightsCheckAndRequest:request Completion:completion];
            break;
        }
        case XFUserPrivacyType_Photos:{
            [XFUserRightsHelper XF_PhotosRightsCheckAndRequest:request Completion:completion];
            break;
        }
        case XFUserPrivacyType_BluetoothSharing:{
            ///未发现授权api
            //[XFUserRightsHelper XF_BluetoothSharingRightsCheckAndRequest:request Completion:completion];
            break;
        }
        case XFUserPrivacyType_Microphone:{
            [XFUserRightsHelper XF_MicrophoneRightsCheckAndRequest:request Completion:completion];
            break;
        }
        case XFUserPrivacyType_SpeechRecognition:{
//            [XFUserRightsHelper XF_SpeechRecognitionRightsCheckAndRequest:request Completion:completion];
            break;
        }
        case XFUserPrivacyType_Camera:{
            [XFUserRightsHelper XF_CameraRightsCheckAndRequest:request Completion:completion];
            break;
        }
        case XFUserPrivacyType_Health:{
//            HKObjectType *objectType = param[@"HKObjectType"];
//            if (!objectType && [objectType isKindOfClass:[HKObjectType class]]) {
//                if (completion) {
//                    completion(NO, XFUserAuthorizationStatus_ErrorParam, nil);
//                }
//                return;
//            }
//            [XFUserRightsHelper XF_HealthRightsCheckAndRequest:request HKObjectType:objectType
//                                                    Completion:completion];
            break;
        }
        case XFUserPrivacyType_HomeKit:{
            ///未发现授权api
            break;
        }
        case XFUserPrivacyType_MediaAndAppleMusic:{
//            [XFUserRightsHelper XF_MediaAndAppleMusicRightsCheckAndRequest:request Completion:completion];
            break;
        }
        case XFUserPrivacyType_MotionAndFitness:{
            ///未发现授权api
            break;
        }
        default:{
            break;
        }
    }
}

+ (BOOL)XF_CameraIsAvailableIsRear:(BOOL)isRear {
    BOOL available = [UIImagePickerController
                      isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (!available) {
        return available;
    }

    UIImagePickerControllerCameraDevice device = isRear ? UIImagePickerControllerCameraDeviceRear :
    UIImagePickerControllerCameraDeviceFront;
    available = [UIImagePickerController isCameraDeviceAvailable:device];

    return available;
}

#pragma mark - Private Methods

+ (void)XF_LocationServicesRightsCheckAndRequest:(BOOL)request Always:(BOOL)always Completion:(XFUserRightsCallBack)completion {
    if (![CLLocationManager locationServicesEnabled]) {
        if (completion) completion(NO, XFUserAuthorizationStatus_NotSupport, nil);
        return;
    }

    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];//读取设备授权状态
    switch (authStatus) {
        case kCLAuthorizationStatusNotDetermined:{
            if (!request) {
                if (completion) completion(NO, XFUserAuthorizationStatus_NotDetermined, nil);
                return;
            }

            [XFUserRightsHelper SharedUserRightsHelper].locAlways = always;
            [XFUserRightsHelper SharedUserRightsHelper].locCompletion = completion;
            [[XFUserRightsHelper SharedUserRightsHelper] requestLocationServicesAuthorization];
            break;
        }
        case kCLAuthorizationStatusRestricted:{
            if (completion) completion(NO, XFUserAuthorizationStatus_Restricted, nil);
            break;
        }
        case kCLAuthorizationStatusDenied:{
            if (completion) completion(NO, XFUserAuthorizationStatus_Denied, nil);
            break;
        }
        case kCLAuthorizationStatusAuthorizedAlways:{
            if (completion) completion(YES, XFUserAuthorizationStatus_LocAuthorizedAlways, nil);
            break;
        }
        case kCLAuthorizationStatusAuthorizedWhenInUse:{
            if (completion) completion(YES, XFUserAuthorizationStatus_LocAuthorizedWhenInUse, nil);
            break;
        }
        default:{
            break;
        }
    }
}

//+ (void)XF_ContactsRightsCheckAndRequest:(BOOL)request Completion:(XFUserRightsCallBack)completion {
//    if (@available(iOS 9.0, *)) {
//        CNAuthorizationStatus authStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
//        switch (authStatus) {
//            case CNAuthorizationStatusNotDetermined:{
//                if (!request) {
//                    if (completion) completion(NO, XFUserAuthorizationStatus_NotDetermined, nil);
//                    return;
//                }
//
//                CNContactStore *contactStore = [[CNContactStore alloc] init];
//                [contactStore requestAccessForEntityType:CNEntityTypeContacts
//                                       completionHandler:^(BOOL granted, NSError * _Nullable error) {
//                    [XFUserRightsHelper XF_ContactsRightsCheckAndRequest:NO Completion:completion];
//                }];
//                break;
//            }
//            case CNAuthorizationStatusRestricted:{
//                if (completion) completion(NO, XFUserAuthorizationStatus_Restricted, nil);
//                break;
//            }
//            case CNAuthorizationStatusDenied:{
//                if (completion) completion(NO, XFUserAuthorizationStatus_Denied, nil);
//                break;
//            }
//            case CNAuthorizationStatusAuthorized:{
//                if (completion) completion(YES, XFUserAuthorizationStatus_Authorized, nil);
//                break;
//            }
//            default:{
//                break;
//            }
//        }
//    } else {
//        ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
//        switch (authStatus) {
//            case kABAuthorizationStatusNotDetermined:{
//                if (!request) {
//                    if (completion) completion(NO, XFUserAuthorizationStatus_NotDetermined, nil);
//                    return;
//                }
//
//                __block ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
//                if (addressBookRef == NULL) {
//                    if (completion) completion(NO, XFUserAuthorizationStatus_NotSupport, nil);
//                }
//
//                ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
//                    [XFUserRightsHelper XF_ContactsRightsCheckAndRequest:NO Completion:completion];
//                    if (addressBookRef) {
//                        CFRelease(addressBookRef);
//                        addressBookRef = NULL;
//                    }
//                });
//                break;
//            }
//            case kABAuthorizationStatusRestricted:{
//                if (completion) completion(NO, XFUserAuthorizationStatus_Restricted, nil);
//                break;
//            }
//            case kABAuthorizationStatusDenied:{
//                if (completion) completion(NO, XFUserAuthorizationStatus_Denied, nil);
//                break;
//            }
//            case kABAuthorizationStatusAuthorized:{
//                if (completion) completion(YES, XFUserAuthorizationStatus_Authorized, nil);
//                break;
//            }
//            default:{
//                break;
//            }
//        }
//
//    }
//}

//+ (void)XF_CalendarsRightsCheckAndRequest:(BOOL)request Completion:(XFUserRightsCallBack)completion {
//    EKAuthorizationStatus authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
//    switch (authStatus) {
//        case EKAuthorizationStatusNotDetermined:{
//            if (!request) {
//                if (completion) completion(NO, XFUserAuthorizationStatus_NotDetermined, nil);
//                return;
//            }
//
//            EKEventStore *store = [[EKEventStore alloc] init];
//            [store requestAccessToEntityType:EKEntityTypeEvent
//                                  completion:^(BOOL granted, NSError * _Nullable error) {
//                [XFUserRightsHelper XF_CalendarsRightsCheckAndRequest:NO Completion:completion];
//            }];
//            break;
//        }
//        case EKAuthorizationStatusRestricted:{
//            if (completion) completion(NO, XFUserAuthorizationStatus_Restricted, nil);
//            break;
//        }
//        case EKAuthorizationStatusDenied:{
//            if (completion) completion(NO, XFUserAuthorizationStatus_Denied, nil);
//            break;
//        }
//        case EKAuthorizationStatusAuthorized:{
//            if (completion) completion(YES, XFUserAuthorizationStatus_Authorized, nil);
//            break;
//        }
//        default:{
//            break;
//        }
//    }
//}

//+ (void)XF_RemindersRightsCheckAndRequest:(BOOL)request Completion:(XFUserRightsCallBack)completion {
//    EKAuthorizationStatus authStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
//    switch (authStatus) {
//        case EKAuthorizationStatusNotDetermined:{
//            if (!request) {
//                if (completion) completion(NO, XFUserAuthorizationStatus_NotDetermined, nil);
//                return;
//            }
//
//            EKEventStore *store = [[EKEventStore alloc] init];
//            [store requestAccessToEntityType:EKEntityTypeReminder
//                                  completion:^(BOOL granted, NSError * _Nullable error) {
//                [XFUserRightsHelper XF_CalendarsRightsCheckAndRequest:NO Completion:completion];
//            }];
//            break;
//        }
//        case EKAuthorizationStatusRestricted:{
//            if (completion) completion(NO, XFUserAuthorizationStatus_Restricted, nil);
//            break;
//        }
//        case EKAuthorizationStatusDenied:{
//            if (completion) completion(NO, XFUserAuthorizationStatus_Denied, nil);
//            break;
//        }
//        case EKAuthorizationStatusAuthorized:{
//            if (completion) completion(YES, XFUserAuthorizationStatus_Authorized, nil);
//            break;
//        }
//        default:{
//            break;
//        }
//    }
//}

+ (void)XF_PhotosRightsCheckAndRequest:(BOOL)request Completion:(XFUserRightsCallBack)completion {
    BOOL available = [UIImagePickerController
                      isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
    if (!available) {
        if (completion) completion(NO, XFUserAuthorizationStatus_NotSupport, nil);
        return;
    }

    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    switch (authStatus) {
        case PHAuthorizationStatusNotDetermined:{
            if (!request) {
                if (completion) completion(NO, XFUserAuthorizationStatus_NotDetermined, nil);
                return;
            }

            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                [XFUserRightsHelper XF_PhotosRightsCheckAndRequest:NO Completion:completion];
            }];
            break;
        }
        case PHAuthorizationStatusRestricted:{
            if (completion) completion(NO, XFUserAuthorizationStatus_Restricted, nil);
            break;
        }
        case PHAuthorizationStatusDenied:{
            if (completion) completion(NO, XFUserAuthorizationStatus_Denied, nil);
            break;
        }
        case PHAuthorizationStatusAuthorized:{
            if (completion) completion(YES, XFUserAuthorizationStatus_Authorized, nil);
            break;
        }
        default:{
            break;
        }
    }
}

+ (void)XF_BluetoothSharingRightsCheckAndRequest:(BOOL)request Completion:(XFUserRightsCallBack)completion {
    [XFUserRightsHelper SharedUserRightsHelper].bleCompletion = completion;
    [[XFUserRightsHelper SharedUserRightsHelper] requestBluetoothSharingAuthorization];
}

+ (void)XF_MicrophoneRightsCheckAndRequest:(BOOL)request Completion:(XFUserRightsCallBack)completion {
    NSString *mediaType = AVMediaTypeAudio;//设定读取媒体类型
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];//读取设备授权状态
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined:{
            if (!request) {
                if (completion) completion(NO, XFUserAuthorizationStatus_NotDetermined, nil);
                return;
            }

            [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
                [XFUserRightsHelper XF_MicrophoneRightsCheckAndRequest:NO Completion:completion];
            }];
            //[[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            //    [XFUserRightsHelper XF_AudioRightsCheckAndRequest:NO Completion:completion];
            //}];
            break;
        }
        case AVAuthorizationStatusRestricted:{
            if (completion) completion(NO, XFUserAuthorizationStatus_Restricted, nil);
            break;
        }
        case AVAuthorizationStatusDenied:{
            if (completion) completion(NO, XFUserAuthorizationStatus_Denied, nil);
            break;
        }
        case AVAuthorizationStatusAuthorized:{
            if (completion) completion(YES, XFUserAuthorizationStatus_Authorized, nil);
            break;
        }
        default:{
            break;
        }
    }
}

//+ (void)XF_SpeechRecognitionRightsCheckAndRequest:(BOOL)request Completion:(XFUserRightsCallBack)completion {
//    if (@available(iOS 10.0, *)) {
//        SFSpeechRecognizerAuthorizationStatus authStatus = [SFSpeechRecognizer authorizationStatus];
//        switch (authStatus) {
//            case SFSpeechRecognizerAuthorizationStatusNotDetermined:{
//                if (!request) {
//                    if (completion) completion(NO, XFUserAuthorizationStatus_NotDetermined, nil);
//                    return;
//                }
//
//                [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
//                    [XFUserRightsHelper XF_SpeechRecognitionRightsCheckAndRequest:NO Completion:completion];
//                }];
//                break;
//            }
//            case SFSpeechRecognizerAuthorizationStatusRestricted:{
//                if (completion) completion(NO, XFUserAuthorizationStatus_Restricted, nil);
//                break;
//            }
//            case SFSpeechRecognizerAuthorizationStatusDenied:{
//                if (completion) completion(NO, XFUserAuthorizationStatus_Denied, nil);
//                break;
//            }
//            case SFSpeechRecognizerAuthorizationStatusAuthorized:{
//                if (completion) completion(YES, XFUserAuthorizationStatus_Authorized, nil);
//                break;
//            }
//            default:{
//                break;
//            }
//        }
//    } else {
//        if (completion) completion(NO, XFUserAuthorizationStatus_NotSupport, nil);
//    }
//}

+ (void)XF_CameraRightsCheckAndRequest:(BOOL)request Completion:(XFUserRightsCallBack)completion {
    BOOL available = [UIImagePickerController
                      isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (!available) {
        if (completion) completion(NO, XFUserAuthorizationStatus_NotSupport, nil);
        return;
    }

    NSString *mediaType = AVMediaTypeVideo;//设定读取媒体类型
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];//读取设备授权状态
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined:{
            if (!request) {
                if (completion) completion(NO, XFUserAuthorizationStatus_NotDetermined, nil);
                return;
            }

            [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
                [XFUserRightsHelper XF_CameraRightsCheckAndRequest:NO Completion:completion];
            }];
            break;
        }
        case AVAuthorizationStatusRestricted:{
            if (completion) completion(NO, XFUserAuthorizationStatus_Restricted, nil);
            break;
        }
        case AVAuthorizationStatusDenied:{
            if (completion) completion(NO, XFUserAuthorizationStatus_Denied, nil);
            break;
        }
        case AVAuthorizationStatusAuthorized:{
            if (completion) completion(YES, XFUserAuthorizationStatus_Authorized, nil);
            break;
        }
        default:{
            break;
        }
    }
}

//+ (void)XF_HealthRightsCheckAndRequest:(BOOL)request HKObjectType:(HKObjectType *)objectType
//                            Completion:(XFUserRightsCallBack)completion {
//    BOOL available = [HKHealthStore isHealthDataAvailable];
//    if (!available) {
//        if (completion) completion(NO, XFUserAuthorizationStatus_NotSupport, nil);
//        return;
//    }
//
//    HKHealthStore *healthStore = [[HKHealthStore alloc] init];
//    HKAuthorizationStatus authStatus = [healthStore authorizationStatusForType:objectType];
//    switch (authStatus) {
//        case HKAuthorizationStatusNotDetermined:{
//            if (!request) {
//                if (completion) completion(NO, XFUserAuthorizationStatus_NotDetermined, nil);
//                return;
//            }
//
//            NSSet *typeSet = [NSSet setWithObject:objectType];
//            //tips 该方法表明，请求时可以批量处理 = =！
//            [healthStore requestAuthorizationToShareTypes:typeSet readTypes:typeSet
//                                               completion:^(BOOL success, NSError * _Nullable error) {
//                // sucess 为YES代表用户响应了该界面，允许或者拒绝
//                if (success) {
//                    // 由于用户已经响该界面（不管是允许或者拒绝）
//                    // 并且这时候应该只会有两种状态：HKAuthorizationStatusSharingAuthorized 或者 HKAuthorizationStatusSharingDenied
//                    [XFUserRightsHelper XF_HealthRightsCheckAndRequest:NO HKObjectType:objectType
//                                                            Completion:completion];
//                } else {
//                    // tips：这个block不止在用户点击允许或者不允许的时候响应，在弹出访问健康数据允许窗口后，\
//                             只要界面发生变化（以及程序进入后台），都会响应该block。
//                }
//            }];
//            break;
//        }
//        case HKAuthorizationStatusSharingDenied:{
//            if (completion) completion(NO, XFUserAuthorizationStatus_Denied, nil);
//            break;
//        }
//        case HKAuthorizationStatusSharingAuthorized:{
//            if (completion) completion(YES, XFUserAuthorizationStatus_Authorized, nil);
//            break;
//        }
//        default:{
//            break;
//        }
//    }
//}

//+ (void)XF_MediaAndAppleMusicRightsCheckAndRequest:(BOOL)request Completion:(XFUserRightsCallBack)completion {
//    if (@available(iOS 9.3, *)) {
//        SKCloudServiceAuthorizationStatus authStatus = [SKCloudServiceController authorizationStatus];
//        switch (authStatus) {
//            case SKCloudServiceAuthorizationStatusNotDetermined:{
//                if (!request) {
//                    if (completion) completion(NO, XFUserAuthorizationStatus_NotDetermined, nil);
//                    return;
//                }
//
//                [SKCloudServiceController requestAuthorization:^(SKCloudServiceAuthorizationStatus status) {
//                    [XFUserRightsHelper XF_MediaAndAppleMusicRightsCheckAndRequest:NO Completion:completion];
//                }];
//                break;
//            }
//            case SKCloudServiceAuthorizationStatusRestricted:{
//                if (completion) completion(NO, XFUserAuthorizationStatus_Restricted, nil);
//                break;
//            }
//            case SKCloudServiceAuthorizationStatusDenied:{
//                if (completion) completion(NO, XFUserAuthorizationStatus_Denied, nil);
//                break;
//            }
//            case SKCloudServiceAuthorizationStatusAuthorized:{
//                if (completion) completion(YES, XFUserAuthorizationStatus_Authorized, nil);
//                break;
//            }
//            default:{
//                break;
//            }
//        }
//    } else {
//        if (completion) completion(NO, XFUserAuthorizationStatus_NotSupport, nil);
//    }
//}

#pragma mark - Life Cycle
+ (XFUserRightsHelper *)SharedUserRightsHelper {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userRightsHelper = [[XFUserRightsHelper alloc] init];
    });
    return userRightsHelper;
}

#pragma mark CLLocationMangerDelegate methods
- (void)requestLocationServicesAuthorization {
    if (!self.locManager) {
        self.locManager  = [[CLLocationManager alloc] init];
        self.locManager.delegate = self;
    }

    if (self.locAlways) {
        [self.locManager requestAlwaysAuthorization];
    } else {
        [self.locManager requestWhenInUseAuthorization];
    }
}
- (void)locationManager:(CLLocationManager *)manager
didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status==kCLAuthorizationStatusNotDetermined) {
        return;
    }

    [XFUserRightsHelper XF_LocationServicesRightsCheckAndRequest:NO Always:self.locAlways
                                                      Completion:self.locCompletion];
    self.locManager = nil;
    self.locCompletion = nil;
}

#pragma mark CBCentralManagerDelegate methods
- (void)requestBluetoothSharingAuthorization {
    if (!self.bleManager) {
        self.bleManager = [[CBCentralManager alloc]
                           initWithDelegate:self queue:nil
                           options:@{CBCentralManagerOptionShowPowerAlertKey:@YES}];
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStateUnknown:{
            if (self.bleCompletion) {
                self.bleCompletion(NO, XFUserAuthorizationStatus_NotDetermined, nil);
            }
            break;
        }
        case CBManagerStateResetting:{
            if (self.bleCompletion) {
                self.bleCompletion(NO, XFUserAuthorizationStatus_NotDetermined, nil);
            }
            break;
        }
        case CBManagerStateUnsupported:{
            if (self.bleCompletion) {
                self.bleCompletion(NO, XFUserAuthorizationStatus_NotSupport, nil);
            }
            break;
        }
        case CBManagerStateUnauthorized:{
            if (self.bleCompletion) {
                self.bleCompletion(NO, XFUserAuthorizationStatus_Denied, nil);
            }
            break;
        }
        case CBManagerStatePoweredOff:{
            if (self.bleCompletion) {
                self.bleCompletion(YES, XFUserAuthorizationStatus_Authorized, nil);
            }
            break;
        }
        case CBManagerStatePoweredOn:{
            if (self.bleCompletion) {
                self.bleCompletion(YES, XFUserAuthorizationStatus_Authorized, nil);
            }
            break;
        }
        default:{
            break;
        }
    }
}

@end
