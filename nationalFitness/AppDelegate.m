//
//  AppDelegate.m
//  nationalFitness
//
//  Created by 程long on 14-10-22.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//

#import "AppDelegate.h"
//#import "NFLoginManger.h"

/**
 *  ShareSDK
 */

//#import <ShareSDK/ShareSDK.h>
//#import "WeiboSDK.h"
//#import "WXApi.h"
//#import <TencentOpenAPI/QQApiInterface.h>
//#import <TencentOpenAPI/TencentOAuth.h>

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>

#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

//微信SDK头文件
#import "WXApi.h"

//新浪微博SDK头文件
#import "WeiboSDK.h"

//appkey 1f4c03c37bf08
//appsecret d426c533ab667b82c43e0212bc8db002

/**
 *  FMDB
 */
#import "PublicDefine.h"
#import "NFDatabaseQueue.h"
/**
 *  高德地图
 */
//#import <MAMapKit/MAMapKit.h>
#include <sys/xattr.h>

#define kUpdateAlertViewTag         101

#define kLatestVersion    @"latestVersion"

#import <MediaPlayer/MediaPlayer.h>
#import "UIImageView+WebCache.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#include <sys/xattr.h>

//#import "BaiduMobStat.h"
#import "SVProgressHUD.h"

//#import "EMClient.h"

#import "AppDelegate+Parse.h"
//#import "UPPaymentControl.h"
#import "sys/utsname.h"

//极光推送
#import "JPUSHService.h"

//支付
//#import <ZFJSDK/ZFJPlugin.h>


//真后台
#import "MMPDeepSleepPreventer.h"



#define IosAppVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

//JPUSHRegisterDelegate
@interface AppDelegate ()<AVAudioPlayerDelegate,WXApiDelegate>
//让代码再后台运行
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundUpdateTask;


@end

@implementation AppDelegate{
    
    JQFMDB *jqFmdb;
    SocketRequest *socketRequest;
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
//    [self showAlertView:@"用户没有点击按钮直接点的推送消息进来的，或者该app在前台状态时接收到消息"];
//    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    //点击本地推送跳转到对应会话
    NSDictionary* info = [notification userInfo];
    ZJContact *singleChatEntity = [ZJContact new];
    singleChatEntity.friend_userid = [[info objectForKey:@"id"] description];
    singleChatEntity.friend_username = [info objectForKey:@"name"];
    
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
    MessageChatViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"MessageChatViewController"];
    toCtrol.singleContactEntity = singleChatEntity;
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    [currentVC.navigationController pushViewController:toCtrol animated:YES];
    
    //更改会话列表缓存 只是单聊
    JQFMDB *jqFmdb = [JQFMDB shareDatabase];
    __block NSArray *chatList = [NSArray new];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        chatList = [strongSelf -> jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@"where conversationId = '%@' and IsSingleChat = '%@'",singleChatEntity.friend_userid,@"1"];
    }];
    MessageChatListEntity *entity = [chatList lastObject];
    entity.unread_message_count = @"0";
    [[NFMyManage new] changeFMDBData:entity KeyWordKey:@"conversationId" KeyWordValue:singleChatEntity.friend_userid FMDBID:@"tongxun.sqlite" secondKeyWordKey:@"IsSingleChat" secondKeyWordValue:@"1" TableName:@"huihualiebiao"];
    
    
}

void UncaughtExceptionHandler(NSException *exception){
    // 可以通过exception对象获取一些崩溃信息，我们就是通过这些崩溃信息来进行解析的，例如下面的symbols数组就是我们的崩溃堆栈。
    NSArray *symbols = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    
}

#pragma mark - 注册远程通知 最下面
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);//奔溃断点
    //将app状态设置为yes 允许sendping
    [NFUserEntity shareInstance].appStatus = YES;
    self.window.backgroundColor = [UIColor whiteColor];
    
    //崩溃日志
    [Fabric with:@[[Crashlytics class]]];
    
    // 将下面C函数的函数地址当做参数
//    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
//    NSDictionary *dic=[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//    if (dic) {
////        [self.myManage notifySet];
//        NSDictionary *info = [dic objectForKey:@"extras"];
//        if ([[[info objectForKey:@"type"] description] isEqualToString:@"single"]) {
//            //当程序不在后台时
//            NSLog(@"\n\n\n预备单聊\n\n\n");
////            [self.myManage notifySet];
//            [NFUserEntity shareInstance].PushQRCode = @"2";
//            //生成跳转到单聊的实体
//            [NFUserEntity shareInstance].pushType = @"single";
//            [NFUserEntity shareInstance].pushId = [[info objectForKey:@"senderId"] description];
//        }else if ([[[info objectForKey:@"type"] description] isEqualToString:@"group"]){
//            //当程序不在后台时
//            NSLog(@"\n\n\n预备群聊\n\n\n");
//            [NFUserEntity shareInstance].PushQRCode = @"3";
//            //生成跳转到群聊的实体
//            [NFUserEntity shareInstance].pushType =@"group";
//            [NFUserEntity shareInstance].pushId = [[info objectForKey:@"groupId"] description];
//        }else if ([[[info objectForKey:@"type"] description] isEqualToString:@"apply"]){
//            //申请请求
//            if ([NFUserEntity shareInstance].PushQRCode) {
//                if ([[NFUserEntity shareInstance].PushQRCode isEqualToString:@"0"]) {
//                    //申请与通知
//                    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
//                    ApplyViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"ApplyViewController"];
//                    //点击后 红点提醒设置为no
//                    [NFUserEntity shareInstance].IsApplyAndNotify = NO;
//                    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
//                    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
//                    [currentVC.navigationController pushViewController:toCtrol animated:YES];
//                }
//            }else{
//                //在首页跳转到申请详情
//                [NFUserEntity shareInstance].PushQRCode = @"4";
//            }
//        }
//    }
    //注册本地推送
