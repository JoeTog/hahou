//
//  SocketRequest.h
//  nationalFitness
//
//  Created by joe on 2018/1/25.
//  Copyright © 2018年 chenglong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketModel.h"
#import "JsonModel.h"
#import <UIKit/UIKit.h>
#import "sys/utsname.h"
#import <AdSupport/AdSupport.h>//获取udid

#define limitCount @"1000" //所有消息历史的分页个数 pageSize

@interface SocketRequest : NSObject


//懒加载
@property (copy, nonatomic) NSMutableDictionary *parms;    //懒加载




+(instancetype)share;

#pragma mark - 请求好友列表
-(void)getFriendList;

#pragma mark - 删除好友请求
-(void)deleteFriendRequest:(NSString *)friendId;

#pragma mark - 申请列表请求 为了显示 是否有添加好友请求
-(void)getIsExistUnReadApply;

#pragma mark - 请求申请列表
-(void)getAddFriendList;

#pragma mark - 获取会话列表请求
-(void)getConversationList;

#pragma mark - 请求已收到 单聊 群聊根据ret区分
-(void)haveReceived:(NSString *)messageId otherPartyId:(NSString *)otherId isSingle:(BOOL)ret;

#pragma mark - 请求已读群聊
-(void)readedRequest:(NSString *)messageId GroupId:(NSString *)groupId;

#pragma mark - 请求已读单聊 【左滑删除】
-(void)readedRequest:(NSString *)messageId receiveName:(NSString *)receiveName;

#pragma mark - 请求某人的个人信息
-(void)requestPersonalInfoWithID:(NSString *)friendId;

#pragma mark - 请求撤回
-(void)drowRequest:(UUMessage *)message;

#pragma mark - 请求正在输入
-(void)enteringRequesst:(ZJContact *)contact;

#pragma mark - 请求结束正在输入
-(void)enteringEndRequest:(ZJContact *)contact;

#pragma mark - 请求单聊历史消息
-(void)getSingleChatDataWithFriendEntity:(ZJContact *)contact LastChatEntity:(MessageChatEntity *)chatEntity;
    
#pragma mark - 请求群聊消息 GroupCreateSuccessEntity
-(void)getGroupChatData:(GroupCreateSuccessEntity *)groupCreateSEntity AndChatEntity:(MessageChatEntity *)chatEntity;

#pragma mark - 单聊详情 暂无接口
-(void)getSingleDetail:(ZJContact *)contact;

#pragma mark - 请求拉黑或者取消拉黑
-(void)pullBlackType:(BOOL)type FriendId:(NSString *)friendid;

#pragma mark - 请求屏蔽朋友圈
-(void)limitDynamicType:(BOOL)type;

#pragma mark - 创建群组请求 request
-(void)createGroupRequest:(NSArray *)memberArr;

#pragma mark - 群组详情请求
-(void)getGroupDetail:(NSString *)groupId;

#pragma mark - 群组详情请求 分页
-(void)getGroupDetail:(NSString *)groupId AndPage:(NSString *)page;
    
#pragma mark - 设置群组信息
-(void)setGroupInfoWithDict:(NSDictionary *)infoDict WithGroupId:(NSString *)groupId;

#pragma mark - 退出群组请求
-(void)requestExitGroup:(NSString *)groupId;

#pragma mark - 解散群组请求
-(void)requestGroupDissolute:(NSString *)groupId;

#pragma 编辑修改我的本群昵称 暂无接口
-(void)requestEditLocalGroupNickName:(NSString *)newName GroupId:(NSString *)groupId;

#pragma 保存、取消群聊到列表
-(void)saveGroupToList:(NSString *)type GroupId:(NSString *)groupId;

#pragma mark - 创建群组请求
-(void)createGroupRequest:(NSArray *)memberArr GroupCreateSuccessEntity:(GroupCreateSuccessEntity *)createSuccessE;

#pragma mark - 群主踢人
-(void)groupOwnerOutMember:(NSArray *)memberArr GroupId:(NSString *)groupId;

#pragma mark - 同意添加好友请求
-(void)acceptFriendAddRequest:(FriendAddListEntity *)entity;

#pragma mark - 请求已读申请列表
-(void)haveReadApplyListRequest;

#pragma mark - 删除、忽略该申请
-(void)ignoreApply:(FriendAddListEntity *)addEntity;

#pragma mark - 搜索好友请求
-(void)searchFriendRequest:(NSString *)keyString;
    
#pragma mark - 发送好友请求
-(void)sendFriendAddRequest:(NSString *)friendName;

#pragma mark - 请求群组
-(void)requestGroupArr;

