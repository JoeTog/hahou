//
//  NewMessageNotificateTableViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/7/14.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NewMessageNotificateTableViewController.h"
#import "JQFMDB.h"


@interface NewMessageNotificateTableViewController ()<ChatHandlerDelegate>

@end

@implementation NewMessageNotificateTableViewController{
    
    //接收新消息通知switch
    __weak IBOutlet UISwitch *receiveNewMessageSwitch;
    //推送
    __weak IBOutlet UISwitch *JPushSwitch;
    
    
    //声音
    __weak IBOutlet UISwitch *soundSwitch;
    
    //震动
    __weak IBOutlet UISwitch *shakeSwitch;
    //铃声
    __weak IBOutlet UILabel *bellName;
    
    
    JQFMDB *jqFmdb;
    SocketModel * socketModel;
    SocketRequest *socketRequest;
    
}

-(void)viewWillAppear:(BOOL)animated{
    //self.tableView.backgroundView=[[NFbaseViewController new] setThemeBackgroundImage];
    [self.tableView reloadData];
    [self initColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"新消息通知";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self initUI];
    [self initSocket];
    
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __block NSArray *arr = [NSArray new];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        arr = [strongSelf ->jqFmdb jq_lookupTable:@"xinxiaoxiTongzhi" dicOrModel:[NewMessageNotifyEntity class] whereFormat:@""];
    }];
    
    for (NewMessageNotifyEntity *entity in arr) {
        if ([entity.setId isEqualToString:@"jieshouxiaoxiTongzhi"]) {
            //设置接收新消息通知
            receiveNewMessageSwitch.on = entity.receiveNewMessageNotify;
        }else if ([entity.setId isEqualToString:@"sound"]){
            //设置声音
            soundSwitch.on = entity.soundNotify;
        }else if ([entity.setId isEqualToString:@"shake"]){
            //设置震动
            shakeSwitch.on = entity.ShakeNotify;
        }
    }
    //设置 是否允许推送switch
    if ([JPUSHService registrationID] && [NFUserEntity shareInstance].IsCloseJPush) {
        JPushSwitch.on = NO;
    }
    
}


-(void)initUI{
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 34)];
    [backBtn setImage:[UIImage imageNamed:@"everyday1_return"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    self.tableView.tableFooterView = [UIView new];
    
}

-(void)initColor{
    self.firstLabel.textColor = [UIColor colorMainTextColor];
    self.secondLabel.textColor = [UIColor colorMainTextColor];
    self.thirdLabel.textColor = [UIColor colorMainTextColor];
    self.forthLabel.textColor = [UIColor colorMainTextColor];
    self.fifthLabel.textColor = [UIColor colorMainTextColor];
    
    self.firstLabel.font = [UIFont fontMainText];
    self.secondLabel.font = [UIFont fontMainText];
    self.thirdLabel.font = [UIFont fontMainText];
    self.forthLabel.font = [UIFont fontMainText];
    self.fifthLabel.font = [UIFont fontMainText];
    
}

-(void)initSocket{
    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.delegate = self;
}


- (void)backClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 收到服务器消息
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_PersonalInfoSet) {
        //JPushSwitch
        if (JPushSwitch.on) {
            //返回 是否开启推送成功
            
        }else{
            //返回 是否关闭推送成功
            
        }
    }
}

#pragma mark - 接受新消息通知 将缓存设置修改
- (IBAction)receiveNewMessageSwitch:(UISwitch *)sender {
    NSLog(@"%d",sender.on);
    NewMessageNotifyEntity *entity = [NewMessageNotifyEntity new];
    entity.receiveNewMessageNotify = sender.on;
    entity.setId = @"jieshouxiaoxiTongzhi";
    //更新缓存
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __block BOOL rett;
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        rett = [strongSelf ->jqFmdb jq_updateTable:@"xinxiaoxiTongzhi" dicOrModel:entity whereFormat:@"where setId = 'jieshouxiaoxiTongzhi'"];
    }];
    //如果没成功 将状态还原
    if (!rett) {
        sender.on = !sender.on;
    }
