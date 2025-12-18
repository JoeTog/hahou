
//
//  RedDetailTableViewController.m
//  nationalFitness
//
//  Created by joe on 2017/12/13.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "RedDetailTableViewController.h"

@interface RedDetailTableViewController ()

@end

@implementation RedDetailTableViewController{
    
    //headView
    redPacketDetailHeadView *headView;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    headView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 240);
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    
    NSString *imageName = @"表头底图";
    //imageName = @"上边框";
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:imageName]
                            forBarPosition:UIBarPositionAny
                                barMetrics:UIBarMetricsDefault];
    //设置文字颜色
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIColor whiteColor],
                                NSForegroundColorAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"红包";
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0xd65a45)] forBarPosition:UIBarPositionAny
                                barMetrics:UIBarMetricsDefault];
    //设置文字颜色
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                UIColorFromRGB(0xf1ebb7),
                                NSForegroundColorAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];
    
    
    [self initUI];
    
    
}

-(void)initUI{
    headView = [[[NSBundle mainBundle]loadNibNamed:@"redPacketDetailHeadView" owner:nil options:nil] firstObject];
    //需要在didappear中设置
    ViewBorderRadius(headView.headImageView, 3, 1, [UIColor whiteColor]);
    
    self.tableView.tableHeaderView = headView;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorInset = UIEdgeInsetsMake(0,0, 0, 0);
    
    
    
}

#pragma mark - tableViewDelegate & tableViewDateSource
//返回分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//返回分区行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

//每一行高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

//头高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

//设置headview 颜色
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
    UILabel *label = [[UILabel alloc] init];
    label.text = @"1个红包共100积分";
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor lightGrayColor];
    [headerView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(headerView.mas_left).offset(20);
        make.centerY.mas_equalTo(headerView.mas_centerY);
        
    }];
    //灰色线
    UILabel *lineLabel = [[UILabel alloc] init];
    lineLabel.backgroundColor = [UIColor lightGrayColor];
    [headerView addSubview:lineLabel];
    [lineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(headerView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 1));
    }];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    return headerView;
}

//返回每一行的内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //RedPacketDetailTableViewCell
    static NSString* cellIdentifier = @"RedPacketDetailTableViewCell";
    RedPacketDetailTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"RedPacketDetailTableViewCell" owner:nil options:nil]firstObject];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}














- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
