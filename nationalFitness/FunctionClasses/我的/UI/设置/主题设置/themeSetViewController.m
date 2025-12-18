//
//  themeSetViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/8/7.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "themeSetViewController.h"
#import "JQFMDB.h"


@interface themeSetViewController ()

@end

@implementation themeSetViewController{
    
    __weak IBOutlet UITableView *themeSetTableV;
    
    
    NSMutableArray *imageArr;
    JQFMDB *jqFmdb;
    
    CacheKeepBoxEntity *KeepBoxEntity;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"主题设置";
    [self initUI];
    [self initDataSource];
    
    
    
}

-(void)initUI{
    themeSetTableV.tableFooterView = [UIView new];
    
    
    
}

-(void)initDataSource{
    KeepBoxEntity = [self getAllCacheDataEntity];
    imageArr = [NSMutableArray new];
    NSArray *imagearr = @[@"图片",@"图片"];
    for (int i = 0; i<imagearr.count; i++) {
        ThemeSetEntity *entity = [ThemeSetEntity new];
        if (i == 0) {
            entity.themeTitle = @"清新画";
        }else{
            entity.themeTitle = @"常规白";
        }
        entity.version = @"1.1.0";
        entity.picPath = @"图片";
        entity.IsUse = NO;
        [imageArr addObject:entity];
    }
    
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    //建表
    __block BOOL ret = NO;
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        ret = [strongSelf ->jqFmdb jq_createTable:@"zhutishezhi" dicOrModel:[ThemeSetEntity class]];
    }];
    if (ret) {
        for (ThemeSetEntity *entity in imageArr) {
            //插入数据
            __block BOOL rett = NO;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                rett = [strongSelf ->jqFmdb jq_insertTable:@"zhutishezhi" dicOrModel:entity];
            }];
            if (!rett) {
                return;
            }
        }
    }
    //可选 清除缓存
//    BOOL deleteRet = [jqFmdb jq_deleteAllDataFromTable:@"zhutishezhi"];
    
    
    //取缓存
    __block NSArray *arrs = [NSArray new];
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        arrs = [strongSelf ->jqFmdb jq_lookupTable:@"zhutishezhi" dicOrModel:[ThemeSetEntity class] whereFormat:@""];
    }];
    imageArr = [NSMutableArray arrayWithArray:arrs];
    [themeSetTableV reloadData];
}

#pragma mark - tableViewDelegate & tableViewDateSource
//返回分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
//返回分区行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return imageArr.count;
}

//每一行高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
    
}

//返回每一行的内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* cellIdentifier = @"themeSetTableViewCell";
    themeSetTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"themeSetTableViewCell" owner:nil options:nil]firstObject];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    ThemeSetEntity *entity = imageArr[indexPath.row];
    cell.themeEntity = entity;
    //与缓存的index比对
    if (KeepBoxEntity.themeSelectedIndex == indexPath.row) {
        cell.isUseLabel.hidden = NO;
        cell.isUseLabel.text = @"已应用";
        cell.userBtn.hidden = YES;
    }else{
        cell.isUseLabel.hidden = YES;
        cell.userBtn.hidden = NO;
        [cell.userBtn setTitle:@"应用" forState:(UIControlStateNormal)];
    }
    [cell.userBtn addTarget:self action:@selector(yingyongClick:event:) forControlEvents:(UIControlEventTouchUpInside)];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"SpecialMerchantStoryboard" bundle:nil];
//    SpActDetailViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"SpActDetailViewController"];
//    [self.navigationController pushViewController:toCtrol animated:YES];
}

#pragma mark - 应用点击
-(void)yingyongClick:(UIButton *)button event:(UIEvent *)event{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:themeSetTableV];
    NSIndexPath *indexPath = [themeSetTableV indexPathForRowAtPoint:currentTouchPosition];
    if (KeepBoxEntity.themeSelectedIndex != indexPath.row) {
        CacheKeepBoxEntity *entity = [CacheKeepBoxEntity new];
        entity.themeSelectedIndex = indexPath.row;
        
        BOOL ret = [self changeCachewithEntity:entity];
        if (ret) {
            [self initDataSource];
        }
        //改变
    }
    
    
}








- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
