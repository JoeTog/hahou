//
//  SaveSetChoseTableViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/7/24.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "SaveSetChoseTableViewController.h"

@interface SaveSetChoseTableViewController ()

@end

@implementation SaveSetChoseTableViewController{
    
    
    IBOutlet UITableView *SaveSetChoseTableView;
    
    NSArray *dataArr;
    
    //记录选中的按钮 实现单选
    UIButton *selectedBtn_;
    //记录选中的row
    int selectedRow;
    NSString *selectedString;
    
    PickerViewChose *pickview;
    //灰色背景色
    UIView *backV;
    
    UIButton *sureButton;
    
    //记录自定义点击的comment
    //数字
    NSInteger firstCompont;
    //类型  0月 1日 2小时 3秒
    NSInteger secondCompont;
    //月 天 时 秒
    NSArray *companyArr;
    JQFMDB *jqFmdb;
    UIButton *backBtn;
}

-(void)viewWillAppear:(BOOL)animated{
    //self.tableView.backgroundView=[[NFbaseViewController new] setThemeBackgroundImage];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self initUI];
    
    
}

-(void)initUI{
    self.tableView.tableFooterView = [UIView new];
    if ([self.type isEqualToString:@"0"]) {
        dataArr = [NSArray arrayWithObjects:@"30秒",@"一分钟",@"五分钟",@"十分钟",@"二十分钟",@"三十分钟", nil];
    }else if ([self.type isEqualToString:@"1"]){
        dataArr = [NSArray arrayWithObjects:@"三小时",@"六小时",@"九小时",@"十二小时",@"二十四小时",@"三十六小时",@"不删除", nil];
    }
    
    sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sureButton.frame = CGRectMake(0, 0, 40, 30);
    sureButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [sureButton setTitle:@"确定" forState:UIControlStateNormal];
    [sureButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [sureButton addTarget:self action:@selector(sureButtonClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView: sureButton];
//    self.navigationItem.rightBarButtonItem = item;
    
    backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 34)];
    [backBtn setImage:[UIImage imageNamed:@"everyday1_return"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
}

//自定义NAV返回按钮
- (void)backClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

//完成 返回选中按钮值
#pragma mark - 确定 废弃 在commit中实现
-(void)sureButtonClick{
    __weak typeof(self)weakSelf=self;
    if ([self.type isEqualToString:@"1"]) {
        if (selectedString.length == 0) {
            [SVProgressHUD showInfoWithStatus:@"您未设置任何时间"];
            return;
        }
        MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"消息永久清空，不留存档（谨慎使用）" sureBtn:@"确认" cancleBtn:@"取消"];
        alertView.resultIndex = ^(NSInteger index)
        {
            __strong typeof(weakSelf)strongSelf=weakSelf;
            //0阅后隐藏 1关机清空
            [self setClearTimeGuanJi];
            strongSelf.returnBlock(selectedString);
            [strongSelf.navigationController popViewControllerAnimated:YES];
        };
        [alertView showMKPAlertView];
        
    }else if([self.type isEqualToString:@"0"]){
        if (selectedString.length == 0) {
            [SVProgressHUD showInfoWithStatus:@"您未设定任何时间"];
            return;
        }
        __strong typeof(weakSelf)strongSelf=weakSelf;
        [self setClearTimeYuehou];
        strongSelf.returnBlock(selectedString);
        
        [strongSelf.navigationController popViewControllerAnimated:YES];
//        CGFloat a = [self saveLevelcaculate];
        NSLog(@"");
    }
}

//单聊隐藏
-(void)hidenSingleMessageAbout{
    [SVProgressHUD show];
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __block NSArray *arrs = [NSArray new];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        arrs = [strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact class] whereFormat:@""];
    }];
    //单聊所有消息列表
    //    NSMutableArray *singleChatListArr = [[NSMutableArray alloc] initWithCapacity:10];
    //遍历所有单聊会话消息记录
    for (ZJContact *contact in arrs) {
        __block int dataaCount = 0;
        __weak typeof(self)weakSelf=self;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:contact.friend_userid];
        }];
        if (dataaCount > 15) {
            NSLog(@"");
            //如果最后一条数据已经是隐藏状态 则break
            __block NSArray *arr = [NSArray new];
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                arr = [strongSelf ->jqFmdb jq_lookupTable:contact.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,1]];
            }];
            MessageChatEntity *chatEntity = [arr firstObject];
            if ([chatEntity.yuehouYinCang isEqualToString:@"1"]) {
                break;
            }
        }
        __block NSArray *SingleChat = [NSArray new];
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            SingleChat = [strongSelf ->jqFmdb jq_lookupTable:contact.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:@""];
        }];
        if (SingleChat.count > 0) {
            for (MessageChatEntity *chatEntity in SingleChat) {
                BOOL ret = [NFbaseViewController compaTodayDateWithDate:chatEntity.localReceiveTime];
                if (!ret) {
                    //需要隐藏
                    if (![chatEntity.yuehouYinCang isEqualToString:@"1"]){
                        chatEntity.yuehouYinCang = @"1";
                        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//                        NSArray *arrss = [jqFmdb jq_lookupTable:contact.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"where chatId = '%@'",chatEntity.chatId]];
                        __weak typeof(self)weakSelf=self;
                        [jqFmdb jq_inDatabase:^{
                            __strong typeof(weakSelf)strongSelf=weakSelf;
                            BOOL rett = [strongSelf ->jqFmdb jq_updateTable:contact.friend_userid dicOrModel:chatEntity whereFormat:[NSString stringWithFormat:@"where chatId = '%@'",chatEntity.chatId]];
                            if (rett) {
                                NSLog(@"");
                            }
                        }];
                    }
                }else{
                    //从index0开始遍历 当遇到不需要隐藏后 说明后面的也不需要隐藏
                    break;
                }
                NSLog(@"");
            }
        }
        NSLog(@"");
    }
    NSLog(@"");
}

