//
//  RingSleepAnalysisView.h
//  nationalFitness
//
//  Created by 蝴蝶 on 15/4/16.
//  Copyright (c) 2015年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PieChartView.h"


@protocol RingSleepBtnDelegate <NSObject>

@optional
- (void)leftBtnTaped;

- (void)rightBtnTaped;

- (void)shoppingBtnTaped;

@end

@interface RingSleepAnalysisView : UIView

@property (weak, nonatomic) IBOutlet PieChartView *pieChartView;
@property (nonatomic,strong) NSString *totalSleepHour; // 总睡眠时间
@property (nonatomic,strong) NSString *lightSleepHour; // 浅睡眠时间
@property (nonatomic,strong) NSString *deepSleepHour;  // 深睡眠时间
@property (nonatomic, copy) NSString *dateString;
@property (nonatomic,strong) NSString *lightP;// 浅睡眠百分比 传入>0 <100整数
@property (nonatomic,strong) NSString *deepP;//  深睡眠百分比 传入>0 <100整数
@property (nonatomic, weak) id<RingSleepBtnDelegate>ringSleepBtnDelegate;
@property (nonatomic,strong) NSString *downDate; // 下方时间
@property (nonatomic) BOOL isBinding; // 是否绑定

@end
