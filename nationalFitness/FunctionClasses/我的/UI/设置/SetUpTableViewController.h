//
//  SetUpTableViewController.h
//  nationalFitness
//
//  Created by Joe on 2017/7/14.
//  Copyright © 2017年 chenglong. All rights reserved.
//weakConnect

#import <UIKit/UIKit.h>
#import "PassWordChangeTableViewController.h"
#import "NewMessageNotificateTableViewController.h"
#import "PopView.h"
#import "PrivacySetTableViewController.h"
#import "OpinionRequestViewController.h"
#import "SaveSetTableViewController.h"
#import "JQFMDB.h"
#import "NewHomeEntity.h"
#import "themeSetViewController.h"
#import "FriendSetTableViewController.h"
#import "NFMyManage.h"
#import "NFTableViewController.h"
#import "LWWeChatActionSheet.h"
#import "MKPAlertView.h"
#import "SocketRequest.h"

#import "HCDTimer.h"


#import "HelpTableViewController.h"

#import "MMPickerView.h"


@interface SetUpTableViewController : NFTableViewController

@property (copy, nonatomic) NSMutableDictionary *parms;    //懒加载

@property (strong, nonatomic) FMDBService *fmdbServicee;




//一键设置字体颜色

@property (weak, nonatomic) IBOutlet UILabel *firstLabel;

@property (weak, nonatomic) IBOutlet UILabel *secondLabel;

@property (weak, nonatomic) IBOutlet UILabel *thirdLabel;

@property (weak, nonatomic) IBOutlet UILabel *forthlabel;

@property (weak, nonatomic) IBOutlet UILabel *fifthLabel;

@property (weak, nonatomic) IBOutlet UILabel *sixthLabel;

@property (weak, nonatomic) IBOutlet UILabel *seventhLasbel;

@property (weak, nonatomic) IBOutlet UILabel *eightthLabel;

@property (weak, nonatomic) IBOutlet UILabel *ninthLabel;

@property (weak, nonatomic) IBOutlet UILabel *tenthLabel;


@property (weak, nonatomic) IBOutlet UILabel *eleventhLabel;


@property (weak, nonatomic) IBOutlet UILabel *TwelvetnLabel;

@property (weak, nonatomic) IBOutlet UILabel *thirTeenthLabel;






@end
