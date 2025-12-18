//
//  RedDetailTableViewController.h
//  nationalFitness
//
//  Created by joe on 2017/12/13.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NFTableViewController.h"

//view
#import "redPacketDetailHeadView.h"

//实体
#import "UUMessageFrame.h"
#import "UUMessage.h"

//功能
#import "Masonry.h"
#import "UIImage+FW.h"

//cell
#import "RedPacketDetailTableViewCell.h"






@interface RedDetailTableViewController : NFTableViewController

//是否为 群聊
@property(nonatomic,assign)BOOL *IsGroupRed;

@property(nonatomic,strong)NSString *nickName;

//RedEntity
@property(nonatomic,strong)RedEntity *redEntity;


@property(nonatomic,strong)UUMessageFrame *redMessage;



@end
