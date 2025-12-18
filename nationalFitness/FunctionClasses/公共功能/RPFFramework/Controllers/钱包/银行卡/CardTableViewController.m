//
//  CardTableViewController.m
//  nationalFitness
//
//  Created by joe on 2020/1/11.
//  Copyright © 2020年 chenglong. All rights reserved.
//

#import "CardTableViewController.h"


#import "SocketModel.h"
#import "SocketRequest.h"


@interface CardTableViewController ()<UITableViewDelegate,UITableViewDataSource,ChatHandlerDelegate>
@property (nonatomic, strong) NSMutableArray<DataBankCardInfo *> *cardInfoArr;       // 银行卡信息数组

@end

@implementation CardTableViewController{
    
    
    SocketModel * socketModel;
    SocketRequest *socketRequest;
    
    BOOL Iskaihu;
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    if (socketModel.delegate != self) {
        socketModel.delegate = self;
    }
    
    
    [self initScoket];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = @"我的银行卡";
    
    
    self.tableView.tableFooterView = [UIView new];
    
    Iskaihu = NO;
    
    
    
}

-(void)initScoket{
    //初始化
    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    //当从登陆界面过来 需要打开下面，这时候
    if (socketModel.isConnected) {
        [socketModel ping];
        if (socketModel.isConnected) {
            
            [socketRequest getBankCardList];
            
            
        }else{
            //设置本地数据
        }
    }else{
        //设置本地数据
    }
}


#pragma mark - 服务器返回
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_BankCardList) {
        Iskaihu = YES;
        if(!chatModel || [chatModel isKindOfClass:[NSNull class]]){
            return;
        }
//        NSDictionary *bankCardDict = chatModel;
//        NSString *card_list = [bankCardDict objectForKey:@"card_list"];
//        NSArray *card_listArr = [self ArrWithJsonString:card_list];
        NSArray *card_listArr = [NSArray arrayWithArray:chatModel];
        
        self.cardInfoArr = [NSMutableArray new];
        for (NSDictionary *dict in card_listArr) {
            DataBankCardInfo *model = [DataBankCardInfo new];
            model.bizProtocolNo = [[dict objectForKey:@"bizProtocolNo"] description];
            model.payProtocolNo = [[dict objectForKey:@"payProtocolNo"] description];
            NSString *str = [[[dict objectForKey:@"cardNo"] description] substringFromIndex:[[[dict objectForKey:@"cardNo"] description] length]-4];
            model.bankName = [[dict objectForKey:@"bankName"] description];
            //[NSString stringWithFormat:@"%@ (%@)",[[dict objectForKey:@"bankName"] description],str]
            model.cardLastNumber = str;
            if ([[[dict objectForKey:@"bankName"] description] containsString:@"中国银行"]) {
                model.logoNamed = @"中国银行";
            }else if ([[[dict objectForKey:@"bankName"] description] containsString:@"建设银行"]){
                model.logoNamed = @"建设银行";
            }else if ([[[dict objectForKey:@"bankName"] description] containsString:@"农业银行"]){
                model.logoNamed = @"农业银行";
            }else if ([[[dict objectForKey:@"bankName"] description] containsString:@"工商银行"]){
                model.logoNamed = @"工商银行";
            }else if ([[[dict objectForKey:@"bankName"] description] containsString:@"民生银行"]){
                model.logoNamed = @"民生银行";
            }else if ([[[dict objectForKey:@"bankName"] description] containsString:@"浦发银行"]){
                model.logoNamed = @"浦发银行";
            }else if ([[[dict objectForKey:@"bankName"] description] containsString:@"招商银行"]){
                model.logoNamed = @"招商银行";
            }
            model.phoneNumber = [[dict objectForKey:@"mobileNo"] description];
            model.bankCardNumber = [[dict objectForKey:@"cardNo"] description];
            model.cardID = [[dict objectForKey:@"cardId"] description];
            //卡类型，0借记卡，1信用卡
//            if ([[[dict objectForKey:@"dcFlag"] description] isEqualToString:@"D"]) {
                model.cardType = @"0";
//            }else{
//                model.cardType = @"1";
//            }
            
//            if([[[dict objectForKey:@"cashFlag"] description] isEqualToString:@"1"]){
                [self.cardInfoArr addObject:model];
//            }
            
        }
        
        [self.tableView reloadData];
        
        
    }else if(messageType == SecretLetterType_BankCardCutResult){
        
        MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"解绑成功" sureBtn:@"确认" cancleBtn:nil];
        alertView.resultIndex = ^(NSInteger index)
        {
            
            [self initScoket];
        };
        [alertView showMKPAlertView];
        
    }else if(messageType == SecretLetterType_UserNotOpenHuiFu){
        Iskaihu = NO;
    }
    
}

