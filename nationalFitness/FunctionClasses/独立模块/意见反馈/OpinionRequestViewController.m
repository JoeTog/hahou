//
//  OpinionRequestViewController.m
//  nationalFitness
//
//  Created by 童杰 on 2016/12/22.
//  Copyright © 2016年 chenglong. All rights reserved.
//

#import "OpinionRequestViewController.h"
#import "PopView.h"
#import "NFMineManager.h"
#import "NFMineEntity.h"
#import "MKPAlertView.h"
#import "SocketModel.h"

@interface OpinionRequestViewController ()<UITextViewDelegate,ChatHandlerDelegate>{
    
    __weak IBOutlet UILabel *textLabel;
    
    __weak IBOutlet UITextView *textV;
    
    UIButton *toBtn;
    
    SocketModel * socketModel;
    
    //当长时间后断线 重连发送保存的字典
    NSDictionary *messageWaitSendDict;
    
}

@end

@implementation OpinionRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.tousu) {
        self.title = @"举报投诉";
        textLabel.text = @"请输入举报内容...";
    }else{
        self.title = @"意见反馈";
    }
    toBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 25)];
    [toBtn setTitle:@"发送" forState:(UIControlStateNormal)];
    toBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [toBtn setTitleColor:[UIColor colorMainTextColor] forState:(UIControlStateNormal)];
    toBtn.backgroundColor = [UIColor whiteColor];
    ViewRadius(toBtn, 3);
    [toBtn addTarget:self action:@selector(toClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *toButtonItem = [[UIBarButtonItem alloc]initWithCustomView:toBtn];
    self.navigationItem.rightBarButtonItem = toButtonItem;
    
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
//    // 定义双击
//    tap.numberOfTapsRequired = 2;
//    [textV addGestureRecognizer:tap];
    
    
    [self initScoket];
    
}

#pragma mark - 点按手势
// UIGestureRecognizer所有手势识别的父类
- (void)tap:(UITapGestureRecognizer *)recognizer {
    [textV resignFirstResponder];
}

#pragma mark - 初始化scoket
-(void)initScoket{
    //获取单例
//    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    
}

#pragma mark - 收到服务器消息
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_ReportIllegal) {
        //举报反馈 MsgDic[@"result"]
        if ([chatModel isKindOfClass:[NSDictionary class]]) {
            //举报后得到服务器的返回，提示举报成功pop回去
            [self performSelector:@selector(turnHUD) withObject:nil afterDelay:0.3];
        }
    }else if (messageType == SecretLetterType_NormalReceipt){
        //举报发送消息给ccc222 成功
        //举报反馈 MsgDic[@"result"]
        if ([chatModel isKindOfClass:[NSDictionary class]]) {
            //举报后得到服务器的返回，提示举报成功pop回去
            [self performSelector:@selector(turnHUD) withObject:nil afterDelay:0.3];
        }
    }else if (messageType == SecretLetterType_LoginReceipt){
        //断线重连成功
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
        if ([currentVC isKindOfClass:[OpinionRequestViewController class]]) {
            [self initScoket];
        }
        
    }
}

#pragma mark - //点击发送
- (void)toClicked
{
    if (textV.text.length == 0) {
        [SVProgressHUD showInfoWithStatus:@"请输入您的建议或看法"];
        return;
    }
    [SVProgressHUD show];
        //发送
        //使用多线程让 hud转一秒钟，优化体验
//        dispatch_queue_t queue = dispatch_queue_create("JoeQueue", DISPATCH_QUEUE_CONCURRENT);
//        dispatch_async(queue, ^(void) {
//            sleep(1);
//            dispatch_async(dispatch_get_main_queue(), ^(void) {
//                [SVProgressHUD dismiss];
//                textLabel.alpha = 1;
//                textV.text = @"";
//                [textV resignFirstResponder];
//                //没图
//                PopView *popV = [[PopView alloc] initWithFrame:self.view.bounds message:@"谢谢您的反馈信息，我们将竭诚为您服务" isNeedCancel:NO isSureBlock:^(BOOL sureBlock) {
//                    if (sureBlock) {                //确认
//                        [[NSNotificationCenter defaultCenter] postNotificationName:kGoto_Home_afterActSuccess object:nil];
//                    }
//                }];
//                [self.view addSubview:popV];
//            });
//        });
    //http举报
//        [self SendAddvise];
    if (self.tousu) {
        //socket举报
//        [self reportRequest];
        [self performSelector:@selector(turnHUD) withObject:nil afterDelay:0.3];
    }else{
        [self performSelector:@selector(turnHUD) withObject:nil afterDelay:0.3];
    }
}