//    [self registerLocalNotification];
    
    NSString *userName = [KeepAppBox checkValueForkey:@"userName"];
    if (userName.length > 0) {
        [NFUserEntity shareInstance].userName = [KeepAppBox checkValueForkey:@"userName"];
    }
    
    
    NSString* phoneModel = [self iphoneType];
    if ([phoneModel isEqualToString:@"iPhone 6s"] ||[phoneModel isEqualToString:@"iPhone 6s Plus"] ||[phoneModel isEqualToString:@"iPhone 7"] ||[phoneModel isEqualToString:@"iPhone 7 Plus"]) {
        //快捷菜单
        UIApplicationShortcutIcon *icon1=[UIApplicationShortcutIcon iconWithTemplateImageName:@"扫一扫图标"];
        UIApplicationShortcutItem *item1=[[UIApplicationShortcutItem alloc]initWithType:@"1"
                                                                         localizedTitle:@"扫一扫"
                                                                      localizedSubtitle:nil
                                                                                   icon:icon1
                                                                               userInfo:nil];
         [[UIApplication sharedApplication] setShortcutItems:@[item1]];
    }

    //检查是否有有推送消息
//    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//    if (userInfo)
//    {
//        [NFUserEntity shareInstance].alertTitleStr = [userInfo objectForKey:@"title"];
//        [NFUserEntity shareInstance].alertHtmlStr = [userInfo objectForKey:@"messUrl"];
//    }
    
    NSString *thisAppVerson = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    //保存系统的版本号
    if (![KeepAppBox checkValueForkey:@"appVerson"])
    {
        [KeepAppBox keepVale:thisAppVerson forKey:@"appVerson"];
        DLog(@"%@",[KeepAppBox checkValueForkey:@"appVerson"]);
    }
    
    //默认经纬度
    [NFUserEntity shareInstance].userLongitude = 112.4305814012;
    [NFUserEntity shareInstance].userLatitude = 34.6240092102;
    
    //检查版本升级
    
    /**
     *  数据库
     */
    NSString *databasePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
                              stringByAppendingPathComponent: kFMDBFilename];
    
    if (![thisAppVerson isEqualToString:[KeepAppBox checkValueForkey:@"appVerson"]])
    {
        [[NSFileManager defaultManager] removeItemAtPath:databasePath error:nil];
        [KeepAppBox keepVale:thisAppVerson forKey:@"appVerson"];
        DLog(@"%@",[KeepAppBox checkValueForkey:@"appVerson"]);
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:databasePath])
    {
        NSLog(@"数据库已经存在");
    }
    else
    {
        NFDatabaseQueue *creatFMDB = [[NFDatabaseQueue alloc]init];
        [creatFMDB createAllTables];
    }
    
    application.applicationIconBadgeNumber = 0;
    
    /*
     *  注册推送通知功能
     */
    if (UIDeviceCurrentDevice >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings
                                                                             settingsForTypes:(UIUserNotificationTypeSound |
                                                                                               UIUserNotificationTypeAlert |
                                                                                               UIUserNotificationTypeBadge)
                                                                             categories:nil]];


        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        //这里还是原来的代码
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeSound)];
    }
#pragma mark - 极光推送
    [JPUSHService setupWithOption:launchOptions appKey:JPushAPPKey
                          channel:@"App Store"
                 apsForProduction:YES
            advertisingIdentifier:@""];
    
//    /**
//     *  社会化分享组件初始化
//     */
//    
//
    
    
    [WXApi registerApp:@"wx857395c70ead408f"];
    //
    [ShareSDK registerApp:@"2326177eba680" activePlatforms:@[
//                            @(SSDKPlatformTypeSinaWeibo),
//                            @(SSDKPlatformTypeMail),
//                            @(SSDKPlatformTypeSMS),
//                            @(SSDKPlatformTypeCopy),
//                            @(SSDKPlatformTypeQQ),
                            @(SSDKPlatformTypeWechat)
                            ]
                 onImport:^(SSDKPlatformType platformType)
     {
         switch (platformType)
         {
             case SSDKPlatformTypeWechat:
                 [ShareSDKConnector connectWeChat:[WXApi class]];
                 break;
//             case SSDKPlatformTypeQQ:
//                 [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
//                 break;
//             case SSDKPlatformTypeSinaWeibo:
//                 [ShareSDKConnector connectWeibo:[WeiboSDK class]];
//                 break;
             default:
                 break;
         }
     }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
     {
         
         switch (platformType)
         {
             case SSDKPlatformTypeSinaWeibo:
                 //设置新浪微博应用信息,其中authType设置为使用ÔSSO＋Web形式授权
                 [appInfo SSDKSetupSinaWeiboByAppKey:@"568898243"
                                           appSecret:@"38a4f8204cc784f81f9f0daaf31e02e3"
                                         redirectUri:@"http://www.sharesdk.cn"
                                            authType:SSDKAuthTypeBoth];
                 break;
             case SSDKPlatformTypeWechat:
                 //微信的分享
                 //c5bdb58d0e1405cb7df7362e5806ff22
                 //wxc85028718b16d1a3
                 [appInfo SSDKSetupWeChatByAppId:@"wx857395c70ead408f"
                                       appSecret:@"e9193b1e3f668e6f88345b929dc442d8"];
                 
                 //原来的
                 //wxc85028718b16d1a3
                 //c5bdb58d0e1405cb7df7362e5806ff22
                 
                 //新的
                 //wx857395c70ead408f
                 //e9193b1e3f668e6f88345b929dc442d8
                 
                 
                 break;
             case SSDKPlatformTypeQQ:
                 //qq分享
                 [appInfo SSDKSetupQQByAppId:@"100371282"
                                      appKey:@"aed9b0303e3ed1e27bae87c33761161d"
                                    authType:SSDKAuthTypeBoth];
                 break;
//             case SSDKPlatformTypeRenren:
//                 [appInfo        SSDKSetupRenRenByAppId:@"226427"
//                                                 appKey:@"fc5b8aed373c4c27a05b712acba0f8c3"
//                                              secretKey:@"f29df781abdd4f49beca5a2194676ca4"
//                                               authType:SSDKAuthTypeBoth];
//                 break;
//             case SSDKPlatformTypeGooglePlus:
//                 [appInfo SSDKSetupGooglePlusByClientID:@"232554794995.apps.googleusercontent.com"
//                                           clientSecret:@"PEdFgtrMw97aCvf0joQj7EMk"
//                                            redirectUri:@"http://localhost"];
//                 break;
             default:
                 break;
         }
     }];
    
    //注册高德地图
//    [MAMapServices sharedServices].apiKey = @"476f25331bcf78e76481a9c48c7426ad";
    //个人账号 com.developer.qmjs
