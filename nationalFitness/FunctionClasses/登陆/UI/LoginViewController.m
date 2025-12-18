//
//  LoginViewController.m
//  nationalFitness
//
//  Created by 童杰 on 2017/3/13.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "LoginViewController.h"
#import "NewHomeViewController.h"
#import "NFbaseNavViewController.h"
#import "FMLinkLabel.h"

#import <ShareSDK/ShareSDK.h>
#import <ShareSDKExtension/SSEThirdPartyLoginHelper.h>

//0打开 1关闭 走动登陆
#define isUseAutoSign @"0"

//0可以 1不可以 是否可以直接用userid登陆
#define isUseUseridLogin @"1"

@interface LoginViewController ()<UITextViewDelegate,ChatHandlerDelegate,UITextFieldDelegate,WXApiDelegate>
@property(nonatomic,strong)HCDTimer *timerr;
@end

@implementation LoginViewController{
    //大背景图
    __weak IBOutlet UIImageView *backImageV;
    //手机号 验证码背景图
    __weak IBOutlet UIView *backView_;
    __weak IBOutlet UITextField *phoneTextF_;
    __weak IBOutlet UIButton *getCodeBtn;
    __weak IBOutlet UITextField *passWordTextF_;
    //登陆按钮
    __weak IBOutlet UIButton *logInBtn;
    //注册按钮
    __weak IBOutlet UIButton *registerBtn;
    
    //同意背景
    __weak IBOutlet UIView *agreeView;
    //同意按钮
    __weak IBOutlet UIButton *agreeBtn;
    //同意条款
    __weak IBOutlet FMLinkLabel *agreeLabel;
    //显示密码
    __weak IBOutlet UIButton *showPassWordBtn;
    //logo距离下面约束
    __weak IBOutlet NSLayoutConstraint *logoBottomConstant;
    //登陆用户名图标
    __weak IBOutlet UIImageView *userAccountImageV;
    //登陆密码图标
    __weak IBOutlet UIImageView *passWordImageV;
    //约束 账号密码背景view 距离上面约束 就是logoBottomConstant
    
    //多信图标距离上面约束
    __weak IBOutlet NSLayoutConstraint *iconTopConstaint;
    //微信登录按钮
    __weak IBOutlet UIButton *weixinBtn;
    //微信top约束
    __weak IBOutlet NSLayoutConstraint *weixinTopConstaint;
    
    //秒
    int secTime_;
    BOOL notFirstCome_;
    NSTimer * timer_;
    //是否发过验证码
    BOOL isGetCode;
    //记录是否走自动登陆逻辑
    BOOL isFromAutoLogin;
    SocketModel * socketModel;
    SocketRequest *socketRequest;
    JQFMDB *jqFmdb;
    //记录是否需要在will里面初始化连接
    BOOL IsNeedInitInWillAppear;
    //foreview
    UIImageView *foreView_;
    //IP地址
    NSString *IPString;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    if (self.navigationController.viewControllers.count > 1) {
        id obj = [self.navigationController.viewControllers objectAtIndex:1];
        NSLog(@"%@",[obj class]);
    }
    
//[SVProgressHUD dismiss];
    NSString *phone = [KeepAppBox checkValueForkey:kLoginUserName];
    
    if([phone containsString:@"hh_"]){
        phoneTextF_.text = @"";
    }else{
        phoneTextF_.text = phone;
    }
    
    //当登陆界面出现时 我的二维码清空
    [NFUserEntity shareInstance].MineQRCodeImage = nil;
    
    //willappear时候 判断是否需要重新建立连接
    if (IsNeedInitInWillAppear) {
        [self initSocket];
        passWordTextF_.text = @"";
        IsNeedInitInWillAppear = NO;
    }else{
        socketModel = [SocketModel share];
        socketModel.delegate = self;
    }
    [self initColor];
//    __block id Field;
//    dispatch_async(dispatch_get_main_queue(), ^(void) {
//        Field = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
//    });
//    UIView *statusBar;
//    if ([Field isKindOfClass:[UIView class]]) {
//        statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
//    }
    NSString *version = [UIDevice currentDevice].systemVersion;
    
    UIView *statusBar;
    if (version.doubleValue >= 13.0) {
        //        UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].keyWindow.windowScene.statusBarManager;
        //        if ([statusBarManager respondsToSelector:@selector(createLocalStatusBar)]) {
        //            UIView *_localStatusBar = [statusBarManager performSelector:@selector(createLocalStatusBar)];
        //            if ([_localStatusBar respondsToSelector:@selector(statusBar)]) {
        //                statusBar = [_localStatusBar performSelector:@selector(statusBar)];
        //            }
        //        }
    }else{
        __block id Field;
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            Field = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
        });
        if ([Field isKindOfClass:[UIView class]]) {
            statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
        }
    }
    
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = [UIColor clearColor];
        //statusBar.backgroundColor = [UIColor redColor];
    }
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

//当将要消失后 设置为需要初始化socket
-(void)viewWillDisappear:(BOOL)animated{
    
    [SVProgressHUD dismiss];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    //界面将要消失 remove
    [foreView_ removeFromSuperview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [NFUserEntity shareInstance].isGuanjiClear = YES;
    if (foreView_) {
        [foreView_ removeFromSuperview];
    }
    
    
    //状态栏 Default为黑色
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    
    
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    //当退出系统的时候 需要判断
    [NFUserEntity shareInstance].isUserMynj = YES;
    // Do any additional setup after loading the view.
//    NSLog(@"%f",backView_.frame.size.width);
    //监听跳往主页的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotoLoginRootview:)
                                                 name:kGoto_Login_Rootview
                                               object:nil];
    backImageV.userInteractionEnabled = YES;
    //tencentoauth
    IsNeedInitInWillAppear = NO;
    self.view.backgroundColor = UIColorFromRGB(0x4EBFF8);
    backImageV.image = [UIImage imageNamed:@"登录背景"];
    //取手机最后一次登录时间 当小于某个时间 可以清除微信、qq的用户名、密码、id等
    NSString *str = [KeepAppBox checkValueForkey:kLoginLastTime];
    if ([[KeepAppBox checkValueForkey:kLoginLastTime] integerValue] < 9 || !str) {
        [NFUserEntity shareInstance].userId = @"";
        [KeepAppBox keepVale:@"" forKey:kLoginPassWord];
        [KeepAppBox keepVale:@"" forKey:kLoginWeixinUserName];
        [NFUserEntity shareInstance].userName = @"";
        NSLog(@"");
    }
    
    [self initUI];
    [self initSocket];
    [self SetSomeRequireData];
    
    
}

#pragma mark - 请求ip地址
- (void)getIPManager
{
    NSMutableDictionary *sendDic = [[NSMutableDictionary alloc] initWithCapacity:2];
    [LoginManager execute:@selector(getIPManagerManager) target:self callback:@selector(getIPManagerCallBack:) args:sendDic,nil];
}

- (void)getIPManagerCallBack:(id)data{
    if (data) {
        NSDictionary *dict = data;
        NSDictionary *ipDict = [dict objectForKey:@"data"];
        [NFUserEntity shareInstance].netIP = [NSString stringWithFormat:@"%@ %@%@",[ipDict objectForKey:@"ip"],[ipDict objectForKey:@"region"],[ipDict objectForKey:@"city"]];
        if ([NFUserEntity shareInstance].netIP.length > 0) {
            [self networkingLogin];
        }
    }
}

#pragma mark - 用户绑定极光id

