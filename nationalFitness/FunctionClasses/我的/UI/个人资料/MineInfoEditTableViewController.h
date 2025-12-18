//
//  MineInfoEditTableViewController.h
//  nationalFitness
//
//  Created by Joe on 2017/7/14.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonalInfoChangeViewController.h"
#import "QRCodeShowViewController.h"
#import "RegInSexViewController.h"
#import "MyPickerV.h"
#import "HDPictureShowViewController.h"
#import "NFTableViewController.h"
#import "SocketModel.h"
#import "SocketRequest.h"
#import "BingingHaHouTableViewController.h"
#import "ChangePhoneTableViewController.h"


@interface MineInfoEditTableViewController : NFTableViewController

@property (copy, nonatomic) NSMutableDictionary *parms;    //懒加载


@property (weak, nonatomic) IBOutlet UILabel *fffFirstLabel;


//一键设置颜色
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;

@property (weak, nonatomic) IBOutlet UILabel *secondlabel;

@property (weak, nonatomic) IBOutlet UILabel *thirdLabel;

@property (weak, nonatomic) IBOutlet UILabel *forthLabel;

@property (weak, nonatomic) IBOutlet UILabel *areaLabel;

@property (weak, nonatomic) IBOutlet UILabel *sixthLanbel;

@property (weak, nonatomic) IBOutlet UILabel *secenthLabel;

@property (weak, nonatomic) IBOutlet UILabel *eightthLabel;



@property (weak, nonatomic) IBOutlet UILabel *ninthLabel;




@end
