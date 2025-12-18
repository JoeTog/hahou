//
//  BellSetTableViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/8/8.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "BellSetTableViewController.h"




@interface BellSetTableViewController ()

@end

@implementation BellSetTableViewController{
    
    NSArray *voiceNameArr;
    
    NSArray *voiceCafArr;
    
    //记录选中的按钮
    UIButton *selectedBtn;
    
    JQFMDB *jqFmdb;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"铃声设置";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 34)];
    [backBtn setImage:[UIImage imageNamed:@"everyday1_return"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    self.tableView.tableFooterView = [UIView new];
    [self initSource];
    
}

- (void)backClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initSource{
    
    voiceNameArr = @[@"katalk",@"katalk2"];
    voiceCafArr = @[@"",@""];
    
    
    
}


#pragma mark - tableViewDelegate & tableViewDateSource
//返回分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
//返回分区行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return
    voiceNameArr.count;
}

//每一行高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
    
}

//返回每一行的内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* cellIdentifier = @"BellSetTableViewCell";
    BellSetTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"BellSetTableViewCell" owner:nil options:nil]firstObject];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.titleLabel.text = voiceNameArr[indexPath.row];
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __block NSArray *arr = [NSArray new];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        arr = [strongSelf ->jqFmdb jq_lookupTable:@"xinxiaoxiTongzhi" dicOrModel:[NewMessageNotifyEntity class] whereFormat:@""];
    }];
    NewMessageNotifyEntity *entityy = [NewMessageNotifyEntity new];
    for (NewMessageNotifyEntity *entity in arr) {
        if ([entity.setId isEqualToString:@"lingshengshezhi"]) {
            entityy = entity;
        }
    }
    if ([cell.titleLabel.text isEqualToString:entityy.voiceName]) {
        cell.selectBtn.selected = YES;
        selectedBtn = cell.selectBtn;
    }else{
        cell.selectBtn.selected = NO;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //播放铃声
    SoundControlSingle * single1 = [SoundControlSingle sharedInstanceForSound:voiceNameArr[indexPath.row]];//获取声音对象
//    SoundControlSingle * single2 = [SoundControlSingle sharedInstanceForProjectSound];//获取自定义声音对象
    [single1 play];//播放
    
    BellSetTableViewCell *cell = (BellSetTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    //判断选中的该cell的按钮是否已经为选中
    if (cell.selectBtn.selected) {
//        selectedBtn.selected = NO;
//        selectedBtn = cell.selectBtn;
    }else{
        //如果是 将原来记录选中的按钮取消选中
        selectedBtn.selected = NO;
        cell.selectBtn.selected = YES;
        selectedBtn = cell.selectBtn;
    }
    
    NewMessageNotifyEntity *entity = [NewMessageNotifyEntity new];
    entity.voiceName = voiceNameArr[indexPath.row];
    entity.setId = @"lingshengshezhi";
    //缓存
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    
//    BOOL re = [jqFmdb jq_alterTable:@"xinxiaoxiTongzhi" dicOrModel:entity];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        BOOL rett = [strongSelf ->jqFmdb jq_updateTable:@"xinxiaoxiTongzhi" dicOrModel:entity whereFormat:@"where setId = 'lingshengshezhi'"];
        if (rett) {
            
        }
    }];
    
    
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