#pragma mark - 微信登录请求
//-(void)weixinLoginRequest:(NSDictionary *)userInfo{
//    [NFUserEntity shareInstance].userType = NFUserWX;
//    [self.parms removeAllObjects];
//    self.parms[@"action"] = @"wxLogin";
//    self.parms[@"headimgurl"] = [userInfo objectForKey:@"headimgurl"];
//    self.parms[@"nickname"] = [userInfo objectForKey:@"nickname"];
////    self.parms[@"headimgurl"] = [NFUserEntity shareInstance].WXHeadPicpath;
////    self.parms[@"nickname"] = [NFUserEntity shareInstance].WXNickName;
//    self.parms[@"openid"] = [userInfo objectForKey:@"openid"];
//
//    self.parms[@"adCode"] = [SystemInfo shareSystemInfo].deviceId; //广告码
//    self.parms[@"phoneType"] = [SystemInfo shareSystemInfo].deviceType;//设备类型
//    self.parms[@"osVersion"] = [SystemInfo shareSystemInfo].OSVersion;//系统版本
//    self.parms[@"loginIp"] = [SystemInfo shareSystemInfo].DeviceIPAddresses;//ip地址
//    self.parms[@"apns_production"] = APNSEnvironmental;
//    NSString *Json = [JsonModel convertToJsonData:self.parms];
//    [self sendMessageWith:Json];
//}

#pragma mark - 三方登陆

- (IBAction)qqClick:(id)sender {
    [SSEThirdPartyLoginHelper loginByPlatform:SSDKPlatformTypeQQ
                                   onUserSync:^(SSDKUser *user, SSEUserAssociateHandler associateHandler) {
                                       
                                       //在此回调中可以将社交平台用户信息与自身用户系统进行绑定，最后使用一个唯一用户标识来关联此用户信息。
                                       //在此示例中没有跟用户系统关联，则使用一个社交用户对应一个系统用户的方式。将社交用户的uid作为关联ID传入associateHandler。
                                       associateHandler (user.uid, user, user);
                                       NSDictionary *dict = user.rawData;
                                       NSLog(@"dd%@",user.rawData);
                                       NSLog(@"dd%@",user.credential);
                                       
                                   }
                                onLoginResult:^(SSDKResponseState state, SSEBaseUser *user, NSError *error) {
                                    
                                    if (state == SSDKResponseStateSuccess)
                                    {
                                        
                                    }
                                }];
}

#pragma mark - 微信登录
- (IBAction)weixinClick:(id)sender {
    //判断网络是否连接
    if (![ClearManager getNetStatus]) {
        [SVProgressHUD showInfoWithStatus:@"网络未连接!"];
        return;
    }else if (![socketModel isConnected]){
        [SVProgressHUD showInfoWithStatus:@"正在连接服务器!"];
        return;
    }
    
    //清空本地微信code 
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"WXAPICode"];
    
    
    if([WXApi isWXAppInstalled]){//判断用户是否已安装微信App
        
        
            SendAuthReq *req = [[SendAuthReq alloc] init];
            req.state = @"wx_oauth_authorization_state";//用于保持请求和回调的状态，授权请求或原样带回
            req.scope = @"snsapi_userinfo";//授权作用域：获取用户个人信息
            //唤起微信
            [WXApi sendReq:req];
    }else{
            [SVProgressHUD showInfoWithStatus:@"未检测到微信"];
    }
    
    
        __weak typeof(self)weakSelf=self;
        [[GCDTimerManager sharedInstance] scheduledDispatchTimerWithName:@"getWXCode"
                                                            timeInterval:1.0
                                                                   queue:nil
                                                                 repeats:YES
                                                            actionOption:AbandonPreviousAction
                                                                  action:^{
                                                                      __strong typeof(weakSelf)strongSelf=weakSelf;
            

            NSUserDefaults *appBox = [NSUserDefaults standardUserDefaults];
            NSString *value = [appBox objectForKey:@"WXAPICode"];
            if (value.length > 0) {
                //三方授权成功 获取到code
                [SVProgressHUD dismiss];
                [self WXGetAccess_tokenWithCode:value];                                                                  [[GCDTimerManager sharedInstance] cancelTimerWithName:@"getWXCode"];

            }
                                                                  }];
    
    
    
    return;
    
    [SSEThirdPartyLoginHelper loginByPlatform:SSDKPlatformTypeWechat
                                   onUserSync:^(SSDKUser *user, SSEUserAssociateHandler associateHandler) {
                                       //在此回调中可以将社交平台用户信息与自身用户系统进行绑定，最后使用一个唯一用户标识来关联此用户信息。
                                       //在此示例中没有跟用户系统关联，则使用一个社交用户对应一个系统用户的方式。将社交用户的uid作为关联ID传入associateHandler。
                                       associateHandler (user.uid, user, user);
                                       NSLog(@"dd%@",user.rawData);
                                       NSLog(@"dd%@",user.credential);
                                       [socketModel ping];
                                       if ([socketModel isConnected]) {
                                           [socketModel ping];
                                           if ([socketModel isConnected]) {
                                               [SVProgressHUD show];
                                               [KeepAppBox keepVale:user.uid forKey:kLoginWeixinUserName];
                                               [KeepAppBox keepVale:user.nickname forKey:kLoginWeixinUserNickName];
                                               [KeepAppBox keepVale:user.icon forKey:kLoginWeixinUserHeadIcon];
                                               NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:user.icon]];
                                               NSString *type = [LoginManager typeForImageData:imageData];
                                               [socketRequest weixinLoginRequest:@{@"headimgurl":user.icon,@"nickname":user.nickname,@"openid":user.uid}];
                                           }
                                       }else{
                                           [self reConnectServerWithReturnBlockWithWXName:user.nickname IconUrl:user.icon OpenId:user.uid];
                                       }
                                   }
                                onLoginResult:^(SSDKResponseState state, SSEBaseUser *user, NSError *error) {
                                    if (state == SSDKResponseStateSuccess)
                                    {
                                        
                                    }
                                }];
}

- (IBAction)weiboClick:(id)sender {
    [SSEThirdPartyLoginHelper loginByPlatform:SSDKPlatformTypeSinaWeibo
                                   onUserSync:^(SSDKUser *user, SSEUserAssociateHandler associateHandler) {
                                       
                                       //在此回调中可以将社交平台用户信息与自身用户系统进行绑定，最后使用一个唯一用户标识来关联此用户信息。
                                       //在此示例中没有跟用户系统关联，则使用一个社交用户对应一个系统用户的方式。将社交用户的uid作为关联ID传入associateHandler。
                                       associateHandler (user.uid, user, user);
                                       NSLog(@"dd%@",user.rawData);
                                       NSLog(@"dd%@",user.credential);
                                       
                                   }
                                onLoginResult:^(SSDKResponseState state, SSEBaseUser *user, NSError *error) {
                                    
                                    if (state == SSDKResponseStateSuccess)
                                    {
                                        
                                    }
                                }];
    
}

/**
 *  第三方认证或者登陆的按钮选择
 *
 *  @param shareType 登陆类型 - 第三方集合 ShareType
 */

#pragma mark - 微信请求用户信息11111
- (void)WXGetAccess_tokenWithCode:(NSString *)code
{
    NSMutableDictionary *sendDic = [[NSMutableDictionary alloc] initWithCapacity:2];
    [sendDic setObject:[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",@"wx857395c70ead408f",@"e9193b1e3f668e6f88345b929dc442d8",code] forKey:@"URL"];
    [LoginManager execute:@selector(WXGetAccess_token) target:self callback:@selector(WXGetAccess_tokenWithCodeManagerCallBack:) args:sendDic,nil];
}

- (void)WXGetAccess_tokenWithCodeManagerCallBack:(id)data{
    if (data) {
        NSDictionary *dict = data;
        if([dict objectForKey:@"access_token"] && [dict objectForKey:@"openid"]){
            [self WXGetUserInfoWithAccess_token:[[dict objectForKey:@"access_token"] description] AndopenId:[[dict objectForKey:@"openid"] description]];
        }else{
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"登录错误 %@",dict]];
        }
        
        
    }
}