//群聊隐藏
-(void)hidenQunliaoMessageAboutBlock:(void(^)(void))block{
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//    NSError *error;
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    //NSCachesDirectory  NSDocumentDirectory
//    NSString  *cachPath = [ NSSearchPathForDirectoriesInDomains ( NSDocumentDirectory , NSUserDomainMask ,  YES )  objectAtIndex : 0 ];
    NSArray *contents = [jqFmdb jq_selectedAllTableName];
//    NSArray *tableArr = [];
    for (NSString *qunzuChatTable in contents) {
        if ([qunzuChatTable containsString:@"qunzu"] && ![qunzuChatTable containsString:@"Detailid"]&& ![qunzuChatTable containsString:@"liebiao"]) {
            //这里应该都是群聊消息表
            __block NSArray *keyArr = [NSArray new];
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                keyArr = [strongSelf ->jqFmdb jq_columnNameArray:qunzuChatTable];
            }];
            if (keyArr.count >= 26) {
                __block int dataaCount = 0;
                __weak typeof(self)weakSelf=self;
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:qunzuChatTable];
                }];
                if (dataaCount > 15) {
                    __block NSArray *arr = [NSArray new];
                    __weak typeof(self)weakSelf=self;
                    [jqFmdb jq_inDatabase:^{
                        __strong typeof(weakSelf)strongSelf=weakSelf;
                        arr = [strongSelf ->jqFmdb jq_lookupTable:qunzuChatTable dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,1]];
                    }];
                    MessageChatEntity *chatEntity = [arr firstObject];
                    if ([chatEntity.yuehouYinCang isEqualToString:@"1"]) {
                        break;
                    }
                }
                __block NSArray *qunliaoChatArr = [NSArray new];
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    qunliaoChatArr = [strongSelf ->jqFmdb jq_lookupTable:qunzuChatTable dicOrModel:[MessageChatEntity class] whereFormat:@""];
                }];
                MessageChatEntity *qunliaoChatEntity = [qunliaoChatArr firstObject];
                if (qunliaoChatEntity.IsSingleChat == NO) {
                    //进行遍历隐藏
                    for (MessageChatEntity *qunliaoChat in qunliaoChatArr) {
                        BOOL ret = [NFbaseViewController compaTodayDateWithDate:qunliaoChat.localReceiveTime];
                        if (!ret && ![qunliaoChat.yuehouYinCang isEqualToString:@"1"]){
                            qunliaoChat.yuehouYinCang = @"1";
//                            NSString *groupIdName = [NSString stringWithFormat:@"qunzu%@",qunzuChatTable];
                            [self.myManage changeFMDBData:qunliaoChat KeyWordKey:@"chatId" KeyWordValue:qunliaoChat.chatId FMDBID:@"tongxun.sqlite" TableName:qunzuChatTable];
                        }
                    }
                }
            }
        }
    }
    block();
}

