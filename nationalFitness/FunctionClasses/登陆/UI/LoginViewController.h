//
//  LoginViewController.h
//  nationalFitness
//
//  Created by 童杰 on 2017/3/13.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NFbaseViewController.h"
#import "LoginEntity.h"
#import "LoginManager.h"
#import "ForgetPassWordViewController.h"
#import "HCDTimer.h"
//#import "ServiceViewController.h"
#import "Data_MD5.h"
#import "SocketModel.h"
#import "SocketRequest.h"
#import "JsonModel.h"
#import "JQFMDB.h"
#import "SystemInfo.h"
#import "UIColor+RYChat.h"
#import "CCXMethods.h"
#import "ServiceViewController.h"
#import "RegistSuccessViewController.h"
#import "ResetPassWordTableViewController.h"
#import "FMDBService.h"

#import "JPUSHService.h"

//IP地址需求库
#import <sys/socket.h>
#import <sys/sockio.h>
#import <sys/ioctl.h>
#import <net/if.h>
#import <arpa/inet.h>

#import "NFBaseRequest.h"



//0打开 1关闭 手机号英文
#define isUseABC @"1"

#define kOFFSET_FOR_KEYBOARD 215

@interface LoginViewController : NFbaseViewController

//懒加载
@property (strong, nonatomic) NFMyManage *myManage;    //懒加载 fmdbServicee
//懒加载
@property (copy, nonatomic) NSMutableDictionary *parms;    //懒加载

@property (strong, nonatomic) FMDBService *fmdbServicee;


//一键设置字体颜色 账号密码
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;

@property (weak, nonatomic) IBOutlet UILabel *secondLabel;


@property (weak, nonatomic) IBOutlet UILabel *firstLineLabel;

@property (weak, nonatomic) IBOutlet UILabel *secondLineLabel;


//登陆手势添加的view
@property (weak, nonatomic) IBOutlet UIView *secretLoginView;





@end