#pragma mark - 微信请求用户信息22222 
- (void)WXGetUserInfoWithAccess_token:(NSString *)Access_token AndopenId:(NSString *)openid
{
    NSMutableDictionary *sendDic = [[NSMutableDictionary alloc] initWithCapacity:2];
    [sendDic setObject:[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",Access_token,openid] forKey:@"URL"];
    [LoginManager execute:@selector(WXGetUserInfo) target:self callback:@selector(WXGetUserInfoManagerCallBack:) args:sendDic,nil];
}

- (void)WXGetUserInfoManagerCallBack:(id)data{
    if (data) {
        NSDictionary *dict = data;
        
        if(![dict objectForKey:@"openid"]){
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"登录错误 %@",dict]];
            return;
        }
        
        [socketModel ping];
        if ([socketModel isConnected]) {
            [socketModel ping];
            if ([socketModel isConnected]) {
                [SVProgressHUD show];
                [KeepAppBox keepVale:[[dict objectForKey:@"openid"] description] forKey:kLoginWeixinUserName];
                [KeepAppBox keepVale:[[dict objectForKey:@"nickname"] description] forKey:kLoginWeixinUserNickName];
                [KeepAppBox keepVale:[[dict objectForKey:@"headimgurl"] description] forKey:kLoginWeixinUserHeadIcon];
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[dict objectForKey:@"access_token"] description]]];
                NSString *type = [LoginManager typeForImageData:imageData];
                [socketRequest weixinLoginRequest:@{@"headimgurl":[[dict objectForKey:@"headimgurl"] description],@"nickname":[[dict objectForKey:@"nickname"] description],@"openid":[[dict objectForKey:@"openid"] description]}];
            }
        }else{
            [self reConnectServerWithReturnBlockWithWXName:[[dict objectForKey:@"nickname"] description] IconUrl:[[dict objectForKey:@"headimgurl"] description] OpenId:[[dict objectForKey:@"openid"] description]];
        }
        
    }
}




-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    int a = [self.myManage checkIsHaveNumAndLetter:string];
    if (textField.tag == 11) {
        if (textField.text.length + string.length - range.length >20) {
            [SVProgressHUD showInfoWithStatus:@"账号不得超过20位"];
            return NO;
        }
        if (a != 4) {
            return YES;
        }else{
            [SVProgressHUD showInfoWithStatus:@"请输入合法帐号"];
            return NO;
        }
    }
    if (textField.text.length + string.length - range.length > 20) {
        [SVProgressHUD showInfoWithStatus:@"密码过长"];
        return NO;
    }
    
    if (a != 4) {
        return YES;
    }else{
        [SVProgressHUD showInfoWithStatus:@"密码格式不正确"];
        return NO;
    }
}

#pragma mark - 登陆成功设置相关
-(void)SetSomeRequireData{
    //设置默认头像
    [NFUserEntity shareInstance].mineHeadView = defaultHeadImaghe;
    
    [NFUserEntity shareInstance].isNeedRefreshChatList = NO;
//    [NSString stringWithFormat:@"http://%@:7999/web_file/Public/uploads/",ServerAddress];
    //116.62.6.189
    //[NFUserEntity shareInstance].HeadPicpathAppendingString = http://114.55.169.228:7999/web_file/Public/uploads/
//    [NFUserEntity shareInstance].HeadPicpathAppendingString = [NSString stringWithFormat:@"%@/web_file/Public/uploads/",kainuo];
    [NFUserEntity shareInstance].HeadPicpathAppendingString = [NSString stringWithFormat:@"https://duoxinphoto.oss-cn-beijing.aliyuncs.com/"];
    //http://47.98.105.33:7999/web_file/Public/uploads/2018-01-27/5a6bd331156c4.jpeg
}


//移除蒙布
-(void)removeForeView{
    [foreView_ removeFromSuperview];
    
}

-(void)initSocket{
    //初始化
    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.isNeedWake = YES;
    socketModel.delegate = self;
    //在didload中设置的是no 那时候刚启动app 有自动登陆，在didappear中设置的yes，注销后不允许自动登陆
    if (!IsNeedInitInWillAppear) {
#pragma mark - 自动登录 0自动登录 1取消自动登录
        if ([isUseAutoSign isEqualToString:@"0"]) {
            //刚进来蒙一层uiimage
            foreView_ = [[UIImageView alloc] initWithFrame:self.view.bounds];
            foreView_.image = [UIImage imageNamed:@"多信启动图"];
            UIWindow *win = [[[UIApplication sharedApplication] windows] firstObject];
            
            [win addSubview:foreView_];
            
            
            [self performSelector:@selector(removeForeView) withObject:nil afterDelay:8];
            
            //[self performSelector:@selector(removeForeView) withObject:nil afterDelay:1];
            if ([ClearManager getNetStatus]) {
                //有网
                //先获取ip地址
                [self getIPManager];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{//如果两秒钟后 没有得到netIP 则不再等待ip 直接进行登录取system的ip
                    if ([NFUserEntity shareInstance].netIP.length == 0) {
                        [self networkingLogin];
                    }
                });
            }else{
                //断网登录
                [self withoutNetLogin];
            }
        }
    }else{
        [socketModel initSocket];
    }
        
}

#pragma mark - 断网登录
-(void)withoutNetLogin{
    //先判断上次是否为微信登录
    NSString *weixinId = [KeepAppBox checkValueForkey:kLoginWeixinUserName];
    if (weixinId.length > 0) {
        //没网 登陆
        [NFUserEntity shareInstance].userType = NFUserWX;
        [NFUserEntity shareInstance].clientId = [KeepAppBox checkValueForkey:@"clientId"];
        [NFUserEntity shareInstance].userId = [[KeepAppBox checkValueForkey:@"userId"] description];
        [NFUserEntity shareInstance].userName = [[KeepAppBox checkValueForkey:@"userName"] description];
        [NFUserEntity shareInstance].nickName = [[KeepAppBox checkValueForkey:@"userNickName"] description];
        [NFUserEntity shareInstance].isBang = YES?[[KeepAppBox checkValueForkey:[NSString stringWithFormat:@"%@IsBang",[NFUserEntity shareInstance].userName]] isEqualToString:@"1"]:NO;
        //                    [NFUserEntity shareInstance].isBang = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:kGoto_Login_Rootview object:kGoto_Login_Rootview_SportHome];
        return;
    }
    //多信登录逻辑
    NSString *phone = [KeepAppBox checkValueForkey:kLoginUserName];
    NSString *password = [KeepAppBox checkValueForkey:kLoginPassWord];
    
    if([phone containsString:@"hh_"]){
        phoneTextF_.text = @"";
    }else{
        phoneTextF_.text = phone;
    }
    
    passWordTextF_.text = password;
    if (phone.length > 0 && password.length > 0) {
        //没网 登陆
        [NFUserEntity shareInstance].userType = NFUserGeneral;
        [NFUserEntity shareInstance].clientId = [KeepAppBox checkValueForkey:@"clientId"];
        [NFUserEntity shareInstance].userId = [[KeepAppBox checkValueForkey:@"userId"] description];
        [NFUserEntity shareInstance].userName = [[KeepAppBox checkValueForkey:@"userName"] description];
        [NFUserEntity shareInstance].nickName = [[KeepAppBox checkValueForkey:@"userNickName"] description];
        [NFUserEntity shareInstance].isBang = YES?[[KeepAppBox checkValueForkey:[NSString stringWithFormat:@"%@IsBang",[NFUserEntity shareInstance].userName]] isEqualToString:@"1"]:NO;

        [[NSNotificationCenter defaultCenter] postNotificationName:kGoto_Login_Rootview object:kGoto_Login_Rootview_SportHome];
    }else{
        if (foreView_) {
            [foreView_ removeFromSuperview];
        }
    }
}