#pragma mark - 举报socket请求
-(void)reportRequest{
    
    if (![ClearManager getNetStatus]) {
        [SVProgressHUD showInfoWithStatus:@"请检查网络设置"];
        return;
    }
    if ([[NFUserEntity shareInstance].connectStatus isEqualToString:@"1"]) {
        [SVProgressHUD showInfoWithStatus:@"未连接到服务器"];
        return;
    }
    [SVProgressHUD show];
    [self.parms removeAllObjects];
//    self.parms[@"action"] = @"userOperationMsg";
//    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
//    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
//    self.parms[@"reportText"] = @"";
//    if (self.cycleId.length > 0) {
//        self.parms[@"cycleId"] = self.cycleId; //动态id
//    }
    self.parms[@"msgType"] = @"normal";
    self.parms[@"fromName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"fromId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"toName"] = @"ddd111";
    self.parms[@"toId"] = @"66";
    if (self.cycleEntity) {
        self.parms[@"content"] = [NSString stringWithFormat:@"收到动态举报:【%@】举报了动态id【%@】,举报内容:【%@】请在后台核实删除！！！",[NFUserEntity shareInstance].userId,self.cycleEntity.circle_id,textV.text];
    }else if (self.groupCreateSEntity){
        self.parms[@"content"] = [NSString stringWithFormat:@"收到举报群组:【%@】举报了群组id【%@】,举报内容:【%@】请在后台核实删除！！！",[NFUserEntity shareInstance].userId,self.groupCreateSEntity.groupId,textV.text];
    }else if (self.contactEntity){
        self.parms[@"content"] = [NSString stringWithFormat:@"收到举报好友:【%@】举报了好友id【%@】,举报内容:【%@】请在后台核实删除！！！",[NFUserEntity shareInstance].userId,self.contactEntity.friend_userid,textV.text];
    }else{
    }
    self.parms[@"createTime"] = [NFMyManage getCurrentTimeStamp];
    self.parms[@"action"] = @"sendMessage";
    self.parms[@"msgClient"] = @"app";
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
//        [self performSelector:@selector(turnHUD) withObject:nil afterDelay:0.3];
        [socketModel initSocket];
        __weak typeof(self)weakSelf=self;
        __weak NSDictionary *dict = self.parms;
        messageWaitSendDict = self.parms;
        [socketModel returnConnectSuccedd:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
                if (![currentVC isKindOfClass:[OpinionRequestViewController class]]) {
                    return ;
                }
                [SVProgressHUD showSuccessWithStatus:@"重连成功"];
                [socketModel sendMsg:Json];
            });
        }];
    }
}

#pragma mark - 举报http请求
- (void)SendAddvise
{
    [SVProgressHUD show];
    NSMutableDictionary *sendDic = [[NSMutableDictionary alloc] initWithCapacity:2];
    [sendDic setObject:textV.text forKey:@"content"];
    [NFMineManager execute:@selector(SendAddviseManager) target:self callback:@selector(SendAddviseManagerCallBack:) args:sendDic,nil];
}
- (void)SendAddviseManagerCallBack:(id)data
{
    //只有一种数据类型
    if (data)
    {
        if ([data objectForKey:kWrongDlog])
        {
            [SVProgressHUD showInfoWithStatus:[data objectForKey:kWrongDlog]];
            DLog(@"%@",[data objectForKey:kWrongDlog]);
        }
        else
        {
            [self performSelector:@selector(turnHUD) withObject:nil afterDelay:0.3];
//            [self turnHUD]; //转一秒并消失,提示反馈成功
        }
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:kDefaultMsg];
    }
}

//反馈完成 友情提示
-(void)turnHUD{
    toBtn.userInteractionEnabled = NO;
    [SVProgressHUD dismiss];
    textLabel.alpha = 1;
    textV.text = @"";
    [textV resignFirstResponder];
    __weak typeof(self)weakSelf=self;
    NSString *content = @"感谢您的反馈，我们将竭诚为您服务";
    if (self.tousu) {
//        content = @"举报成功,我们将尽快核实处理!";
        content = @"举报成功!";
    }
    MKPAlertView *alertView = [[MKPAlertView alloc]initWithTitle:@"" message:content sureBtn:@"确认" cancleBtn:nil];
    alertView.resultIndex = ^(NSInteger index)
    {
        [self.navigationController popViewControllerAnimated:YES];
        
    };
    [alertView showMKPAlertView];
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
//    textLabel.alpha = 0;
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    if (textView.text.length != 0) {
        textLabel.alpha = 0;
    }else{
        textLabel.alpha = 1;
    }
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
    // Dispose of any resources that can be recreated.
}



@end
