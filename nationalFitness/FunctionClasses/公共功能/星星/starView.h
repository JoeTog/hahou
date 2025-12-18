//
//  starView.h
//  星星
//
//  Created by bwfstu on 16/6/7.
//  Copyright © 2016年 Joe. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "Masonry.h"

@interface starView : UIView

//点击星星时，返回点击的index代码块
@property(nonatomic,strong)void(^selectStar)(NSInteger);


//设置星星的星级 最高5星
-(void)setStarValue:(CGFloat)starValue;
//重写init方法
// starViewWidth(2, 10)计算starView的总宽度，10为starView的高度，后面2为星星间距，10为星星宽度，type1为男式样，2位女式样
-(instancetype)initWithFrame:(CGRect)frame STARGAP:(CGFloat)gap STARHW:(CGFloat)heitAndWidth TYPE:(int)type;

//-(UIView *)createStarViewWithGAP:(CGFloat)gap starHW:(CGFloat)Width;

//创建可点击的五个星星，用于用户评论星级
-(instancetype)initWithFrame:(CGRect)frame TYPE:(int)type clickBlock:(void(^)(NSInteger index))selectBlock;

@end
