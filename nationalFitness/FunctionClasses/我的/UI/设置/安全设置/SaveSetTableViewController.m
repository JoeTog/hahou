//
//  SaveSetTableViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/7/24.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "SaveSetTableViewController.h"

@interface SaveSetTableViewController ()

@end

@implementation SaveSetTableViewController{
    
    //阅后隐藏
    __weak IBOutlet UILabel *yuehouyincangLabel;
    
    
    //关机清空
    __weak IBOutlet UILabel *guanjiqingkongLabel;
    
}

-(void)viewWillAppear:(BOOL)animated{
    //self.tableView.backgroundView=[[NFbaseViewController new] setThemeBackgroundImage];
    [self.tableView reloadData];
    [self initColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"安全设置";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self initUI];
}

-(void)initUI{
    self.tableView.tableFooterView = [UIView new];
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 34)];
    [backBtn setImage:[UIImage imageNamed:@"everyday1_return"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    
    //先取自定义的时间
    NSString *yuehouStringZiDingYi = [KeepAppBox checkValueForkey:@"yuehouYincangStringZiDingYi"];
    if (yuehouStringZiDingYi.length > 0) {
        yuehouyincangLabel.text = yuehouStringZiDingYi;
    }else{
        //没有则取可选的时间
        NSString *yuehouString = [KeepAppBox checkValueForkey:@"yuehouYincangString"];
        if (yuehouString.length > 0) {
            yuehouyincangLabel.text = yuehouString;
        }else{
            yuehouyincangLabel.text = @"未设置";
        }
    }
    
    NSString *guanjiString = [KeepAppBox checkValueForkey:@"guanjiQingkongString"];
    if (guanjiString.length > 0) {
        guanjiqingkongLabel.text = guanjiString;
    }else{
        guanjiqingkongLabel.text = @"未设置";
    }
    
}

-(void)initColor{
    self.firstLabel.textColor = [UIColor colorMainTextColor];
    self.secondLanel.textColor = [UIColor colorMainTextColor];
    yuehouyincangLabel.textColor = [UIColor colorMainTextColor];
    guanjiqingkongLabel.textColor = [UIColor colorMainTextColor];
}

//自定义NAV返回按钮
- (void)backClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

//cell设置成透明
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    __strong typeof(self)strongSelf=self;
    if (indexPath.row == 0) {
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MineStoryboard" bundle:nil];
        SaveSetChoseTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"SaveSetChoseTableViewController"];
        toCtrol.type = @"0";
        [toCtrol returnSelectedRow:^(NSString *selectedString) {
            //nsinter格式 【用于比对】
            [KeepAppBox keepVale:[NSString stringWithFormat:@"%ld",[NFUserEntity shareInstance].yuehouYincang] forKey:@"yuehouYincang"];
            [NFUserEntity shareInstance].showHidenMessage = NO;
            if ([selectedString isEqualToString:@"不隐藏"]) {
                [KeepAppBox keepVale:@"" forKey:@"yuehouYincang"];
                [NFUserEntity shareInstance].showHidenMessage = YES;
            }
            //nsstring格式
            [KeepAppBox keepVale:selectedString forKey:@"yuehouYincangString"];
            strongSelf -> yuehouyincangLabel.text = selectedString;
        }];
        [self.navigationController pushViewController:toCtrol animated:YES];
    }else if (indexPath.row == 1){
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MineStoryboard" bundle:nil];
        SaveSetChoseTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"SaveSetChoseTableViewController"];
        toCtrol.type = @"1";
        [toCtrol returnSelectedRow:^(NSString *selectedString) {
            //nsinter格式 【用于比对】
            [KeepAppBox keepVale:[NSString stringWithFormat:@"%ld",[NFUserEntity shareInstance].guanjiQingkong] forKey:@"guanjiQingkong"];
            //nsstring格式
            [KeepAppBox keepVale:selectedString forKey:@"guanjiQingkongString"];
            strongSelf -> guanjiqingkongLabel.text = selectedString;
        }];
        [self.navigationController pushViewController:toCtrol animated:YES];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}





@end




