//
//  SaveSetChoseTableViewController.h
//  nationalFitness
//阅后隐藏
//  Created by Joe on 2017/7/24.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SaveSetTableViewCell.h"
#import "SaveSetCustomTableViewCell.h"
#import "PickerViewChose.h"
#import "PopView.h"
#import "NFTableViewController.h"
#import "MKPAlertView.h"
#import "ShowHidenMessageTableViewCell.h"
#import "SaveSetCommitTableViewCell.h"
#import "JQFMDB.h"
#import "ZJContact.h"
#import "NFMyManage.h"


typedef void(^ReturnSelectedRow)(NSString *selectedString);

@interface SaveSetChoseTableViewController : NFTableViewController

@property (strong, nonatomic) NFMyManage *myManage;

//0阅后隐藏 1关机清空
@property(nonatomic,strong)NSString *type;

@property(nonatomic,copy)ReturnSelectedRow returnBlock;

-(void)returnSelectedRow:(ReturnSelectedRow)block;




@end
