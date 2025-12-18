//
//  ResetPassWordTableViewController.h
//  nationalFitness
//
//  Created by joe on 2017/12/18.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NFTableViewController.h"

//功能
#import "SocketModel.h"
#import "UIColor+RYChat.h"
#import "HCDTimer.h"
#import "LoginManager.h"


#import "MBSliderView.h"

#define verfication @"959045"

//controller


//entity

//

@interface ResetPassWordTableViewController : NFTableViewController

//懒加载
@property (strong, nonatomic) NFMyManage *myManage;    //懒加载 fmdbServicee
//懒加载
@property (copy, nonatomic) NSMutableDictionary *parms;    //懒加载

@property (weak, nonatomic) IBOutlet UILabel *firstLabel;

@property (weak, nonatomic) IBOutlet UILabel *secondLabel;

@property (weak, nonatomic) IBOutlet UILabel *thirdLabel;

@property (weak, nonatomic) IBOutlet UILabel *forthLabel;

@property (weak, nonatomic) IBOutlet UILabel *firstLineLabel;

@property (weak, nonatomic) IBOutlet UILabel *secondLinelbasle;

@property (weak, nonatomic) IBOutlet UILabel *thirdLineLabel;

@property (weak, nonatomic) IBOutlet UILabel *forthLinelabel;


@property (strong, nonatomic) MBSliderView *MBSlider;//滑块带边框


@end
