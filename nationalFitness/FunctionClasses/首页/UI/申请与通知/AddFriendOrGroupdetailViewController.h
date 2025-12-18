//
//  AddFriendOrGroupdetailViewController.h
//  nationalFitness
//  添加联系人 群组详情
//  Created by Joe on 2017/7/3.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NFbaseViewController.h"
#import "PopView.h"
#import "JsonModel.h"
#import "SocketModel.h"
#import "SocketRequest.h"
#import "MKPAlertView.h"
#import "BYRadarView.h"
#import "HCDTimer.h"
#import "MBProgressHUD+NHAdd.h"


@interface AddFriendOrGroupdetailViewController : NFbaseViewController

//懒加载
@property (copy, nonatomic) NSMutableDictionary *parms;    //懒加载


//类型 0申请与通知 1添加好友 2群组
@property(nonatomic,strong)NSString *addFriendType;

//好友id
@property(nonatomic,strong)NSString *addFriendId;

//好友name
@property(nonatomic,strong)NSString *addFriendName;

//好友头像
@property(nonatomic,strong)NSString *headPicpath;



@end
