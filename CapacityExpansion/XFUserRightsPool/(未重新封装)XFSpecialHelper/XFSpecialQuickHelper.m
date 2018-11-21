//
//  XFSpecialQuickHelper.m
//  XiaoFuTech
//
//  Created by 胡文峰 on 2018/8/29.
//  Copyright © 2018年 XiaoFu. All rights reserved.
//

#import "XFSpecialQuickHelper.h"

#import <Photos/Photos.h>
#import "XFUserRightsHelper.h"

@implementation XFSpecialQuickHelper

+ (void)XF_TrySavedToPhotoLibraryImage:(UIImage *)image
                            Completion:(void (^)(BOOL success, NSError *error,
                                                 NSString *imageId))completion {
    NSString *imageId;
    __block __typeof(&*imageId) blockImageId = imageId;

    [XFUserRightsHelper XF_StatusCheckAndRequest:YES PrivacyType:XFUserPrivacyType_Photos Param:nil
                                      Completion:^(BOOL authorized,
                                                   XFUserAuthorizationStatus status,
                                                   NSError *error) {
        if (authorized) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetChangeRequest* req = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
                blockImageId = req.placeholderForCreatedAsset.localIdentifier;
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (completion) {
                    completion(success, error, blockImageId);
                }
            }];
        } else {
            if (completion) {
                completion(NO, error, nil);
            }
        }
    }];
}

@end
