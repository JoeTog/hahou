//
//  UIImage+FW.h
//  RYKit
//
//  Created by zhangll on 16/4/11.
//  Copyright © 2016年 安徽软云信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (FW)

/**
 *  返回一张自由拉伸的图片
 */
+ (UIImage *)resizedImageWithName:(NSString *)name;
+ (UIImage *)resizedImageWithName:(NSString *)name left:(CGFloat)left top:(CGFloat)top;
/**
 *  返回一张圆形图片
 */
+ (UIImage*) circleImage:(UIImage*) image withParam:(CGFloat) inset;
/**
 *  根据颜色快速创建一个图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color CGSize:(CGSize)size;
/**
 *  合成图片
 */
+ (UIImage *)imageWithImageOne:(UIImage *)image1 ImageTwo:(UIImage *)image2 totalSize:(CGSize)totalSize rectOne:(CGRect)oneRect rectTwo:(CGRect)twoRect;
/**
 *  倍数放大或缩小图片
 */
- (UIImage *)scalingToSize:(CGSize)size;

@end
