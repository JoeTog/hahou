//
//  MessageChatListViewController.h
//  nationalFitness
//  消息列表
//单聊：收到消息刷新会话列表
//群聊：收到消息刷新会话列表、请求会话列表有未读的消息历史【用本地最后一条消息id】缓存消息历史
//  Created by Joe on 2017/6/30.
//  Copyright © 2017年 chenglong. All rights reserved.
// weakConnect

#import "NFbaseViewController.h"
#import "MessageChatListTableViewCell.h"
#import "MessageChatViewController.h"
#import "JsonModel.h"
#import "SocketModel.h"
#import "SocketRequest.h"
#import "LoginViewController.h"
#import "JQFMDB.h"
#import "NFMyManage.h"
#import "CCZTableButton.h"
#import "MLMOptionSelectView.h"
#import "UIView+Category.h"
#import "MLMOptionSelectTableViewCell.h"
#import "HCDTimer.h"
#import "SaveSetTableViewController.h"
#import "UIColor+RYChat.h"
#import "ZJSearchResultController.h"
#import "GroupChatViewController.h"
#import "FMDBService.h"
#import "CreateNewTableViewCell.h"

#import "AFNetworking.h"
#import "TZLocationManager.h"

#import "NotDismissAlertView.h"


//微信SDK头文件
#import "WXApi.h"

#import "DisconnectView.h"

#import "GCDTimerManager.h"

#import "BillListTableViewController.h"
#import "HelperTableViewController.h"



#define STOREAPPID @"1286622976"
#define IsCheckUpdate YES //是否检查更新
#define IsForceUpdate NO //是否强制更新 强制更新 必须用 NotDismissAlertView 弹框类



@interface MessageChatListViewController : NFbaseViewController

//懒加载
@property (strong, nonatomic) NFMyManage *myManage;    //懒加载 fmdbServicee
//懒加载
@property (copy, nonatomic) NSMutableDictionary *parms;    //懒加载

//yes 来自转发
@property (nonatomic) BOOL fromType;
//和谁聊天的
@property (strong, nonatomic) NSString *chatingName;
//转发消息类型 0文字 1图片 2语音
@property (nonatomic,strong) NSString *contentType;
//转发内容
@property (strong, nonatomic) NSString *forwardContent;
//转发的消息实体
@property (strong, nonatomic) UUMessageFrame *forwardUUMessageFrame;


@property (nonatomic) BOOL IsFromCard;    
@property (strong, nonatomic) ZJContact *cardContact;

-(void)refreshLocalData;

#pragma mark - 刷新函数
-(void)refresh;

#pragma mark - 会话列表收到服务器消息 相关处理
-(void)conversationListRefresh:(NSArray *)chatModel;


-(void)checkChatListCorrect;





@end
