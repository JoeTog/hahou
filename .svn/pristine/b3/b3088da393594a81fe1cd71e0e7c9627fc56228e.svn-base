//
//  ZBExpressionSectionBar.m
//  MessageDisplay
//
//  Created by zhoubin@moshi on 14-5-13.
//  Copyright (c) 2014年 Crius_ZB. All rights reserved.
//

#import "ZBExpressionSectionBar.h"

@implementation ZBExpressionSectionBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
        for (NSInteger i = 0; i < 1; i ++)
        {
            UIButton *button1 =[UIButton buttonWithType:UIButtonTypeCustom];
            [self addSubview:button1];
            [button1 setFrame:CGRectMake(2 + 40 * i, self.bounds.origin.y - 2.5, 40, 40)];
            [button1 setImage:[UIImage imageNamed:[NSString stringWithFormat:@"smiley_%ld",(long)i]] forState:UIControlStateNormal];
            [button1 setContentEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
            UIView* line1 = [[UIView alloc] initWithFrame:CGRectMake(41 + 40 * i, self.bounds.origin.y, 1, self.bounds.size.height)];
            [self addSubview:line1];
            line1.backgroundColor = [UIColor lightGrayColor];
        }
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
