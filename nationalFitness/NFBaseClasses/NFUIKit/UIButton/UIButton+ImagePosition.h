//
//  UIButton+ImagePosition.h
//  RYKit
//
//  Created by zhangll on 16/5/9.
//  Copyright © 2016年 安徽软云信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 文字和图片位置的自由排列 */
typedef NS_ENUM(NSInteger, ImagePosition) {
    /** 图片在左，文字在右，默认 */
    ImagePositionLeft            = 0,
    /** 图片在右，文字在左 */
    ImagePositionRight           = 1,
    /** 图片在上，文字在下 */
    ImagePositionTop             = 2,
    /** 图片在下，文字在上 */
    ImagePositionBottom          = 3,
    /** 图片文字都在中间 */
    ImagePositionMid          = 4
};

@interface UIButton (ImagePosition)

/**
 *  利用 UIButton 的 titleEdgeInsets 和 imageEdgeInsets 来实现 按钮内容垂直居中样式 且 文字和图片位置 的自由排列。
 *  注意：这个方法需要在设置图片和文字之后才可以调用，且最终 UIButton大小 = 图片大小 + spacing + 文字大小
 *
 *  @param spacing 图片和文字的间隔
 */
- (CGSize)setImagePosition:(ImagePosition)postion spacing:(CGFloat)spacing;

@end