-(NSArray *)ArrWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSArray *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


//返回分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.cardInfoArr.count + 1;
}
//返回分区行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

//每一行高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == self.cardInfoArr.count) {
        return 44;
    }
    return 100;
    
}

//头高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if(section == 0){
        return 20;
    }
    return 10;
    
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* cellIdentifier = @"AddCardTableViewCell";
    if (indexPath.section == self.cardInfoArr.count) {
        AddCardTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"AddCardTableViewCell" owner:nil options:nil]firstObject];
        }
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    cellIdentifier = @"CardTableViewCell";
    CardTableViewCell  * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"CardTableViewCell" owner:nil options:nil]firstObject];
    }
    DataBankCardInfo *info = self.cardInfoArr[indexPath.section];
    cell.imageV.image = [UIImage imageNamed:info.logoNamed];
    cell.cardTitleLabel.text = info.bankName;
    if ([info.cardType isEqualToString:@"0"]) {
        cell.cardTypeLabel.text = @"储蓄卡";
    }else{
        cell.cardTypeLabel.text = @"信用卡";
    }
    cell.cardTailLabel.text = info.cardLastNumber;
    
    if ([info.bankName containsString:@"中国银行"]) {
        cell.backView.backgroundColor = UIColorFromRGB(0xC0535B);
    }else if ([info.bankName containsString:@"建设银行"]){
        cell.backView.backgroundColor = UIColorFromRGB(0x3573A5);
    }else if ([info.bankName containsString:@"农业银行"]){
        cell.backView.backgroundColor = UIColorFromRGB(0x28927E);
    }else if ([info.bankName containsString:@"工商银行"]){
        cell.backView.backgroundColor = UIColorFromRGB(0xC0535B);
    }else if ([info.bankName containsString:@"招商银行"]){
        cell.backView.backgroundColor = UIColorFromRGB(0xC0535B);
    }else if ([info.bankName containsString:@"民生银行"]){
        cell.backView.backgroundColor = UIColorFromRGB(0x3573A5);
    }else if ([info.bankName containsString:@"浦发银行"]){
        cell.backView.backgroundColor = UIColorFromRGB(0x145D98);
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    
    if (indexPath.section == self.cardInfoArr.count) {
        //添加银行卡
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"RedPacketStoryboard" bundle:nil];
        AddCardTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"AddCardTableViewController"];
        
        if (self.cardInfoArr.count > 0) {
            toCtrol.cardBank = self.cardInfoArr[0];
        }else if(!Iskaihu){
            [SVProgressHUD showInfoWithStatus:@"请点击充值，完成实名认证"];
            return;
        }
        [self.navigationController pushViewController:toCtrol animated:YES];
    }
    
    

}

#pragma mark - 编辑tableView

/*改变删除按钮的title*/
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"解除绑定";
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle ==UITableViewCellEditingStyleDelete)
    {
        
        DataBankCardInfo *info = self.cardInfoArr[indexPath.section];
        if (info.cardID) {
            [socketRequest catBindCard:info.cardID];
        }
        
//        [carsIDColor removeObjectAtIndex:indexPath.row];
//        [carsNumber removeObjectAtIndex:indexPath.row];
//        //删除row
//        [myCartableView_   deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath]withRowAnimation:UITableViewRowAnimationAutomatic];  //删除对应数据的cell
//        //删除section
//        [messageTableV_ deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]
//                      withRowAnimation:UITableViewRowAnimationFade];
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == self.cardInfoArr.count) {
        return NO;
    }
    return YES;
}



@end