//    [MAMapServices sharedServices].apiKey = @"27d54f7d031abe66d7bbf397f1615676";
//    appstore 提交的 com.smartsport.luoyang
//    [MAMapServices sharedServices].apiKey = @"0a31075a1e0273b7c697d22160edc348";
    // 常州299 com.changzhou.OlympicStadium
//    [MAMapServices sharedServices].apiKey = @"0977a36c819acec738b4b9faeb0e11d6";
    
    //关闭icloud
    [self closeUpIcloud];
    
    // 环信中有用到Parse，您的项目中需要添加 暂无用
    [self parseApplication:application didFinishLaunchingWithOptions:launchOptions];
    
    //设置hud的样式
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [SVProgressHUD setFont:[UIFont boldSystemFontOfSize:14.0f]];
    //设置svphud最小显示时间为1.5 默认是5
    [SVProgressHUD setMinimumDismissTimeInterval:1.5];
    [SVProgressHUD setBackgroundColor:UIColorFromRGB(0xe4e6ea)];
    [SVProgressHUD setCornerRadius:10];
    [SVProgressHUD setRingNoTextRadius:10];
    [SVProgressHUD setRingRadius:10];
    [SVProgressHUD setMinimumSize:CGSizeMake(kPLUS_SCALE_X(70), kPLUS_SCALE_X(70))];
    
    //    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    //    [SVProgressHUD setBackgroundColor:SsecondGray];
    //    [SVProgressHUD setForegroundColor:[UIColor blueColor]];
    //    [SVProgressHUD setBackgroundLayerColor:[UIColor yellowColor]];
    
//    [SVProgressHUD setSuccessImage:[UIImage imageNamed:@"success"]];
//    [SVProgressHUD setInfoImage:[UIImage imageNamed:@"success"]];
//    [SVProgressHUD setErrorImage:[UIImage imageNamed:@"success"]];
    
    
    //删除功能 默认为删除
    [NFUserEntity shareInstance].isGuanjiClear = YES;
    
    
    //支付
//    ZFJPlugin *zfj = [ZFJPlugin shareInstance];
//    //    zfj.isTestEnv = YES;
//    [ZFJPlugin registerAppid:@"wx857395c70ead408f"];
    //    [zfj test];
    
    
    
    
    
    
    
    return YES;
}

#pragma mark - 本地推送注册
-(void)registerLocalNotification{
//    UIMutableUserNotificationAction *zanAction = [[UIMutableUserNotificationAction alloc] init];
//    zanAction.identifier = kNotificationActionIdentifileStar;
//    zanAction.title = @"赞";
//    zanAction.activationMode = UIUserNotificationActivationModeBackground;
//    zanAction.authenticationRequired = YES;
//    zanAction.destructive = YES;
    UIMutableUserNotificationAction *comAction = [[UIMutableUserNotificationAction alloc] init];
    comAction.identifier = kNotificationActionIdentifileComment;
    comAction.title = @"回复";
    comAction.activationMode = UIUserNotificationActivationModeBackground;
    comAction.authenticationRequired = YES;
    comAction.destructive = NO;
    if ([comAction respondsToSelector:@selector(behavior)] && [comAction respondsToSelector:@selector(parameters)]) {
        
        comAction.behavior = UIUserNotificationActionBehaviorTextInput;
        comAction.parameters = @{UIUserNotificationActionResponseTypedTextKey:@"回下"};
    }
    UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory alloc] init];
    category.identifier = kNotificationCategoryIdentifile;
//    [category setActions:@[zanAction,comAction] forContext:UIUserNotificationActionContextDefault];
    [category setActions:@[comAction] forContext:UIUserNotificationActionContextDefault];
    UIUserNotificationSettings *uns = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert) categories:[NSSet setWithObject:category]];
    [[UIApplication sharedApplication] registerUserNotificationSettings:uns];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
}

// Returns the types of data that Fit wishes to write to HealthKit.

//- (NSSet *)dataTypesToWrite {
////    HKQuantityType *dietaryCalorieEnergyType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryChloride];
//    HKQuantityType *activeEnergyBurnType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
////    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
////    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
//    HKQuantityType *disType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
//    HKQuantityType *calType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
//    
////    return [NSSet setWithObjects:dietaryCalorieEnergyType, activeEnergyBurnType, heightType, weightType,disType,calType, nil];
//    return [NSSet setWithObjects:activeEnergyBurnType, disType, calType, nil];
//}
//
//// Returns the types of data that Fit wishes to read from HealthKit.
//- (NSSet *)dataTypesToRead {
////    HKQuantityType *dietaryCalorieEnergyType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryChloride];
//    HKQuantityType *activeEnergyBurnType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
////    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
////    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
////    HKCharacteristicType *birthdayType = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
//    HKQuantityType *disType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
//    HKQuantityType *calType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
//    
////    return [NSSet setWithObjects:dietaryCalorieEnergyType, activeEnergyBurnType, heightType, weightType, birthdayType,disType,calType, nil];
//     return [NSSet setWithObjects:activeEnergyBurnType, disType, calType, nil];
//}

-(void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler{
    if ([shortcutItem.type isEqualToString:@"1"]) {
        //二维码跳转
        if ([NFUserEntity shareInstance].PushQRCode) {
            if ([[NFUserEntity shareInstance].PushQRCode isEqualToString:@"0"]) {
                //当程序在后台的情况
                UIStoryboard * sb = [UIStoryboard storyboardWithName:@"NFQRCodeStoryboard" bundle:nil];
                QRCodeScanViewController * qrcodeScanVC = [sb instantiateViewControllerWithIdentifier:@"QRCodeScanViewController"];
                UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
                [currentVC.navigationController pushViewController:qrcodeScanVC animated:YES];
            }
        }else{
            //点击了3d touch 并为第一次运行 到首页跳转到扫描二维码
            [NFUserEntity shareInstance].PushQRCode = @"1";
            
        }
    }
}

- (BOOL)checkIsExistPropertyWithInstance:(id)instance verifyPropertyName:(NSString *)verifyPropertyName
{
    unsigned int outCount, i;
    
    // 获取对象里的属性列表
    objc_property_t * properties = class_copyPropertyList([instance
                                                           class], &outCount);
    
    for (i = 0; i < outCount; i++) {
        objc_property_t property =properties[i];
        //  属性名转成字符串
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        // 判断该属性是否存在
        if ([propertyName isEqualToString:verifyPropertyName]) {
            free(properties);
            return YES;
        }
    }
    free(properties);
    
    return NO;
}


- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        rootVC = [rootVC presentedViewController];
    }
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
    } else {
        // 根视图为非导航类
        currentVC = rootVC;
    }
    return currentVC;
}

