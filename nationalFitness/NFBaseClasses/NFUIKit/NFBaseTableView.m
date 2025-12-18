//
//  NFBaseTableView.m
//  nationalFitness
//
//  Created by liumac on 15/7/4.
//  Copyright (c) 2015年 chenglong. All rights reserved.
//

#import "NFBaseTableView.h"
#import "PublicDefine.h"


@interface NFBaseTableView ()

{
    NFNothingView *nothing_;
}

@end

@implementation NFBaseTableView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/



- (void)showNone
{
    if (nothing_ == nil && _isNeed)
    {
        nothing_ = [[NFNothingView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:nothing_];
    }
}

- (void)showNoneWithImage:(NSString *)imageName WithTitle:(NSString *)title
{
    if (nothing_ == nil && _isNeed)
    {
        nothing_ = [[NFNothingView alloc]initWithFrame:CGRectMake(0, 80, self.frame.size.width, self.frame.size.height)WithTitle:title WithImageName:imageName];
//        NSLog(@"%ld",nothing_.userInteractionEnabled);
        //设置uiview 交互关闭
        nothing_.userInteractionEnabled = NO;
        [self addSubview:nothing_];
        
    }
}

- (void)showNoneWithImage:(NSString *)imageName WithTitle:(NSString *)title AndHeight:(CGFloat)height{
    if (nothing_ == nil && _isNeed)
    {
        nothing_ = [[NFNothingView alloc]initWithFrame:CGRectMake(0, height, self.frame.size.width, self.frame.size.height - height)WithTitle:title WithImageName:imageName];
//        NSLog(@"%ld",nothing_.userInteractionEnabled);
        //设置uiview 交互关闭
        nothing_.userInteractionEnabled = NO;
        [self addSubview:nothing_];
    }
}

- (void)showNoneWithImage:(NSString *)imageName WithTitle:(NSString *)title TableviewWidth:(CGFloat)width AndHeight:(CGFloat)height{
    if (nothing_ == nil && _isNeed)
    {
        nothing_ = [[NFNothingView alloc]initWithFrame:CGRectMake(0, height, width, self.frame.size.height - height)WithTitle:title WithImageName:imageName];
//        NSLog(@"%ld",nothing_.userInteractionEnabled);
        //设置uiview 交互关闭
        nothing_.userInteractionEnabled = NO;
        [self addSubview:nothing_];
    }
}


// 针对特定界面
- (void)showNoneInChatWithImage:(NSString *)imageName WithTitle:(NSString *)title
{
    if (nothing_ == nil && _isNeed)
    {
        nothing_ = [[NFNothingView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH - 200)/2, 0, 200, self.frame.size.height)WithTitle:title WithImageNam:imageName];
        [self addSubview:nothing_];
    }
}

- (void)removeNone
{
    [nothing_ removeFromSuperview];
    nothing_ = nil;
}


@end
