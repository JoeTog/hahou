//
//  NTESRedPacketManager.m
//  NIM
//
//  Created by chris on 2017/7/17.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESRedPacketManager.h"
//#import "JRMFHeader.h"
//#import "NTESSessionUtil.h"
//#import "NTESMainTabController.h"
#import "UIView+Toast.h"
//#import "NTESRedPacketAttachment.h"
//#import "NTESRedPacketTipAttachment.h"
//#import "NTESSessionMsgConverter.h"
//#import "NTESDemoConfig.h"
#import "RPFPacket.h"
#import "JRMFSington.h"
//#import "NTESLoginManager.h"

//#define THIRD_TOKEN [[NTESLoginManager sharedManager] currentLoginData].token
#define THIRD_TOKEN @""

@interface NTESRedPacketManager()<jrmfManagerDelegate>
{
//    NIMSession *_currentSession;
    NSString *_currentSession;
    
    NSString *_currentRedpacketId;
    NSString *_currentRedpacketFrom;
    
    BOOL _onceToken;
}

@end

@implementation NTESRedPacketManager

+ (instancetype)sharedManager
{
    static NTESRedPacketManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NTESRedPacketManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        //[[NIMSDK sharedSDK].loginManager addDelegate:self];
//        extern NSString *NTESNotificationLogout;
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLogout:) name:NTESNotificationLogout object:nil];
    }
    return self;
}

