//
//  RPFSendRedPacketVC.h
//  NIM
//
//  Created by King on 2019/2/2.
//  Copyright © 2019年 Netease. All rights reserved.
//

#import "BaseRPFViewController.h"

#import "MessageEntity.h"

#import "ForgetPasswordTableViewController.h"


#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

/*
 *  红包发送回调
 *
 *  @param envId    红包ID
 *  @param envName  红包名称
 *  @param envMsg   描述信息
 *  @param jrmfStat 发送状态
 *  @param type     红包类型
 
- (void)dojrmfActionDidSendEnvelopedWithID:(NSString *)envId Name:(NSString *)envName Message:(NSString *)envMsg Stat:(jrmfSendStatus)jrmfStat packType:(JrmfRedPacketType)type;
 */

//其他定义
typedef void(^SendRedPacketFinishBlock)(NSString *envId,NSString *envName,NSString *envMsg,int jrmfStat, int type);


@interface RPFSendRedPacketVC : BaseRPFViewController

@property(nonatomic, copy)NSString * sessionId;//会话id
@property(nonatomic, copy)NSString * thirdToken;//
@property(nonatomic, assign)BOOL isGroup;//
@property(nonatomic, copy)NSString * userId;//
@property(nonatomic, copy)NSString * userName;//
@property(nonatomic, copy)NSString * userHeadLink;//
@property(nonatomic, copy)NSString * groupNum;//
@property(nonatomic, copy)NSString * appkey;//
@property(nonatomic, copy)NSString * toGroupId;//
@property(nonatomic, copy)NSString * toUserId;//




@property(nonatomic, copy)SendRedPacketFinishBlock sendRPFinishBlock;
/*
 *  @param viewController 当前视图
 *  @param thirdToken     三方签名令牌
 *  @param isGroup        是否为群组红包
 *  @param receiveID      接受者ID（单人红包：接受者用户唯一标识；群红包：群组ID，唯一标识）
 *  @param userName       发送者昵称
 *  @param userHeadLink   发送者头像链接
 *  @param userId         发送者ID
 *  @param groupNum       群人数(个人红包可不传)
 *
 */



//群组创建成功实体 使用中
@property(nonatomic,strong)GroupCreateSuccessEntity *groupCreateSEntity;


@end


NS_ASSUME_NONNULL_END