#pragma mark - 设置头像请求
-(void)setHeadPicthWithUr:(NSString *)picPath;

#pragma mark - 退出登录 不需要收到退出消息
-(void)quitSocketRequest;

#pragma mark - 用户绑定极光id
-(void)setJPUSHServiceId;

#pragma mark - 用户清空极光id
-(void)clearJPUSHServiceId;

#pragma mark - 账号密码登录
-(void)loginWithDefaultTypeWithName:(NSString *)userName AndPassWord:(NSString *)password;
    
#pragma mark - 微信登录请求
-(void)weixinLoginRequest:(NSDictionary *)userInfo;

#pragma mark - 扫码登录
-(void)QRCodeLoginWithWebClientId:(NSString *)ClientId;



//红包

#pragma mark - 查看用户余额
-(void)checkuserAccountWithGroupId:(NSString *)groupid;

#pragma mark - 充值
-(void)rechargeWithGroupId:(NSString *)groupid rechargeUserId:(NSString *)memberId amount:(NSString *)amount;

#pragma mark - 设置支付密码
-(void)setpasswordWirhPassword:(NSString *)password;

#pragma mark - 修改支付密码
-(void)setpasswordWirhPassword:(NSString *)password AndCode:(NSString *)code;

#pragma mark - 发红包
-(void)sendredPacketFirst:(NSDictionary *)dic;

#pragma mark - 发红包
-(void)sendredPacket:(NSDictionary *)dic;

#pragma mark - 发红包 新生 一步完成
-(void)sendredPacketNew:(NSDictionary *)dic;

#pragma mark - 检查check红包
-(void)checkRedPacket:(NSDictionary *)dic;

#pragma mark - 拆红包
-(void)pickRedPacket:(NSDictionary *)dic;

#pragma mark - 修改支付密码 发送验证码
-(void)forgetPayPasswordSendCode:(NSString *)phone;

#pragma mark - 修改支付密码 请求
-(void)changePayPasswordSendCode:(NSDictionary *)dic;


#pragma mark - 数据恢复接口
#pragma mark - 请求所有单聊历史消息
-(void)getAllDataOfSingleChatWithFriendId:(NSString *)friendId FriendName:(NSString *)friendName;

#pragma mark - 请求所有单聊历史消息
-(void)getAllDataOfSingleChatWithFriendId:(NSString *)friendId FriendName:(NSString *)friendName LastMessageId:(NSString *)messageId;
    

#pragma mark - 请求所有群聊历史消息
-(void)getAllDataOfGroupChatWithGroupId:(NSString *)friendId GroupName:(NSString *)friendName;

#pragma mark - 请求所有群聊历史消息
-(void)getAllDataOfGroupChatWithGroupId:(NSString *)friendId GroupName:(NSString *)friendName LastMessageId:(NSString *)messageId;
    
    
#pragma mark - 请求所有群组
-(void)requestAllGroupArr;



#pragma 设置群禁言
-(void)forbiddenGroup:(BOOL)ret GroupId:(NSString *)groupId;

#pragma 设置群管理
-(void)manageGroup:(BOOL)ret GroupId:(NSString *)groupId AndContact:(ZJContact *)contact;

#pragma 设置群隐私
-(void)manageGroupSectet:(BOOL)ret GroupId:(NSString *)groupId;
    

#pragma 设置群免打扰
-(void)manageGroupnotpush:(BOOL)ret GroupId:(NSString *)groupId;
    

#pragma 设置好友备注
-(void)setFriendMark:(NSString *)markname FriendId:(NSString *)friendId;

#pragma 设置群内昵称
-(void)setInGroup:(NSString *)markname groupId:(NSString *)groupId;

#pragma 转让群主
-(void)groupZhuanrang:(NSString *)memberid groupId:(NSString *)groupId;


#pragma 举报
-(void)jubaoWithuserid:(NSString *)userid groupId:(NSString *)groupId Content:(NSString *)content PicArr:(NSArray *)arr;

#pragma 设置群验证
-(void)manageGroupEnterCheck:(BOOL)ret GroupId:(NSString *)groupId;
    
#pragma mark - 同意进群
-(void)acceptGroupJoinAddRequest:(FriendAddListEntity *)entity;

#pragma mark - 删除、忽略 群组成员加入申请
-(void)ignoreGroupApply:(FriendAddListEntity *)addEntity;

#pragma mark - 充值
-(void)recharge:(NSDictionary *)dict;


#pragma mark - 提现 获取 value
-(void)cashOut:(NSDictionary *)dict;


#pragma mark - 授权免密支付 获取 value
-(void)shouquanOut:(NSDictionary *)dict;