#pragma mark - 有网登录
-(void)networkingLogin{
    //先判断上次是否为微信登录
    NSString *weixinId = [KeepAppBox checkValueForkey:kLoginWeixinUserName];
    if (weixinId.length > 0) {
        isFromAutoLogin = YES;
        if (socketModel.isConnected) {
            [socketRequest weixinLoginRequest:@{@"headimgurl":[KeepAppBox checkValueForkey:kLoginWeixinUserHeadIcon]?[KeepAppBox checkValueForkey:kLoginWeixinUserHeadIcon]:@"",@"nickname":[KeepAppBox checkValueForkey:kLoginWeixinUserNickName]?[KeepAppBox checkValueForkey:kLoginWeixinUserNickName]:@"",@"openid":weixinId}];
        }else{
            [self reConnectServerWithReturnBlock];
        }
        return;
    }
    //多信登录逻辑
    NSString *phone = [KeepAppBox checkValueForkey:kLoginUserName];
    NSString *password = [KeepAppBox checkValueForkey:kLoginPassWord];
    
    if([phone containsString:@"hh_"]){
        phoneTextF_.text = @"";
    }else{
        phoneTextF_.text = phone;
    }
    
    passWordTextF_.text = password;
    NSLog(@"%@",passWordTextF_.text);
    if (phone.length > 0 && password.length > 0) {
        isFromAutoLogin = YES;
        if (socketModel.isConnected) {
            [socketRequest loginWithDefaultTypeWithName:phone AndPassWord:password];
        }else{
            //如果未连接 则等成功连接后再进行登录
            [self reConnectServerWithReturnBlock];
        }
    }else{
        if (foreView_) {
            [foreView_ removeFromSuperview];
        }
    }
    
}

#pragma mark - 收到服务器消息 9001
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_LoginReceipt){//1002
        [self performSelector:@selector(removeForeView) withObject:nil afterDelay:1];
        
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
        if (![currentVC isKindOfClass:[LoginViewController class]]) {
            return;
        }
        LoginEntity *entity = chatModel;
        //有错误信息 展示错误信息
        if (entity.wrongMessage) {
            [SVProgressHUD showInfoWithStatus:entity.wrongMessage];
            return;
        }
        //正常没有报错 获取参数 跳转首页
        //登陆设置 登陆必要参数设置
        [NFUserEntity shareInstance].clientId = entity.clientId;
        
        if (entity.isSetTixian) {
            [NFUserEntity shareInstance].isTiXianPassWord = YES;
        }
        if (entity.isCancelPwd) {
            [NFUserEntity shareInstance].isShouquanCancelPwd = YES;
        }
        //
        
        [NFUserEntity shareInstance].nickName = [entity.nickName description];
        [NFUserEntity shareInstance].signText = entity.sign;
        [NFUserEntity shareInstance].userId = [entity.userId description];
        [NFUserEntity shareInstance].userName = entity.userName;
        [NFUserEntity shareInstance].mineHeadView = entity.headPicPath;
        [NFUserEntity shareInstance].phoneNum = entity.phoneNum;
        
//        [JPUSHService setTags:[NSSet set] alias:[NFUserEntity shareInstance].userId callbackSelector:nil target:self];
        
        [KeepAppBox keepVale:entity.clientId forKey:@"clientId"];
        [KeepAppBox keepVale:entity.userId forKey:@"userId"];
        [KeepAppBox keepVale:entity.userName forKey:@"userName"];
        [KeepAppBox keepVale:entity.nickName forKey:@"userNickName"];
        
        [KeepAppBox keepVale:entity.isBang forKey:[NSString stringWithFormat:@"%@IsBang",entity.userName]];
        
//        [NFUserEntity shareInstance].isBang = entity.isBang;
        [NFUserEntity shareInstance].isBang = YES?[[KeepAppBox checkValueForkey:[NSString stringWithFormat:@"%@IsBang",[NFUserEntity shareInstance].userName]] isEqualToString:@"1"]:NO;
//        [NFUserEntity shareInstance].isBang = NO;
        
        [KeepAppBox keepVale:[NFUserEntity shareInstance].userName forKey:kLoginUserName];
        NSLog(@"%@",passWordTextF_.text);
        if (passWordTextF_.text.length > 0 && [NFUserEntity shareInstance].userType == NFUserGeneral) {//当passWordTextF_的text有才缓存 否则不缓存 能到这里 要么为普通登录passWordTextF_肯定有值，要么自动登录 那么能到这里 缓存肯定有值
            [KeepAppBox keepVale:passWordTextF_.text forKey:kLoginPassWord];
        }
        [KeepAppBox keepVale:[NFMyManage getCurrentTimeStamp] forKey:kLoginLastTime];
        
        if ([NFUserEntity shareInstance].userType == NFUserWX) {
            [NFUserEntity shareInstance].WXHeadPicpath = entity.headPicPath;
            [NFUserEntity shareInstance].WXNickName = entity.nickName;
        }
        
//        CacheKeepBoxEntity *entityy = [[NFbaseViewController new] getAllCacheDataEntity];
//        [NFUserEntity shareInstance].backgroundImage = entityy.themeSelectedImageName;
        
        //设置缓存相关 必须等到userNameyou 了才能设置
        [self setMineSetAbout];
        //设置缓存相关 不能与setMineSetAbout放一起 会引起数据库崩溃
        [self setChatListAbout];
        //登录成功 绑定极光id
        
//        if (entity.userId.length > 0) {
//            //微信登录 没有设置多信账号
//
//        }else if ([NFUserEntity shareInstance].nickName.length > 0){
//            //微信登录 设置了多信账号
//            [[NSNotificationCenter defaultCenter] postNotificationName:kGoto_Login_Rootview object:kGoto_Login_Rootview_SportHome];
//        }else if ([NFUserEntity shareInstance].nickName.length > 0){
//            //多信登录 设置了昵称
//            [[NSNotificationCenter defaultCenter] postNotificationName:kGoto_Login_Rootview object:kGoto_Login_Rootview_SportHome];
//        }else{
//            //多信登录没有设置昵称
//            //没有昵称，跳转设置昵称
//            //RegistSuccessViewController
//            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"loginStoryboard" bundle:nil];
//            RegistSuccessViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"RegistSuccessViewController"];
//            [self.navigationController pushViewController:toCtrol animated:YES];
//        }
        
        if ([NFUserEntity shareInstance].nickName.length > 0) {
            if ([JPUSHService registrationID]) {
                [NFUserEntity shareInstance].JPushId = [JPUSHService registrationID];
                [socketRequest setJPUSHServiceId];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kGoto_Login_Rootview object:kGoto_Login_Rootview_SportHome];
        }else{
            //没有昵称，跳转设置昵称
            //RegistSuccessViewController
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"loginStoryboard" bundle:nil];
            RegistSuccessViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"RegistSuccessViewController"];
            
            [self.navigationController pushViewController:toCtrol animated:YES];
        }
    }else if (messageType == SecretLetterType_PersonalInfoSet) {
        [NFUserEntity shareInstance].IsUploadingPicture = NO;
        //设置成功
        id obj = chatModel;
        
        NSLog(@"");
    }
}

#pragma mark - 懒加载建立会话列表数据库
-(void)setChatListAbout{
    
    [self.fmdbServicee IsExistHuihualiebiao];
    [self.fmdbServicee IsExistGroupDetailTable];
    [self.fmdbServicee IsExistGroupMemberTable];
    [self.fmdbServicee IsExistLianxirenLieBiao];
    [self.fmdbServicee IsExistQunzuLiebiao];
    [self.fmdbServicee IsExistYinCangLianxirenLieBiao];
    
}

