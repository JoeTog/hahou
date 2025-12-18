//
//  ZJContact.h
//  ZJIndexContacts
//
//  Created by ZeroJ on 16/10/10.
//  Copyright © 2016年 ZeroJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZJContact : NSObject
//@property (copy, nonatomic) NSString *name;
//@property (strong, nonatomic) UIImage *icon;

@property (strong, nonatomic) NSString *iconUrl;

//id
//@property (strong, nonatomic) NSString *chatId;
//建立时间
//@property (strong, nonatomic) NSString *createTime;
//原始名 
@property (strong, nonatomic) NSString *friend_username;
//原始昵称
@property (strong, nonatomic) NSString *friend_originalnickname;
//昵称
@property (strong, nonatomic) NSString *friend_nickname;
//好友备注
@property (strong, nonatomic) NSString *friend_comment_name;


@property (strong, nonatomic) NSString *friend_userid;
//群聊添加成员 该成员是否可选
@property(nonatomic)BOOL IsCanSelect;
//是否已选
@property(nonatomic)BOOL IsSelect;
//是否屏蔽消息
@property(nonatomic)BOOL IsShield;
//是否屏蔽动态
@property(nonatomic)BOOL IsShieldDynamic;

//群组id
@property (strong, nonatomic) NSString *groupId;

//群组名
@property (strong, nonatomic) NSString *groupName;

//当为群组时候 存放群聊人员数组  或者在详情页请求数据，需要缓存了 放memberArr
@property(nonatomic,copy)NSArray *groupArr;

//群组成员
//更新时间
//@property(nonatomic,strong)NSString *updatetime;


//是否退群 0没 1退群
@property(nonatomic,strong)NSString *exit_group;

//退群时间
//@property(nonatomic,strong)NSString *exit_time;

//所在群id
//@property(nonatomic,strong)NSString *group_id;

//在群里面的名字
@property(nonatomic,strong)NSString *in_group_name;

//是否为管理员 1是 0不是
@property(nonatomic,strong)NSString *is_admin;

//是否为创建者 1是 0不是
@property(nonatomic,strong)NSString *is_creator;

//加群时间
//@property(nonatomic,strong)NSString *join_time;

//原来名字
@property(nonatomic,strong)NSString *user_name;

@property(nonatomic,strong)NSString *user_id;


// 搜索联系人的方法 (拼音/拼音首字母缩写/汉字)
+ (NSArray<ZJContact *> *)searchText:(NSString *)searchText inDataArray:(NSArray<ZJContact *> *)dataArray;





@end







