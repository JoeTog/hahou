//
//  MessageEntity.h
//  nationalFitness
//
//  Created by Joe on 2017/6/28.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NFBaseEntity.h"
#import "ChatModel.h"

@interface MessageEntity : NFBaseEntity

@end


//聊天相关实体 加字段需要在登录界面setMineSetAbout中更改
@interface MessageChatEntity : NFBaseEntity

//
//@property(nonatomic,strong)NSString *testid;

//pkid
@property(nonatomic,strong)NSString *pkid;

//是否为自己的消息  0是 1不是
@property(nonatomic,strong)NSString *isSelf;


//chatid 消息id
@property(nonatomic,strong)NSString *chatId;

//app本地的 消息id 【用于发送消息给服务器后 服务器返回这个id和chatid，本地更改缓存的chatid】
@property(nonatomic,strong)NSString *appMsgId;

//头像 群组会话用得到【点击群成员 到详情】
@property(nonatomic,strong)NSString *headPicPath;

// 单聊 发送人id。群聊 发送人id
@property(nonatomic,strong)NSString *user_id;

// 单聊 发送人用户名。群聊 发送人用户名
@property(nonatomic,strong)NSString *user_name;

// 单聊 发送人昵称。群聊 发送人昵称
@property(nonatomic,strong)NSString *nickName;

// 群聊 发送人昵称。群聊 发送人昵称 【当有备注的情况下，记住群内昵称或者昵称】
@property(nonatomic,strong)NSString *originalNickName;


//单聊 接受人id。群聊 群组id
//@property(nonatomic,strong)NSString *receive_user_id;

//单聊 接受人用户名。群聊 群组名／昵称
//@property(nonatomic,strong)NSString *receive_user_name;


//
@property(nonatomic,strong)NSString *message_content;

//
//@property(nonatomic,strong)NSString *send_time;

//
//@property(nonatomic,strong)NSString *message_length;

//
//@property(nonatomic)BOOL is_receive_message;

//
//@property(nonatomic)BOOL is_message_read;

//
@property(nonatomic,strong)NSString *message_read_time;

//section头显示的时间
@property(nonatomic,strong)NSString *create_time_head;

//消息傍边显示的时间
@property(nonatomic,strong)NSString *create_time;

//warning
//@property(nonatomic,strong)NSString *update_time;

//月后隐藏字段 1隐藏
@property(nonatomic,strong)NSString *yuehouYinCang;

//关机删除字段 0删除 1不删除
@property(nonatomic,strong)NSString *guanjiShanChu;

//接收到消息的时间 
@property(nonatomic,assign)NSInteger localReceiveTime;

//接收到消息的时间
@property(nonatomic,copy)NSString *localReceiveTimeString;

//语音data
@property (nonatomic, copy) NSData   *voiceData;

//语音时间
@property (nonatomic, copy) NSString *strVoiceTime;

//消息类型 0文字 1图片 2语音 3红包  4 名片    5红包领取记录 6转账 7系统消息
@property (nonatomic, copy) NSString *type;

//红包金额
//@property (nonatomic, copy) NSString *redPrice;

//红包个数 群组菜大于1
//@property (nonatomic, copy) NSString *redCount;

//消息类型 0文字 1图片 2语音 3红包 4转账 
@property (nonatomic, copy) NSString *msgType;

//图片id 【用于传给服务器】
@property (nonatomic, copy) NSString *fileId;
//图片
//@property (nonatomic, copy) NSData *pictureData;

//图片宽高比例
@property (nonatomic, assign) CGFloat pictureScale;

//图片image
@property (nonatomic, copy) UIImage *picture;

//图片缓存地址
@property (nonatomic, copy) NSString *pictureUrl;

//图片缓存地址
//@property (nonatomic, copy) NSString *cachePicPath;

//类型 yes为单聊 no为群聊  暂时无用
@property(nonatomic)BOOL IsSingleChat;

