//
//  NewMessageNotificateTableViewController.h
//  nationalFitness
//
//  Created by Joe on 2017/7/14.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+RYChat.h"
#import "NFMineEntity.h"
#import "NFbaseViewController.h"
#import "BellSetTableViewController.h"
#import "NFTableViewController.h"
#import "SocketModel.h"
#import "LWWeChatActionSheet.h"


@interface NewMessageNotificateTableViewController : NFTableViewController


//一键设置字体颜色
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;//接收新消息通知

@property (weak, nonatomic) IBOutlet UILabel *secondLabel;//声音

@property (weak, nonatomic) IBOutlet UILabel *thirdLabel;//震动

@property (weak, nonatomic) IBOutlet UILabel *forthLabel;//提醒声设置

@property (weak, nonatomic) IBOutlet UILabel *fifthLabel;//允许通知





@end
