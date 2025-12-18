//
//  AddFriendOrGroupdetailViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/7/3.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "AddFriendOrGroupdetailViewController.h"

@interface AddFriendOrGroupdetailViewController ()<ChatHandlerDelegate>

@property(nonatomic,strong)HCDTimer *timer;

@end

@implementation AddFriendOrGroupdetailViewController{
    
    //用户头像
    __weak IBOutlet UIImageView *headImageV;
    //用户名
    __weak IBOutlet UILabel *nameLabel;
    //发送请求按钮
    __weak IBOutlet UIButton *sendAddBtn;
    //发送按钮top约束
    __weak IBOutlet NSLayoutConstraint *sendBtnTopConstaint;
    
    //背景图片宽度
    __weak IBOutlet NSLayoutConstraint *backImageWidthConstaint;
    
    __weak IBOutlet UIImageView *backImageV;
    
    //头像宽度约束
    __weak IBOutlet NSLayoutConstraint *headViewWidthConstaint;
    
    SocketModel * socketModel;
    SocketRequest *socketRequest;
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [self.timer invalidate];
    self.timer = nil;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (socketModel.delegate != self) {
        socketModel.delegate = self;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self.addFriendType isEqualToString:@"0"]) {
        
    }else if ([self.addFriendType isEqualToString:@"1"]){
        self.title = @"添加好友";
    }else if ([self.addFriendType isEqualToString:@"2"]){
        self.title = @"添加群组";
    }
    [SVProgressHUD dismiss];
    [self initUI];
    [self initScoket];
    
}

-(void)initUI{
    self.title = @"添加好友";
    
    ViewRadius(sendAddBtn, sendAddBtn.frame.size.width/2);
    sendAddBtn.backgroundColor = [UIColor colorThemeColor];
    sendBtnTopConstaint.constant = SCREEN_WIDTH/7;
    
    nameLabel.text = self.addFriendName;
    nameLabel.textColor = [UIColor colorThemeColor];
    nameLabel.font = [UIFont fontWithName:@"Courier-Bold" size:18];
    if ([self.headPicpath containsString:@"http"]) {
        [headImageV sd_setImageWithURL:[NSURL URLWithString:self.headPicpath] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
    }else{
//        if ([self.headPicpath containsString:@"head_man"]) {
//            [headImageV sd_setImageWithURL:[NSURL URLWithString:self.headPicpath] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
//        }else{
            if ([self.headPicpath containsString:@"http"] || [self.headPicpath containsString:@"wx.qlogo.cn"]) {
                [headImageV sd_setImageWithURL:[NSURL URLWithString:self.headPicpath] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
            }else{
                [headImageV sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,self.headPicpath]] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
            }
//        }
    }
    
//    backImageV.userInteractionEnabled = YES;
    backImageV.image = [UIImage imageNamed:@"波纹背景"];
    backImageV.backgroundColor = nil;
    
    //背景图片宽度约束
    backImageWidthConstaint.constant = SCREEN_WIDTH/5*4;
    //头像宽度约束
    headViewWidthConstaint.constant = (SCREEN_WIDTH/5*4) * .25;
    ViewRadius(headImageV, headImageV.frame.size.width/2);
    __weak typeof(self)weakSelf=self;
    self.timer = [HCDTimer repeatingTimerWithTimeInterval:1 block:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        BYRadarView * radView = [[BYRadarView alloc] initWithFrame:backImageV.bounds];
        radView.backgroundColor = [UIColor clearColor];
        [strongSelf ->backImageV addSubview:radView];
    }];
    
//    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
//    [headImageV addGestureRecognizer:tap];
    
}

#pragma mark - 链接scoket聊天
-(void)initScoket{
    //初始化
    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    
}

//-(void)hideMBHUD{
//    [MBProgressHUD hideHUD];
//}

#pragma mark - 发送好友请求
-(void)sendFriendAddRequest{
    if ([SVProgressHUD isVisible]) {
        [MBProgressHUD showTitleToView:self.view postion:NHHUDPostionBottom title:@"请勿重复操作!"];
        return;
    }
    [socketRequest sendFriendAddRequest:self.addFriendName];
}


#pragma mark - 收到服务器消息
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_FriendAddSendSuccess) {
        [SVProgressHUD dismiss];
        MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:@"请求已发送" sureBtn:@"确认" cancleBtn:nil];
        alertView.resultIndex = ^(NSInteger index)
        {
//            if (index == 2) {
                [self.navigationController popViewControllerAnimated:YES];
//            }
        };
        [alertView showMKPAlertView];
    }
}


#pragma mark - 发送请求
- (IBAction)sendAddApplicationClick:(id)sender {
    if (![ClearManager getNetStatus]) {
        [SVProgressHUD showInfoWithStatus:@"请检查网络设置"];
        return;
    }
    if ([[NFUserEntity shareInstance].connectStatus isEqualToString:@"1"]) {
        [SVProgressHUD showInfoWithStatus:@"未连接到服务器"];
        return;
    }
    [NFUserEntity shareInstance].isNeedRefreshFriendList = YES;
    [self sendFriendAddRequest];
    
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kGoto_Home_afterActSuccess object:nil];
//    [self.navigationController popViewControllerAnimated:YES];
    
}

//懒加载
-(NSMutableDictionary *)parms{
    if (!_parms) {
        _parms = [[NSMutableDictionary alloc] init];
    }
    return _parms;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"\n\n\n\n\ndidReceiveMemoryWarning\n\n\n\n\n");
    // Dispose of any resources that can be recreated.
    
    
    
    
}



@end