//拉人者
@property (nonatomic, copy) NSString *invitor;
//被拉者
@property (nonatomic, copy) NSString *pulledMemberString;
//type 拉人进群还是二维码进群 1为二维码  3为 管理员收到 进群申请
@property (nonatomic, copy) NSString *pullType;

//当为自己发消息，需要开始记录失败状态  成功为0  失败为1
@property (nonatomic, copy) NSString *failStatus;


//红包
@property (nonatomic, copy) NSString *redpacketString;


//红包 是否被点击过 点击过则为1，没有点击过则为其他
@property (nonatomic, copy) NSString *redIsTouched;

//红包
@property (nonatomic, copy) NSDictionary *redpacketDict;


@end

//会话列表  加字段需要在登录界面setMineSetAbout中更改
@interface MessageChatListEntity : NFBaseEntity


//测试
//@property(nonatomic,strong)NSString *ceshiString;

//会话id 群组会话id
@property(nonatomic,strong)NSString *conversationId;

//群人数
//@property(nonatomic,strong)NSString *groupTotalNum;

//receive_user_name
@property(nonatomic,strong)NSString *receive_user_name;

//id mohu
//@property(nonatomic,strong)NSString *ChatListId;

//时间
//@property(nonatomic,strong)NSString *messageTime;

//标题
//@property(nonatomic,strong)NSString *messageTitle;

//头像
@property(nonatomic,strong)NSString *headPicpath;

//内容
@property(nonatomic,strong)NSString *messageContant;

//内容类型
@property(nonatomic,strong)NSString *msgType;

//user_id
//@property(nonatomic,strong)NSString *user_id;

//user_name
//@property(nonatomic,strong)NSString *user_name;

//昵称
@property(nonatomic,strong)NSString *nickName;

//receive_user_id
@property(nonatomic,strong)NSString *receive_user_id;


//last_send_time
@property(nonatomic,strong)NSString *last_send_time;

//last_message_id
@property(nonatomic,strong)NSString *last_message_id;

//last_send_message
@property(nonatomic,strong)NSString *last_send_message;

//message_count
//@property(nonatomic,strong)NSString *message_count;

//unread_message_count
@property(nonatomic,copy)NSString *unread_message_count;

//comment
//@property(nonatomic,strong)NSString *comment;

//create_time
//@property(nonatomic,strong)NSString *create_time;

//update_time
@property(nonatomic,strong)NSString *update_time;

//月后隐藏字段 1隐藏
@property(nonatomic,strong)NSString *yuehouYinCang;

//关机删除字段 0删除
@property(nonatomic,strong)NSString *guanjiShanChu;

//接收到消息的时间
@property(nonatomic,strong)NSString *localReceiveTime;

//接收到消息的时间
@property(nonatomic,copy)NSString *localReceiveTimeString;

//是否为顶置
@property(nonatomic)BOOL IsUpSet;

//类型 yes为单聊 no为群聊 
@property(nonatomic)BOOL IsSingleChat;

//原始穿过来的time 用来进行排序
@property(nonatomic,copy)NSString *originTimeString;


//类型 yes为不允许通知声音 no为允许通知声音
@property(nonatomic)BOOL IsDisturb;


//是否请求消息历史
@property(nonatomic,strong)NSString *IsNotRequestHistory;

//艾特的 消息id
//@property(nonatomic,copy)NSString *aiteLastMessageId;



@end


//群组列表
@interface GroupListEntity : NSObject

//群组ids
@property(nonatomic,strong)NSString *groupId;

//群组名
@property(nonatomic,strong)NSString *groupName;

//总人数
@property(nonatomic,strong)NSString *groupTotalNum;

//建立时间
@property(nonatomic,strong)NSString *groupCreateTime;


@property(nonatomic,strong)NSString *groupPhoto;


@end





//群组实体
@interface GroupChatEntity : NFBaseEntity
//
@property (copy, nonatomic) NSString *iconUrl;
//id
@property (strong, nonatomic) NSString *groupChatId;

@property (strong, nonatomic) NSString *createTime;

