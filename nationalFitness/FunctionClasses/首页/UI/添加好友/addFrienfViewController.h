//
//  addFrienfViewController.h
//  nationalFitness
//  好友申请与通知列表  添加好友 添加群组
//  Created by Joe on 2017/6/30.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NFbaseViewController.h"
#import "ContantTableViewCell.h"
#import "ZJContact.h"
#import "MessageEntity.h"
#import "ApplyViewDetailViewController.h"
#import "AddFriendOrGroupdetailViewController.h"

#import "SocketRequest.h"



@interface addFrienfViewController : NFbaseViewController


//类型 0申请与通知 1添加好友 2群组
@property(nonatomic,strong)NSString *addFriendType;

//懒加载
@property (copy, nonatomic) NSMutableDictionary *parms;    //懒加载







@end