#pragma mark - 判断屏幕旋转
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    // Get topmost/visible view controller
    UIViewController *currentViewController = [self topViewController];
    
    NSString *className = currentViewController ? NSStringFromClass([currentViewController class]) : nil;
    
    if ([className isEqualToString:@"AVFullScreenViewController"] || [className isEqualToString:@"MPMoviePlayerViewController"])
    {
        return UIInterfaceOrientationMaskAll;
    }
    
    // Only allow portrait (standard behaviour)
    return UIInterfaceOrientationMaskPortrait;
}

- (UIViewController*)topViewController
{
    return [KeepAppBox topViewController];
}

#pragma mark - push 设置 收到deviceToken回调 当在上面注册推送并成功后 会调用这里
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //生成的deviceToken
    NSString* devToken = [NSString stringWithFormat:@"%@",deviceToken];
    NSString *devToken1 = [devToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *token = [devToken1 substringWithRange:NSMakeRange(1,64)];
    [KeepAppBox keepVale:token forKey:kDeviceTokenKey];
    
    //环信token
//    [[EMClient sharedClient] bindDeviceToken:deviceToken];
    
#pragma mark - 极光推送
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
    //tagsAliasCallback:tags:alias:
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(networkDidLogin:) name:kJPFNetworkDidLoginNotification object:nil];
    
    
}

/**
 *  登录成功，设置别名，移除监听
 *
 *  @param notification notification description
 */
- (void)networkDidLogin:(NSNotification *)notification {
    NSLog(@"已登录");
//    [JPUSHService setTags:[NSSet set] alias:@"20" callbackSelector:@selector(tagsAliasCallback:tags:alias:) target:self];
    NSString *registrationID = [JPUSHService registrationID];
    if (![registrationID isEqualToString:[NFUserEntity shareInstance].JPushId]) {
        NSLog(@"");
    }
//    NSString *UDID = [JIGUANGLogin ResultDown];
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:kJPFNetworkDidLoginNotification
//                                                  object:nil];
    //如果socket连接状态不是0 则进行登录
   // NSLog(@"11111");
    NSLog(@"[NFUserEntity shareInstance].connectStatus = %@",[NFUserEntity shareInstance].connectStatus);
    if (![[NFUserEntity shareInstance].connectStatus isEqualToString:@"0"]) {
        
        SocketModel *socketSec = [SocketModel share];
        [socketSec initSocket];
        
//        SocketModel *socket = [SocketModel share];
//        NSString *password = [KeepAppBox checkValueForkey:kLoginPassWord];
//        if (password.length > 0 && ![NFUserEntity shareInstance].userIsConncected) {
//            //[socket loginWithDefaultType];
//            [socket loginWithDefaultTypeStrong];
//        }
//        NSString *weixinId = [KeepAppBox checkValueForkey:kLoginWeixinUserName];
//        //当非登录状态下才进行重连
//        if (weixinId.length > 0 && ![NFUserEntity shareInstance].userIsConncected) {
//            [socket weixinLoginRequest];
//        }
    }
    NSLog(@"5555");
    
    //kJPFNetworkIsConnectingNotification
}

-(void)tagsAliasCallback:(int)codes tags:(NSSet *)iTags alias:(NSString *)iAlias{
    
    NSLog(@"\n-----JPUSHLogin-----\n%@",[JPUSHService registrationID]);
    //程序激活后 貌似不走这里
    SocketModel *socket = [SocketModel share];
    NSString *password = [KeepAppBox checkValueForkey:kLoginPassWord];
    if (password.length > 0 && ![NFUserEntity shareInstance].userIsConncected) {
        [socket loginWithDefaultTypeStrong];
    }
    NSString *weixinId = [KeepAppBox checkValueForkey:kLoginWeixinUserName];
    //当非登录状态下才进行重连
    if (weixinId.length > 0 && ![NFUserEntity shareInstance].userIsConncected) {
        [socket weixinLoginRequest];
    }
    
}


- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    NSLog(@"apns -> 注册推送功能时发生错误， 错误信息:\n %@", err);
}


#pragma mark - 程序在后台时 点击推送消息 进入这里
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
//    UIApplicationStateActive,
//    UIApplicationStateInactive,
//    UIApplicationStateBackground
    if (application.applicationState == 0) {//如果在前台直接return
        return;
    }
    NSLog(@"%ld",application.applicationState);
    NSLog(@"\n\n\napplicationState上\n\n\n");
    
    NSLog(@"\n\n\napplicationState下\n\n\n");
    application.applicationIconBadgeNumber = 0;
    NSLog(@"\n\n\n\n推送消息\n%@\n\n",userInfo);
    //这里对接收到的推送消息进行处理 比如缓存、修改会话列表
//    [JPUSHService handleRemoteNotification:userInfo];
    
    NSLog(@"%@",[NFUserEntity shareInstance].currentChatId);
    
    [JPUSHService setBadge:0];
//    completionHandler(UIBackgroundFetchResultNewData);
    NSDictionary *info = [userInfo objectForKey:@"extras"];
    //点击推送处理
    [self receiveServerAPSDict:info];
    
}

//-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
//    
//    NSLog(@"");
//    
//}

#pragma mark - Convenience

// Set the healthStore property on each view controller that will be presented to the user. The root view controller is a tab
// bar controller. Each tab of the root view controller is a navigation controller which contains its root view controller—
// these are the subclasses of the view controller that present HealthKit information to the user.
- (void)setupHealthStoreForTabBarControllers
{
//    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.healthStore,@"healthStore", nil];
//    [[NSNotificationCenter defaultCenter]postNotificationName:@"healthStore" object:self userInfo:dic];
//    
//    UIApplication *app = [UIApplication sharedApplication];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    application.applicationIconBadgeNumber = 0;
    NSLog(@"程序暂停");
}

// App进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application {
//    [[EMClient sharedClient] applicationDidEnterBackground:application];
    //记录时间戳
    NSString *currentTimeString = [NFMyManage getCurrentTimeStamp];
    [KeepAppBox keepVale:currentTimeString forKey:@"enterBackTime"];
    //通知结束正在输入
    [[NSNotificationCenter defaultCenter] postNotificationName:@"enteringEndRequest" object:nil];
    
