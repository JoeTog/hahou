//
//  NewHomeEntity.h
//  nationalFitness
//
//  Created by 童杰 on 2017/2/25.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewHomeEntity : NSObject




@end

//好友列表
@interface FriendListEntity : NSObject

@property(nonatomic,strong)NSString *friend_userid;

@property(nonatomic,strong)NSString *user_id;

//朋友名
@property(nonatomic,strong)NSString *friend_username;

//更新时间
@property(nonatomic,strong)NSString *updatetime;

//建立时间
@property(nonatomic,strong)NSString *createtime;

//昵称
@property(nonatomic,strong)NSString *nickName;

//头像
@property(nonatomic,strong)NSString *headImage;

//群组相关
//是否退群 0没 1退群
@property(nonatomic,strong)NSString *exit_group;

//退群时间
@property(nonatomic,strong)NSString *exit_time;

//所在群id
@property(nonatomic,strong)NSString *group_id;

//在群里面的名字
@property(nonatomic,strong)NSString *in_group_name;

//是否为管理员 0是 1不是
@property(nonatomic,strong)NSString *is_admin;

//是否为创建者 0是 1不是
@property(nonatomic,strong)NSString *is_creator;

//加群时间
@property(nonatomic,strong)NSString *join_time;

//
//@property(nonatomic,strong)NSString *user_id;

//原来名字
@property(nonatomic,strong)NSString *user_name;


@end


#pragma mark - 好友添加通知
//好友添加通知列表 【申请人列表】
@interface FriendAddListEntity : NSObject

//id
@property(nonatomic,strong)NSString *addId;

//时间
@property(nonatomic,strong)NSString *send_time;
//头像
@property(nonatomic,strong)NSString *photo;
//发送人的名字
@property(nonatomic,strong)NSString *send_user_name;
//发送人的昵称
@property(nonatomic,strong)NSString *send_nick_name;
//发送人的id
@property(nonatomic,strong)NSString *send_user_id;

//接受人的名字
@property(nonatomic,strong)NSString *receive_user_name;


//接受人的id
@property(nonatomic,strong)NSString *receive_user_id;

//结束时间
@property(nonatomic,strong)NSString *finished_time;

//状态
@property(nonatomic,strong)NSString *status;

//错误信息
@property(nonatomic,strong)NSString *wrongMessage;

//是否已读
@property(nonatomic,strong)NSString *isRead;


//是否是群通知
@property(nonatomic,strong)NSString *IsGroup;
//群组id
@property(nonatomic,strong)NSString *group_id;
//群组id
@property(nonatomic,strong)NSString *group_name;

//邀请人id
@property(nonatomic,strong)NSString *who_invite_user_id;
//邀请人
@property(nonatomic,strong)NSString *who_invite_user_name;
@property(nonatomic,strong)NSString *who_invite_user_nickname;

//被邀请人id
@property(nonatomic,strong)NSString *user_id;
//被邀请人
@property(nonatomic,strong)NSString *user_name;
@property(nonatomic,strong)NSString *user_nickname;





@end

//回复操作通知  可能是错误 可能是成功提示
@interface WrongMessageAddFriendEntity : NSObject

//信息
@property(nonatomic,strong)NSString *backMessage;

//成功还是失败
@property(nonatomic)BOOL IsSuccess;

// 信息类型 1接受好友请求成功 2拒绝成功
@property(nonatomic,strong)NSString *messageType;


//id
@property(nonatomic,strong)NSString *backId;

//name
@property(nonatomic,strong)NSString *backName;

@end


//群组成员列表
@interface GroupMemberEntity : NSObject

@property(nonatomic,strong)NSString *user_id;

//更新时间
@property(nonatomic,strong)NSString *updatetime;

//建立时间
@property(nonatomic,strong)NSString *createtime;

//群组相关
//是否退群 0没 1退群
@property(nonatomic,strong)NSString *exit_group;

//退群时间
@property(nonatomic,strong)NSString *exit_time;

//所在群id
@property(nonatomic,strong)NSString *group_id;

//在群里面的名字
@property(nonatomic,strong)NSString *in_group_name;

//是否为管理员 0是 1不是
@property(nonatomic,strong)NSString *is_admin;

//是否为创建者 0是 1不是
@property(nonatomic,strong)NSString *is_creator;

//加群时间
@property(nonatomic,strong)NSString *join_time;

//原来名字
@property(nonatomic,strong)NSString *user_name;


@end

//搜索好友返回
@interface FriendSearchResultEntity : NSObject

//
@property(nonatomic,strong)NSString *friendId;

//
@property(nonatomic,strong)NSString *name;

//
@property(nonatomic,strong)NSString *nickname;

//
@property(nonatomic,strong)NSString *photo;


//
@property(nonatomic,strong)NSString *userAndNickName;

@end


