//
//  ZJContactDetailTableViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/8/8.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "ZJContactDetailTableViewController.h"
#import "ZJContactDetailHeadView.h"
#import "UIColor+RYChat.h"

#define neisuoHeight SCREEN_HEIGHT - 200

@interface ZJContactDetailTableViewController ()<UIGestureRecognizerDelegate,UITableViewDelegate, UITableViewDataSource>

@end

@implementation ZJContactDetailTableViewController{
    
    //免费聊天按钮
    
    ZJContactDetailHeadView *headView;
    
}

-(void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:YES]; //这里不注释会影响动态哪里点击头像聊天
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    //headview高度
//    CGFloat height = kTabBarHeight >49?neisuoHeight-kTabbarMoreHeight-kStatusBarMoreHeight:neisuoHeight;
//    //    headView.frame = CGRectMake(0, -(neisuoHeight), SCREEN_WIDTH, height);
//    if (kTabBarHeight >49) {
//        NSLog(@"%f",neisuoHeight-kTabbarMoreHeight-kStatusBarMoreHeight);
//        headView.frame = CGRectMake(0, -(neisuoHeight), SCREEN_WIDTH, neisuoHeight-kTabbarMoreHeight-kStatusBarMoreHeight);
//    }else{
//        headView.frame = CGRectMake(0, -(neisuoHeight), SCREEN_WIDTH, neisuoHeight);
//    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self initUI];
    
}

-(void)initUI{
    //设置tableview 内缩 减去
    if (kTabBarHeight >49) {
        self.tableView.contentInset = UIEdgeInsetsMake(neisuoHeight - kTabbarMoreHeight - kStatusBarMoreHeight, 0, 0, 0);
    }else{
        self.tableView.contentInset = UIEdgeInsetsMake(neisuoHeight, 0, 0, 0);
    }
    //设置headview
    headView = [[[NSBundle mainBundle]loadNibNamed:@"ZJContactDetailHeadView" owner:nil options:nil] firstObject];
    //设置位置为tableview内缩大小
    //headview高度
    headView.frame = CGRectMake(0, -(neisuoHeight), SCREEN_WIDTH, neisuoHeight);
    [headView.popBtn addTarget:self action:@selector(popClick) forControlEvents:(UIControlEventTouchUpInside)];
    
//    [headView.xiangceBtn addTarget:self action:@selector(xiangceClick) forControlEvents:(UIControlEventTouchUpInside)];
    headView.showMoreBtn.hidden = YES;
    [headView.showMoreBtn addTarget:self action:@selector(showMoreClick) forControlEvents:(UIControlEventTouchUpInside)];
    
    [headView.shoucangBtn setImage:[UIImage imageNamed:@"联系人详情收藏选中"] forState:(UIControlStateSelected)];
    [headView.shoucangBtn addTarget:self action:@selector(shoucangClick:) forControlEvents:(UIControlEventTouchUpInside)];
    headView.closeTopConstaint.constant = kTabBarHeight >49 ?50:30;;
    [self.tableView addSubview:headView];
    
    [self.nameEditBtn setTitleColor:[UIColor colorMainTextColor] forState:(UIControlStateNormal)];
    //来自哪里 联系人 还是 群聊  0联系人 1群聊 2单聊
    if ([self.SourceFrom isEqualToString:@"0"]) {
        if (self.contant.friend_comment_name.length > 0) {
            [self.nameEditBtn setTitle:self.contant.friend_nickname forState:(UIControlStateNormal)];
            self.userNameLabel.text = [NSString stringWithFormat:@"%@ (%@)",self.contant.friend_username?self.contant.friend_username:self.contant.user_name,self.contant.friend_originalnickname];
        }else{
            [self.nameEditBtn setTitle:self.contant.friend_nickname forState:(UIControlStateNormal)];
            self.userNameLabel.text = self.contant.friend_username?self.contant.friend_username:self.contant.user_name;//username
        }
        
        
    }else if ([self.SourceFrom isEqualToString:@"1"]){
        headView.showMoreBtn.hidden = NO;
        if (self.contant.friend_comment_name.length > 0) {
            [self.nameEditBtn setTitle:self.contant.friend_nickname forState:(UIControlStateNormal)];
            self.userNameLabel.text = [NSString stringWithFormat:@"%@(%@)",self.contant.friend_username?self.contant.friend_username:self.contant.user_name,self.contant.friend_originalnickname];
        }else{
            [self.nameEditBtn setTitle:self.contant.in_group_name?self.contant.in_group_name:self.contant.friend_nickname forState:(UIControlStateNormal)];
            self.userNameLabel.text = self.contant.friend_username?self.contant.friend_username:self.contant.user_name;//username
        }
        
        
    }else if ([self.SourceFrom isEqualToString:@"2"]){
        if (self.contant.friend_comment_name.length > 0) {
            [self.nameEditBtn setTitle:self.contant.friend_nickname forState:(UIControlStateNormal)];
            self.userNameLabel.text = [NSString stringWithFormat:@"%@(%@)",self.contant.friend_username?self.contant.friend_username:self.contant.user_name,self.contant.friend_originalnickname];
        }else{
            [self.nameEditBtn setTitle:self.contant.friend_nickname forState:(UIControlStateNormal)];
            self.userNameLabel.text = self.contant.friend_username?self.contant.friend_username:self.contant.user_name;//username
        }
        
        
    }
    
    //    [self.HeadBtn sd_setImageWithURL:[NSURL URLWithString:self.contant.iconUrl] forState:(UIControlStateNormal) placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
//    [self.nfHeadImageV ShowHeadImageWithUrlStr:self.contant.iconUrl withUerId:nil completion:^(BOOL success, UIImage *image) {
//        
//    }];
    
}

//点击界面上的按钮
-(void)clickWhichIndex:(clickPopOrCameraOrShoucang)block{
    if (self.clickWhich != block) {
        self.clickWhich = block;
    }
}

#pragma mark - 返回
-(void)popClick{
    self.clickWhich(0);
}

#pragma mark - 相册点击 //无用
-(void)xiangceClick{
    self.clickWhich(1);
    
}

//点击右上角更多 使用中
-(void)showMoreClick{
    
    self.clickWhich(1);
}


#pragma mark - 收藏
-(void)shoucangClick:(UIButton *)sender{
    self.clickWhich(2);
    sender.selected = !sender.selected;
    //并缓存
    
}

#pragma mark - 拉伸图片
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat y = scrollView.contentOffset.y;
    
    CGRect frame = headView.frame;
    frame.origin.y = y;
    frame.size.height = - y;
    
    headView.frame = frame;
    if (-y - (SCREEN_HEIGHT - 200) > 80) {
        //返回10 手势
        self.clickWhich(10);
    }
}

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//
//    return 200;
//}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"\n\n\n\n\ndidReceiveMemoryWarning\n\n\n\n\n");
    // Dispose of any resources that can be recreated.
}


@end