//    BOOL backgroundAccepted = [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{
////        [self backgroundHandler];
//
//    }];
//    if (backgroundAccepted)
//    {
//        NSLog(@"VOIP backgrounding accepted");
//    }
    NSLog(@"程序进入后台");
    //记录状态 进入后台 当进入前台的时候 防止sendping崩溃
    //将app状态设置为yes 刚进来的时候不允许sendping
    [NFUserEntity shareInstance].appStatus = NO;
    [JPUSHService setBadge:0];
    [UIApplication sharedApplication].idleTimerDisabled = NO; //关闭屏幕常亮
//    BOOL backgroundAccepted = [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{
//        [[SocketModel share] sendhert];
//    }];
//    if (backgroundAccepted)
//    {
//        NSLog(@"backgrounding accepted");
//    }
    
    //保持后台一直链接
    [self beingBackgroundUpdateTask];
    
    
}

// App将要从后台返回
- (void)applicationWillEnterForeground:(UIApplication *)application {
    // 直接打开app时，图标上的数字清零
    application.applicationIconBadgeNumber = 0;
    [JPUSHService setBadge:0];
//    [[EMClient sharedClient] applicationWillEnterForeground:application];
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
    //当app进入前台，判断是否为单聊界面并且输入框是不是第一响应者
    if ([currentVC isKindOfClass:[MessageChatViewController class]]) {
        MessageChatViewController *VC = (MessageChatViewController *)currentVC;
        if ([VC.IFView_.TextViewInput isFirstResponder]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"enteringRequesst" object:nil];
        }
    }
    
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSString *enterBackTime = [KeepAppBox checkValueForkey:@"enterBackTime"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[enterBackTime integerValue]];
    NSTimeInterval time = [currentDate timeIntervalSinceDate:confromTimesp];
    NSInteger timme = time;
    //当进入后台的时间超过10分钟，进行重新连接socket
    if (timme >= 550) {
        NSLog(@"重新连接socket");
        SocketModel *socketModel = [SocketModel share];
        [socketModel initSocket];//是否需要这个重连
//        [socketModel returnConnectSuccedd:^{
//            NSLog(@"断线时间超过10分钟 进行重连刷新");
//            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
//            UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
//            if ([currentVC respondsToSelector:@selector(refresh)]) {
//                [currentVC performSelector:@selector(refresh) withObject:nil afterDelay:0];
//            }
//        }];
    }else{
        //检查是否断连
        
    }
    //将app状态设置为yes 允许sendping
     [NFUserEntity shareInstance].appStatus = YES;
    //将后台运行 一直关闭
    [self endBackgroundUpdateTask];
    NSLog(@"程序进入前台");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    //比较时间戳时间戳
    NSString *enterBackTime = [KeepAppBox checkValueForkey:@"enterBackTime"];
    if (enterBackTime.length == 0) {
        //第一次安装会有这样情况 因为没有退出过
        NSLog(@"没有获取到程序退出时间戳");
    }else{
        BOOL IsShanChuRet = [NFbaseViewController compaTodayDateReturnDeleteWithDate:[enterBackTime integerValue]];
        if (!IsShanChuRet) {
            //进行删除
            [SVProgressHUD show];
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
                [self clearAllData];
                [NFUserEntity shareInstance].badgeCount = 0;
                [[NFbaseViewController new] setBadgeCountWithCount:0 AndIsAdd:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                });
            });
        }
    }
    //当有网 并且正常情况下
    if ([[NFUserEntity shareInstance].PushQRCode isEqualToString:@"0"] && [ClearManager getNetStatus]) {
        //如果为0 则通知刷新当前界面
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
        if ([currentVC respondsToSelector:@selector(refresh)]) {
            [currentVC performSelector:@selector(refresh) withObject:nil afterDelay:0];
            
        }
        if ([currentVC isKindOfClass:[MessageChatViewController class]]) {
            MessageChatViewController *VC = (MessageChatViewController *)currentVC;
            VC.isCanSendMessage = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                VC.isCanSendMessage = YES;
            });
        }else if ([currentVC isKindOfClass:[GroupChatViewController class]]) {
            GroupChatViewController *VC = (GroupChatViewController *)currentVC;
            VC.isCanSendMessage = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                VC.isCanSendMessage = YES;
            });
        }
        UIViewController * viewVC = [currentVC.navigationController.viewControllers objectAtIndex:currentVC.navigationController.viewControllers.count - currentVC.navigationController.viewControllers.count];
        //当显示界面的根视图不是会话列表界面 则通知刷新会话列表 显示未读 【这是这时候消息历史没有缓存 因为界面不是会话列表界面 只有在会话列表或群聊界面才会缓存会话历史】
        if (![viewVC isKindOfClass:[MessageChatListViewController class]]) {
            socketRequest = [SocketRequest share];
            [socketRequest getConversationList];
        }
        NSLog(@"");
    }
    //当app刚打开的时候 设置两秒钟之内不允许 提示音【当收到推送 会有声音提醒 刚进来socket会一下子将所有推送都推送过来 造成了点击推送进来会响一次提示音】 这里用gcd 设置刚打开app一秒之内不允许有提示音
    [NFUserEntity shareInstance].showPrompt = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [NFUserEntity shareInstance].showPrompt = YES;
    });
    [NFUserEntity shareInstance].reconnectTimeInterval = 0.1;//程序第一次到界面 设置重连延迟为0.1【首次连接时间为0.1秒】
    NSLog(@"程序再次激活");
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    //记录时间戳
    socketRequest = [SocketRequest share];
    [socketRequest quitSocketRequest];
    
    NSString *currentTimeString = [NFMyManage getCurrentTimeStamp];
    [KeepAppBox keepVale:currentTimeString forKey:@"enterBackTime"];
//    [JPUSHService setTags:[NSSet set] alias:@"" callbackSelector:nil target:self];
    NSLog(@"程序意外终止");
    [UIApplication sharedApplication].idleTimerDisabled = NO; //关闭屏幕常亮
    
    
    
    
}

