//
//  PrivacySetTableViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/7/14.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "PrivacySetTableViewController.h"

@interface PrivacySetTableViewController ()

@end

@implementation PrivacySetTableViewController{
    //需要验证
    
    __weak IBOutlet UISwitch *needYanzhengSwitch;
    
    //向我推荐通讯录好友
    __weak IBOutlet UISwitch *recommendFriendSwitch;
    
    
    JQFMDB *jqFmdb;
    
}

-(void)viewWillAppear:(BOOL)animated{
    //self.tableView.backgroundView=[[NFbaseViewController new] setThemeBackgroundImage];
    [self.tableView reloadData];
    [self initColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"隐私设置";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self initUI];
    
    //从缓存取值设置
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __block NSArray *arr = [NSArray new];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        arr = [strongSelf ->jqFmdb jq_lookupTable:@"yinsiSet" dicOrModel:[PrivacySetEntity class] whereFormat:@""];
    }];
    for (PrivacySetEntity *entity in arr) {
        if ([entity.setId isEqualToString:@"xuyaoYanzheng"]) {
            //需要验证
            needYanzhengSwitch.on = entity.needVerificate;
        }else if ([entity.setId isEqualToString:@"tuijiantongxunluHaoyou"]){
            //向我推荐通讯录好友
            recommendFriendSwitch.on = entity.recommendMailList;
        }
    }
    
}

-(void)initUI{
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 34)];
    [backBtn setImage:[UIImage imageNamed:@"everyday1_return"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    self.tableView.tableFooterView = [UIView new];
    
    self.tableView.tableFooterView = [UIView new];
    
    
}

- (void)backClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initColor{
    self.firstLabel.textColor = [UIColor colorMainTextColor];
    self.secondLabel.textColor = [UIColor colorMainTextColor];
    
    self.firstLabel.font = [UIFont fontMainText];
    self.secondLabel.font = [UIFont fontMainText];
    
}

#pragma mark - 加我为朋友时需要验证
- (IBAction)needVerrificateWhenAdd:(UISwitch *)sender {
    //PrivacySetEntity
    NSLog(@"%d",sender.on);
    PrivacySetEntity *entity = [PrivacySetEntity new];
    entity.needVerificate = sender.on;
    entity.setId = @"xuyaoYanzheng";
    //更新缓存
    __block BOOL rett;
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        rett = [strongSelf ->jqFmdb jq_updateTable:@"yinsiSet" dicOrModel:entity whereFormat:@"where setId = 'xuyaoYanzheng'"];
        //如果没成功 将状态还原
        if (!rett) {
            sender.on = !sender.on;
        }
    }];
}




#pragma mark - 向我推荐通讯录好友
- (IBAction)recommendMailList:(UISwitch *)sender {
    //PrivacySetEntity
    NSLog(@"%d",sender.on);
    PrivacySetEntity *entity = [PrivacySetEntity new];
    entity.recommendMailList = sender.on;
    entity.setId = @"tuijiantongxunluHaoyou";
    //更新缓存
    __block BOOL rett;
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        rett = [strongSelf ->jqFmdb jq_updateTable:@"yinsiSet" dicOrModel:entity whereFormat:@"where setId = 'tuijiantongxunluHaoyou'"];
    }];
    //如果没成功 将状态还原
    if (!rett) {
        sender.on = !sender.on;
    }
}

//cell设置成透明
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
