//
//  SendTableViewController.m
//  nationalFitness
//
//  Created by joe on 2020/6/24.
//  Copyright © 2020 chenglong. All rights reserved.
//

#import "SendTableViewController.h"
#import "NFHeadImageView.h"



#import "SocketModel.h"
#import "SocketRequest.h"


@interface SendTableViewController ()<UITableViewDelegate, UITableViewDataSource,ChatHandlerDelegate>

@property(nonatomic,strong)NSDictionary * dataDic;


@end

@implementation SendTableViewController{
    
    //状态
    __weak IBOutlet NFHeadImageView *stateImageV;
    //待xxx确认收款a
    __weak IBOutlet UILabel *waitSureLabel;
    //金额
    __weak IBOutlet UILabel *accountLabel;
    //1天内。。。
    __weak IBOutlet UILabel *systemDetailLabel;
    
//确认收款按钮
    __weak IBOutlet UIButton *sureBtn;
    
    //转账时间
    __weak IBOutlet UILabel *transterTimeLabel;
    
    //确认收款时间
    __weak IBOutlet UILabel *receiveTimeLabel;
    
    //流水号
    __weak IBOutlet UILabel *PayNumLabel;
    
    
    
    SocketModel * socketModel;
    SocketRequest *socketRequest;
    
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (socketModel.delegate != self) {
        socketModel.delegate = self;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if(self.redDetailDict && [self.redDetailDict isKindOfClass:[NSDictionary class]]){
            
    //        NSDictionary *dict = @{@"content":[self.redDetailDict objectForKey:@"content"],
    //                               @"list":@[],
    //                               @"count":[self.redDetailDict objectForKey:@"count"],
    //                               @"senduserId":[self.redDetailDict objectForKey:@"senduserId"],
    //                               @"totalMoney":[self.redDetailDict objectForKey:@"totalMoney"]
    //                               };
            
            self.dataDic = self.redDetailDict;
            //self.dataArray = [self.redDetailDict objectForKey:@"list"];
            //[self buildView];
            [self refreshDetailInfo];
            [self initScoket];
        }else{
            
            [self initScoket];
        }
    
    
}


- (IBAction)backClickk:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}




#pragma mark - 初始化scoket
-(void)initScoket{
    //获取单例
    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    
    //检查红包
    //[socketRequest RedPacketDetail:@{@"redpacketId":self.redpacketId}];
    
    //[self refreshDetailInfo];
    
    
    
}

