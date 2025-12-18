//
//  UIImage+FW.m
//  RYKit
//
//  Created by zhangll on 16/4/11.
//  Copyright © 2016年 安徽软云信息科技有限公司. All rights reserved.
//

#import "UIImage+FW.h"

@implementation UIImage (FW)

+ (UIImage *)resizedImageWithName:(NSString *)name
{
    return [self resizedImageWithName:name left:0.5 top:0.5];
}

+ (UIImage *)resizedImageWithName:(NSString *)name left:(CGFloat)left top:(CGFloat)top
{
    UIImage *image = [self imageNamed:name];
    return [image stretchableImageWithLeftCapWidth:image.size.width * left topCapHeight:image.size.height * top];
}

+ (UIImage *)circleImage:(UIImage *)image withParam:(CGFloat) inset
{
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2);
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGRect rect = CGRectMake(inset, inset, image.size.width - inset * 2.0f, image.size.height - inset * 2.0f);
    CGContextAddEllipseInRect(context, rect);
    CGContextClip(context);
    
    [image drawInRect:rect];
    CGContextAddEllipseInRect(context, rect);
    CGContextStrokePath(context);
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimg;
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

+ (UIImage *)imageWithColor:(UIColor *)color CGSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, 0, [UIScreen mainScreen].scale);
    [color  set];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    UIImage *pressedColorImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return pressedColorImg;
}

+ (UIImage *)imageWithImageOne:(UIImage *)image1 ImageTwo:(UIImage *)image2 totalSize:(CGSize)totalSize rectOne:(CGRect)oneRect rectTwo:(CGRect)twoRect
{
    UIGraphicsBeginImageContext(totalSize);
    // Draw image1
    [image1 drawInRect:oneRect];
    // Draw image2
    [image2 drawInRect:twoRect];
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

- (UIImage *)scalingToSize:(CGSize)size
{
    CGFloat scale = 0.0f;
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    CGFloat width = size.width;
    CGFloat height = size.height;
    if (CGSizeEqualToSize(self.size, size) == NO) {
        CGFloat widthFactor = size.width / self.size.width;
        CGFloat heightFactor = size.height / self.size.height;
        scale = (widthFactor > heightFactor ? widthFactor : heightFactor);
        width  = self.size.width * scale;
        height = self.size.height * scale;
        y = (size.height - height) * 0.5;
        
        x = (size.width - width) * 0.5;
        
    }
    // this is actually the interesting part:
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(x, y, width, height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if(newImage == nil) {
        NSLog(@"绘制指定大小的图片失败");
        return self;
    }
    return newImage;
}

@end
