//
//  FriendSetTableViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/8/9.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "FriendSetTableViewController.h"

@interface FriendSetTableViewController ()

@end

@implementation FriendSetTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"好友设置";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self initUI];
    
    self.firstLabel.textColor = [UIColor colorMainTextColor];
    self.firstLabel.font = [UIFont fontMainText];
}

-(void)initUI{
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 34)];
    [backBtn setImage:[UIImage imageNamed:@"everyday1_return"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    self.tableView.tableFooterView = [UIView new];
}

- (void)backClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (@available(iOS 13.0, *)) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell右箭头"]];
    }
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MineStoryboard" bundle:nil];
    FriendSetDetailTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"FriendSetDetailTableViewController"];
    [self.navigationController pushViewController:toCtrol animated:YES];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


@end
