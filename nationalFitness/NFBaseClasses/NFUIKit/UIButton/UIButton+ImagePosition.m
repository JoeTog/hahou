//
//  UIButton+ImagePosition.m
//  RYKit
//
//  Created by zhangll on 16/5/9.
//  Copyright © 2016年 安徽软云信息科技有限公司. All rights reserved.
//

#import "UIButton+ImagePosition.h"

@implementation UIButton (ImagePosition)

- (CGSize)setImagePosition:(ImagePosition)postion spacing:(CGFloat)spacing//10
{
    CGSize size = CGSizeZero;
    
    //1.先设置按钮内容还原到以左上原点的布局位置
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    //2.取得图片大小
    CGFloat imageWith = self.imageView.image.size.width;
    CGFloat imageHeight = self.imageView.image.size.height;
    //3.取得文字大小
    CGFloat labelWidth = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}].width;
    CGFloat labelHeight = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}].height;
    
    
    //4.计算内容占位宽度总和(图宽+间距+文字宽)
    CGFloat contentW = 0.f;CGFloat contentH = 0.f;
    if (postion==ImagePositionLeft || postion==ImagePositionRight) {
        contentW = imageWith+spacing+labelWidth;
    } else {
        contentW = imageWith>labelWidth ? imageWith : labelWidth;
    }
    //5.计算内容占位高度总和(图高+间距+文字高)
    if (postion==ImagePositionTop || postion==ImagePositionBottom) {
        contentH = imageHeight+spacing+labelHeight;
    } else {
        contentH = imageHeight>labelHeight ? imageHeight : labelHeight;
    }
    //6.当按钮还未设置宽高时，先得出最优宽高，再用最优宽高计算偏移；当按钮设置了宽高时，得出最优宽高等于当前宽高
    if (self.frame.size.width == 0) {
        size.width = contentW;
    } else {
        size.width = self.frame.size.width;
    }
    if (self.frame.size.height == 0) {
        size.height = contentH;
    } else {
        size.height = self.frame.size.height;
    }
    //7.得出实际图片和文字应该设置的偏移量
    switch (postion) {
        case ImagePositionLeft:
        {
            //得出图片的实际偏移xy
            CGFloat offsetx = (size.width - contentW)/2;
            CGFloat offsety = (size.height - imageHeight)/2;
            self.imageEdgeInsets = UIEdgeInsetsMake(offsety, offsetx, 0, 0);
            //得出文字的实际偏移xy
            CGFloat offsetX = (size.width - offsetx - labelWidth - imageWith);
            CGFloat offsetY = (size.height - labelHeight)/2;
            self.titleEdgeInsets = UIEdgeInsetsMake(offsetY, offsetX, 0, 0);
        }
            break;
        case ImagePositionRight:
        {
            //得出图片的实际偏移xy
            CGFloat offsetx = (size.width - contentW)/2 + labelWidth +spacing;
            CGFloat offsety = (size.height - imageHeight)/2;
            self.imageEdgeInsets = UIEdgeInsetsMake(offsety, offsetx, 0, 0);
            //得出文字的实际偏移xy
            CGFloat offsetX = (size.width - contentW)/2 - imageWith;
            CGFloat offsetY = (size.height - labelHeight)/2;
            self.titleEdgeInsets = UIEdgeInsetsMake(offsetY, offsetX, 0, 0);
        }
            break;
        case ImagePositionTop:
        {
            //得出图片的实际偏移xy
            CGFloat offsetx = (size.width - imageWith)/2;
            CGFloat offsety = (size.height - contentH)/2;
            self.imageEdgeInsets = UIEdgeInsetsMake(offsety, offsetx, 0, 0);
            //得出文字的实际偏移xy
            CGFloat offsetX = (size.width - labelWidth)/2 - imageWith;
            CGFloat offsetY = size.height - (size.height - contentH)/2 - labelHeight;
            self.titleEdgeInsets = UIEdgeInsetsMake(offsetY, offsetX, 0, 0);
        }
            break;
        case ImagePositionBottom:
        {
            //得出图片的实际偏移xy
            CGFloat offsetx = (size.width - imageWith)/2 - labelWidth;
            CGFloat offsety = size.height - (size.height - contentH)/2 - imageHeight;
            self.imageEdgeInsets = UIEdgeInsetsMake(offsety, offsetx, 0, 0);
            //得出文字的实际偏移xy
            CGFloat offsetX = (size.width - labelWidth)/2;
            CGFloat offsetY = (size.height - contentH)/2;
            self.titleEdgeInsets = UIEdgeInsetsMake(offsetY, offsetX, 0, 0);
        }
            break;
        case ImagePositionMid:
        {
            spacing = -(imageWith + labelWidth)/2;
            contentW = imageWith+spacing+labelWidth;
            CGFloat offsetx = (size.width - contentW)/2;
            CGFloat offsety = (size.height - imageHeight)/2;
            self.imageEdgeInsets = UIEdgeInsetsMake(offsety, offsetx, 0, 0);
            //得出文字的实际偏移xy
            CGFloat offsetX = (size.width - offsetx - labelWidth - imageWith);
            CGFloat offsetY = (size.height - labelHeight)/2;
            self.titleEdgeInsets = UIEdgeInsetsMake(offsetY, offsetX, 0, 0);
        }
            break;//ImagePositionMid
        default:
            break;
    }
    //8.设置按钮位置内容还原到以垂直居中的布局位置
//    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
//    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    return size;
}

@end