#pragma mark - 我的设置建立数据库 有则忽略
-(void)setMineSetAbout{
//    [NFUserEntity shareInstance].isBang = YES?[[KeepAppBox checkValueForkey:[NSString stringWithFormat:@"%@IsBang",[NFUserEntity shareInstance].userName]] isEqualToString:@"1"]:NO;
    
    
    NSString *yincang = [KeepAppBox checkValueForkey:@"yuehouYincang"];
    [NFUserEntity shareInstance].showHidenMessage = yincang.length>0?NO:YES;;
    //缓存设置属性字段相关
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __weak typeof(self)weakSelf=self;
    __block BOOL IsexistKeep = NO;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        IsexistKeep = [strongSelf ->jqFmdb jq_isExistTable:@"keepBoxEntity"];
    }];
    if (!IsexistKeep) {
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
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                BOOL rett = [strongSelf ->jqFmdb jq_insertTable:@"keepBoxEntity" dicOrModel:entity];
                if (rett) {
                }
            }];
        }
    }
    
//    [jqFmdb jq_inDatabase:^{
    __block BOOL Createxinxiao = NO;
    __block BOOL IsExistYinC = NO;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        IsExistYinC = [strongSelf ->jqFmdb jq_isExistTable:@"xinxiaoxiTongzhi"];
        if (!IsExistYinC) {
            Createxinxiao = [strongSelf ->jqFmdb jq_createTable:@"xinxiaoxiTongzhi" dicOrModel:[NewMessageNotifyEntity class]];
        }
    }];
    
    __block NSArray *arrs = [NSArray new];
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        arrs = [strongSelf ->jqFmdb jq_lookupTable:@"xinxiaoxiTongzhi" dicOrModel:[NewMessageNotifyEntity class] whereFormat:@""];
    }];
        if (Createxinxiao) {
            //如果没有缓存 新建三个数据
            __weak typeof(self)weakSelf=self;
            for (int i = 0; i < 4; i++) {
                if (i == 0) {
                    NewMessageNotifyEntity *entity = [NewMessageNotifyEntity new];
                    entity.setId = @"jieshouxiaoxiTongzhi";
                    entity.receiveNewMessageNotify = YES;
                    
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
//    }];
    
//    [jqFmdb jq_inDatabase:^{
        //是否能建表
        __block BOOL rett = NO;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            rett = [strongSelf ->jqFmdb jq_createTable:@"yinsiSet" dicOrModel:[PrivacySetEntity class]];
        }];
        if (rett) {
            for (int i = 0; i < 2; i++) {
                if (i == 0) {
                    //
                    PrivacySetEntity *entity = [PrivacySetEntity new];
                    entity.setId = @"xuyaoYanzheng";
                    entity.needVerificate = YES;
                    __weak typeof(self)weakSelf=self;
                    [jqFmdb jq_inDatabase:^{
                        __strong typeof(weakSelf)strongSelf=weakSelf;
                        BOOL ret = [strongSelf ->jqFmdb jq_insertTable:@"yinsiSet" dicOrModel:entity];
                        if (ret) {
                            NSLog(@"newyinsiSet");
                        }
                    }];
                }else if (i == 1){
                    PrivacySetEntity *entity = [PrivacySetEntity new];
                    entity.setId = @"tuijiantongxunluHaoyou";
                    entity.recommendMailList = YES;
                    __weak typeof(self)weakSelf=self;
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
            NSLog(@"");
        }
//    }];
}

//-(void)textViewDidBeginEditing:(UITextView *)textView{
//    NSLog(@"");
//    if (textView.tag == 12) {
//
//        self.view.frame = CGRectMake(0, -50, SCREEN_WIDTH, SCREEN_HEIGHT);
//    }
//}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self setViewMovedUp:NO];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    UIWindow *win = [[[UIApplication sharedApplication] windows] firstObject];
    //如果编辑的textfield被键盘遮挡的话那么就上移
    if (SCREEN_HEIGHT - CGRectGetMaxY([textField convertRect: textField.bounds toView:win]) < kOFFSET_FOR_KEYBOARD) {
        [self setViewMovedUp:YES];
    }
}

-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5]; // if you want to slide up the view
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        //        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        //        rect.size.height -= kOFFSET_FOR_KEYBOARD;
        rect.origin.y = 0;
        rect.size.height = SCREEN_HEIGHT;
    }
    self.view.frame = rect;
    [UIView commitAnimations];
}

//-(void)textViewDidBeginEditing:(UITextView *)textView{
//    
//    if (textView.tag == 12) {
//        
//        self.view.frame = CGRectMake(0, -50, SCREEN_WIDTH, SCREEN_HEIGHT);
//    }
//    
//    
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
//    if (phoneTextF_.text.length == 0) {
//        [SVProgressHUD showInfoWithStatus:@"请输入账号"];
//        return YES;
//    }
//    if (passWordTextF_.text.length == 0) {
//        [SVProgressHUD showInfoWithStatus:@"请输入密码"];
//        return YES;
//    }
//    if (textField.tag == 11) {
//        if (textField.text.length >20) {
//            [SVProgressHUD showInfoWithStatus:@"账号不得超过20位"];
//            return YES;
//        }else if (textField.text.length < 6){
//            [SVProgressHUD showInfoWithStatus:@"账号不得低于6位"];
//            return YES;
//        }
//    }
//    if (textField.text.length >20) {
//        [SVProgressHUD showInfoWithStatus:@"密码过长"];
//        return YES;
//    }
//    if (!agreeBtn.selected) {
//        [SVProgressHUD showInfoWithStatus:@"请阅读并同意服务条款"];
//        return YES;
//    }
//    if (![ClearManager getNetStatus]) {
//        [SVProgressHUD showInfoWithStatus:@"网络异常"];
//        return YES;
//    }
//    if ([self.myManage checkIsHaveNumAndLetter:phoneTextF_.text] == 4) {
//        [SVProgressHUD showInfoWithStatus:@"账号不能含有特殊符号"];
//        return YES;
//    }
//    if ([self.myManage checkIsHaveNumAndLetter:passWordTextF_.text] == 4) {
//        [SVProgressHUD showInfoWithStatus:@"密码格式不正确"];
//        return YES;
//    }
//
//    if (socketModel.isConnected) {
//        [socketRequest loginWithDefaultTypeWithName:phoneTextF_.text AndPassWord:passWordTextF_.text];
//    }else{
//        //如果未连接 则等成功连接后再进行登录
//        [self reConnectServerWithReturnBlock];
//    }
    
    return YES;
    
}

-(void)initColor{
    phoneTextF_.textColor = [UIColor colorMainTextColor];
    passWordTextF_.textColor = [UIColor colorMainTextColor];
    
}

-(void)initUI{
    //判断设备是否安装了微信
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]]) {
        weixinBtn.hidden = YES;
    }
    logoBottomConstant.constant = kPLUS_SCALE_X(60);
    if (SCREEN_WIDTH == 320) {
        logoBottomConstant.constant = 10;
        weixinTopConstaint.constant = 5;
    }
    SystemInfo *systemInfo = [SystemInfo shareSystemInfo];
    NSString *type = [[UIDevice currentDevice] model];
    if ([type isEqualToString:@"iPad"]) {
        logoBottomConstant.constant = kPLUS_SCALE_Y(20);
        iconTopConstaint.constant = kPLUS_SCALE_Y(20);
        
        weixinBtn.hidden = YES;
        
    }
    