//群聊删除 无效
-(void)deleteQunliaoMessageAboutBlock:(void(^)(void))block{
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//    NSError *error;
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    //NSCachesDirectory  NSDocumentDirectory
//    NSString  *cachPath = [ NSSearchPathForDirectoriesInDomains ( NSDocumentDirectory , NSUserDomainMask ,  YES )  objectAtIndex : 0 ];
    NSArray *contents = [jqFmdb jq_selectedAllTableName];
    for (NSString *qunzuChatTable in contents) {
        if ([qunzuChatTable containsString:@"qunzu"] &&![qunzuChatTable containsString:@"Detailid"]&&![qunzuChatTable containsString:@"liebiao"]) {
            //这里应该都是群聊消息表
            __block NSArray *keyArr = [NSArray new];
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                keyArr = [strongSelf ->jqFmdb jq_columnNameArray:qunzuChatTable];
            }];
            if (keyArr.count >= 26) {
                __block NSArray *qunliaoChatArr = [NSArray new];
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    qunliaoChatArr = [strongSelf ->jqFmdb jq_lookupTable:qunzuChatTable dicOrModel:[MessageChatEntity class] whereFormat:@""];
                }];
                MessageChatEntity *qunliaoChatEntity = [qunliaoChatArr firstObject];
                if (qunliaoChatEntity.IsSingleChat == NO) {
                    //进行遍历删除
                    for (MessageChatEntity *qunliaoChat in qunliaoChatArr) {
                        __block BOOL IsShanChuRet = NO;
                        [jqFmdb jq_inDatabase:^{
                            IsShanChuRet = [NFbaseViewController compaTodayDateReturnDeleteWithDate:qunliaoChat.localReceiveTime];
                        }];
                        if (!IsShanChuRet) {
                            [self.myManage deleteAPriceDataBase:@"tongxun.sqlite" InTable:qunzuChatTable DataKind:[MessageChatEntity class] KeyName:@"chatId" ValueName:qunliaoChat.chatId];
                        }
                    }
                }
            }
        }
    }
    block();
}

//单聊删除 无效
//-(void)deleteSingleMessageAbout{
//    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//    NSArray *arrs = [jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact class] whereFormat:@""];
//    for (ZJContact *contact in arrs) {
//        NSArray *SingleChat = [jqFmdb jq_lookupTable:contact.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:@""];
//        if (SingleChat.count > 0) {
//            for (MessageChatEntity *chatEntity in SingleChat) {
//                BOOL IsShanChuRet = [NFbaseViewController compaTodayDateReturnDeleteWithDate:chatEntity.localReceiveTime];
//                if (!IsShanChuRet) {
//                    [self.myManage deleteAPriceDataBase:@"tongxun.sqlite" InTable:contact.friend_userid DataKind:[MessageChatEntity class] KeyName:@"chatId" ValueName:chatEntity.chatId];
//                }
//            }
//        }
//    }
//}


-(NFMyManage *)myManage{
    if (!_myManage) {
        _myManage = [[NFMyManage alloc] init];
    }
    return _myManage;
}


-(void) returnSelectedRow:(ReturnSelectedRow)block{
    if (self.returnBlock != block) {
        self.returnBlock = block;
    }
}

#pragma mark - tableViewDelegate & tableViewDateSource

//cell设置成透明
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //确定section 直接return
    if (indexPath.section == 2) {
        return;
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor whiteColor];
}

//头高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1 &&[self.type isEqualToString:@"1"]) {
        return 0.1;
    }
    return 10;
}

//设置headview 颜色
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
    [headerView setBackgroundColor:[UIColor colorSectionHeader]];
    return headerView;
}

