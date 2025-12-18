//
//  MineTableViewController.h
//  nationalFitness
// 
//  Created by Joe on 2017/7/14.
//  Copyright © 2017年 chenglong. All rights reserved.
//weakConnect
//StrongQuit

#import <UIKit/UIKit.h>
#import "SetUpTableViewController.h"
#import "QRCodeShowViewController.h"
#import "MineInfoEditTableViewController.h"
#import "QRCodeScanViewController.h"
#import "MineTableHeadView.h"
#import "RegSetImageViewCtroller.h"
#import "NFTableViewController.h"
#import "UIFont+RYChat.h"
#import "EGORefreshTableHeaderView.h"
#import "SocketRequest.h"

#import "RPFMyWalletVC.h"
#import "RPFMyWalletVCSec.h"

#import "WalletTableViewController.h"

//支付
//#import <ZFJSDK/ZFJSDK.h>

#import "NFMineManager.h"

#import "OpenAccountViewController.h"

#import "HelpTableViewController.h"




@interface MineTableViewController : NFTableViewController

//懒加载
@property (copy, nonatomic) NSMutableDictionary *parms;    //懒加载


//一键设置字体
//用户名
@property (weak, nonatomic) IBOutlet UILabel *userLabel;


//我的二维码
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;

//扫一扫
@property (weak, nonatomic) IBOutlet UILabel *saoyisaoLabel;

//设置
@property (weak, nonatomic) IBOutlet UILabel *settingLabel;

//绑定多信账号
@property (weak, nonatomic) IBOutlet UILabel *hahouLabel;

@property (weak, nonatomic) IBOutlet UILabel *qianbaolabel;




//一键设置字体颜色
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *accountNumberLabel;

@property (weak, nonatomic) IBOutlet UILabel *kefuLabel;


@property (weak, nonatomic) IBOutlet UILabel *aotukefuLabel;





@end
