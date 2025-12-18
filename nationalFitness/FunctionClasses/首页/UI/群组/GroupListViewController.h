//
//  GroupListViewController.h
//  nationalFitness
//  群组主页
//  Created by Joe on 2017/6/30.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NFbaseViewController.h"
#import "addFrienfViewController.h"
#import "SocketModel.h"
#import "SocketRequest.h"
#import "AppDelegate.h"
#import "GroupAddMemberViewController.h"
#import "GroupChatViewController.h"
#import "NFMyManage.h"


@interface GroupListViewController : NFbaseViewController

//懒加载
@property (copy, nonatomic) NSMutableDictionary *parms;    //懒加载


@property (nonatomic, strong) FMDBService  *fmdbServicee;


//yes 来自转发 在这里转发到某些人
@property (nonatomic) BOOL fromType;

//和谁聊天的
@property (strong, nonatomic) NSString *chatingName;
//转发消息类型 0文字 1图片 2语音
@property (nonatomic,strong) NSString *contentType;
//转发内容
@property (strong, nonatomic) NSString *forwardContent;
//转发的消息实体
@property (strong, nonatomic) UUMessageFrame *forwardUUMessageFrame;







@end
