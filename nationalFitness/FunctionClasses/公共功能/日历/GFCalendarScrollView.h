//
//  GFCalendarScrollView.h
//
//  Created by Mercy on 2016/11/9.
//  Copyright © 2016年 Mercy. All rights reserved.
//

#import <UIKit/UIKit.h>
//我添加 为了取消报警 下面的block重复定义了
#import "GFCalendarView.h"


//typedef void (^DidSelectDayHandler)(NSInteger, NSInteger, NSInteger);

@interface GFCalendarScrollView : UIScrollView


@property (nonatomic, strong) DidSelectDayHandler didSelectDayHandler; // 日期点击回调

- (void)refreshToCurrentMonth; // 刷新 calendar 回到当前日期月份


@end
