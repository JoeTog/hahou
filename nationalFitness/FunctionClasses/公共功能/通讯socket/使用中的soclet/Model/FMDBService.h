//
//  FMDBService.h
//  nationalFitness
//
//  Created by Joe on 2017/9/1.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageEntity.h"
#import "NFMyManage.h"
#import "NewHomeEntity.h"
#import "ZJContact.h"
#import "NFbaseViewController.h"
#import "MessageParser.h"

@interface FMDBService : NSObject


//懒加载
//群组实体
@property (strong, nonatomic) GroupCreateSuccessEntity *chatCreateSuccessEntity;
//用于缓存在会话用 【需要从上面实体取值】
@property (strong, nonatomic) MessageChatListEntity *messageChatListEntity;

@property (copy, nonatomic) NSMutableArray *groupDetailAndMemberArr;

@property (strong, nonatomic) NFMyManage *myManage;



#pragma mark -  根据 groupid 取出群组详情、成员缓存
-(NSArray *)getGroupDetailEntityAndMemberListWithGroupId:(NSString *)groupId;

#pragma mark -  缓存群组详情 群详情【@[群组成员]】
-(void)cacheGroupDetail:(GroupCreateSuccessEntity *)groupEntity;

#pragma mark - 创建群组成功 缓存到会话列表 cacheChatList
-(void)cacheChatGroupCreateList:(GroupCreateSuccessEntity *)entity;


//缓存群组【@[群组成员]】
-(void)cacheGroupMemberWith:(ZJContact *)contact AndGroupId:(NSString *)groupid;
    
    
#pragma mark - 发送单聊消息 缓存到会话列表
-(void)cacheChatListWithZJContact:(ZJContact *)contact AndDic:(NSDictionary *)dict;

#pragma mark - 收到群组消息 更改会话列表群组缓存
-(void)receiveGroupMessageChangeChatListCache:(NSDictionary *)resulyDict;

#pragma mark - 更改数据库数据
-(void)changeFMDBData:(id)entity KeyWordKey:(NSString *)key KeyWordValue:(NSString *)keyValue FMDBID:(NSString *)fmdbId TableName:(NSString *)tableName;

#pragma mark - 更改数据库数据 两个条件
-(void)changeFMDBData:(id)entity KeyWordKey:(NSString *)key KeyWordValue:(NSString *)keyValue FMDBID:(NSString *)fmdbId secondKeyWordKey:(NSString *)secondKey secondKeyWordValue:(NSString *)secondKeyValue TableName:(NSString *)tableName;

#pragma mark - 根据会话列表两个参数将未读设置为0
-(void)ConversationListUnReadSetZeroWithGroupId:(NSString *)groupId AndGroupName:(NSString *)groupName;

#pragma mark - 根据字典转 会话列表实体MessageChatListEntity
-(MessageChatListEntity *)returnMessageChatListEntityFromDict:(NSDictionary *)dict;

#pragma mark - 缓存ZJContact联系人到 联系人缓存
-(void)cacheZJContactListWithArr:(NSArray *)ZJContactArr;

#pragma mark - 插入一条消息到某个单聊表
-(void)insertAMessageToSingleChatTable:(NSString *)table AndDic:(NSDictionary *)dic;
    
#pragma mark - 数据库是否存在某群组聊天表
-(void)IsExistGroupChatHistory:(NSString *)groupId ISNeedAppend:(BOOL)IsNeed;

#pragma mark - 数据库是否存在 和某人聊天表
-(void)IsExistSingleChatHistory:(NSString *)friendId;

#pragma mark - 检查联系人列表
-(void)IsExistLianxirenLieBiao;

#pragma mark - 检查隐藏联系人表
-(void)IsExistYinCangLianxirenLieBiao;

#pragma mark - 检查申请与通知表
-(void)IsExistShenQingTongZhi;

#pragma mark - 检查群组列表 表
-(void)IsExistQunzuLiebiao;

#pragma mark - 检查会话列表 表
-(void)IsExistHuihualiebiao;
#pragma mark - 检查群组详情 表
-(void)IsExistGroupDetailTable;
#pragma mark - 检查群组成员 表
-(void)IsExistGroupMemberTable;

#pragma mark - UUMessageFrame转MessageChatEntity
-(MessageChatEntity *)UUMessageFrameToMessageChatEntity:(UUMessageFrame *)messageFrame;

#pragma mark - MessageChatEntity转UUMessageFrame


#pragma mark -  获取联系人列表
-(NSArray *)getLianxirenList;
#pragma mark -  传入 ZJContact 传出 是否有备注的 ZJContact
-(ZJContact *)checkContactIsHaveCommmentname:(ZJContact *)outContact;

#pragma mark -  根据userid，查找本地是否有该联系人
-(NSArray *)checkContactWithId:(NSString * )userid;



#pragma mark - 根据收到的单聊dict 缓存单聊消息到本地 收到web端消息
-(void)addSingleSpecifiedItem:(NSDictionary *)dic;











@end