//返回分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    //隐藏 和 删除 都有三个section 但是删除中section1为空的
    return 3;
}

//返回分区行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        if ([self.type isEqualToString:@"0"]) {
            return dataArr.count + 2;
        }else if ([self.type isEqualToString:@"1"]){
            return dataArr.count;
        }
    }else if (section == 1){
        //阅后隐藏才走这里  设置的显示隐藏消息的switch
        return 0;
        return 1;
    }
    return 1;
}

//每一行高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section== 2) {
        return 100;
    }
    if (indexPath.section == 1 && [self.type isEqualToString:@"1"]) {
        return 0.1;
    }
    return 44;
}
//返回每一行的内容
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId;
    if (indexPath.section == 0) {
        if (indexPath.row == dataArr.count && [self.type isEqualToString:@"0"]) {
            cellId = @"zidingyicellId";
            SaveSetCustomTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"SaveSetCustomTableViewCell" owner:nil options:nil]firstObject];
            }
            NSString *yuehouString = [KeepAppBox checkValueForkey:@"yuehouYincangStringZiDingYi"];
            if (yuehouString.length > 0) {
                cell.titleLabel.text = yuehouString;
            }else{
                cell.titleLabel.text = @"未设置";
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        if (indexPath.section == 0 && indexPath.row == 7) {
            cellId = @"cellId";
            SaveSetTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle]loadNibNamed:@"SaveSetTableViewCell" owner:nil options:nil]firstObject];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.titleLabell.text = @"不隐藏";
            if ([cell.titleLabell.text isEqualToString:[KeepAppBox checkValueForkey:@"yuehouYincangString"]]) {
                cell.seclectButton.selected = YES;
            }
            return cell;
        }
        cellId = @"cellId";
        SaveSetTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"SaveSetTableViewCell" owner:nil options:nil]firstObject];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.titleLabell.text = dataArr[indexPath.row];
        if ([self.type isEqualToString:@"0"]) {
            if ([cell.titleLabell.text isEqualToString:[KeepAppBox checkValueForkey:@"yuehouYincangString"]]) {
                cell.seclectButton.selected = YES;
            }
        }else if ([self.type isEqualToString:@"1"]){
            if ([cell.titleLabell.text isEqualToString:[KeepAppBox checkValueForkey:@"guanjiQingkongString"]]) {
                cell.seclectButton.selected = YES;
            }
        }
        return cell;
    }
    if (indexPath.section == 1 && [self.type isEqualToString:@"0"]) {
        //阅后隐藏才有这里
        cellId = @"cellId";
        ShowHidenMessageTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"ShowHidenMessageTableViewCell" owner:nil options:nil]firstObject];
        }
        cell.titleLabell.text = @"显示隐藏消息";
        if ([NFUserEntity shareInstance].showHidenMessage) {
            cell.switchBtn.on = YES;
        }else{
            cell.switchBtn.on = NO;
        }
        [cell.switchBtn addTarget:self action:@selector(switchChange:) forControlEvents:(UIControlEventValueChanged)];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    cellId = @"cellId";
    SaveSetCommitTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"SaveSetCommitTableViewCell" owner:nil options:nil]firstObject];
    }
    [cell.commitBtn addTarget:self action:@selector(commitClick) forControlEvents:(UIControlEventTouchUpInside)];
    cell.commitBtn.backgroundColor = [UIColor colorThemeColor];
    ViewRadius(cell.commitBtn, 3);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

