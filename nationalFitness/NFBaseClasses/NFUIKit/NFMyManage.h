//
//  NFMyManage.h
//  nationalFitness
//
//  Created by Joe on 2017/8/1.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageEntity.h"
#import "FMLinkLabel.h"
#import "JQFMDB.h"
#import "PopMessageView.h"
#import "NSDate+RYChat.h"
#import "SoundControlSingle.h"
#import "UUMessageFrame.h"
#import "UUMessage.h"
#import "FLStatusBarHUD.h"
#import "ZJContact.h"



@interface NFMyManage : NSObject

//群聊详情实体 相关
@property (nonatomic, strong) GroupCreateSuccessEntity *groupCreateSuccess;





//将数字转成字符串
-(NSString *)NumToString:(NSString *)num;

//是否含有数字 或字母 汉字 表情
//全部符合数字，表示沒有英文 1
//全部符合英文，表示沒有数字 2
//符合英文和符合数字条件的相加等于密码长度 3
//可能包含标点符号的情況，或是包含非英文的文字，这里再依照需求详细判断想呈现的错误 4
//
-(int)checkIsHaveNumAndLetter:(NSString*)password;

#pragma mark - 删除某个表某个数据
-(BOOL)deleteAPriceDataBase:(NSString *)dataBase InTable:(NSString *)tableName DataKind:(id)kind KeyName:(NSString *)keyName ValueName:(NSString *)valueName;

#pragma mark - 删除某个表某个数据两个条件
-(BOOL)deleteAPriceDataBase:(NSString *)dataBase InTable:(NSString *)tableName DataKind:(id)kind KeyName:(NSString *)keyName ValueName:(NSString *)valueName SecondKeyName:(NSString *)secondKeyName SecondValueName:(NSString *)secondValueName;


#pragma mark - 更改数据库数据
-(void)changeFMDBData:(id)entity KeyWordKey:(NSString *)key KeyWordValue:(NSString *)keyValue FMDBID:(NSString *)fmdbId TableName:(NSString *)tableName;

#pragma mark - 更改数据库数据 两个条件
-(void)changeFMDBData:(id)entity KeyWordKey:(NSString *)key KeyWordValue:(NSString *)keyValue FMDBID:(NSString *)fmdbId secondKeyWordKey:(NSString *)secondKey secondKeyWordValue:(NSString *)secondKeyValue TableName:(NSString *)tableName;
    
#pragma mark - 清空表 \ 删除表
#pragma mark - 清空表 \ 删除表
-(BOOL)clearTableWithDatabaseName:(NSString *)database tableName:(NSString *)tableName IsDelete:(BOOL)isDelete;

#pragma mark - 插入数据 只能单纯地插入数据 不可替换某个数据 不可用
//-(BOOL)insertDataToFMDBDataBase:(NSString *)database tableName:(NSString *)tableName EntityKind:(id)entity InsertDataArr:(NSArray *)dataArr;


#pragma mark - 查的话 就直接用 jqfmdb 方法
//NSArray *arrs = [jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@""];
//[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",keyName,valueName,secondKeyName,secondValueName]

#pragma mark - 设置不同颜色的label
+(FMLinkLabel *)createFMLinkLabelWithText:(NSString *)text ColorfulText:(NSString *)colorText NormalTextColor:(UIColor *)normalColor SpecialColor:(UIColor *)color Font:(NSInteger)font;


#pragma mark - 获取当前时间戳
+(NSString *)getCurrentTimeStamp;

#pragma mark - nsinteger转string 昨天
+(NSString *)timestampSwitchTime:(NSInteger)timestamp;

#pragma mark - 返回当前日期 比如 昨天
+(NSString *)getCurrentDateTimeYesterday;

#pragma mark - 根据
+(NSString *)getTimeStringWithNum:(NSInteger)timestamp ToFormat:(NSString *)format;

//取缓存某一条数据 改变某些值 再缓存
//NSString *firstKey = @"conversationId";
//NSString *firstValue = self.groupCreateSEntity.groupId;
//NSString *secondKey = @"receive_user_name";
//NSString *secondValue = self.groupCreateSEntity.groupName;
//NSArray *arrs = [jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:[NSString stringWithFormat:@"where %@ = '%@' and %@ = '%@'",firstKey,firstValue,secondKey,secondValue]];
//if (arrs.count > 0) {
//    //一般为一条数据
//    MessageChatListEntity *chatListEntity = [arrs lastObject];
//    chatListEntity.unread_message_count = @"0";
//    [[NFMyManage new] changeFMDBData:chatListEntity KeyWordKey:firstKey KeyWordValue:firstValue FMDBID:@"tongxun.sqlite" secondKeyWordKey:secondKey secondKeyWordValue:secondValue TableName:@"huihualiebiao"];
//}

#pragma mark - 获取当前controller
+ (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC;

- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC;

#pragma mark - 提醒设置
//是否允许通知 [[NFMyManage new] IsCanReveive]
-(BOOL)IsCanReveive;
//
//#pragma mark - //声音震动设置 目前只有当收到 群聊单聊消息 才有可能提示声音
////声音震动设置 [[NFMyManage new] notifySet]
-(void)notifySet;

#pragma mark - 设置弹窗 没用到
-(void)setAlertView:(NSDictionary *)msg IsRequest:(BOOL)request;

-(void)weakConnect;


+  (UIViewController *)getnextVCFrom:(UIViewController *)rootVC;

//判断是否含有表情
+ (BOOL)validateContainsEmoji:(NSString *)string ;

#pragma mark - 是否是好友
-(BOOL)IsMyFriendWithFrienid:(NSString *)friendid WithDatabaseName:(NSString *)database tableName:(NSString *)tableName;
    
    
    
@end
