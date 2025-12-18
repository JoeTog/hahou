//
//  NFTableViewController.m
//  nationalFitness
//
//  Created by 童杰 on 2017/3/31.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NFTableViewController.h"

@interface NFTableViewController ()

@end

@implementation NFTableViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [UIView setAnimationsEnabled:YES];
    if (self.navigationController.viewControllers.count == 1) {
        self.tabBarController.tabBar.hidden =NO;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.tableView.backgroundColor = [UIColor colorSectionHeader];
    if (self.navigationController && self.navigationController.viewControllers.count > 1)
    {
        UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 34)];
        [backBtn setImage:[UIImage imageNamed:@"everyday1_return"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
        self.navigationItem.leftBarButtonItem = backButtonItem;
    }
    
}

//自定义NAV返回按钮
- (void)backClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

//界面将要消失时消隐当前界面的hud
-(void)viewWillDisappear:(BOOL)animated{
    [SVProgressHUD dismiss];
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"\n\n\n\n\ndidReceiveMemoryWarning\n\n\n\n\n");
    // Dispose of any resources that can be recreated.
}
@end