#pragma mark - 第三方回调
- (BOOL)application:(UIApplication *)application  handleOpenURL:(NSURL *)url
{
    return [WXApi handleOpenURL:url delegate:self];
//    return [ShareSDK handleOpenURL:url
//                        wxDelegate:self];
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    //scheme -- 智能门户返回值
    if ([[url scheme] isEqualToString:kAppScheme])
    {
        // 支付宝支付
        if ([[url host] isEqualToString:@"safepay"]) {
            NSString *query = [[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = @{@"query": query};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"AliPayNotification" object:nil userInfo:dict];
            return YES;
        }
        else if([[url host] isEqualToString:@"uppayresult"])
        {
//            [[UPPaymentControl defaultControl] handlePaymentResult:url completeBlock:^(NSString *code, NSDictionary *data) {
            
//                NSDictionary *dict = @{@"query": code};
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"uppayresultNotification" object:nil userInfo:dict];
//            }];
        }else if ([url.host isEqualToString:@"oauth"]){
            return [WXApi handleOpenURL:url delegate:self];
        }
        //参数
        NSString *tHost = [[url host] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LOGIN_FROM_MYNJ" object:tHost];
        return YES;
    }
    //scheme -- 第三方返回值
//    return [ShareSDK handleOpenURL:url
//                 sourceApplication:sourceApplication
//                        annotation:annotation
//                        wxDelegate:self];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
  if ([url.host isEqualToString:@"oauth"]){//微信登录
        return [WXApi handleOpenURL:url delegate:self];
    }
return YES;
//if ([url.host isEqualToString:@"safepay"]) {}//支付宝用这个
}

#pragma mark - 微信支付回调
//-(void) onResp:(BaseResp*)resp
//{
//    if([resp isKindOfClass:[PayResp class]]){
//        NSDictionary *result = [[NSDictionary alloc] initWithObjectsAndKeys:resp,@"resp", nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"wxChatonResp" object:nil userInfo:result];
//    }
//}

//微信回调代理
- (void)onResp:(BaseResp *)resp{
    
    // =============== 获得的微信登录授权回调 ============
    if ([resp isMemberOfClass:[SendAuthResp class]])  {
        NSLog(@"******************获得的微信登录授权******************");
        
        SendAuthResp *aresp = (SendAuthResp *)resp;
        if (aresp.errCode != 0 ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showErrorWithStatus:@"微信授权失败"];
            });
            return;
        }
        //授权成功获取 OpenId
        NSString *code = aresp.code;
        //[self getWeiXinOpenId:code];
        [SVProgressHUD showWithStatus:@"获取中..."];
        [[NSUserDefaults standardUserDefaults] setObject:code forKey:@"WXAPICode"];
    }
    // =============== 获得的微信支付回调 ============
    if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
    }
}




#pragma mark - wtx
- (UIViewController *)topController{
    UIViewController *topController = [[[[UIApplication sharedApplication]delegate] window] rootViewController];
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}

#pragma mark - 关闭iCloud的方法
- (void)addSkipBackupAttributeToPath:(NSString*)path
{
    u_int8_t b = 1;
    setxattr([path fileSystemRepresentation], "com.apple.MobileBackup", &b, 1, 0, 0);
}

- (void)closeUpIcloud
{
    //为Document文件设置不iCloud存储属性，防止AppStore审核无法通过2.23条款
    NSString *notBackUpPathDoc = nil;
    notBackUpPathDoc = [NSString stringWithFormat:@"%@/Documents/",NSHomeDirectory()];
    [self addSkipBackupAttributeToPath:notBackUpPathDoc];
    
    NSString *notBackUpPathCach = nil;
    notBackUpPathCach = [NSString stringWithFormat:@"%@/Library/Caches/",NSHomeDirectory()];
    [self addSkipBackupAttributeToPath:notBackUpPathCach];
}



#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.boweifeng.BWF_coreData" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"nationalFitness" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"nationalFitness.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support
- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSString *)iphoneType {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
    
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
    
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    
    if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    
    if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    
    if ([platform isEqualToString:@"iPod1,1"])  return @"iPod Touch 1G";
    
    if ([platform isEqualToString:@"iPod2,1"])  return @"iPod Touch 2G";
    
    if ([platform isEqualToString:@"iPod3,1"])  return @"iPod Touch 3G";
    
    if ([platform isEqualToString:@"iPod4,1"])  return @"iPod Touch 4G";
    
    if ([platform isEqualToString:@"iPod5,1"])  return @"iPod Touch 5G";
    
    if ([platform isEqualToString:@"iPad1,1"])  return @"iPad 1G";

    if ([platform isEqualToString:@"iPad2,1"])  return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,2"])  return @"iPad 2";

    if ([platform isEqualToString:@"iPad2,3"])  return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,4"])  return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,5"])  return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad2,6"])  return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad2,7"])  return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad3,1"])  return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,2"])  return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,3"])  return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,4"])  return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad3,5"])  return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad3,6"])  return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad4,1"])  return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,2"])  return @"iPad Air";

    if ([platform isEqualToString:@"iPad4,3"])  return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,4"]) return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"iPad4,5"])  return @"iPad Mini 2G";

    if ([platform isEqualToString:@"iPad4,6"])  return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"i386"])  return @"iPhone Simulator";
    
    if ([platform isEqualToString:@"x86_64"]) return @"iPhone Simulator";
    
    return platform;
    
}

-(NFMyManage *)myManage{
    if (!_myManage) {
        _myManage = [[NFMyManage alloc] init];
    }
    return _myManage;
}