//    NSArray *arr = [jqFmdb jq_lookupTable:@"xinxiaoxiTongzhi" dicOrModel:[NewMessageNotifyEntity class] whereFormat:@"where setId = 'jieshouxiaoxiTongzhi'"];

}

#pragma mark - 推送设置 是否允许推送
- (IBAction)notificationSwitch:(UISwitch *)sender {
    if (![ClearManager getNetStatus] || !socketModel.isConnected) {
        [SVProgressHUD showInfoWithStatus:@"未连接到服务器!"];
        return;
    }
    if (sender.isOn && [JPUSHService registrationID]) {
        MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"当系统通知中关闭多信推送，这里的允许推送设置将失效!" sureBtn:@"确认" cancleBtn:@"取消"];
        alertView.resultIndex = ^(NSInteger index)
        {
            if (index == 2) {
                [NFUserEntity shareInstance].IsCloseJPush = NO;
                [socketRequest setJPUSHServiceId];//设置推送id
            }else if (index == 1){
                NSLog(@"");
                sender.on = NO;
            }
        };
        [alertView showMKPAlertView];
        
    }else if (!sender.isOn && [JPUSHService registrationID]){
        [NFUserEntity shareInstance].IsCloseJPush = YES;
        [NFUserEntity shareInstance].JPushId = @"";
        [socketRequest clearJPUSHServiceId];//关闭推送 设置推送id为nil
    }else if(sender.isOn){
        NSLog(@"");
//        sender.on = !sender.on;
        [SVProgressHUD showInfoWithStatus:@"未获取到推送id"];
    }else if (!sender.isOn){
        [NFUserEntity shareInstance].IsCloseJPush = YES;
        [NFUserEntity shareInstance].JPushId = @"";
    }
    
    
}



#pragma mark - 声音 将缓存设置修改
- (IBAction)soundSwitch:(UISwitch *)sender {
    NSLog(@"%d",sender.on);
    NewMessageNotifyEntity *entity = [NewMessageNotifyEntity new];
    entity.soundNotify = sender.on;
    entity.setId = @"sound";
    //更新缓存
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __block BOOL rett;
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        rett = [strongSelf ->jqFmdb jq_updateTable:@"xinxiaoxiTongzhi" dicOrModel:entity whereFormat:@"where setId = 'sound'"];
    }];
    //如果没成功 将状态还原
    if (!rett) {
        sender.on = sender.on;
    }
}





#pragma mark - 震动 将缓存设置修改
- (IBAction)shockSwitch:(UISwitch *)sender {
    NSLog(@"%d",sender.on);
    NewMessageNotifyEntity *entity = [NewMessageNotifyEntity new];
    entity.ShakeNotify = sender.on;
    entity.setId = @"shake";
    //更新缓存
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __block BOOL rett;
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        rett = [strongSelf ->jqFmdb jq_updateTable:@"xinxiaoxiTongzhi" dicOrModel:entity whereFormat:@"where setId = 'shake'"];
    }];
    //如果没成功 将状态还原
    if (!rett) {
        sender.on = sender.on;
    }
}


//cell设置成透明
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

//头高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return 25;
    }
    return 10;
    
}

//设置headview 颜色
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
        //    [headerView setBackgroundColor:UIColorFromRGB(0xebebf1)];
        [headerView setBackgroundColor:[UIColor colorSectionHeader]];
        return headerView;
    }
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 25)];
    //    [headerView setBackgroundColor:UIColorFromRGB(0xebebf1)];
    [headerView setBackgroundColor:[UIColor colorSectionHeader]];
    return headerView;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1 && indexPath.row == 0) {
        //设置铃声 BellSetTableViewController
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MineStoryboard" bundle:nil];
        BellSetTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"BellSetTableViewController"];
        [self.navigationController pushViewController:toCtrol animated:YES];
    }
}

-(void)viewDidUnload{
    [super viewDidUnload];
    NSLog(@"viewDidUnload");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"\n\n\n\n\ndidReceiveMemoryWarning\n\n\n\n\n");
    // Dispose of any resources that can be recreated.
}

@end
