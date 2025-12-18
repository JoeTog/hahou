//
//  UITableView+RYChat.m
//  RYKit
//
//  Created by zhangll on 16/8/16.
//  Copyright © 2016年 安徽软云信息科技有限公司. All rights reserved.
//

#import "UITableView+RYChat.h"

@implementation UITableView (RYChat)

- (void)scrollToBottomWithAnimation:(BOOL)animation offset:(CGFloat)height
{
    //NSLog(@"\n%f&\n%f\n",self.contentSize.height,self.frame.size.height);
//    CGFloat offsetY = self.contentSize.height > self.frame.size.height ? self.contentSize.height - self.frame.size.height : -(364 + 20);
//    NSLog(@"%f&&%f",self.contentSize.height,SCREEN_HEIGHT - 49 - 64);
//    CGFloat offsetY = self.contentSize.height > self.frame.size.height - 20 ? self.contentSize.height - self.frame.size.height +50 + 64 + kTabbarMoreHeight + height: 0;
////    if (offsetY == 0) {
////
////    }
    CGFloat offsetY = self.contentSize.height > self.height ? self.contentSize.height - self.height : -(64);
////    NSLog(@"%f",offsetY);
    
    
    [self setContentOffset:CGPointMake(0, offsetY) animated:animation];

    
    
}


//发送消息后 消息滑倒底部
-(void)SendMessageLetTableScrollToBottom:(BOOL)animation offset:(CGFloat)height{
    
    
    [self setContentOffset:CGPointMake(0, height) animated:animation];
    
    
}

//-(void)setContentOffset:(CGPoint)contentOffset{
//
//    NSLog(@"contentOffset 1111 = %@",contentOffset);
//
//}
//
//-(void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated{
//
//
//    NSLog(@"contentOffset 22222 = %@",contentOffset);
//}




-(void)SendMessageLetTableScrollToBottomBegin:(BOOL)animation offset:(CGFloat)height{
    
    [self setContentOffset:CGPointMake(0, height - 30) animated:NO];
    
    
}



- (void)groupScrollToBottomWithAnimation:(BOOL)animation offset:(CGFloat)height
{
    //NSLog(@"\n%f&\n%f\n",self.contentSize.height,self.frame.size.height);
    //    CGFloat offsetY = self.contentSize.height > self.frame.size.height ? self.contentSize.height - self.frame.size.height : -(364 + 20);
    //NSLog(@"%f&&%f",self.contentSize.height,SCREEN_HEIGHT - 49 - 64);
    CGFloat offsetY = self.contentSize.height > self.frame.size.height ? self.contentSize.height - self.frame.size.height + height: 0;
    //    if (offsetY == 0) {
    //
    //    }
    //    CGFloat offsetY = self.contentSize.height > self.height ? self.contentSize.height - self.height : -(64);
    [self setContentOffset:CGPointMake(0, offsetY) animated:animation];
}


@end