#pragma mark - 确定按钮
-(void)commitClick{
    __weak typeof(self)weakSelf=self;
    if ([self.type isEqualToString:@"1"]) {
        if (selectedString.length == 0) {
//            [SVProgressHUD showInfoWithStatus:@"您未设置任何时间"];
//            return;
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"设置删除消息永久清空，不留存档（谨慎使用）" sureBtn:@"确认" cancleBtn:@"取消"];
        alertView.resultIndex = ^(NSInteger index)
        {
            if (index == 1) {
                return ;
            }
            __strong typeof(weakSelf)strongSelf=weakSelf;
            //0阅后隐藏 1关机清空
            [self setClearTimeGuanJi];
            strongSelf.returnBlock(selectedString);
            [strongSelf.navigationController popViewControllerAnimated:YES];
//            [SVProgressHUD showWithStatus:@"正在删除"];
//            backBtn.userInteractionEnabled = NO;
//            SaveSetChoseTableView.userInteractionEnabled  = NO;
//            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
//                [self deleteSingleMessageAbout];
//                [self deleteQunliaoMessageAboutBlock:^{
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [SVProgressHUD dismiss];
//                        backBtn.userInteractionEnabled = YES;
//                        SaveSetChoseTableView.userInteractionEnabled  = YES;
//                        [strongSelf.navigationController popViewControllerAnimated:YES];
//                    });
//                }];
//            });
        };
        [alertView showMKPAlertView];
    }else if([self.type isEqualToString:@"0"]){
        if (selectedString.length == 0) {
//            [SVProgressHUD showInfoWithStatus:@"您未设定任何时间"];
//            return;
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        __strong typeof(weakSelf)strongSelf=weakSelf;
        [self setClearTimeYuehou];
        strongSelf.returnBlock(selectedString);
        
        
        //对消息进行遍历
        [SVProgressHUD showWithStatus:@"正在隐藏"];
        backBtn.userInteractionEnabled = NO;
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
            [self hidenSingleMessageAbout];
            __weak typeof(self)weakSelf=self;
            [self hidenQunliaoMessageAboutBlock:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    strongSelf ->backBtn.userInteractionEnabled = YES;
                    strongSelf ->SaveSetChoseTableView.userInteractionEnabled  = YES;
                    [strongSelf.navigationController popViewControllerAnimated:YES];
                });
            }];
        });
        
        //        CGFloat a = [self saveLevelcaculate];
        NSLog(@"");
    }
    
    
    
}

#pragma mark - 展示隐藏的消息
-(void)switchChange:(UISwitch *)sender{
    if (sender.isOn) {
        [NFUserEntity shareInstance].showHidenMessage = YES;
    }else{
        [NFUserEntity shareInstance].showHidenMessage = NO;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //当点击了section1 2 不做任何操作
    if (indexPath.section == 1 || indexPath.section == 2) {
        return;
    }
    //
    for (int i = 0; i< dataArr.count; i++) {
        NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
        SaveSetTableViewCell *cell = (SaveSetTableViewCell *)[tableView cellForRowAtIndexPath:index];
        cell.seclectButton.selected = NO;
    }
    if ([self.type isEqualToString:@"0"]) {
        NSIndexPath *index = [NSIndexPath indexPathForRow:6 inSection:0];
        SaveSetCustomTableViewCell *cell = (SaveSetCustomTableViewCell *)[tableView cellForRowAtIndexPath:index];
        cell.titleLabel.text = @"未设置";
        //设置不隐藏按钮为正常
        NSIndexPath *indexx = [NSIndexPath indexPathForRow:7 inSection:0];
        SaveSetTableViewCell *celll = (SaveSetTableViewCell *)[tableView cellForRowAtIndexPath:indexx];
        celll.seclectButton.selected = NO;
    }
        //点击 阅后隐藏的 自定义后
    if (indexPath.section == 0 && indexPath.row == dataArr.count && [self.type isEqualToString:@"0"]) {
        //点击自定义后
        NSIndexPath *index = [NSIndexPath indexPathForRow:6 inSection:0];
        SaveSetCustomTableViewCell *cell = (SaveSetCustomTableViewCell *)[tableView cellForRowAtIndexPath:index];
        //自定义 pickerview
        NSMutableArray *timeArr = [NSMutableArray new];
        for (int i = 1; i<=60; i++) {
            [timeArr addObject:[NSString stringWithFormat:@"%d",i]];
        }
        companyArr = @[@"月",@"日",@"小时",@"分钟",@"秒"];
//        __weak typeof(self)weakSelf=self;
        pickview = [[PickerViewChose alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 200, SCREEN_WIDTH, 200) FirstCompontArr:timeArr SecondCompont:companyArr ThirdCompont:@[] forthCompont:@[] rowHeight:44 ReturnEveryRowBlock:^(BOOL isSure, NSInteger firstRow, NSInteger secondRow, NSInteger thirdRow, NSInteger forthRow) {
            [backV removeFromSuperview];
            if (isSure) {
                //将上面选中的cell 取消选中
                for (int i = 0; i< dataArr.count; i++) {
                    NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
                    SaveSetTableViewCell *cell = (SaveSetTableViewCell *)[tableView cellForRowAtIndexPath:index];
                    cell.seclectButton.selected = NO;
                }
                
                //当点击的是自动义，则点击的row 就是数组的count index
                selectedRow = indexPath.row;
//                NSLog(@"%ld%@",(long)firstRow + 1,companyArr[secondRow]);
                firstCompont = firstRow;
                secondCompont = secondRow;
                cell.titleLabel.text = [NSString stringWithFormat:@"%ld%@",(long)firstRow + 1,companyArr[secondRow]];
                selectedString = cell.titleLabel.text;
            }
        }];
        UIWindow *win = [[[UIApplication sharedApplication] windows] firstObject];
        backV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT*1.2)];
        backV.backgroundColor = [UIColor blackColor];
        backV.alpha = 0.3;
        [win addSubview:backV];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackgroundClickk)];
        [backV addGestureRecognizer:tap];
        [win addSubview:pickview];
