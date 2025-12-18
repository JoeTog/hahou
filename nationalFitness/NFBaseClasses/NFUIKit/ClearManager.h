//
//  ClearManager.h
//  nationalFitness
//
//  Created by Joe on 2017/9/8.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"




@interface ClearManager : NSObject





//将数字转成字符串
-(NSString *)NumToString:(NSString *)num;
//将数字转成字符串
+ (NSString *)NumToString:(NSString *)num;
    
#pragma mark - 通知appicon角标
+(void)notificateBadge:(NSString *)message infoDict:(NSDictionary *)info;

#pragma mark - 获取表情个数
+ (NSInteger)stringContainsEmojiCount:(NSString *)string;

#pragma mark - 是否含有表情
+ (BOOL)stringContainsEmoji:(NSString *)string;

#pragma mark - 存字典到userdefault
+(void)saveToArrWithDict:(NSDictionary *)dic UserDefaultName:(NSString *)tablenamwe;
    
#pragma mark - 取字典数组到userdefault
+(NSArray *)getDictArrFromTableName:(NSString *)tablenamwe;
    
#pragma mark - 图片转字符串
+(NSString *)UIImageToBase64Str:(UIImage *) image IsOriginalImage:(BOOL)ret;

#pragma mark - base64字符串转图片
+(UIImage *)Base64StringToImage:(NSString *) imageString;


//图片压缩到指定大小
+ (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize Image:(UIImage *)image;

#pragma mark - 是否允许撤回
+(BOOL)IsAllowDraw:(NSInteger)receiveTime;

#pragma mark - 获取网络状态
+(BOOL)getNetStatus;

#pragma mark - 生成本地唯一APPMsgId
+(NSString *)getAPPMsgId;

#pragma mark - 获取域名的ip地址
-(void)getServerIP;

#pragma mark - 获取当前时间戳
+(NSString *)getCurrentTimeStamp;

#pragma mark - 获取index为index的根视图
-(UIViewController *)getRootViewControllerOfTabbarRootIndex:(NSInteger)index;

+ (BOOL)isBlank:(NSString*)str ;


//控制图片大小在120字节内
+(NSData *)imageDataScale:(UIImage *)image scale:(CGFloat)scale;




@end
