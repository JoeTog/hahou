//
//  BingingHaHouTableViewController.h
//  nationalFitness
//
//  Created by joe on 2017/12/26.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NFTableViewController.h"
#import "ForgetPassWordViewController.h"
#import "forgetPassHeadView.h"
#import "HCDTimer.h"
#import "LoginManager.h"
#import "PopView.h"
#import "Data_MD5.h"
#import "Reachability.h"
#import "UIColor+RYChat.h"
#import "SocketModel.h"
#import "MKPAlertView.h"
#import "UIColor+RYChat.h"

#import "MBSliderView.h"




@interface BingingHaHouTableViewController : NFTableViewController

//懒加载
@property (strong, nonatomic) NFMyManage *myManage;    //懒加载 fmdbServicee
//懒加载
@property (copy, nonatomic) NSMutableDictionary *parms;    //懒加载

@property (weak, nonatomic) IBOutlet UILabel *firstLabel;

@property (weak, nonatomic) IBOutlet UILabel *secondlabel;

@property (weak, nonatomic) IBOutlet UILabel *thirdLabel;

@property (weak, nonatomic) IBOutlet UILabel *forthLabel;


@property (weak, nonatomic) IBOutlet UILabel *firstLineLabel;

@property (weak, nonatomic) IBOutlet UILabel *secondLineLabel;

@property (weak, nonatomic) IBOutlet UILabel *thirdLineLabel;

@property (weak, nonatomic) IBOutlet UILabel *forthLineLabel;


@property (strong, nonatomic) MBSliderView *MBSlider;//滑块带边框





@end
