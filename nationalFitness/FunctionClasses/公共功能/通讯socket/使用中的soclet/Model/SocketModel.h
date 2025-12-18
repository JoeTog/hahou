//
//  SocketModel.h
//  WebSocket
//
//  Created by King on 2017/6/30.
//  Copyright © 2017年 King. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NFbaseViewController.h"
#import "MessageEntity.h"
#import "ChatModel.h"

#import "LoginEntity.h"
#import "MessageEntity.h"
#import "NewHomeEntity.h"
#import "NFDynamicEntity.h"

#import "LoginParser.h"
#import "NewHomeParser.h"
#import "MessageParser.h"
#import "NFMineParser.h"

#import "ZJContactViewController.h"
#import "UUMessageFrame.h"
#import "UUMessage.h"
#import "PopMessageView.h"
#import "NFbaseViewController.h"


#import "FLStatusBarHUD.h"
#import "SoundControlSingle.h"
#import "NFMineEntity.h"
#import "UIFont+RYChat.h"
#import "Data_MD5.h"
#import "Masonry.h"
#import "FMDBService.h"
#import "MessageChatListViewController.h"
#import "HCDTimer.h"
#import "NFDynamicParser.h"
#import "ClearManager.h"
#import <netdb.h>
#import "DisconnectView.h"



#import "RedSocketModel.h"
#import "RedParser.h"


#define notifyDelayTime 0.5



//--ip地址
//上架环境
//#define ServerAddress @"116.62.6.189"
//开发环境
//#define ServerAddress @"116.62.53.142"

//连接成功回调
typedef void(^ConnectSuccess)(void);


@protocol ChatHandlerDelegate <NSObject>

@required

//接收消息代理
//- (void)didReceiveMessage:(ChatModelEntity *)chatModel type:(ChatMessageType)messageType;

- (void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType;

@optional
//发送消息超时代理
- (void)sendMessageTimeOutWithTag:(long)tag;

@end

typedef void (^receiveMessage)(NSString *message);

typedef enum : NSUInteger {
    disConnectByUser ,
    disConnectByServer,
} DDisConnectType;

@interface SocketModel : NSObject

//懒加载
@property (strong, nonatomic) NFMyManage *myManage;    //懒加载 fmdbServicee
//懒加载
@property (copy, nonatomic) NSMutableDictionary *parms;    //懒加载

@property(nonatomic,strong)HCDTimer *timer; //是否需要提醒开小差

@property(nonatomic)BOOL isNeedWake;

@property(weak,nonatomic)id<ChatHandlerDelegate> delegate;




@property (nonatomic, strong) receiveMessage  messageContent;
//是否处于连接状态
@property (nonatomic, assign) BOOL  isConnected;

//查询服务
@property (nonatomic, strong) FMDBService  *fmdbServicee;

//NFMyManage


//群聊详情实体 相关
@property (nonatomic, strong) GroupCreateSuccessEntity *groupCreateSuccess;

-(void)initSocket;

//当手动退出登录后 再次进行登录 需要重连 重连成功回调
@property(nonatomic,copy)ConnectSuccess ConnectSucceedBlock;
-(void)returnConnectSuccedd:(ConnectSuccess)block;


+ (instancetype)share;


- (void)connect;
- (void)disConnect;

//  重连机制
-(void)reConnect;

- (void)sendMsg:(id)msg;

- (void)ping;

//发送心跳
- (void)sendhert;

#pragma mark - 为了重新建立服务器链接
-(void)getAddFriendList;

#pragma mark - 登陆
- (void)loginWithDefaultType;

#pragma mark - 不做任何连接判断 强行连接
-(void)loginWithDefaultTypeStrong;

#pragma mark - 微信登录
-(void)weixinLoginRequest;



@end