//        [pickview setBackImageView:@"底图3"];
        pickview.backgroundColor = [UIColor colorSectionHeader];
    }else{
        if (indexPath.row == 7) {
            SaveSetTableViewCell *cell = (SaveSetTableViewCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:7 inSection:0]];
            cell.seclectButton.selected = YES;
            selectedRow = indexPath.row;
            selectedString = @"不隐藏";
            return;
        }
        //正常点击
        SaveSetTableViewCell *cell = (SaveSetTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.seclectButton.selected = YES;
        selectedRow = indexPath.row;
        selectedString = dataArr[indexPath.row];
    }
    //当点击了section1
//    if (indexPath.section == 1) {
//        SaveSetTableViewCell *cell = (SaveSetTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
//        cell.seclectButton.selected = YES;
//        selectedRow = indexPath.row; //记录section1
//        if (indexPath.row == 0) {
//            selectedString = @"显示隐藏消息";
//        }
//    }
    
    
}

-(void)tapBackgroundClickk{
    __weak typeof(self)weakSelf=self;
    [UIView animateWithDuration:0.5 animations:^{
        //将某个tableview 经过动画缩小到右上角一点
        //        tableView.transform = CGAffineTransformMakeScale(0.000001, 0.0001);
    } completion:^(BOOL finished) {
        __strong typeof(weakSelf)strongSelf=weakSelf;
        [strongSelf ->backV removeFromSuperview];
        [strongSelf ->pickview removeFromSuperview];
    }];
}

-(void)setUserEnabledYES{
    sureButton.userInteractionEnabled = YES;
    
}

-(void)setUserEnabledNO{
    sureButton.userInteractionEnabled = NO;
}

-(void)setClearTimeYuehou{
    [KeepAppBox keepVale:@"" forKey:@"yuehouYincangStringZiDingYi"];
    
    if (selectedRow == 0) {
        [NFUserEntity shareInstance].yuehouYincang = 30;
    }else if (selectedRow == 1){
        [NFUserEntity shareInstance].yuehouYincang = 60;
    }else if (selectedRow == 2){
        [NFUserEntity shareInstance].yuehouYincang = 5*60;
    }else if (selectedRow == 3){
        [NFUserEntity shareInstance].yuehouYincang = 10*60;
    }else if (selectedRow == 4){
        [NFUserEntity shareInstance].yuehouYincang = 20*60;
    }else if (selectedRow == 5){
        [NFUserEntity shareInstance].yuehouYincang = 30*60;
    }else if (selectedRow == dataArr.count){
        //点击的自定义 设置
        //类型  0月 1日 2小时 3秒
        if (secondCompont == 0) {
            [NFUserEntity shareInstance].yuehouYincang = 30*24*3600*(firstCompont+1);
        }else if (secondCompont == 1){
            [NFUserEntity shareInstance].yuehouYincang = 24*3600*(firstCompont+1);
        }else if (secondCompont == 2){
            [NFUserEntity shareInstance].yuehouYincang = 3600*(firstCompont+1);
        }else if (secondCompont == 3){
            [NFUserEntity shareInstance].yuehouYincang = 60 * (firstCompont+1);
        }else if (secondCompont == 4){
            [NFUserEntity shareInstance].yuehouYincang = firstCompont+1;
        }
        //保存自定义
        [KeepAppBox keepVale:[NSString stringWithFormat:@"%ld%@",firstCompont+1,companyArr[secondCompont]] forKey:@"yuehouYincangStringZiDingYi"];
    }
    
    [KeepAppBox keepVale:[NSString stringWithFormat:@"%ld",[NFUserEntity shareInstance].yuehouYincang] forKey:@"yuehouYincangStringCount"];
    
    //不隐藏设置 0长度
    if ([selectedString containsString:@"不隐藏"]) {
        [KeepAppBox keepVale:@"" forKey:@"yuehouYincangStringCount"];
        
    }
//    else if ([selectedString containsString:@"显示隐藏消息"]){
//        //显示隐藏 设置特殊字符
//        [KeepAppBox keepVale:@"showHiden" forKey:@"yuehouYincangStringCount"];
//    }
    
    
    
}


