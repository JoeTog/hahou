//
//  BYIndicatorView.m
//  Animation
//
//  Created by apple on 16/6/24.
//  Copyright © 2016年 Bangyang. All rights reserved.
//

#import "BYIndicatorView.h"

#define Angel 180

@implementation BYIndicatorView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _color = [UIColor colorWithRed:255 / 255.0 green:218 / 255.0 blue:69 / 255.0 alpha:1];
        _repeatCount = HUGE_VALF;  //无穷大
        _borderColor = [UIColor colorWithRed:255 / 255.0 green:218 / 255.0 blue:69 / 255.0 alpha:1];
        _borderWidth = 1.0;
    }
    return self;
}


-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    self.layer.cornerRadius = self.frame.size.height / 2.0;
    self.clipsToBounds = YES;
//    self.layer.borderColor = _color.CGColor;
//    self.layer.borderWidth = 1.0;
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (float i = 0; i <= Angel; i ++) {
        CGColorRef shadowColor = [_color colorWithAlphaComponent:(i / 600)].CGColor; //计算扇形填充颜色
        CGContextSetFillColorWithColor(context, shadowColor);
        
        CGContextMoveToPoint(context, self.center.x, self.center.y); //指定圆心
        CGContextAddArc(context, self.center.x, self.center.y, self.frame.size.height / 2, (-Angel + i + 1.15) / Angel * (float)M_PI, (-Angel + i - 1.15) / Angel * (float)M_PI, 1); //画一个扇形
        CGContextClosePath(context);//封闭形状
        
        CGContextDrawPath(context, kCGPathFill);//绘制扇形
    }
    
    CGContextSetLineWidth(context, 1.0);//线的宽度
    CGContextSetStrokeColorWithColor(context,[_color colorWithAlphaComponent:1].CGColor);
    CGContextMoveToPoint(context, self.center.x, self.center.y);
    CGContextAddLineToPoint(context, self.frame.size.height, self.center.y);
    CGContextStrokePath(context);
    
    CGContextSetRGBStrokeColor(context,1,218 / 255.0,69 / 255.0,0.1);//画笔线的颜色
    CGContextSetLineWidth(context, 2.0);//线的宽度
    CGContextAddArc(context, self.center.x, self.center.y, self.frame.size.height / 2.0, 0, 2 *M_PI, 1); //添加一个圆
    CGContextDrawPath(context, kCGPathStroke); //绘制路径
    // 3.显示所绘制的东西
    CGContextStrokePath(context);

    
    //扫描动画
    CABasicAnimation * rotateAnimation = [[CABasicAnimation alloc] init];
    rotateAnimation.keyPath = @"transform.rotation.z";
    rotateAnimation.toValue = @((double)2 * M_PI); // 终止角度
    rotateAnimation.duration = 3;
    rotateAnimation.removedOnCompletion = NO;
    rotateAnimation.repeatCount = _repeatCount;
    [self.layer addAnimation:rotateAnimation forKey:@"rotate_layer"];

}


@end