-(void)clearAllData{
    [NFUserEntity shareInstance].isNeedRefreshLocalChatList = YES;
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __weak typeof(self)weakSelf=self;
    __block NSArray *contentsss = [NSArray new];
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        contentsss = [strongSelf ->jqFmdb jq_selectedAllTableName];
    }];
    for (NSString *qunzuChatTable in contentsss) {
        if (![qunzuChatTable containsString:@"keepBoxEntity"]&&![qunzuChatTable containsString:@"xinxiaoxiTongzhi"]&&![qunzuChatTable containsString:@"yinsiSet"]&&![qunzuChatTable containsString:@"groupDetailliebiao"]&&![qunzuChatTable containsString:@"groupMenberliebiao"]&&![qunzuChatTable containsString:@"lianxirenliebiao"]&&![qunzuChatTable containsString:@"qunzuliebiao"]){
            __block NSArray *keyArr = [NSArray new];
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                keyArr = [strongSelf ->jqFmdb jq_columnNameArray:qunzuChatTable];
            }];
            NSLog(@"%d",keyArr.count);
            if (keyArr.count >= 26){
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    BOOL ret = [strongSelf ->jqFmdb jq_deleteAllDataFromTable:qunzuChatTable];
                    if (ret) {
                    }
                }];
            }
        }
    }
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
    if ([currentVC isKindOfClass:[MessageChatListViewController class]]) {
        NSLog(@"");
        MessageChatListViewController *VC =(MessageChatListViewController *)currentVC;
        [VC refreshLocalData];
    }else{
        [SVProgressHUD dismiss];
    }
    //删除完立马创建空的
    [self setChatListAbout];
    //    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    //    //删除会话数据库数据
    //    BOOL huihualiebiao = [[NFMyManage new] clearTableWithDatabaseName:@"tongxun.sqlite" tableName:@"huihualiebiao" IsDelete:NO];
    ////    BOOL shenqingtongzhi = [[NFMyManage new] clearTableWithDatabaseName:@"tongxun.sqlite" tableName:@"shenqingtongzhi" IsDelete:NO];
    ////    BOOL lianxirenliebiao = [[NFMyManage new] clearTableWithDatabaseName:@"tongxun.sqlite" tableName:@"lianxirenliebiao" IsDelete:NO];
    //    //删除f各联系人的缓存聊天
    //    NSArray *arrs = [jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[FriendListEntity class] whereFormat:@""];
    //
    //    for (FriendListEntity *entity in arrs) {
    //        int a = [[NFMyManage new] checkIsHaveNumAndLetter:entity.friend_username];
    //        if (a ==1 || a == 3) {
    //            entity.friend_username = [[NFMyManage new] NumToString:entity.friend_username];
    //        }
    //        BOOL rett = [[NFMyManage new] clearTableWithDatabaseName:@"tongxun.sqlite" tableName:entity.friend_username IsDelete:YES];
    //        if (rett) {
    //            NSLog(@"");
    //        }
    //    }
}


#pragma mark - 懒加载建立会话列表数据库
-(void)setChatListAbout{
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        if (![strongSelf ->jqFmdb jq_isExistTable:@"huihualiebiao"]) {
            BOOL huihualiebiaoret = [strongSelf ->jqFmdb jq_createTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class]];
        }
        if (![strongSelf ->jqFmdb jq_isExistTable:@"groupDetailliebiao"]) {
            BOOL groupDetailliebiaoret = [strongSelf ->jqFmdb jq_createTable:@"groupDetailliebiao" dicOrModel:[GroupCreateSuccessEntity class]];
        }
        if (![strongSelf ->jqFmdb jq_isExistTable:@"groupMemberliebiao"]) {
            BOOL groupMemberliebiaoret = [strongSelf ->jqFmdb jq_createTable:@"groupMemberliebiao" dicOrModel:[FriendListEntity class]];
        }
    }];
    [self setMineSetAbout];
}

#pragma mark - 我的设置建立数据库 有则忽略
-(void)setMineSetAbout{
    //缓存设置属性字段相关
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    
    __block BOOL ret = NO;
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        ret = [strongSelf ->jqFmdb jq_isExistTable:@"keepBoxEntity"];
    }];
    if (!ret) {
        __block BOOL keepBoxEntityRet = NO;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            keepBoxEntityRet = [strongSelf ->jqFmdb jq_createTable:@"keepBoxEntity" dicOrModel:[CacheKeepBoxEntity class]];
        }];
        if (keepBoxEntityRet) {
            CacheKeepBoxEntity *entity = [CacheKeepBoxEntity new];
            entity.keepBoxId = @"keepBoxId";
            entity.themeSelectedIndex = 1;
            entity.themeSelectedImageName = @"";
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                BOOL rett = [strongSelf ->jqFmdb jq_insertTable:@"keepBoxEntity" dicOrModel:entity];
                if (rett) {
                }
            }];
        }
    }
    
    //    [jqFmdb jq_inDatabase:^{
    __block BOOL IsExistyincang = NO;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        IsExistyincang = [strongSelf ->jqFmdb jq_isExistTable:@"xinxiaoxiTongzhi"];
    }];
    if (!IsExistyincang) {
        __block BOOL ret = NO;
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            ret = [strongSelf ->jqFmdb jq_createTable:@"xinxiaoxiTongzhi" dicOrModel:[NewMessageNotifyEntity class]];
        }];
        if (ret) {
            //如果没有缓存 新建三个数据
            for (int i = 0; i < 4; i++) {
                if (i == 0) {
                    NewMessageNotifyEntity *entity = [NewMessageNotifyEntity new];
                    entity.setId = @"jieshouxiaoxiTongzhi";
                    entity.receiveNewMessageNotify = YES;
                    __weak typeof(self)weakSelf=self;
                    [jqFmdb jq_inDatabase:^{
                        __strong typeof(weakSelf)strongSelf=weakSelf;
                        BOOL ret = [strongSelf ->jqFmdb jq_insertTable:@"xinxiaoxiTongzhi" dicOrModel:entity];
                        if (ret) {
                            NSLog(@"newjieshouxiaoxiTongzhi");
                        }
                    }];
                }else if (i == 1){
                    NewMessageNotifyEntity *entity = [NewMessageNotifyEntity new];
                    entity.setId = @"sound";
                    entity.soundNotify = YES;
                    __weak typeof(self)weakSelf=self;
                    [jqFmdb jq_inDatabase:^{
                        __strong typeof(weakSelf)strongSelf=weakSelf;
                        BOOL ret = [strongSelf ->jqFmdb jq_insertTable:@"xinxiaoxiTongzhi" dicOrModel:entity];
                        if (ret) {
                            NSLog(@"newsound");
                        }
                    }];
                    
                }else if (i == 2){
                    NewMessageNotifyEntity *entity = [NewMessageNotifyEntity new];
                    entity.setId = @"shake";
                    entity.ShakeNotify = YES;
                    __weak typeof(self)weakSelf=self;
                    [jqFmdb jq_inDatabase:^{
                        __strong typeof(weakSelf)strongSelf=weakSelf;
                        BOOL ret = [strongSelf ->jqFmdb jq_insertTable:@"xinxiaoxiTongzhi" dicOrModel:entity];
                        if (ret) {
                            NSLog(@"newshake");
                        }
                    }];
                    
                }else if (i == 3){
                    NewMessageNotifyEntity *entity = [NewMessageNotifyEntity new];
                    entity.setId = @"lingshengshezhi";
//                    entity.voiceName = @"katalk2";
                    entity.voiceName = @"katalk";
                    __weak typeof(self)weakSelf=self;
                    [jqFmdb jq_inDatabase:^{
                        __strong typeof(weakSelf)strongSelf=weakSelf;
                        BOOL ret = [strongSelf ->jqFmdb jq_insertTable:@"xinxiaoxiTongzhi" dicOrModel:entity];
                        if (ret) {
                            NSLog(@"lingshengshezhi");
                        }
                    }];
                }
            }
        }
    }
    __block NSArray *arrs = [NSArray new];
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        arrs = [strongSelf ->jqFmdb jq_lookupTable:@"xinxiaoxiTongzhi" dicOrModel:[NewMessageNotifyEntity class] whereFormat:@""];
    }];
    
    
    //    }];
    
    //    [jqFmdb jq_inDatabase:^{
    //是否能建表
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        BOOL rett = [strongSelf ->jqFmdb jq_createTable:@"yinsiSet" dicOrModel:[PrivacySetEntity class]];
        if (rett) {
            for (int i = 0; i < 2; i++) {
                if (i == 0) {
                    //
                    __block PrivacySetEntity *entity = [PrivacySetEntity new];
                    entity.setId = @"xuyaoYanzheng";
                    entity.needVerificate = YES;
                    [jqFmdb jq_inDatabase:^{
                        __strong typeof(weakSelf)strongSelf=weakSelf;
                        BOOL ret = [strongSelf ->jqFmdb jq_insertTable:@"yinsiSet" dicOrModel:entity];
                        if (ret) {
                            NSLog(@"newyinsiSet");
                        }
                    }];
                }else if (i == 1){
                    __block PrivacySetEntity *entity = [PrivacySetEntity new];
                    entity.setId = @"tuijiantongxunluHaoyou";
                    entity.recommendMailList = YES;
                    [jqFmdb jq_inDatabase:^{
                        __strong typeof(weakSelf)strongSelf=weakSelf;
                        BOOL ret = [strongSelf ->jqFmdb jq_insertTable:@"yinsiSet" dicOrModel:entity];
                        if (ret) {
                            NSLog(@"newyinsiSet");
                        }
                    }];
                }
            }
        }else{
//            NSArray *arr = [jqFmdb jq_lookupTable:@"yinsiSet" dicOrModel:[PrivacySetEntity class] whereFormat:@""];
//            NSLog(@"");
        }
    }];
    
    //    }];
}

