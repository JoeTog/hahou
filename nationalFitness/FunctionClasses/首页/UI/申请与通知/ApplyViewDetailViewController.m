//
//  ApplyViewDetailViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/6/30.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "ApplyViewDetailViewController.h"

@interface ApplyViewDetailViewController ()<ChatHandlerDelegate>

@end

@implementation ApplyViewDetailViewController{
    
    //用户头像
    __weak IBOutlet NFShowImageView *headImageV;
    
    //拒绝按钮
    __weak IBOutlet UIButton *refuseBtn;
    
    //同意按钮
    __weak IBOutlet UIButton *agreeBtn;
    
    //背景imageview
    __weak IBOutlet UIImageView *backImageV;
    //背景水平约束
    __weak IBOutlet NSLayoutConstraint *backImageVHorizonConstaint;
    
    
    JQFMDB *jqFmdb;
    SocketModel * socketModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(self.IsGroup){
        self.title = @"群申请管理";
    }else{
        self.title = @"好友验证";
    }
    
    [self initUI];
    [self initScoket];
}

-(void)initScoket{
    //初始化
//    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    
    __weak typeof(self)weakSelf=self;
    
}

#pragma mark - 发送消息
- (void)sendMesageFrom:(NSString *)from To:(NSString *)to Content:(NSString *)content Createtime:(NSString *)createtime
{
    [self.parms removeAllObjects];
    self.parms[@"msgType"] = @"normal";
    self.parms[@"fromName"] = from;
    self.parms[@"fromId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"toName"] = to;
    self.parms[@"toId"] = self.entity.send_user_id;
    self.parms[@"content"] = content;
    self.parms[@"createTime"] = createtime;
    self.parms[@"action"] = @"sendMessage";
    self.parms[@"msgClient"] = @"app";
    if ([content isKindOfClass:[NSString class]]) {
        NSString *JsonStr = [JsonModel convertToJsonData:self.parms];
        if (socketModel.isConnected) {
            [socketModel sendMsg:JsonStr];
        }
    }
}

#pragma mark - 收到服务器消息
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType  == SecretLetterType_Promet) {
        //设置刷新好友列表
        [NFUserEntity shareInstance].isNeedRefreshFriendList = YES;
        [NFUserEntity shareInstance].isNeedRefreshLocalChatList = YES;
        [NFUserEntity shareInstance].IsNeedRefreshApply = YES;//刷新申请列表
        
        WrongMessageAddFriendEntity *entity = chatModel;
        //先显示提示信息
        [SVProgressHUD showInfoWithStatus:entity.backMessage];
        //如果是成功 就返回 失败则留在本界面
        __weak typeof(self)weakSelf=self;
        if ([entity.messageType isEqualToString:@"1"]) {
            //发送消息 我已通过你的好友请求，我们现在可以聊天了
            NSString *currentTime = [NFMyManage getCurrentTimeStamp];
            [self sendMesageFrom:[NFUserEntity shareInstance].userName To:self.entity.send_user_name Content:@"我已通过你的好友请求，我们现在可以聊天了" Createtime:currentTime];
            __weak UIViewController * viewVC = [weakSelf.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 3];
            __weak typeof(self)weakSelf=self;
            [self createDispatchWithDelay:1 block:^{
                [weakSelf.navigationController popToViewController:viewVC animated:YES];
            }];
        }else if ([entity.messageType isEqualToString:@"2"]){
            //拒绝成功
            __weak typeof(self)weakSelf=self;
            [self createDispatchWithDelay:1 block:^{
//                [weakSelf.navigationController popToViewController:viewVC animated:YES];
                
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
            
            
        }
    }else if (messageType == SecretLetterType_NormalReceipt){
        //单聊消息发送回执
        //        [SVProgressHUD dismiss];
        if ([chatModel isKindOfClass:[NSDictionary class]]) {
            [SVProgressHUD dismiss];
            NSDictionary *infoDict = chatModel;
            if ([[[infoDict objectForKey:@"type"] description] isEqualToString:@"0"] ) {
                //将单聊中的代码拉过来 进行修改
                
                [self addSpecifiedItem:(NSDictionary *)chatModel];
                
                
            }
        }
    }else if(messageType == SecretLetterType_yanzhengOver){
        
        [SVProgressHUD showInfoWithStatus:@"申请已过期"];
        
    }else if(messageType == SecretLetterType_yanzhengReject){
        [SVProgressHUD showInfoWithStatus:@"拒绝成功"];
        
    }else if(messageType == SecretLetterType_yanzhengAccept){
        [NFUserEntity shareInstance].IsNeedRefreshApply = YES;
        [SVProgressHUD showInfoWithStatus:@"操作成功"];
        __weak typeof(self)weakSelf=self;
        [self createDispatchWithDelay:1 block:^{
            //                [weakSelf.navigationController popToViewController:viewVC animated:YES];
            
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
    }else if(messageType == SecretLetterType_GroupBreak){
        [SVProgressHUD showInfoWithStatus:@"群组已解散"];
        __weak typeof(self)weakSelf=self;
        [self createDispatchWithDelay:1 block:^{
            //                [weakSelf.navigationController popToViewController:viewVC animated:YES];
            
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
    }else if (messageType == SecretLetterType_yanzheng){
        [SVProgressHUD showInfoWithStatus:@"用户已经在群中"];
    }
    
}




-(void)initUI{
    //
    //发送者头像
    [headImageV ShowImageWithUrlStr:[self.entity.photo containsString:@"http"]?self.entity.photo:[NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,self.entity.photo] placeHoldName:defaultHeadImaghe completion:^(BOOL success, UIImage *image) {
    }];
//    ViewRadius(headImageV, 3);//头像圆角3
    
    //设置发送者的名字
    
    self.sendNameLabel.text = self.entity.send_nick_name;
    if (self.IsGroup) {//
        self.sendNameLabel.numberOfLines = 0;
        self.sendNameLabel.text = [NSString stringWithFormat:@"%@邀请%@加入%@",self.entity.who_invite_user_nickname,self.entity.user_nickname,self.entity.group_name];
        [self.sendNameLabel sizeToFit];
    }
    [refuseBtn setTitleColor:[UIColor colorThemeColor] forState:(UIControlStateNormal)];
    [agreeBtn setTitleColor:[UIColor colorThemeColor] forState:(UIControlStateNormal)];
    
    agreeBtn.backgroundColor = UIColorFromRGB(0xf8f8f8);
    ViewBorderRadius(agreeBtn, 3, 1, UIColorFromRGB(0xe9e9e9));
    
    refuseBtn.backgroundColor = UIColorFromRGB(0xf8f8f8);
    ViewBorderRadius(refuseBtn, 3, 1, UIColorFromRGB(0xe9e9e9));
    
    [agreeBtn setTitle:@"同意" forState:(UIControlStateNormal)];
    [refuseBtn setTitle:@"拒绝" forState:(UIControlStateNormal)];
    
    ViewRadius(backImageV, 3);
    backImageVHorizonConstaint.constant = -kPLUS_SCALE_X(45);
    
    //当已经为接收状态 拒绝按钮不可点
    if ([self.entity.status isEqualToString:@"accept"]) {
//        [refuseBtn setTitleColor:[UIColor lightGrayColor] forState:(UIControlStateNormal)];
//        [refuseBtn setTitleColor:[UIColor colorThemeColor] forState:(UIControlStateNormal)];
        refuseBtn.userInteractionEnabled = NO;//        [agreeBtn setTitleColor:[UIColor colorThemeColor] forState:(UIControlStateNormal)];
        [agreeBtn setTitle:@"已同意" forState:(UIControlStateNormal)];
        agreeBtn.userInteractionEnabled = NO;
        
        agreeBtn.backgroundColor = SecondGray;
        refuseBtn.backgroundColor = SecondGray;
        
    }
    //当为已拒绝时
    if ([self.entity.status isEqualToString:@"reject"]) {
//        [refuseBtn setTitleColor:[UIColor lightGrayColor] forState:(UIControlStateNormal)];
        [refuseBtn setTitle:@"已拒绝" forState:(UIControlStateNormal)];
        refuseBtn.userInteractionEnabled = NO;
        agreeBtn.userInteractionEnabled = NO;
        
        agreeBtn.backgroundColor = SecondGray;
        refuseBtn.backgroundColor = SecondGray;
        
    }
    
    
}

-(void)ReturnAddFriendBlockk:(ReturnAddFriendBlock)block{
    self.addFriendBlock = block;
}

//拒绝
#pragma markl - 拒绝请求
- (IBAction)confuseClick:(id)sender {
    if (![ClearManager getNetStatus]) {
        [SVProgressHUD showInfoWithStatus:@"请检查网络设置"];
        return;
    }
    if ([[NFUserEntity shareInstance].connectStatus isEqualToString:@"1"]) {
        [SVProgressHUD showInfoWithStatus:@"未连接到服务器"];
        return;
    }
    //reduseFriendCount
    [self.parms removeAllObjects];
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"receiveUserName"] = self.entity.send_user_name;
    self.parms[@"action"] = @"responseFriendRequest";
    self.parms[@"responseAction"] = @"reject";
    self.parms[@"responseId"] = self.entity.addId;
    if (self.IsGroup) {
        [self.parms removeAllObjects];
        self.parms[@"action"] = @"responseGroupRequest";
        self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
        self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
        self.parms[@"responseAction"] = @"reject";
        self.parms[@"responseId"] = self.entity.addId;
    }
    
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [SVProgressHUD show];
        [socketModel sendMsg:Json];
    }else{
//        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
    
//    self.addFriendBlock(@"reduse");
    
    
}

#pragma markl - 同意请求
//同意
- (IBAction)agreeClick:(id)sender {
    if (![ClearManager getNetStatus]) {
        [SVProgressHUD showInfoWithStatus:@"请检查网络设置"];
        return;
    }
    if ([[NFUserEntity shareInstance].connectStatus isEqualToString:@"1"]) {
        [SVProgressHUD showInfoWithStatus:@"未连接到服务器"];
        return;
    }
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"responseFriendRequest";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"receiveUserName"] = self.entity.send_user_name;
    self.parms[@"responseAction"] = @"accept";
    self.parms[@"responseId"] = self.entity.addId;
    
    if (self.IsGroup) {
        [self.parms removeAllObjects];
        self.parms[@"action"] = @"responseGroupRequest";
        self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
        self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
        self.parms[@"responseAction"] = @"accept";
        self.parms[@"responseId"] = self.entity.addId;
        
    }
    
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [SVProgressHUD show];
        [socketModel sendMsg:Json];
    }else{
//        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
    
}

#pragma mark - 发送消息后展示、缓存
- (void)addSpecifiedItem:(NSDictionary *)dic
{
    //记录刷新会话列表
    //    [NFUserEntity shareInstance].isNeedRefreshChatList = YES;
    ZJContact *contact = [ZJContact new];
    contact.friend_userid = self.entity.send_user_id;
    contact.friend_username = self.entity.send_user_name;
    contact.friend_nickname = self.entity.send_nick_name;
    contact.iconUrl = self.entity.photo;
    [self.fmdbServicee cacheChatListWithZJContact:contact AndDic:dic];
    
    UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
    UUMessage *message = [[UUMessage alloc] init];
    NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    
    NSString *URLStr = @"http://img0.bdstatic.com/img/image/shouye/xinshouye/mingxing16.jpg";
    URLStr = @"";
    [dataDic setObject:@1 forKey:@"from"];
    [dataDic setObject:[[NSDate date] description] forKey:@"strTime"];
    if ([dic objectForKey:@"userName"]) {
        [dataDic setObject:[dic objectForKey:@"userName"] forKey:@"userName"];
    }
    if ([dic objectForKey:@"strIcon"]) {
        [dataDic setObject:URLStr forKey:@"strIcon"];
    }
    //设置消息内容数据
    [message setWithDict:dataDic];
    [message minuteOffSetStart:previousTime end:dataDic[@"strTime"]];
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSTimeInterval interval = [currentDate timeIntervalSince1970];
    message.localReceiveTime = interval;
    NSInteger time = interval;
    message.localReceiveTimeString = [NSString stringWithFormat:@"%ld",time];
    message.strTime = [[NFbaseViewController new] timestampSwitchTime:interval anddFormatter:@"HH:mm"];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:interval];
    if (![confromTimesp isThisYear]) {
        message.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:interval anddFormatter:@"YYYY年MM月dd日"];
    }else{
        message.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:interval anddFormatter:@"MM月dd日"];
    }
    
    message.chatId = dataDic[@"chatId"];
    [messageFrame setMessage:message];
    //检查表存在
    [self.fmdbServicee IsExistShenQingTongZhi];
    //缓存
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    MessageChatEntity *entity = [self.fmdbServicee UUMessageFrameToMessageChatEntity:messageFrame];
    entity.IsSingleChat = YES;
    if(![entity.type isEqualToString:@"4"]){
        entity.redpacketString = @"";
    }
    
    __weak typeof(self)weakSelf=self;
    __block NSArray *lastArr = [NSArray new];
    __block int dataaCount = 0;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        //userId = userId order by id desc limit 5
        dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:contact.friend_userid];
        lastArr = [strongSelf ->jqFmdb jq_lookupTable:contact.friend_userid dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,1]];
        
    }];
    //重复消息 单聊
    if(lastArr.count == 1){
        MessageChatEntity *lastEntity = [lastArr firstObject];
        if ([entity.chatId isEqualToString:lastEntity.chatId] && entity.chatId.length > 0) {
            //如果有相同消息 则return
            return;
        }
    }
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        BOOL rett = [strongSelf ->jqFmdb jq_insertTable:contact.friend_userid dicOrModel:entity];
        if (!rett) {
            [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
            return;
        }
    }];
    
}

static NSString *previousTime = nil;

//懒加载
-(NSMutableDictionary *)parms{
    if (!_parms) {
        _parms = [[NSMutableDictionary alloc] init];
    }
    return _parms;
}

-(FMDBService *)fmdbServicee{
    if (!_fmdbServicee) {
        _fmdbServicee = [[FMDBService alloc] init];
    }
    return _fmdbServicee;
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"\n\n\n\n\ndidReceiveMemoryWarning\n\n\n\n\n");
    // Dispose of any resources that can be recreated.
}


@end
