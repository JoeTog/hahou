//
//  RPFPacket.m
//  NIM
//
//  Created by King on 2019/1/30.
//  Copyright © 2019年 Netease. All rights reserved.
//

#import "RPFPacket.h"
#import "RPFSendRedPacketVC.h"
#import "RPFRedpacketDetailVC.h"
#import "RPFOpenPacketViewController.h"
#import "RPFRedpacketDetailVC.h"


@implementation RPFPacket

/**
 *  发红包
 *
 *  @param viewController 当前视图
 *  @param thirdToken     三方签名令牌
 *  @param isGroup        是否为群组红包
 *  @param receiveID      接受者ID（单人红包：接受者用户唯一标识；群红包：群组ID，唯一标识）
 *  @param userName       发送者昵称
 *  @param userHeadLink   发送者头像链接
 *  @param userId         发送者ID
 *  @param groupNum       群人数(个人红包可不传)
 *
 *  @discussion      三方签名令牌（服务端计算后给到app，服务端算法为md5（custUid+appsecret））
 */
- (void)doActionPresentSendRedEnvelopeViewController:(UIViewController *)viewController thirdToken:(NSString *)thirdToken withGroup:(BOOL)isGroup receiveID:(NSString *)receiveID sendUserName:(NSString *)userName sendUserHead:(NSString *)userHeadLink sendUserID:(NSString *)userId groupNumber:(NSString *)groupNum appKey:(NSString *)appkey
{
    RPFSendRedPacketVC * srpVC = [[RPFSendRedPacketVC alloc] init];
    //srpVC.sessionId = receiveID;
    srpVC.isGroup = isGroup;
    //srpVC.userId = userId;
    //srpVC.userName = userName;
    //srpVC.userHeadLink= userHeadLink;
    //srpVC.thirdToken = thirdToken;
    //srpVC.groupNum = groupNum;
    //srpVC.appkey = appkey;
    
    if(isGroup)
    {
        srpVC.toGroupId = receiveID;
        srpVC.toUserId = @"";
    }
    else
    {
        srpVC.toGroupId = @"";
        srpVC.toUserId = receiveID;
    }
    srpVC.groupNum = groupNum;
    /*
     kjrmfStatCancel = 0,     // 取消发送，用户行为
     kjrmfStatSucess = 1,     // 红包发送成功
     kjrmfStatUnknow,         // 其他
     --------------------------------------
     RedPacketTypeSingle = 1,/ 单人红包 /
     RedPacketTypeGroupPin,/ 群拼手气 /
     RedPacketTypeGroupNormal,/ 群普通 /
     */
    
    //红包发送结束的block
    //这里是代理回调 暂时没有作用
    srpVC.sendRPFinishBlock = ^(NSString * _Nonnull envId, NSString * _Nonnull envName, NSString * _Nonnull envMsg, int jrmfStat, int type) {
        
        
        if(type==0)
        {
            type = 1;
        }
        else if(type==1)
        {
            type = 2;
        }
        
        if(jrmfStat)
        {
            
        }
        jrmfSendStatus state = kjrmfStatCancel;
        if (jrmfStat == 0) {
            state = kjrmfStatCancel;
        }else if(jrmfStat == 1){
            state = kjrmfStatSucess;
        }
        
        JrmfRedPacketType typeee = RedPacketTypeGroupNormal;
        if (type == 1) {
            typeee = RedPacketTypeSingle;
        }else if(type == 1){
            typeee = RedPacketTypeGroupPin;
        }
        
        //调用红包发送结束的代理方法
        [_delegate dojrmfActionDidSendEnvelopedWithID:envId Name:envName Message:envMsg Stat:state packType:typeee];
        
    };
    
    if(viewController)
    {
        if (@available(iOS 13.0, *)) {
            srpVC.modalPresentationStyle =UIModalPresentationFullScreen;
        }
        [viewController presentViewController:srpVC animated:YES completion:^{
            NSLog(@"in--SendRedPacketVC");
            
        }];
    }
    
}

+ (NSString *)getCurrentVersion
{
    return @"0.1";
}


/**
 *  拆红包
 *
 *  @param viewController   当前视图
 *  @param thirdToken       三方签名令牌
 *  @param userName         当前操作用户姓名
 *  @param userHeadLink     头像链接
 *  @param userId           当前操作用户ID
 *  @param envelopeId       红包ID
 *  @param isGroup          是否为群组红包
 *
 *  @discussion      三方签名令牌（服务端计算后给到app，服务端算法为md5（custUid+appsecret））
 */
- (void)doActionPresentOpenViewController:(UIViewController *)viewController thirdToken:(NSString *)thirdToken withUserName:(NSString *)userName userHead:(NSString *)userHeadLink userID:(NSString *)userId envelopeID:(NSString *)envelopeId isGroup:(BOOL)isGroup appKey:(NSString *)appkey groupId:(NSString *)groupId
{
    //领取红包 弹窗
    RPFOpenPacketViewController * openVC = [[RPFOpenPacketViewController alloc] initWithNibName:@"RPFOpenPacketViewController" bundle:nil];
    openVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    openVC.thirdToken = thirdToken?thirdToken:@"";
    openVC.userName = userName;
    openVC.sendUserId = userId;//发包人的id，用于点击叉号后， 设置正在聊天中
    openVC.userHeadUrl = userHeadLink;
    openVC.redpacketId = envelopeId;//
    openVC.isGroup = isGroup;
    openVC.appkey = appkey;
    openVC.groupId = groupId;//
    if(!isGroup){
        openVC.groupId = @"";//
    }
    
    openVC.openRPFinishBlock = ^(BOOL isDone) {
        [_delegate dojrmfActionOpenPacketSuccessWithGetDone:isDone];
    };
    
    if(viewController)
    {
        if (@available(iOS 13.0, *)) {
            //
//            openVC.modalPresentationStyle =UIModalPresentationOverFullScreen;
            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
            NSArray *viewcontrollers=currentVC.navigationController.viewControllers;
            if (viewcontrollers.count > 1) {
                NSLog(@"");
                } else {
                    //present方式
                    openVC.modalPresentationStyle = UIModalPresentationFullScreen;  // 修改默认值
                }
            
//            openVC.modalPresentationStyle =UIModalPresentationFullScreen;//diss回去直接到登陆界面了
        }
        [viewController presentViewController:openVC animated:YES completion:^{
            NSLog(@"in--SendRedPacketVC");
            
        }];
    }
    
}

/**
 查看红包领取详情 不走
 
 @param userId          用户ID
 @param packetId        红包ID
 @param thirdToken      三方签名令牌
 */
- (void)doActionPresentPacketDetailInViewWithUserID:(NSString *)userId packetID:(NSString *)packetId thirdToken:(NSString *)thirdToken appKey:(NSString *)appkey currentViewController:(UIViewController *)curVC
{
    RPFRedpacketDetailVC * vc = [[RPFRedpacketDetailVC alloc] init];
    //vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    vc.thirdToken = thirdToken;
    vc.userId = userId;
    vc.redpacketId = packetId;
    vc.appkey = appkey;
    
    if(curVC)
    {
        if (@available(iOS 13.0, *)) {
            vc.modalPresentationStyle =UIModalPresentationFullScreen;
        }
        [curVC presentViewController:vc animated:YES completion:^{
            NSLog(@"in--RPFRedpacketDetailVC");
            
        }];
    }

}

@end