-(void)refreshDetailInfo{
    
    if([self.dataDic objectForKey:@""]){
        stateImageV.image = [UIImage imageNamed:@""];
    }else if (YES){
        
    }
    waitSureLabel.text = [NSString stringWithFormat:@"待xxx确认收款"];
    accountLabel.text = [NSString stringWithFormat:@"￥1.00"];
    //systemDetailLabel.text = [NSString stringWithFormat:@"1天内朋友未确认，将退还给您。"];
    
    
    transterTimeLabel.text = [NSString stringWithFormat:@"转账时间：2020-06-24 10:32:22"];
    receiveTimeLabel.text = [NSString stringWithFormat:@"收款时间：2020-06-24 10:35:22"];
    
    
    if([self.type isEqualToString:@"0"]){
        stateImageV.image = [UIImage imageNamed:@"转账等待"];
        if(self.isOverDue){
            waitSureLabel.text = [NSString stringWithFormat:@"已过期"];
        }else{
            waitSureLabel.text = [NSString stringWithFormat:@"待%@确认收款",self.singleContactEntity.friend_nickname];
        }
        accountLabel.text = [NSString stringWithFormat:@"￥%.2f",[[self.dataDic objectForKey:@"totalMoney"] floatValue]/100];
        transterTimeLabel.text = [NSString stringWithFormat:@"转账时间：%@",[self.dataDic objectForKey:@"datetime"]];
        PayNumLabel.text = [NSString stringWithFormat:@"流水号：%@",[self.dataDic objectForKey:@"order_id"]];
        sureBtn.hidden = YES;
        receiveTimeLabel.hidden = YES;
        
    }else if ([self.type isEqualToString:@"1"]){
        stateImageV.image = [UIImage imageNamed:@"转账成功"];
        waitSureLabel.text = [NSString stringWithFormat:@"%@已收款",self.singleContactEntity.friend_nickname];
        accountLabel.text = [NSString stringWithFormat:@"￥%.2f",[[self.dataDic objectForKey:@"totalMoney"] floatValue]/100];
        transterTimeLabel.text = [NSString stringWithFormat:@"转账时间：%@",[self.dataDic objectForKey:@"datetime"]];
        PayNumLabel.text = [NSString stringWithFormat:@"流水号：%@",[self.dataDic objectForKey:@"order_id"]];
        NSArray *arr = [self.dataDic objectForKey:@"list"];
        if(arr.count > 0){
            NSDictionary *info = [arr firstObject];
            receiveTimeLabel.text = [NSString stringWithFormat:@"收款时间：%@",[self.dataDic objectForKey:@"datetime"]];
        }
        sureBtn.hidden = YES;
        systemDetailLabel.hidden = YES;
        receiveTimeLabel.hidden = NO;
        
    }else if([self.type isEqualToString:@"2"]){
        
        stateImageV.image = [UIImage imageNamed:@"转账等待"];
        waitSureLabel.text = [NSString stringWithFormat:@"待确认收款"];
        accountLabel.text = [NSString stringWithFormat:@"￥%.2f",[[self.dataDic objectForKey:@"totalMoney"] floatValue]/100];
        transterTimeLabel.text = [NSString stringWithFormat:@"转账时间：%@",[self.dataDic objectForKey:@"datetime"]];
        PayNumLabel.text = [NSString stringWithFormat:@"流水号：%@",[self.dataDic objectForKey:@"order_id"]];
        sureBtn.hidden = NO;
        receiveTimeLabel.hidden = YES;
        
    }else if([self.type isEqualToString:@"3"]){
        
        stateImageV.image = [UIImage imageNamed:@"转账成功"];
        waitSureLabel.text = [NSString stringWithFormat:@"已收款"];
        accountLabel.text = [NSString stringWithFormat:@"￥%.2f",[[self.dataDic objectForKey:@"totalMoney"] floatValue]/100];
        transterTimeLabel.text = [NSString stringWithFormat:@"转账时间：%@",[self.dataDic objectForKey:@"datetime"]];
        PayNumLabel.text = [NSString stringWithFormat:@"流水号：%@",[self.dataDic objectForKey:@"order_id"]];
        NSArray *arr = [self.dataDic objectForKey:@"list"];
        if(arr.count > 0){
            NSDictionary *info = [arr firstObject];
            receiveTimeLabel.text = [NSString stringWithFormat:@"收款时间：%@",[self.dataDic objectForKey:@"datetime"]];
        }
         
        sureBtn.hidden = YES;
        systemDetailLabel.hidden = YES;
        receiveTimeLabel.hidden = NO;
        
    }
    
    
}

#pragma mark - 收到服务器消息
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
     if(messageType == SecretLetterType_RedOverdue){
         
        [SVProgressHUD dismiss];
         
        // self.redDetailDict = chatModel;
        self.isOverDue = YES;
        self.dataDic = chatModel;
        //self.dataArray = [self.dataDic objectForKey:@"list"];
        
        [self refreshDetailInfo];
    }else if(messageType == SecretLetterType_openPacketSuccess){
        
        [SVProgressHUD show];
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
            [NSThread sleepForTimeInterval:1];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [SVProgressHUD dismiss];
                
                [socketRequest RedPacketDetail:@{@"redpacketId":self.redpacketId}];
            });
        });
        
        
        
    }else if(messageType == SecretLetterType_lookPacket){
        
        [SVProgressHUD dismiss];
        
        self.dataDic = chatModel;
        self.redDetailDict = chatModel;
        self.type = @"3";
        [self refreshDetailInfo];
    }
    
}



- (IBAction)sureClick:(id)sender {
    
    [socketRequest pickRedPacket:@{@"redpacketId":self.redpacketId}];
    
    
}







@end