//    accountBackViewConstaint.constant = 10;
    [agreeBtn setImage:[UIImage imageNamed:@"CellButtonSelected"] forState:(UIControlStateSelected)];
    [agreeBtn setImage:[UIImage imageNamed:@"CellButton"] forState:(UIControlStateNormal)];
    agreeBtn.selected = YES;//默认为yes
    agreeLabel.text = @"我已阅读并同意 服务条款";
    [agreeLabel addClickText:@"服务条款" attributeds:@{NSForegroundColorAttributeName : UIColorFromRGB(0x2EBBF0)} transmitBody:@"呵呵哒 被点击了" clickItemBlock:^(id transmitBody) {
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"PublicFunctionStoryboard" bundle:nil];
        ServiceViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"ServiceViewController"];
        toCtrol.isShowBack = YES;
        [self.navigationController pushViewController:toCtrol animated:YES];
    }];
    
    [showPassWordBtn setImage:[UIImage imageNamed:@"登陆眼睛"] forState:(UIControlStateSelected)];
    
    if ([isUseABC isEqualToString:@"0"]) {
        phoneTextF_.keyboardType = UIKeyboardTypeASCIICapable;
    }else{
        phoneTextF_.keyboardType = UIKeyboardTypeDefault;
    }
    
    phoneTextF_.font = [UIFont fontWithName:@"Avenir-Book" size:16];
    passWordTextF_.font = [UIFont fontWithName:@"Avenir-Book" size:16];
    
    phoneTextF_.backgroundColor = [UIColor whiteColor];
    passWordTextF_.backgroundColor = [UIColor whiteColor];
    
    passWordTextF_.clearButtonMode = UITextFieldViewModeNever;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:phoneTextF_.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(3, 3)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = phoneTextF_.bounds;
    maskLayer.path = maskPath.CGPath;
    if (SCREEN_WIDTH < 500) {
        phoneTextF_.layer.mask = maskLayer;
    }
    
    UIBezierPath *maskPathh = [UIBezierPath bezierPathWithRoundedRect:passWordTextF_.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(3, 3)];
    CAShapeLayer *maskLayerr = [[CAShapeLayer alloc] init];
    maskLayerr.frame = passWordTextF_.bounds;
    maskLayerr.path = maskPathh.CGPath;
    if (SCREEN_WIDTH < 500) {
        passWordTextF_.layer.mask = maskLayer;
    }
    
    UIBezierPath *maskPathhh = [UIBezierPath bezierPathWithRoundedRect:userAccountImageV.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(3, 3)];
    CAShapeLayer *maskLayerrr = [[CAShapeLayer alloc] init];
    maskLayerrr.frame = userAccountImageV.bounds;
    maskLayerrr.path = maskPathhh.CGPath;
    userAccountImageV.layer.mask = maskLayerrr;
    
    UIBezierPath *maskPathhhh = [UIBezierPath bezierPathWithRoundedRect:passWordImageV.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft cornerRadii:CGSizeMake(3, 3)];
    CAShapeLayer *maskLayerrrr = [[CAShapeLayer alloc] init];
    maskLayerrrr.frame = passWordImageV.bounds;
    maskLayerrrr.path = maskPathhhh.CGPath;
    passWordImageV.layer.mask = maskLayerrrr;
    
    ViewRadius(logInBtn, 3);
    //logInBtn.backgroundColor = [UIColor colorThemeColor];
    [logInBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [registerBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    
    [phoneTextF_ setValue:[NSNumber numberWithInt:5] forKey:@"paddingLeft"];
    [passWordTextF_ setValue:[NSNumber numberWithInt:5] forKey:@"paddingLeft"];
    
//    ViewBorderRadius(phoneTextF_, 0, 1, UIColorFromRGB(0x111111));
//    ViewBorderRadius(passWordTextF_, 0, 1, UIColorFromRGB(0x111111));
    
    //隐藏 发送验证码按钮
    getCodeBtn.hidden = YES;
    //密文显示
    passWordTextF_.secureTextEntry = YES;
//    NFbaseViewController *baseV2 = [NFbaseViewController new];
//    [baseV2 setViewRound:backView_ TopLeft:NO TopRight:NO BottomLeft:NO BottomRight:NO cornerRadii:20];
    
//    NFbaseViewController *baseV1 = [NFbaseViewController new];
//    [baseV1 setBtnRound:logInBtn TopLeft:NO TopRight:NO BottomLeft:NO BottomRight:NO cornerRadii:20];
//    ViewRadius(logInBtn, 10);
    
    //设置登录注册按钮字体
    logInBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    registerBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    
//    logInBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    
    //ViewBorderRadius(getCodeBtn, 5, 1, UIColorFromRGB(0x2EBBF0));
    ViewRadius(agreeView, 5);
    
    //设置颜色
    self.firstLabel.textColor = [UIColor colorThemeColor];
    self.secondLabel.textColor = [UIColor colorThemeColor];
    self.firstLineLabel.backgroundColor = [UIColor colorThemeColor];
    self.secondLineLabel.backgroundColor = [UIColor colorThemeColor];
    
    self.firstLabel.font = [UIFont boldSystemFontOfSize:20];
    self.secondLabel.font = [UIFont boldSystemFontOfSize:20];
    
    //secretLoginView
    // 一、点按
    // numberOfTapsRequired 点击次数：单击/双击
    // numberOfTouchesRequired 几根手指
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    // 定义双击
    tap.numberOfTapsRequired = 4;
    self.secretLoginView.backgroundColor = [UIColor clearColor];
    [self.secretLoginView addGestureRecognizer:tap];
    
}

#pragma mark - //右下角 点击两下 登陆进行无网登陆
- (void)tap:(UITapGestureRecognizer *)recognizer{
    if (phoneTextF_.text.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"请输入账号"];
        return;
    }
    //没网 登陆
    [NFUserEntity shareInstance].clientId = [KeepAppBox checkValueForkey:@"clientId"];
    [NFUserEntity shareInstance].userId = [[KeepAppBox checkValueForkey:@"userId"] description];
    [NFUserEntity shareInstance].userName = [KeepAppBox checkValueForkey:@"userName"];
    if (phoneTextF_.text.length > 0) {
        [NFUserEntity shareInstance].userName = phoneTextF_.text;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kGoto_Login_Rootview object:kGoto_Login_Rootview_SportHome];
    
}

#pragma mark - 密文显示开关
- (IBAction)canSeeBtn:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        passWordTextF_.secureTextEntry = NO;
    }else{
        passWordTextF_.secureTextEntry = YES;
    }
}

#pragma mark - 忘记密码
- (IBAction)forgetPassWordBtn:(id)sender {
    //ResetPassWordTableViewController
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"loginStoryboard" bundle:nil];
    ResetPassWordTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"ResetPassWordTableViewController"];
    [self.navigationController pushViewController:toCtrol animated:YES];
}

#pragma mark - 注册
- (IBAction)resgisterClick:(id)sender {
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"loginStoryboard" bundle:nil];
    ForgetPassWordViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"ForgetPassWordViewController"];
    [self.navigationController pushViewController:toCtrol animated:YES];
}
#pragma mark - 已经隐藏按钮
//获取验证码
- (IBAction)getCodeBtn:(id)sender {
}
- (IBAction)agreeBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
}

- (IBAction)gestureClick:(id)sender {
//    [phoneTextF_ resignFirstResponder];
//    [passWordTextF_ resignFirstResponder];
    
    [self.view endEditing:YES];
    
}

