//
//  UITabBarItem+Badge.m
//  YeeBadgeDemo
//
//  Created by Yee on 2017/7/10.
//  Copyright © 2017年 CoderYee. All rights reserved.
//

#import "UITabBarItem+Badge.h"
#import "YeeBadgeLable.h"
#include <objc/runtime.h>
 const  static NSString *Yee_TabBar_BadgeLableString=@"Yee_TabBar_BadgeLableString";
@implementation UITabBarItem (Badge)

-(void)yee_MakeBadgeTextNum:(NSInteger )textNum
                  textColor:(UIColor *)tColor
                  backColor:(UIColor *)backColor
                       Font:(UIFont*)tfont{
    if (textNum>99) {
        //如果大于99条 则显示99
        id Field = [self valueForKey:@"_view"];
        UIView *TabBar_item_;
        if ([Field isKindOfClass:[UIView class]]) {
            TabBar_item_=[self valueForKey:@"_view"];
        }
        UIView *UITabBarSwappableImageView=[self findSwappableImageViewByInView:TabBar_item_];
        if ([self yee_BadgeLable]==nil) {//如果没有绑定就重新创建,然后绑定
            YeeBadgeLable *badgeLable =[[YeeBadgeLable alloc] init];
            objc_setAssociatedObject(self, &Yee_TabBar_BadgeLableString, badgeLable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [UITabBarSwappableImageView addSubview:badgeLable];
        }
        //cgrect为角标位置
        [[self  yee_BadgeLable] makeBrdgeViewWithText:[NSString stringWithFormat:@"%d",99] textColor:tColor backColor:backColor textFont:tfont tframe:CGRectMake(UITabBarSwappableImageView.frame.size.width - 3, -5, 15, 15)];
        //有消息通知 则显示
        [self yee_BadgeLable].hidden = NO;
    }else{
        id Field = [self valueForKey:@"_view"];
        UIView *TabBar_item_;
        if ([Field isKindOfClass:[UIView class]]) {
            TabBar_item_=[self valueForKey:@"_view"];
        }
        UIView *UITabBarSwappableImageView=[self findSwappableImageViewByInView:TabBar_item_];
        if ([self yee_BadgeLable]==nil) {//如果没有绑定就重新创建,然后绑定
            YeeBadgeLable *badgeLable =[[YeeBadgeLable alloc] init];
            objc_setAssociatedObject(self, &Yee_TabBar_BadgeLableString, badgeLable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            [UITabBarSwappableImageView addSubview:badgeLable];
        }
        //cgrect为角标位置
        if (textNum<0) {
            textNum = 0;
        }
        if (textNum <= 0) {
            //如果未读为0 则隐藏
            [self yee_BadgeLable].hidden = YES;
            return;
        }
        [[self  yee_BadgeLable] makeBrdgeViewWithText:[NSString stringWithFormat:@"%ld",textNum] textColor:tColor backColor:backColor textFont:tfont tframe:CGRectMake(UITabBarSwappableImageView.frame.size.width - 3, -5, 15, 15)];
        //有消息通知 则显示
        [self yee_BadgeLable].hidden = NO;
    }
    
}

-(void)yee_MakeRedBadge:(CGFloat)corner color:(UIColor *)cornerColor{
    
    id Field = [self valueForKey:@"_view"];
    UIView *TabBar_item_;
    if ([Field isKindOfClass:[UIView class]]) {
        TabBar_item_=[self valueForKey:@"_view"];
    }
    
    UIView *UITabBarSwappableImageView=[self findSwappableImageViewByInView:TabBar_item_];
    if ([self yee_BadgeLable]==nil) {//如果没有绑定就重新创建,然后绑定
        YeeBadgeLable *badgeLable =[[YeeBadgeLable alloc] init];
        objc_setAssociatedObject(self, &Yee_TabBar_BadgeLableString, badgeLable, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [UITabBarSwappableImageView addSubview:badgeLable];
        
    }else{
        [self yee_BadgeLable].hidden = NO;
        
    }
    
    [[self yee_BadgeLable]setFrame:CGRectMake(UITabBarSwappableImageView.frame.size.width-corner, -corner, corner*2.0, corner*2.0)];
    [self  yee_BadgeLable].text = @"";//红点不显示数字
    [[self  yee_BadgeLable] makeBrdgeViewWithCor:corner CornerColor:cornerColor];
    
    
    
}

-(void)removeBadgeView{
    
//    [[self yee_BadgeLable] removeFromSuperview];
    [self yee_BadgeLable].hidden = YES;
}
-(YeeBadgeLable *)yee_BadgeLable{
    
    YeeBadgeLable *badgeLable=objc_getAssociatedObject(self, &Yee_TabBar_BadgeLableString);
    return badgeLable;
}
-(UIView *)findSwappableImageViewByInView:(UIView *)inView{
    
    for (UIView *subView in inView.subviews) {
        
        
        if ([subView isKindOfClass:[UIImageView class]]) {
            
            return subView;
        }
        
    }
    return nil;
}
@end
