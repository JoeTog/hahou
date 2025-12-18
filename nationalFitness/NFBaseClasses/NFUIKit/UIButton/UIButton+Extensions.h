//
//  UIButton+Extensions.h
//  ZhiBo
//
//  Created by zhangll on 17/1/10.
//  Copyright © 2017年 安徽软云信息科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Extensions)


- (void)setImage:(UIImage *)image imageHL:(UIImage *)imageHL;

- (void)setEnlargeEdge:(CGFloat) size;
- (void)setEnlargeEdgeWithTop:(CGFloat) top right:(CGFloat) right bottom:(CGFloat) bottom left:(CGFloat) left;

@end
