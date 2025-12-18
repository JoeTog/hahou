//
//  AliyunOSSUpload.h
//  nationalFitness
//
//  Created by joe on 2020/10/28.
//  Copyright © 2020 chenglong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AliyunOSSiOS/AliyunOSSiOS.h>

NS_ASSUME_NONNULL_BEGIN

/// 上传到阿里云的 EndPoint
static NSString * _Nonnull const OSS_ENDPOINT = @"oss-cn-beijing.aliyuncs.com";
/// 上传到阿里云的 BucketName
static NSString * _Nonnull const BucketName = @"duoxinphoto";

@interface AliyunOSSUpload : NSObject

+(AliyunOSSUpload *)aliyunInit;

/// 上传图片
/// @param imgArray 放入需要上传的图片
/// @param success 上传成功,返回自己拼接的图片名字
- (void)uploadImage:(NSArray <UIImage *>*)imgArray success:(void (^)(NSArray <NSString *> * nameArray))success;






@end

NS_ASSUME_NONNULL_END
