//
//  NSString+XFCategory.h
//  XiaoFuTechBasic
//
//  Created by xiaofutech on 2017/9/25.
//  Copyright © 2017年 XiaoFu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (XFCategory)

/**
 正则匹配判定
 @param regEx 正则表达式
 @return 判定结果
 */
- (BOOL)xf_IsMatchRegEx:(NSString *)regEx;

/**
 SHA-256加密
 @return 已加密字符串
 */
- (NSString *)xf_EncryptSHA256;
+ (NSString *)XF_EncryptSHA256:(NSData *)keyData;

/**
 SHA-1加密
 @return 已加密字符串
 */
- (NSString *)xf_EncryptSHA1;
+ (NSString *)XF_EncryptSHA1:(NSData *)keyData;


/**
 MD5加密
 @return 已加密字符串
 */
- (NSString *)xf_EncryptMD5;

/**
 十六进制字符串转成无符号整型值
 @return 无符号整型值
 备注：1.转换失败会返回 0
 2.类似的还可以转，无符号长整型，单精度浮点型，双精度浮点型
 ps.无符号整型值的取值范围：16位机（0 ~ 2^16，0xffff，65535），32位机（0 ~ 2^32，0xffffffff，4294967295）
 */
- (unsigned int)xf_HexStringToUnsignedInt;

- (int)XF_GetNumberOfCharactersWithCRNum:(int)crNum;

@end