//原始名
@property (strong, nonatomic) NSString *group_username;



@property(nonatomic,copy)NSArray *groupMemmberArr;

//name
@property(nonatomic,strong)NSString *OverHeadName;


//操作人信息





@end

//创建群组成功 /群详情
@interface GroupCreateSuccessEntity : NFBaseEntity

//群组id
@property(nonatomic,strong)NSString *groupId;

//群组头像
@property(nonatomic,strong)NSString *groupHeadPic;

@property (strong, nonatomic) NSString *createTime;

//创建者id
@property(nonatomic,strong)NSString *creatorId;

//创建者用户名
@property(nonatomic,strong)NSString *creatorName;

//是否为创建者
//@property(nonatomic)BOOL IsCreator;

//群名称
@property(nonatomic,strong)NSString *groupName;

//群组成员 zjcontact
@property(nonatomic,copy)NSArray *groupAllUser;

//群总人数
@property(nonatomic,strong)NSString *groupTotalNum;

//操作人信息
//是否推送
@property(nonatomic,copy)NSString *allow_push;
//是否退群 0
@property(nonatomic,copy)NSString *exit_group;
//退群时间
@property(nonatomic,copy)NSString *exit_time;
//在群组里面名字
@property(nonatomic,copy)NSString *in_group_name;
//1表示该成员是管理员
@property(nonatomic,copy)NSString *is_admin;
//1表示该成员是创建者
@property(nonatomic,copy)NSString *is_creator;
//加群时间
@property(nonatomic,copy)NSString *join_time;
//操作人id
@property(nonatomic,copy)NSString *user_id;
//操作人 用户名
@property(nonatomic,copy)NSString *user_name;

//是否保存群
@property(nonatomic,copy)NSString *save_group;

//是否全体禁言
@property(nonatomic,copy)NSString *isMsgForbidden;

//是否群隐私
@property(nonatomic,copy)NSString *groupSecret ;


//是否群验证
@property(nonatomic,copy)NSString *needAllow ;


//群公告
@property(nonatomic,copy)NSString *notice ;



@end


//单聊详情
@interface SingleDetailEntity : NSObject

//拉黑返回还是取消拉黑返回
@property(nonatomic)BOOL IsPullBlack;

//是否加入黑名单
@property(nonatomic)BOOL IsInBlack;
//备注
@property(nonatomic,copy)NSString *remarkName;


@end


//红包消息 实体
@interface RedMessageEntity : NSObject

@property(nonatomic, copy)NSString * userId;
@property(nonatomic, copy)NSString * userName;
@property(nonatomic, copy)NSString * sendUserId;
@property(nonatomic, copy)NSString * userHeadUrl;
@property(nonatomic, copy)NSString * wishContent;
@property(nonatomic, copy)NSString * redpacketId;
@property(nonatomic, copy)NSString * thirdToken;
@property(nonatomic, assign)BOOL isGroup;
@property(nonatomic, copy)NSString * appkey;
@property(nonatomic, copy)NSString * groupId;



@end

//红包实体
@interface RedEntity : NSObject

@property(nonatomic,strong)NSString *redType; //红包类型  0单聊红包。1群聊红包

@property(nonatomic,strong)NSString *redPacketCount; //红包个数

@property(nonatomic,strong)NSString *redPacketTotalPrice; //红包总金额

@property(nonatomic,strong)NSString *redPacketText; //附加文字




@property(nonatomic, copy)NSString * userId;
@property(nonatomic, copy)NSString * sendUserId;

@property(nonatomic, copy)NSString * userName;
@property(nonatomic, copy)NSString * userHeadUrl;
@property(nonatomic, copy)NSString * wishContent;
@property(nonatomic, copy)NSString * redpacketId;
@property(nonatomic, copy)NSString * thirdToken;
@property(nonatomic, assign)BOOL isGroup;
@property(nonatomic, copy)NSString * appkey;
@property(nonatomic, copy)NSString * groupId;




@end

















