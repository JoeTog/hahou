//
//  UUMessage.h
//  UUChatDemoForTextVoicePicture
//
//  Created by shake on 14-8-26.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import <Foundation/Foundation.h>
#

typedef enum {
    UUMessageTypeText     = 0 , // 文字
    UUMessageTypePicture  = 1 , // 图片
    UUMessageTypeVoice    = 2 ,  // 语音
    UUMessageTypeRed    = 3   ,// 红包
    UUMessageTypeRecommendCard    = 4,   // 名片
    UUMessageTypeRedRobRecord = 5,    //红包领取记录
    UUMessageTypeTransfer = 6,    //转账消息
    UUMessageTypeSystem = 7     //系统消息
} MessageType;


typedef enum {
    UUMessageFromMe    = 100,   // 自己发的
    UUMessageFromOther = 101,   // 别人发得
    UUMessageFromInvite = 102,   //邀请
} MessageFrom;
//MessageFrom

@interface UUMessage : NSObject

//用户id
@property (nonatomic, copy) NSString *userId;
//名字
@property (nonatomic, copy) NSString *userName;
//原始昵称 用于@，【群昵称、原来昵称】
@property (nonatomic, copy) NSString *originalNickName;
//昵称
@property (nonatomic, copy) NSString *nickName;
//月后隐藏字段 1隐藏
@property(nonatomic,strong)NSString *yuehouYinCang;

//关机删除字段 0删除
@property(nonatomic,strong)NSString *guanjiShanChu;
//接收到消息的时间
@property(nonatomic,assign)NSInteger localReceiveTime;
//接收到消息的时间
@property(nonatomic,strong)NSString *localReceiveTimeString;
//chatid 消息id
@property(nonatomic,strong)NSString *chatId;
//app本地的 消息id 【用于发送消息给服务器后 服务器返回这个id和chatid，本地更改缓存的chatid】
@property(nonatomic,strong)NSString *appMsgId;

@property (nonatomic, copy) NSString *strIcon;
@property (nonatomic, copy) NSString *strId;//名片userid
@property (nonatomic, copy) NSString *strTime;//消息左下角时间
@property (nonatomic, copy) NSString *strTimeHeader;//消息头上时间
@property (nonatomic, copy) NSString *strName;


@property (nonatomic, copy) NSString *strContent;
@property (nonatomic, copy) UIImage  *picture;
@property (nonatomic, copy) NSString  *pictureUrl;//名片昵称
//图片id 【用于转发传给服务器】
@property (nonatomic, copy) NSString  *fileId;//名片头像
//图片宽高比例
@property (nonatomic, assign) CGFloat pictureScale;
//图片缓存地址
@property (nonatomic, copy) NSString *cachePicPath;
//语音
@property (nonatomic, copy) NSData   *voice;
@property (nonatomic, copy) NSString *strVoiceTime;//名片用户名

@property (nonatomic, assign) MessageType type;
@property (nonatomic, assign) MessageFrom from;
//显示时间 侧边的
@property (nonatomic, assign) BOOL showDateLabel;

//type 拉人进群还是二维码进群 0为拉人 1为二维码 3为拉人消息【管理员】 4为扫码二维码消息【管理员】
@property (nonatomic, copy) NSString *pullType;
//拉人者
@property (nonatomic, copy) NSString *invitor;
//被拉者
@property (nonatomic, copy) NSString *pulledMemberString;


//是否为系统通知 0不是 1是
@property (nonatomic, copy) NSString *IsIsSystemPush;



//单聊红包金额
@property (nonatomic, copy) NSString *priceAccount;
@property (nonatomic, copy) NSString *redCount;

//红包参数
@property (nonatomic, copy) NSString *redpacketString;

//红包 是否被点击过 点击过则为1，没有点击过则为其他
@property (nonatomic, copy) NSString *redIsTouched;


//当为自己发消息，需要开始记录失败状态 0位成功 1为失败
@property (nonatomic, copy) NSString *failStatus;

//是否为选中状态 【编辑删除的时候会用到】
@property (nonatomic, assign) BOOL IsSelected;

//是否来自web的消息
@property (nonatomic, assign) BOOL IsFromWeb;






- (void)setWithDict:(NSDictionary *)dict;

- (void)minuteOffSetStart:(NSString *)start end:(NSString *)end;

@end
