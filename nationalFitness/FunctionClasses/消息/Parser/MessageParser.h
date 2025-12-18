//
//  MessageParser.h
//  nationalFitness
//
//  Created by Joe on 2017/7/20.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NFBaseParser.h"
#import "MessageEntity.h"
#import "NewHomeEntity.h"
#import "NFbaseViewController.h"
#import "UUMessageFrame.h"
#import "UUMessage.h"
#import "NSDate+Extension.h"
#import "YYModel.h"
#import "ZJContact.h"
#import "NFMyManage.h"
#import "EmojiShift.h"
#import "NFMyManage.h"
#import "RedAbountEntity.h"


#import "MKPAlertView.h"


@interface MessageParser : NFBaseParser

@property(nonatomic,copy)NSMutableArray *backArr;

//懒加载
@property (strong, nonatomic) NFMyManage *myManage;    //懒加载 fmdbServicee


//会话列表
+(id)ConvasationListParser:(NSDictionary *)data;


//历史消息 单聊
+(id)ConvasationHistoryChatContantParser:(NSArray *)data;

//历史消息 群聊
+(id)ConvasationGroupHistoryChatContantParser:(NSArray *)data;

//接收到远程消息 4002
+(id)GotNormalMessageContantParser:(NSDictionary *)data;

//请求群组列表 GroupListEntity
+(id)groupListManagerParserr:(NSArray *)data;

//创建群组成功返回
+(id)groupCreateSuccessManagerParserr:(NSArray *)data;

//接收到群组远程消息 5003
+(id)GotGroupNormalMessageContantParser:(NSDictionary *)data;

//群组详情
+(id)groupDetailManagerParserr:(NSDictionary *)data;

//群组成员详情数组 解析
+(id)groupmemberManagerParserr:(NSArray *)dataArr;
    
//重复创建群组
+(id)groupCreateRepeatManagerParserr:(NSDictionary *)data;
    
//拉人解析
+(id)PullUserParser:(NSDictionary *)data;
    
+(id)GotGroupRedpacketMessageContantParser:(NSDictionary *)data;

//接收到单聊红包消息
+(id)GotNormalRedPacketMessageContantParser:(NSDictionary *)data;

//领红包
+(id)RobRedPacketParser:(NSDictionary *)data;

//领红包 我是抢包人 收到红包领取通知【都是自己领取别人的,自己领取自己的不处理】
+(id)RobOtherRedPacketParser:(NSDictionary *)data;

//拉人解析 【管理收到申请】
+(id)PullUserManageParser:(NSDictionary *)data;

// 群系统通知 设置管理员 、踢人等
+(id)GroupNoticeParser:(NSDictionary *)data;


// 多信助手 l消息列表
+(id)helperList:(NSArray *)data;



@end


 