#pragma mark - 红包详情
-(void)RedPacketDetail:(NSDictionary *)dic;

#pragma mark - 支付密码
-(void)cashPassword;

#pragma mark - 零钱记录
-(void)recordMonryWithPage:(NSString *)page;


#pragma mark - 余额查询
-(void)accountDetail;

//支付 相关
#pragma mark - 获取 value
-(void)SignsRequest:(NSDictionary *)Info;


//支付 定时检查
#pragma mark - 支付 定时检查
-(void)checkTuikuanWithinfo:(NSDictionary *)info;

//提现密码设置 检查
#pragma mark - 提现密码设置 检查
-(void)tixianPwdCheck;

//免密支付设置 检查
#pragma mark - 免密支付设置 检查
-(void)mianmiPayCheck;

#pragma mark - 免密授权  验证码
-(void)noPasswordSendCode:(NSDictionary *)dic;

#pragma mark - 免密授权  验证
-(void)noPasswordOpenCode:(NSDictionary *)dic;

#pragma mark - 免密授权 取消 验证
-(void)noPasswordCloseCode:(NSDictionary *)dic;

#pragma mark - 红包记录
-(void)redRecordListReqquest:(NSDictionary *)dic;


#pragma mark - 银行卡列表
-(void)getBankCardList;

#pragma mark -    发送验证码 绑卡
-(void)bindCardSendCode:(NSDictionary *)dic;

#pragma mark -  绑卡  验证短信 并绑卡
-(void)bindCardCheckCodeAndBind:(NSDictionary *)dic;


#pragma mark -  解绑卡
-(void)catBindCard:(NSString *)cardid;

#pragma mark - 充值记录
-(void)chongzhiRecordWithPage:(NSString *)page;

#pragma mark -  账单
-(void)BillListWithPage:(NSString *)page IsSystem:(BOOL)ret;

#pragma mark - 修改支付密码 不用验证码 【设置免密后使用】
-(void)setpasswordWithPassword:(NSString *)password;

#pragma mark - 请求撤回 群聊
-(void)drowGroupRequest:(UUMessage *)message;

#pragma mark - 转账 第一步
-(void)transferFirst:(NSDictionary *)dic;

#pragma mark - 转账 第二步
-(void)transferPacketSec:(NSDictionary *)dic;

#pragma mark - 转账 新生 一步完成
-(void)transferFirstNew:(NSDictionary *)dic;

#pragma mark - 开子账户 获取
-(void)SubAccountRequest:(NSDictionary *)Info;

#pragma mark -开户 接口版
-(void)OpenAccountRequest:(NSDictionary *)Info;

#pragma mark - 子账户查询接口
-(void)SubAccountLookRequest;
    
#pragma mark - 验证支付密码
-(void)checkPayPasswordWithPassword:(NSString *)password;
    
#pragma mark - 拉黑列表
-(void)getBlackList;
    

#pragma mark - 收藏表情
-(void)collectEmoji:(NSDictionary *)Info;

#pragma mark - 删除收藏表情
-(void)deleteCollectEmoji:(NSDictionary *)Info;


#pragma mark - 请求收藏表情
-(void)requestCollectEmoji;

//getEmoji


#pragma mark - 管理员同意进群
-(void)requestAcceptJoinGroupWithInfo:(NSString *)addId;

#pragma mark - 管理员拒绝进群
-(void)requestRefuseJoinGroupWithInfo:(NSString *)addId;

#pragma mark - 实名认证发送验证码
-(void)shimingSendCode:(NSString *)code;


#pragma mark -  多信助手
-(void)helperMessageList;
    
#pragma mark -  注销多信
-(void)logoffDuoxinRequest;

#pragma mark -  会话已读
-(void)allReadRequest;
    
#pragma mark -  朋友圈评论相关
-(void)getCircleMsg;


#pragma mark -  朋友圈 评论列表
-(void)PointListRequestWithPage:(NSString *)page;
    
#pragma mark -  朋友圈评列表
-(void)getCircleUnreadMsg;


#pragma mark -   验证短信  充值
-(void)chargeMoneyCheckCodeAndBind:(NSDictionary *)dic;
#pragma mark -    发送验证码 充值
-(void)chargeMoneySendCode:(NSDictionary *)dic;







#pragma mark - 优化

#pragma mark - 请求所有群成员id
-(void)requestGroupAllMemberIdWithGroup:(NSString *)groupId;

#pragma mark - 根据群成员id数组，请求群成员信息
-(void)getUserInGroupDetail:(NSString *)groupId AndGroupuserArr:(NSArray *)arr;












#pragma mark - 测试 action
-(void)testActionaaa;





@end