- (void)dealloc
{
   // [[NIMSDK sharedSDK].loginManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)start
{
//    DDLogInfo(@"RedPacketManager setup");
//    DDLogInfo(@"start jrmf packet, current version: %@",[RPFPacket getCurrentVersion]);
}

- (void)updateUserInfo
{
//    NSString *me = [[NIMSDK sharedSDK].loginManager currentAccount];
//    NSString *nickName = [NTESSessionUtil showNick:me inSession:nil];
//    NSString *headUrl = [[NIMKit sharedKit] infoByUser:me option:nil].avatarUrlString;

//    [RPFPacket updateUserMsgWithUserId:me userName:nickName userHead:headUrl thirdToken:[JRMFSington GetPacketSington].JrmfThirdToken completion:^(NSError *error, NSDictionary *resultDic) {
//        DDLogInfo(@"red packet update user info complete, error : %@",error);
//    }];
}

- (void)sendRedPacket:(NSDictionary *)session
{
    RPFPacket *jrmf = [[RPFPacket alloc] init];
    jrmf.delegate = self;
//    NSString *me = [[NIMSDK sharedSDK].loginManager currentAccount];
//    NSString *nickName = [NTESSessionUtil showNick:me inSession:session];
//    NSString *headUrl = [[NIMKit sharedKit] infoByUser:me option:nil].avatarUrlString;
//
//    NIMTeam *team = nil;
//    if (session.sessionType == NIMSessionTypeTeam)
//    {
//        if ([[NIMSDK sharedSDK].teamManager isMyTeam:session.sessionId])
//        {
//            team = [[NIMSDK sharedSDK].teamManager teamById:session.sessionId];
//        }
//        else
//        {
//            [self.currentTopViewController.view makeToast:@"不在群中，无法发送红包" duration:2.0 position:CSToastPositionCenter];
//        }
//    }
    
    
    _currentSession = [session objectForKey:@"groupId"];
    
    
//    NSString *appKey = [[NTESDemoConfig sharedConfig] appKey];
    
    NSString *me = [session objectForKey:@""];
    NSString *nickName = [session objectForKey:@""];
    NSString *headUrl = [session objectForKey:@""];
    BOOL isGroup = YES;
    if ([[[session objectForKey:@"groupId"] description] length] == 0) {
        isGroup = NO;
        _currentSession = [session objectForKey:@"receiveId"];
    }
    NSString *appKey = [session objectForKey:@""];

    if (isGroup) {
        [jrmf doActionPresentSendRedEnvelopeViewController:[self topViewController]
                                                thirdToken:THIRD_TOKEN
                                                 withGroup:isGroup
                                                 receiveID:_currentSession
                                              sendUserName:nickName
                                              sendUserHead:headUrl
                                                sendUserID:me groupNumber:[session objectForKey:@"groupNum"] appKey:appKey];
    }else{
        [jrmf doActionPresentSendRedEnvelopeViewController:[self topViewController]
                                                thirdToken:THIRD_TOKEN
                                                 withGroup:isGroup
                                                 receiveID:_currentSession
                                              sendUserName:nickName
                                              sendUserHead:headUrl
                                                sendUserID:me groupNumber:@"" appKey:appKey];
    }
}

- (void)openRedPacket:(NSString *)redpacketId
                 from:(NSDictionary *)from
              session:(NSString *)session
{
    RPFPacket *jrmf = [[RPFPacket alloc] init];
    jrmf.delegate = self;
//    NSString *me = [[NIMSDK sharedSDK].loginManager currentAccount];
//    NSString *nickName = [NTESSessionUtil showNick:me inSession:session];
//    NSString *headUrl = [[NIMKit sharedKit] infoByUser:me option:nil].avatarUrlString;
//    BOOL isGroup = session.sessionType == NIMSessionTypeTeam;
//    NSString *appKey = [[NTESDemoConfig sharedConfig] appKey];
    

    NSString *me;
    NSString *nickName;
    NSString *headUrl ;
    BOOL isGroup = YES;
    if([from objectForKey:@"isGroup"] && [[from objectForKey:@"isGroup"] isEqualToString:@"0"]){
        isGroup = NO;
    }
    NSString *appKey = @"";
    
//    [jrmf doActionPresentOpenViewController:self.currentTopViewController thirdToken:THIRD_TOKEN withUserName:nickName userHead:headUrl userID:me envelopeID:redpacketId isGroup:isGroup appKey:appKey groupId:session.sessionId];
    [jrmf doActionPresentOpenViewController:[self topViewController] thirdToken:THIRD_TOKEN withUserName:[from objectForKey:@"name"] userHead:[from objectForKey:@"headurl"] userID:[from objectForKey:@"senduserid"] envelopeID:redpacketId isGroup:isGroup appKey:appKey groupId:session];
    
    _currentSession = session;
    _currentRedpacketId   = redpacketId;
    _currentRedpacketFrom = [from objectForKey:@"name"];
    
    //wj-开红包,参数代表红包是否被领完
    //[self dojrmfActionOpenPacketSuccessWithGetDone:NO];
//    [self showRedPacketDetail:redpacketId];
}

- (void)showRedPacketDetail:(NSString *)redPacketId
{
//    NSString *appKey = [[NTESDemoConfig sharedConfig] appKey];
    NSString *appKey = @"";

    RPFPacket *jrmf = [[RPFPacket alloc] init];
    jrmf.delegate = self;
    NSString *me ;
    [jrmf doActionPresentPacketDetailInViewWithUserID:me packetID:redPacketId thirdToken:THIRD_TOKEN appKey:appKey currentViewController:[self topViewController]];
}


#pragma mark - jrmfManagerDelegate
//红包发送成功 回调 提示发送成功吧
-(void)dojrmfActionDidSendEnvelopedWithID:(NSString *)envId Name:(NSString *)envName Message:(NSString *)envMsg Stat:(jrmfSendStatus)jrmfStat packType:(JrmfRedPacketType)type
{
    switch (jrmfStat) {
        case kjrmfStatUnknow:
            break;
        case kjrmfStatSucess:
        {
//            NTESRedPacketAttachment *attachment = [[NTESRedPacketAttachment alloc] init];
//            attachment.title = envName;
//            attachment.redPacketId = envId;
//            attachment.content = envMsg;
//            NIMMessage *message = [NTESSessionMsgConverter msgWithRedPacket:attachment];
//            [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:_currentSession error:nil];
            
            
            
            
        }
        case kjrmfStatCancel:
            //取消成功都重置会话
            _currentSession = nil;
        default:
            break;
    }
    
}


- (void)dojrmfActionDidSendEnvelopedWithID:(NSString *)envId Name:(NSString *)envName Message:(NSString *)envMsg Stat:(jrmfSendStatus)jrmfStat
{
    switch (jrmfStat) {
        case kjrmfStatUnknow:
            break;
        case kjrmfStatSucess:
        {
            
//            NTESRedPacketAttachment *attachment = [[NTESRedPacketAttachment alloc] init];
//            attachment.title = envName;
//            attachment.redPacketId = envId;
//            attachment.content = envMsg;
//            NIMMessage *message = [NTESSessionMsgConverter msgWithRedPacket:attachment];
//            [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:_currentSession error:nil];
            
        }
        case kjrmfStatCancel:
            //取消成功都重置会话
            _currentSession = nil;
        default:
            break;
    }
}

- (void)dojrmfActionOpenPacketSuccessWithGetDone:(BOOL)isDone
{    
//    NTESRedPacketTipAttachment *attachment = [[NTESRedPacketTipAttachment alloc] init];
//    attachment.isGetDone = @(isDone).description;
//    attachment.openPacketId = [[NIMSDK sharedSDK].loginManager currentAccount];
//    attachment.packetId = _currentRedpacketId;
//    attachment.sendPacketId = _currentRedpacketFrom;
//
//    [[NIMSDK sharedSDK].chatManager sendMessage:[NTESSessionMsgConverter msgWithRedPacketTip:attachment] toSession:_currentSession error:nil];
    
    _currentSession = nil;
    _currentRedpacketId   = nil;
    _currentRedpacketFrom = nil;
}

#pragma mark - NIMLoginManagerDelegate

//- (void)onLogin:(NIMLoginStep)step
//{
//    switch (step)
//    {
//        case NIMLoginStepSyncOK:
//        {
//            if (!_onceToken)
//            {
//                NIMRedPacketTokenRequest *request = [[NIMRedPacketTokenRequest alloc] init];
//                request.type = NIMRedPacketServiceTypeJRMF;
//                NSString *envelopeName = @"云信红包";
////                BOOL isOnLine = [NTESDemoConfig sharedConfig].redPacketConfig.useOnlineEnv;
//                BOOL isOnLine = YES;
////                NSString *aliPaySchemeUrl = [NTESDemoConfig sharedConfig].redPacketConfig.aliPaySchemeUrl;
////                NSString *weChatSchemeUrl = [NTESDemoConfig sharedConfig].redPacketConfig.weChatSchemeUrl;
//                NSString *aliPaySchemeUrl = @"";
//                NSString *weChatSchemeUrl = @"";
//                [[NIMSDK sharedSDK].redPacketManager fetchTokenWithRedPacketRequest:request completion:^(NSError * _Nullable error, NSString * _Nullable token) {
//                    if (!error)
//                    {
//                        [JRMFSington GetPacketSington].JrmfThirdToken = token;
//
////                        [RPFPacket instanceRPFPacketWithPartnerId:[JRMFSington GetPacketSington].JrmfPartnerId EnvelopeName:envelopeName aliPaySchemeUrl:aliPaySchemeUrl weChatSchemeUrl:weChatSchemeUrl appMothod:isOnLine];
//                    }
//                    else
//                    {
//                        DDLogError(@"fetch red packet token error : %@",error);
//                    }
//                }];
//                _onceToken = YES;
//            }
//        }
//            break;
//        default:
//            break;
//    }
//}

- (void)onLogout:(id)sender
{
    _onceToken = NO;
}


#pragma mark - open url

- (void)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
    }
    
}

- (void)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString*, id> *)options
{
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
    }
    
}

- (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return NO;
}

#pragma mark - Private
//- (UIViewController *)currentTopViewController
//{
//    UINavigationController *nav = [NTESMainTabController instance].selectedViewController;
//    UIViewController *vc = [nav isKindOfClass:[UINavigationController class]]? nav.topViewController : nav;
//    return vc;
//}


- (UIViewController*)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

@end