#pragma mark - 根据服务器推送给的额extra 进行后续处理
-(void)receiveServerAPSDict:(NSDictionary *)info{
    //    //判断点击推送消息 进来 正在和该对象聊天 那么不回到会话列表
    if (([[[info objectForKey:@"type"] description] isEqualToString:@"single"] && [[NFUserEntity shareInstance].currentChatId isEqualToString:[[info objectForKey:@"senderId"] description]]) || ([[[info objectForKey:@"type"] description] isEqualToString:@"group"] && [[NFUserEntity shareInstance].currentChatId isEqualToString:[[info objectForKey:@"groupId"] description]])) {
        return;
    }
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    //UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    if ([[[info objectForKey:@"type"] description] isEqualToString:@"single"] || [[[info objectForKey:@"type"] description] isEqualToString:@"group"]) {
        //当为聊天消息 则直接return。只是进入app
        //到本界面的根视图
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
        UIViewController * viewVC = [currentVC.navigationController.viewControllers objectAtIndex:currentVC.navigationController.viewControllers.count - currentVC.navigationController.viewControllers.count];
        [currentVC.navigationController popToViewController:viewVC animated:YES];
        //pop回根视图后 设置选中为会话列表
        currentVC.tabBarController.selectedIndex = 0;
        return;
    }else if ([[[info objectForKey:@"type"] description] isEqualToString:@"apply"]){
        //申请请求
        if ([NFUserEntity shareInstance].PushQRCode) {
            if ([[NFUserEntity shareInstance].PushQRCode isEqualToString:@"0"]) {
                //申请与通知
                UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
                ApplyViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"ApplyViewController"];
                //点击后 红点提醒设置为no
                [NFUserEntity shareInstance].IsApplyAndNotify = NO;
                UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
                [currentVC.navigationController pushViewController:toCtrol animated:YES];
            }
        }else{
            //在首页跳转到申请详情
            [NFUserEntity shareInstance].PushQRCode = @"4";
        }
    }
}

#pragma mark - 唐巧方法
//让程序在后台长久运行的示例代码如下
//- (void)applicationDidEnterBackground:(UIApplication *)application
//{
//    [self beingBackgroundUpdateTask];
//    // 在这里加上你需要长久运行的代码
//    [self endBackgroundUpdateTask];
//}

- (void)beingBackgroundUpdateTask
{
    //让app一直运行 当收到单聊、群聊消息时候 在后台情况下 不进行任何操作直接return，等打开app进入前台后再进行一系列操作
    //这里只是让app一直运行 只是为了保持socket不断
//    self.backgroundUpdateTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
//        NSLog(@"");
////        [self endBackgroundUpdateTask];
//    }];

    
    
//    MMPDeepSleepPreventer *ddd = [MMPDeepSleepPreventer shareMMPDeepSleepPreventer];
//    ddd.isOnForeground = NO;
//    if (!ddd.isVoiceOrVideoCall) {
//        [ddd startPreventSleep];
//    }
    
    
}

- (void)endBackgroundUpdateTask
{
//    [[UIApplication sharedApplication] endBackgroundTask: self.backgroundUpdateTask];
//    self.backgroundUpdateTask = UIBackgroundTaskInvalid;
    
    
//    MMPDeepSleepPreventer *deepSleep = [MMPDeepSleepPreventer shareMMPDeepSleepPreventer];
//    deepSleep.isOnForeground = YES;
//    if (!deepSleep.isVoiceOrVideoCall) {
//        [deepSleep stopPreventSleep];
//    }
    
}

#pragma mark - 奔溃断点
void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"\n\n\nCRASH: %@\n\n", exception);
    NSLog(@"Stack Trace: %@\n\n\n", [exception callStackSymbols]);
    // Internal error reporting
}















@end