#pragma mark - 登陆按钮点击
- (IBAction)loginBtClick:(UIButton *)sender {
    [SVProgressHUD show];
    [self.view endEditing:YES];
    if (phoneTextF_.text.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"请输入账号"];
        return ;
    }
    if (passWordTextF_.text.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"请输入密码"];
        return ;
    }
    if (phoneTextF_.text.length < 6) {
        [SVProgressHUD showInfoWithStatus:@"账号不合法"];
        return;
    }
    if (!agreeBtn.selected) {
        [SVProgressHUD showInfoWithStatus:@"请同意服务条款"];
        return;
    }
    if (![ClearManager getNetStatus]) {
        [SVProgressHUD showInfoWithStatus:@"网络异常"];
        return;
    }
    
    if ([self.myManage checkIsHaveNumAndLetter:phoneTextF_.text] == 4) {
        [SVProgressHUD showInfoWithStatus:@"账号不能含有特殊符号"];
        return ;
    }
    if ([self.myManage checkIsHaveNumAndLetter:passWordTextF_.text] == 4) {
        [SVProgressHUD showInfoWithStatus:@"密码格式不正确"];
        return ;
    }
    
    [socketModel ping];
    if (socketModel.isConnected) {
        [socketRequest loginWithDefaultTypeWithName:phoneTextF_.text AndPassWord:passWordTextF_.text];
    }else{
        //如果未连接 则等成功连接后再进行登录
        [self initSocket];
        [self reConnectServerWithReturnBlock];
    }
}

#pragma mark - 登陆
//- (void)loginWithDefaultType
//{
//    [NFUserEntity shareInstance].userType = NFUserGeneral;
//    //调用获取ui中的值 需要在主线程中执行并且为strongself 不能为weakself。
//    [self.parms removeAllObjects];
//    self.parms[@"action"] = @"userLogin";
//    self.parms[@"username"] = phoneTextF_.text;
//    if (phoneTextF_.text.length == 0) {
//        return;
//    }
//    NSString *pwd = [Data_MD5 MD5ForUpper32Bate:passWordTextF_.text];
//    if (passWordTextF_.text.length == 0) {
//        return;
//    }
//    NSLog(@"上传服务器验证的密码:%@",pwd);
//    self.parms[@"password"] = pwd;
//    self.parms[@"adCode"] = [SystemInfo shareSystemInfo].deviceId; //广告码
//    self.parms[@"phoneType"] = [SystemInfo shareSystemInfo].deviceType;//设备类型
//    self.parms[@"osVersion"] = [SystemInfo shareSystemInfo].OSVersion;//系统版本
//    self.parms[@"loginIp"] = [SystemInfo shareSystemInfo].DeviceIPAddresses;//ip地址
//    self.parms[@"apns_production"] = APNSEnvironmental;
////    self.parms[@"apns_production"] = @"False";
////    self.parms[@"type"] = @"production";
//    NSString *Json = [JsonModel convertToJsonData:self.parms];
//    [self sendMessageWith:Json];
//
//}

#pragma mark - 账号密码登录
//-(void)loginWithDefaultTypeWithName:(NSString *)userName AndPassWord:(NSString *)password{
//    [NFUserEntity shareInstance].userType = NFUserGeneral;
//    //调用获取ui中的值 需要在主线程中执行并且为strongself 不能为weakself。
//    [self.parms removeAllObjects];
//    self.parms[@"action"] = @"userLogin";
//    self.parms[@"username"] = userName;
//    if (userName.length == 0) {
//        return;
//    }
//    NSString *pwd = [Data_MD5 MD5ForUpper32Bate:password];
//    if (password.length == 0) {
//        return;
//    }
//    self.parms[@"password"] = pwd;
//    self.parms[@"adCode"] = [SystemInfo shareSystemInfo].deviceId; //广告码
//    self.parms[@"phoneType"] = [SystemInfo shareSystemInfo].deviceType;//设备类型
//    self.parms[@"osVersion"] = [SystemInfo shareSystemInfo].OSVersion;//系统版本
//    self.parms[@"loginIp"] = [SystemInfo shareSystemInfo].DeviceIPAddresses;//ip地址
//    self.parms[@"apns_production"] = APNSEnvironmental;
//    NSString *Json = [JsonModel convertToJsonData:self.parms];
//    [self sendMessageWith:Json];
//}

//-(void)sendMessageWith:(NSString *)json{
//    if (socketModel.isConnected) {
//        [socketModel ping];
//    }
//    if (socketModel.isConnected) {
////        [SVProgressHUD showInfoWithStatus:@"连接成功!"];
//        [socketModel sendMsg:json];
//    }else{
////        [SVProgressHUD showInfoWithStatus:@"正在努力连接..."];
//        //首次登陆 自动登陆会走这里，连上后回调代码块登陆
//        __weak typeof(self)weakSelf=self;
//        [socketModel returnConnectSuccedd:^{
//            __strong typeof(weakSelf)strongSelf=weakSelf;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
//                UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
//                if (![currentVC isKindOfClass:[LoginViewController class]]) {
//                    return ;
//                }
//                if ([strongSelf ->socketModel isConnected]) {
//                    [strongSelf ->socketModel ping];
//                }
//                if (strongSelf ->socketModel.isConnected) {
//                    [SVProgressHUD show];
//                    NSString *weixinId = [KeepAppBox checkValueForkey:kLoginWeixinUserName];
//                    if (weixinId.length > 0) {
//                        [socketRequest weixinLoginRequest:@{@"headimgurl":@"",@"nickname":@"",@"openid":weixinId}];
//                    }else{
//                        [socketRequest loginWithDefaultTypeWithName:phoneTextF_.text AndPassWord:passWordTextF_.text];
//                    }
//                }
//            });
//        }];
//    }
//}

-(void)reConnectServerWithReturnBlock{
    __weak typeof(self)weakSelf=self;
    [socketModel returnConnectSuccedd:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
            if (![currentVC isKindOfClass:[LoginViewController class]]) {
                return ;
            }
            if ([strongSelf ->socketModel isConnected]) {
                [strongSelf ->socketModel ping];
            }
            if (strongSelf ->socketModel.isConnected) {
                [SVProgressHUD show];
                NSString *weixinId = [KeepAppBox checkValueForkey:kLoginWeixinUserName];
                if (weixinId.length > 0) {
                    
                    [socketRequest weixinLoginRequest:@{@"headimgurl":[KeepAppBox checkValueForkey:kLoginWeixinUserHeadIcon]?[KeepAppBox checkValueForkey:kLoginWeixinUserHeadIcon]:@"",@"nickname":[KeepAppBox checkValueForkey:kLoginWeixinUserNickName]?[KeepAppBox checkValueForkey:kLoginWeixinUserNickName]:@"",@"openid":weixinId}];
                }else{
                    [socketRequest loginWithDefaultTypeWithName:phoneTextF_.text AndPassWord:passWordTextF_.text];
                }
            }
        });
    }];
}

//第一次微信登录时 socket 还没有连接成功
-(void)reConnectServerWithReturnBlockWithWXName:(NSString *)name IconUrl:(NSString *)icon OpenId:(NSString *)openId{
    __weak typeof(self)weakSelf=self;
    [socketModel returnConnectSuccedd:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
            if (![currentVC isKindOfClass:[LoginViewController class]]) {
                return ;
            }
            [SVProgressHUD show];
            
            [socketRequest weixinLoginRequest:@{@"headimgurl":icon,@"nickname":name,@"openid":openId}];
        });
    }];
}

- (void)userInfoWithDic :(id)data{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kGoto_Login_Rootview object:kGoto_Login_Rootview_SportHome];
    //NewHomeStoryboard
}

#pragma mark - 登陆app首页
/**
 *  登录APP首页
 */
- (void)goAppHomeViewCtrol{
    UIStoryboard *SportBoard = [UIStoryboard storyboardWithName:@"NewHomeStoryboard" bundle:nil];
    UIViewController *ViewCtrl = [SportBoard instantiateInitialViewController];
    ViewCtrl.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    if (@available(iOS 13.0, *)) {
        ViewCtrl.modalPresentationStyle =UIModalPresentationFullScreen;
    }
    [self.view.superview setTransitionAnimationType:(CCXTransitionAnimationTypeRippleEffect) toward:(CCXTransitionAnimationTowardFromTop) duration:1];
    [self presentViewController:ViewCtrl animated:YES completion:nil];
    
}

