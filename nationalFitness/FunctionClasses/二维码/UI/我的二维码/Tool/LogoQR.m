//
//  LogoQR.m
//  iOS二维码详细生成代码
//
//  Created by 金钱象 on 16/11/1.
//  Copyright © 2016年 zhonghuatianchuang. All rights reserved.
//

#import "LogoQR.h"
#import "UIImage+MultiFormat.h"
#import <CoreImage/CoreImage.h>

@interface LogoQR ()
{
   UIImage *icon_image;
   NSData *data;
}

@end
@implementation LogoQR

#pragma mark 二维码的生成
-(UIImage *)QRurl:(NSString *)url messages:(NSString *)message
{
    // 1、创建滤镜对象
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    // 恢复滤镜的默认属性
    [filter setDefaults];
    
    // 2、设置数据
    NSString *string_data = message;
    // 将字符串转换成 NSdata (虽然二维码本质上是字符串, 但是这里需要转换, 不转换就崩溃)
    NSData *qrImageData = [string_data dataUsingEncoding:NSUTF8StringEncoding];
    
    // 设置过滤器的输入值, KVC赋值
    [filter setValue:qrImageData forKey:@"inputMessage"];
    
    // 3、获得滤镜输出的图像
    CIImage *outputImage = [filter outputImage];
    
    // 图片小于(27,27),我们需要放大
    outputImage = [outputImage imageByApplyingTransform:CGAffineTransformMakeScale(20, 20)];
    
    // 4、将CIImage类型转成UIImage类型
    UIImage *start_image = [UIImage imageWithCIImage:outputImage];
    
    // - - - - - - - - - - - - - - - - 添加中间小图标 - - - - - - - - - - - - - - - -
    // 5、开启绘图, 获取图形上下文 (上下文的大小, 就是二维码的大小)
    UIGraphicsBeginImageContext(start_image.size);
    
    // 把二维码图片画上去 (这里是以图形上下文, 左上角为(0,0)点
    [start_image drawInRect:CGRectMake(0, 0, start_image.size.width, start_image.size.height)];
    
    // 再把小图片画上去
    if (url==nil) {
        
        icon_image = [UIImage imageNamed:@"touxiang.jpg"];
        
    }else
    {
        data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        icon_image = [UIImage sd_imageWithData:data];
    }
    CGFloat a = 200;
    CGFloat icon_imageW = a;
    CGFloat icon_imageH = icon_imageW;
    CGFloat icon_imageX = (start_image.size.width - icon_imageW) * 0.5;
    CGFloat icon_imageY = (start_image.size.height - icon_imageH) * 0.5;
    
    [icon_image drawInRect:CGRectMake(icon_imageX, icon_imageY, icon_imageW, icon_imageH)];
    
    // 6、获取当前画得的这张图片
    UIImage *final_image = UIGraphicsGetImageFromCurrentImageContext();
    
    // 7、关闭图形上下文
    UIGraphicsEndImageContext();
    
    // 8、将最终合得的图片显示在UIImageView上
    
    return final_image;
}



@end
