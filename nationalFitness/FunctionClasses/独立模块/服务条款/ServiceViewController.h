//
//  ServiceViewController.h
//  nationalFitness
//
//  Created by 童杰 on 2016/12/19.
//  Copyright © 2016年 chenglong. All rights reserved.
//

#import "NFbaseViewController.h"
#import "UIColor+RYChat.h"

@interface ServiceViewController : NFbaseViewController

@property(nonatomic)BOOL isShowBack;

//充值
@property(nonatomic)BOOL isPay;

//提现
@property(nonatomic)BOOL isCash;

//设置密码
@property(nonatomic)BOOL isPassword;

//免密支付
@property(nonatomic)BOOL isCancelPwd;

//是否强制有返回
@property(nonatomic)BOOL isFouBack;


@property (copy, nonatomic) NSDictionary *payDict;    //懒加载

@property(nonatomic,strong)NSString *requestUrl;




@end