-(void)setClearTimeGuanJi{
    if (selectedRow == 0) {
        [NFUserEntity shareInstance].guanjiQingkong = 3*3600;
    }else if (selectedRow == 1){
        [NFUserEntity shareInstance].guanjiQingkong = 6*3600;
    }else if (selectedRow == 2){
        [NFUserEntity shareInstance].guanjiQingkong = 9*3600;
    }else if (selectedRow == 3){
        [NFUserEntity shareInstance].guanjiQingkong = 12*3600;
    }else if (selectedRow == 4){
        [NFUserEntity shareInstance].guanjiQingkong = 24*3600;
    }else if (selectedRow == 5){
        [NFUserEntity shareInstance].guanjiQingkong = 36*3600;
    }else if (selectedRow == 6){
        //设置为 从不
        [NFUserEntity shareInstance].guanjiQingkong = 0;
    }
    [KeepAppBox keepVale:[NSString stringWithFormat:@"%ld",[NFUserEntity shareInstance].guanjiQingkong] forKey:@"guanjiQingkongCount"];
}

#pragma mark - 计算安全等级
-(CGFloat)saveLevelcaculate{
    CGFloat starValue = 0;
    //关机清空
    NSString *guanjiQingkong = [KeepAppBox checkValueForkey:@"guanjiQingkongCount"];
    NSInteger guanjiQingkongCount = [guanjiQingkong integerValue];
    //设置了关机清空 则加1
//    if (guanjiQingkongCount <= 36*3600) {
//        starValue += 2;
//    }
    if (guanjiQingkongCount <= 3*3600 &&guanjiQingkongCount != 0) {
        starValue += 4;
    }else if (guanjiQingkongCount <= 6*3600&&guanjiQingkongCount != 0){
        starValue += 3.5;
    }else if (guanjiQingkongCount <= 12*3600&&guanjiQingkongCount != 0){
        starValue += 3;
    }else if (guanjiQingkongCount <= 36*3600&&guanjiQingkongCount != 0){
        starValue += 2.5;
    }else{
        starValue += 1;
    }
    
    //阅后隐藏
    NSString *yuehouYincangString = [KeepAppBox checkValueForkey:@"yuehouYincangStringCount"];
    NSInteger yuehouYincangStringCount = [yuehouYincangString integerValue];
    if (yuehouYincangStringCount <= 60 && yuehouYincangStringCount != 0) {
        starValue += 6;
    }else if (yuehouYincangStringCount <= 5*60 && yuehouYincangStringCount != 0){
        starValue += 5;
    }else if (yuehouYincangStringCount <= 10*60 && yuehouYincangStringCount != 0){
        starValue += 4.5;
    }else if (yuehouYincangStringCount <= 20*60 && yuehouYincangStringCount != 0){
        starValue += 4;
    }else if (yuehouYincangStringCount <= 30*60 && yuehouYincangStringCount != 0){
        starValue += 3.5;
    }else{
        starValue += 2;
    }
    
    return starValue;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
