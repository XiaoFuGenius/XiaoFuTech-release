//
//  XFSpecialQuickHelper.h
//  XiaoFuTech
//
//  Created by 胡文峰 on 2018/8/29.
//  Copyright © 2018年 XiaoFu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XFSpecialQuickHelper : NSObject

/**
 保存图片到相册
 @parma image 待保存的图片对象
 @param completion 完成回调
 备注：需要先在Info.plist添加相应的权限，若之前未授权，则会弹出授权
 */
+ (void)XF_TrySavedToPhotoLibraryImage:(UIImage *)image
                            Completion:(void (^)(BOOL success, NSError *error,
                                                 NSString *imageId))completion;

@end
