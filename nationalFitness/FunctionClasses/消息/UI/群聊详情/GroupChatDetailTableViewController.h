//
//  GroupChatDetailTableViewController.h
//  nationalFitness
//群聊详情
//  Created by Joe on 2017/7/13.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupDetailHeadTableViewCell.h"
#import "PersonalInfoChangeViewController.h"
#import "GroupChatAllMemberCollectionViewController.h"
#import "UIColor+RYChat.h"
#import "SocketModel.h"
#import "SocketRequest.h"
#import "FMDBService.h"
#import "NFTableViewController.h"
#import "OpinionRequestViewController.h"
#import "QRCodeShowViewController.h"
#import "QRGroupCodeViewController.h"

#import "RPFMyWalletVC.h"

#define RequestNumber 50

//编辑昵称代码块
typedef void (^ReturnGroupNameEditBlock)(NSString *enitedName);

//是否清除了缓存
typedef void (^ReturnIsDeleteBlock)(BOOL IsDelete);


@interface GroupChatDetailTableViewController : NFTableViewController


@property(nonatomic,copy)ReturnGroupNameEditBlock returnGroupNameBlock;

@property(nonatomic,copy)ReturnIsDeleteBlock returnDeleteBlock;


-(void)returnEditedName:(ReturnGroupNameEditBlock)block;

-(void)returnDelete:(ReturnIsDeleteBlock)block;

//懒加载
@property (strong, nonatomic) NFMyManage *myManage;    //懒加载 fmdbServicee
//懒加载
@property (copy, nonatomic) NSMutableDictionary *parms;    //懒加载
@property (nonatomic, strong) FMDBService  *fmdbServicee;


//群聊id
@property(nonatomic,copy)NSString *groupChatId;

//群组聊天 联系人数组
@property(nonatomic,copy)NSArray *memberArr;


//群组实体 暂无用
@property (nonatomic, strong)GroupChatEntity *groupContactEntity;

//群组创建成功实体 使用中
@property(nonatomic,strong)GroupCreateSuccessEntity *groupCreateSEntity;


//一键设置字体颜色
//
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;

@property (weak, nonatomic) IBOutlet UILabel *secLabel;

@property (weak, nonatomic) IBOutlet UILabel *thirdLaberl;

@property (weak, nonatomic) IBOutlet UILabel *fifthLabel;

@property (weak, nonatomic) IBOutlet UILabel *sixthLabel;

@property (weak, nonatomic) IBOutlet UILabel *seventhLabel;

@property (weak, nonatomic) IBOutlet UILabel *eightLabel;

@property (weak, nonatomic) IBOutlet UILabel *ninthLabel;

@property (weak, nonatomic) IBOutlet UILabel *tenthLabel;

@property (weak, nonatomic) IBOutlet UILabel *elevenyhLabel;

@property (weak, nonatomic) IBOutlet UILabel *twelveLabel;

@property (weak, nonatomic) IBOutlet UILabel *thirteenLabel;

@property (weak, nonatomic) IBOutlet UILabel *forteenLabel;

@property (weak, nonatomic) IBOutlet UILabel *fifteenlabel;

@property (weak, nonatomic) IBOutlet UILabel *sixteenLabel;

@property (weak, nonatomic) IBOutlet UILabel *seventeenthLabel;


@property (weak, nonatomic) IBOutlet UILabel *eightteenthLabel;



@end