#pragma mark - 返回登陆界面
//递归消隐所有的模态视图
- (void)dismissPresentedViewController:(UIViewController *)viewController
{
    UIViewController *subViewController = viewController.presentedViewController;
    
    if (subViewController)
    {
        [self dismissPresentedViewController:subViewController];
    }
    else
    {
        
    }
    if (viewController != self)
    {
        [viewController dismissViewControllerAnimated:NO completion:NULL];
    }
}

/**
 *  在用户填写资料或者其他界面操作时需要先回到主界面，然后再跳转到其他界面的时候，先返回主界面再跳转到其他界面
 *
 *  @param notification notification
 跳转到APP首页                kGoto_Login_Rootview_SportHome
 不跳转直接到登陆页           kGoto_Login_Rootview_LgoinHome
 */
- (void)gotoLoginRootview:(NSNotification *)notification
{
    if([notification.object isEqualToString:kGoto_Login_Rootview_SportHome])
    {
        [self dismissPresentedViewController:self];
        [timer_ invalidate];
        timer_ = nil;
        [getCodeBtn setTitle:@"获取验证码" forState:(UIControlStateNormal)];
        
        //登陆成功 设置下次再来 进行重新连接socket
        IsNeedInitInWillAppear = YES;
        
        [self goAppHomeViewCtrol];
        
    }
    else if([notification.object isEqualToString:kGoto_Login_Rootview_LgoinHome])
    {
        //        [self loginHomeClearUserInfo];
        
        [self dismissPresentedViewController:self];
        
        //下面不注释 登录界面会没有
        //[self performSelector:@selector(clearSbView) withObject:nil afterDelay:0.2];
    }
}
//
- (void)clearSbView
{
    //清除view最上层添加的view
    for(id sbView in [[[[UIApplication sharedApplication] delegate] window] viewForBaselineLayout].subviews)
    {
        UIResponder *nextResponder = [sbView nextResponder];
        DLog(@"%@",nextResponder);
        if ([nextResponder isKindOfClass:[NFbaseNavViewController class]])
        {
//            NSString *phone = [KeepAppBox checkValueForkey:kLoginUserName];
//            phoneTextF_.text = phone;
//            [logInBtn setTitle:@"登录" forState:(UIControlStateNormal)];
        }
        else
        {
            [sbView removeFromSuperview];
        }
    }
    [self.navigationController popToRootViewControllerAnimated:NO];
}

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
    }
    // =============== 获得的微信支付回调 ============
    if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
    }
}


#pragma mark - 获取设备ip地址
-(NSString *)getDeviceIPAddresses
{
    int sockfd = socket(AF_INET,SOCK_DGRAM, 0);
    // if (sockfd <</span> 0) return nil; //这句报错，由于转载的，不太懂，注释掉无影响，懂的大神欢迎指导
    NSMutableArray *ips = [NSMutableArray array];
    
    int BUFFERSIZE =4096;
    
    struct ifconf ifc;
    
    char buffer[BUFFERSIZE], *ptr, lastname[IFNAMSIZ], *cptr;
    
    struct ifreq *ifr, ifrcopy;
    
    ifc.ifc_len = BUFFERSIZE;
    
    ifc.ifc_buf = buffer;
    
    if (ioctl(sockfd,SIOCGIFCONF, &ifc) >= 0){
        
        for (ptr = buffer; ptr < buffer + ifc.ifc_len; ){
            
            ifr = (struct ifreq *)ptr;
            
            int len =sizeof(struct sockaddr);
            
            if (ifr->ifr_addr.sa_len > len) {
                len = ifr->ifr_addr.sa_len;
            }
            
            ptr += sizeof(ifr->ifr_name) + len;
            
            if (ifr->ifr_addr.sa_family !=AF_INET) continue;
            
            if ((cptr = (char *)strchr(ifr->ifr_name,':')) != NULL) *cptr =0;
            
            if (strncmp(lastname, ifr->ifr_name,IFNAMSIZ) == 0)continue;
            
            memcpy(lastname, ifr->ifr_name,IFNAMSIZ);
            
            ifrcopy = *ifr;
            
            ioctl(sockfd,SIOCGIFFLAGS, &ifrcopy);
            
            if ((ifrcopy.ifr_flags &IFF_UP) == 0)continue;
            
            NSString *ip = [NSString stringWithFormat:@"%s",inet_ntoa(((struct sockaddr_in *)&ifr->ifr_addr)->sin_addr)];
            [ips addObject:ip];
        }
    }
    close(sockfd);
    
    NSString *deviceIP =@"";
    
    for (int i=0; i < ips.count; i++){
        if (ips.count >0){
            deviceIP = [NSString stringWithFormat:@"%@",ips.lastObject];
        }
    }
    
    return deviceIP;
}

//懒加载
-(NFMyManage *)myManage{
    if (!_myManage) {
        _myManage = [[NFMyManage alloc] init];
    }
    return _myManage;
}
//懒加载
-(NSMutableDictionary *)parms{
    if (!_parms) {
        _parms = [[NSMutableDictionary alloc] init];
    }
    return _parms;
}

-(FMDBService *)fmdbServicee{
    if (!_fmdbServicee) {
        _fmdbServicee = [[FMDBService alloc] init];
    }
    return _fmdbServicee;
}

////返回登录界面清除用户详情的缓存
//- (void)loginHomeClearUserInfo
//{
//    [KeepAppBox keepVale:@"" forKey:@"nickname"];
//    [KeepAppBox keepVale:@"" forKey:@"mobile"];
//    [KeepAppBox keepVale:@"" forKey:@"hdnumber"];
//    [KeepAppBox keepVale:@"" forKey:@"userId"];
//    [KeepAppBox keepVale:@"" forKey:@"sex"];
//    [KeepAppBox keepVale:@"" forKey:@"userType"];
//    [KeepAppBox keepVale:@"" forKey:@"smallpicPath"];
//    [KeepAppBox keepVale:@"" forKey:@"bigpicPath"];
//    [KeepAppBox keepVale:@"" forKey:@"age"];
//    [KeepAppBox keepVale:@"" forKey:@"birthday"];
//    [KeepAppBox keepVale:@"" forKey:@"height"];
//    [KeepAppBox keepVale:@"" forKey:@"weight"];
//    [KeepAppBox keepVale:@"" forKey:@"signature"];
//    [KeepAppBox keepVale:@"" forKey:@"qrbigpicPath"];
//    [KeepAppBox keepVale:@"" forKey:@"qrsmallpicPath"];
//    [KeepAppBox keepVale:@"" forKey:@"hobby"];
//    [KeepAppBox keepVale:@"" forKey:@"conStellName"];
//    [KeepAppBox keepVale:@"" forKey:@"sexUalityName"];
//    [KeepAppBox keepVale:@"0" forKey:@"roleType"];
//
//    //注销第三方登陆信息
//    [ShareSDK cancelAuthWithType:ShareTypeQQSpace];
//    [ShareSDK cancelAuthWithType:ShareTypeSinaWeibo];
//    [ShareSDK cancelAuthWithType:ShareTypeRenren];
//    [ShareSDK cancelAuthWithType:ShareTypeWeixiTimeline];
//
//    [[NSNotificationCenter defaultCenter]removeObserver:self
//                                                   name:UIApplicationDidBecomeActiveNotification
//                                                 object:nil];
//}

//-(void)dealloc{
//    timer_ = nil;
//    [getCodeBtn setTitle:@"获取验证码" forState:(UIControlStateNormal)];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"\n\n\n\n\ndidReceiveMemoryWarning\n\n\n\n\n");
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
