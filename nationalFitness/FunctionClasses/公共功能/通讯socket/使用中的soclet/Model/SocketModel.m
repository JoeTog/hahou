//
//  SocketModel.m
//  WebSocket
//
//  Created by King on 2017/6/30.
//  Copyright © 2017年 King. All rights reserved.
//

#import "SocketModel.h"
#import "SRWebSocket.h"
#import "JsonModel.h"
#import "JQFMDB.h"

//#define dispatch_main_async_safe(block)\
//if ([NSThread isMainThread]) {\
//block();\
//} else {\
//dispatch_async(dispatch_get_main_queue(), block);\
//}

//是否开启测试框 0开启 1关闭
#define UseTest @"1"



//--ip地址
//上架环境
//static  NSString * Khost = @"116.62.6.189";
//#define ServerAddress @"116.62.6.189"
//开发环境
//static  NSString * Khost = @"116.62.53.142";
//#define ServerAddress @"116.62.53.142"


//--ip地址
//上架环境
//static  NSString * Khost = @"47.97.230.179";e
static  NSString * Khost = @"121.43.116.159";
//开发环境
//static  NSString * Khost = @"116.62.53.142";

//inet6 addr: fe80::216:3eff:fe12:74cf/64 Scope:Link
//static  NSString * Khost = @"fe80::216:3eff:fe12:74cf/64";

//--端口号
//static const uint16_t Kport = 6062;
static const uint16_t Kport = 6062;



@interface SocketModel()<SRWebSocketDelegate>
{
    NSTimeInterval reConnecTime;
    
    //逻辑判断是否能移除通知的messagePopview
    int a;//当有消息推送后+1，
    int b;//当动画从 展示到移除 完成后+1， 然后在移除处判断两者是否相等 相等说明上一个展示到移除已经走完 不是的话就定时1秒从新走一遍
    //消息弹出框
    PopMessageView *popView;
    //未连接到服务器弹窗
    DisconnectView *disconnectView;
    // 是否手动处理statusBar点击
    BOOL _clicked;
    // 隐藏开启与否
    BOOL _flag;
    JQFMDB *jqFmdb;
    //重连次数
    int reconnectCount;
    //超时监听
    int TimeOutCount;
    //是否为重连 重连不显示连不上
    BOOL IsReconnecting;
    
    UIButton *bottomBtn;
    UIButton *clearBtn;
    UITextView *textView;
    UIButton *removeBtn;
    //用来强引用一下代理 防止代理丢失
    id<ChatHandlerDelegate> currentDelegate;
    //上一次请求登录时间间隔
    NSInteger loginRequestTime;
    
    RedSocketModel *redSocketModel;
    
    BOOL IsShowBreak;
}

@property (nonatomic, strong)SRWebSocket * webSocket;
@property (nonatomic, strong)NSTimer * heartBeat;



@end

@implementation SocketModel

+(instancetype)share
{
    static dispatch_once_t onceToken;
    static SocketModel * instance=nil;
    dispatch_once(&onceToken,^{
        instance=[[self alloc]init];
        [instance initSocket];
        
    });
    return instance;
    
}

//初始化
-(void)initSocket
{
    
    redSocketModel = [RedSocketModel share];
    
    _clicked = YES;
    _flag = YES;
    //默认处于未连接的状态
    _isConnected = NO;
    
    IsReconnecting = YES;
    
    [self disConnect];
    
    self.webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"ws://%@:%d", Khost, Kport]]];
    self.webSocket.delegate=self;
    //  设置代理线程queue
    NSOperationQueue * queue=[[NSOperationQueue alloc]init];
    queue.maxConcurrentOperationCount=1;
    [self.webSocket setDelegateOperationQueue:queue];
   // [self disConnect];
    //  连接
    [self.webSocket open];
    
}

//主动连接成功的回调 当退出登录再次登录需要
-(void)returnConnectSuccedd:(ConnectSuccess)block{
    
    if (self.ConnectSucceedBlock != block) {
        
        self.ConnectSucceedBlock = block;
        
    }
    
}

//初始化心跳
-(void)initHearBeat
{
    dispatch_main_async_safe(^{
        [self destoryHeartBeat];
        //心跳设置为1分钟，NAT超时一般为5分钟
        self.heartBeat = [NSTimer scheduledTimerWithTimeInterval:1*60 target:self selector:@selector(sendhert) userInfo:self repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.heartBeat forMode:NSRunLoopCommonModes];
    })
}

//发送心跳
- (void)sendhert
{
    //和服务端约定好发送什么作为心跳标识，尽可能的减小心跳包大小
    NSLog(@"heart");
//    if (self.isConnected && [NFUserEntity shareInstance].appStatus) {
//        [self ping];
//    }
    
    if ([NFUserEntity shareInstance].appStatus) {
        [self sendMsg:[NSString stringWithFormat:@"heart %@",[NFUserEntity shareInstance].userName]];
    }
}
//取消心跳
-(void)destoryHeartBeat
{
    dispatch_main_async_safe(^{
        if (self.heartBeat) {
            [self.heartBeat invalidate];
            self.heartBeat=nil;
        }
        
    })
    
}

//建立连接
-(void)connect
{
  [self initSocket];
}

//断开连接
-(void)disConnect
{
    if (self.webSocket){
        self.webSocket.delegate= nil;
        [self.webSocket close];
        self.webSocket=nil;
        self.isConnected = NO; //非连接状态
    }
}

//发送消息
-(void)sendMsg:(id)msg
{
//    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
//        [self getIPWithHostName:Khost];
//    });
    NSLog(@"msg = %@",msg);
    if (self.delegate) {
        currentDelegate = self.delegate;
    }
    //一旦发送请求，便进行超时监听 当发送为心跳 不计算超时
     if ([msg isKindOfClass:[NSString class]] &![msg isEqualToString:@"heart"]) {
        [NFUserEntity shareInstance].timeOutCountBegin = YES;
        //每次请求从0开始计算
        TimeOutCount = 0;
        //非心跳 才显示
//        NSDictionary *MsgDic = [JsonModel dictionaryWithJsonString:msg];
//        dispatch_queue_t mainQueue = dispatch_get_main_queue();
//        dispatch_async(mainQueue, ^{
//            [self setAlertView:MsgDic IsRequest:YES];
////            [self.myManage setAlertView:msg IsRequest:YES];
//        });
//        IsReconnecting = NO;//主动连接 重连为no
    }else{
        //发送心跳 不算超时计算
//        [NFUserEntity shareInstance].timeOutCountBegin = NO;
    }
    
    [self ping];
    if(self.isConnected){
        [self.webSocket send:msg];
    }
    if (![msg isEqualToString:@"heart"]) {
        if (self.timer) {
            TimeOutCount = 0;
//            [NFUserEntity shareInstance].timeOutCountBegin = NO;
            [self.timer invalidate];
        }
        self.timer = [HCDTimer repeatingTimerWithTimeInterval:1 block:^{
            [self timeOutCountCaculation:999];
        }];
    }
    
}
//

#pragma mark - 设置弹窗
-(void)setAlertView:(NSDictionary *)msg IsRequest:(BOOL)request{
    NSDictionary *messageDict = msg;
    NSString *title = [NSString new];
    if (request) {
        title = @"请求";
    }else{
        title = @"返回";
    }
    id obj = [messageDict objectForKey:@"result"];
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = [messageDict objectForKey:@"result"];
        NSArray *arr = [NSArray new];
        if ([dict objectForKey:@"singleChat"]) {
            arr = [dict objectForKey:@"singleChat"];
        }
        if (arr.count > 0) {
            NSMutableArray *arrr = [[NSMutableArray alloc] initWithCapacity:2];
            for (NSDictionary *dicc in arr) {
                NSString *contentString = [dicc objectForKey:@"lastMsgContent"];
                if (contentString.length > 10) {
                    //如果消息长度大于10 可能为语音 图片
                    contentString = [contentString substringToIndex:10];
                }
                if ([contentString isEqualToString:@"/+NARAAAAA"]) {
                    [dicc setValue:@"Voice" forKey:@"lastMsgContent"];
                    [arrr addObject:dicc];
                }else if ([contentString containsString:@"/9j/"]){
                    [dicc setValue:@"\n\npicture\n\n" forKey:@"lastMsgContent"];
                    [arrr addObject:dicc];
                }else{
                    if (contentString.length < 10000) {
                        [arrr addObject:dicc];
                    }else{
                        [dicc setValue:@"\n\n pictureOrPicture \n\n" forKey:@"lastMsgContent"];
                        [arrr addObject:dicc];
                    }
                }
            }
            messageDict =@{@"result":@{@"groupChat":@[],@"singleChat":arrr}};
        }
    }
    
    if (textView) {
        NSString *text = textView.text;
        NSMutableString *mutableString = [[NSMutableString alloc] initWithFormat:@"%@",text];
        [mutableString appendString:[NSString stringWithFormat:@"\n%@：%@\n**********************\n",title,(NSString *)messageDict]];
        textView.text = [NSString stringWithFormat:@"%@",mutableString];
        [textView scrollRectToVisible:CGRectMake(0, textView.contentSize.height-15, textView.contentSize.width, 10) animated:YES];
        if (mutableString.length < 1000) {
            //打印请求：:
//            NSLog(@"%@",mutableString);
        }
    }
    if (!textView) {
        textView = [[UITextView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, 64.5, SCREEN_WIDTH/2, SCREEN_HEIGHT/2)];
        textView.font = [UIFont systemFontOfSize:13];
        textView.text = [NSString stringWithFormat:@"%@:%@",title,messageDict];
        [textView scrollRectToVisible:CGRectMake(0, textView.contentSize.height-15, textView.contentSize.width, 10) animated:YES];
    }
//    [textView scrollRectToVisible:CGRectMake(0, textView.contentSize.height-15, textView.contentSize.width, 10) animated:YES];
    ViewRadius(textView, 3);
    textView.backgroundColor = [UIColor blackColor];
    textView.textColor = [UIColor whiteColor];
//    NSLog(@"%d",[NFUserEntity shareInstance].IsNotNeedTestView);
    if (![NFUserEntity shareInstance].IsNotNeedTestView) {
        textView.alpha = 0.7;
    }
    textView.editable = NO;
    UIWindow *win = [[[UIApplication sharedApplication] windows] firstObject];
    
    if (!bottomBtn) {
        bottomBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/4*3 + 2, SCREEN_HEIGHT/2 + 64, SCREEN_WIDTH/8, 35)];
    }else if (![NFUserEntity shareInstance].IsNotNeedTestView){
        [bottomBtn removeFromSuperview];
        bottomBtn = nil;
        bottomBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/4*3 + 2, SCREEN_HEIGHT/2 + 64, SCREEN_WIDTH/8, 35)];
    }
    [bottomBtn setTitle:@"底部" forState:(UIControlStateNormal)];
    [bottomBtn addTarget:self action:@selector(BottomClick) forControlEvents:(UIControlEventTouchDown)];
    bottomBtn.backgroundColor = [UIColor lightGrayColor];
    [bottomBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    
    //clearBtn
    if (!clearBtn) {
        clearBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/8*7 + 2 + 2, SCREEN_HEIGHT/2 + 64, SCREEN_WIDTH/8, 35)];
    }else if (![NFUserEntity shareInstance].IsNotNeedTestView){
        [clearBtn removeFromSuperview];
        clearBtn = nil;
        clearBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/8*7 + 2 + 2, SCREEN_HEIGHT/2 + 64, SCREEN_WIDTH/8, 35)];
    }
    [clearBtn setTitle:@"清空" forState:(UIControlStateNormal)];
    [clearBtn addTarget:self action:@selector(clearClick) forControlEvents:(UIControlEventTouchDown)];
    clearBtn.backgroundColor = [UIColor lightGrayColor];
    [clearBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    
    if (!removeBtn) {
        removeBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 + 64, SCREEN_WIDTH/4, 35)];
    }
    [removeBtn setTitle:@"Hiden" forState:(UIControlStateNormal)];
    [removeBtn setTitle:@"Show" forState:(UIControlStateSelected)];
    [removeBtn addTarget:self action:@selector(removeOrAdd:) forControlEvents:(UIControlEventTouchDown)];
    removeBtn.backgroundColor = [UIColor lightGrayColor];
    [removeBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    
    if ([UseTest isEqualToString:@"0"]) {
        [win addSubview:textView];
        [win addSubview:removeBtn];
        [win addSubview:clearBtn];
        [win addSubview:bottomBtn];
    }
}
//展开收起
-(void)buttonClick:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (sender.selected) {
        textView.alpha = 0;
    }else{
        textView.alpha = 0.7;
    }
}
//测试弹框滑到底部
-(void)BottomClick{
    [textView scrollRectToVisible:CGRectMake(0, textView.contentSize.height-15, textView.contentSize.width, 10) animated:YES];
}

//清空数据
-(void)clearClick{
    textView.text = @"";
}

//移除测试弹框
-(void)removeOrAdd:(UIButton *)sender{
    removeBtn.selected = !removeBtn.selected;
    if (removeBtn.selected) {
        bottomBtn.alpha = 0;
        clearBtn.alpha = 0;
        textView.alpha = 0;
        [NFUserEntity shareInstance].IsNotNeedTestView = YES;
    }else{
        [NFUserEntity shareInstance].IsNotNeedTestView = NO;
        bottomBtn.alpha = 1;
        clearBtn.alpha = 1;
        textView.alpha = 0.7;
    }
}

//  重连机制
-(void)reConnect
{
    IsReconnecting = YES;
    [self disConnect];
    //  重连2分钟后就不再进行重连操作，等待网络变化后 走推送登录进行重连
    if (reConnecTime>64) {
        return;
    }
    //重连时间间隔 第一次为0.1秒内重连，第二次开始则为1秒
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([NFUserEntity shareInstance].reconnectTimeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.webSocket=nil;
        [self initSocket];
    });
    [NFUserEntity shareInstance].reconnectTimeInterval = 1;//首次快速重连后 后面重连间隔为1秒
    
    //   重连时间2的指数级增长
    if (reConnecTime == 0) {
        reConnecTime = 2;
    }else{
        reConnecTime += 1;
    }
}
// pingpong
-(void)ping{
//    Reachability *reachability   = [Reachability reachabilityWithHostName:@"www.apple.com"];
//    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
//    if (internetStatus == NotReachable) {
//        self.isConnected = NO;
//    }else{
//        self.isConnected = YES;
//    }
    if (self.webSocket.readyState == SR_OPEN) {
        [self.webSocket sendPing:nil];
    }else{
        //重连
//        [self initSocket];
        //设置连接状态为NO
        self.isConnected = NO;
    }
    
}

#pragma mark - 超时计算
-(void)timeOutCountCaculation:(NSInteger)status{
    //三秒一次心跳 加一次超时计算 并且当请求时进行超时监听
//    if (status == 999 && [NFUserEntity shareInstance].timeOutCountBegin) {
//        TimeOutCount ++;
//    }
//    //一旦有回应 则将超时监听计算初始化
//    if (status != 999) {
//        TimeOutCount = 0;
//        [NFUserEntity shareInstance].timeOutCountBegin = NO;
//    }s
    TimeOutCount++;
    NSLog(@"%d",TimeOutCount);
    if (![NFUserEntity shareInstance].timeOutCountBegin) {
        TimeOutCount = 0;
        [self.timer invalidate];
    }
    if (TimeOutCount >5 && [NFUserEntity shareInstance].timeOutCountBegin) {
        TimeOutCount = 0;
        [self.timer invalidate];
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
        if ([SVProgressHUD isVisible]) {
            NSLog(@"dissmiss");
//            [SVProgressHUD showInfoWithStatus:@"连接超时"];
            //请求接口进行重连 【假断开可以重连上，如果真断开那么不能连上】
//            [self getAddFriendList];
            //通知界面结束刷新
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"" type:SecretLetterType_SocketRequestFailed];
                });
            }
        }else if ([currentVC isKindOfClass:[QRCodeScanViewController class]]){
            //当在二维码扫描界面 通知其超时
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"" type:SecretLetterType_SocketRequestFailed];
                });
            }
        }
        
    }
    
//    if (TimeOutCount >= 5 && !self.isConnected) {
//        [SVProgressHUD showInfoWithStatus:kWrongMessage];
////        if ([NFUserEntity shareInstance].IsUploadingPicture) {
////            TimeOutCount++;
////            return;
////        }
//        //提示后 初始化超时计算
//        TimeOutCount = 0;
//        [NFUserEntity shareInstance].timeOutCountBegin = NO;
//        [self.timer invalidate];
//    }else{
//        if (![NFUserEntity shareInstance].timeOutCountBegin && TimeOutCount > 6) {
//            TimeOutCount = 0;
//            [self.timer invalidate];
//            if ([SVProgressHUD isVisible]) {
//                NSLog(@"dissmiss");
//                [SVProgressHUD showInfoWithStatus:@"连接超时"];
//            }
//        }
//    }
}

#pragma mark - SRWebScokerDelegate
-(void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSString *messString = message;
    if ([messString isEqualToString:@"JSON_ERROR"]) {
        return;
    }
    NSDictionary *MsgDic = [JsonModel dictionaryWithJsonString:message];
    NSInteger  status = [MsgDic[@"status"] integerValue];
    SecretLetterModel messageType     = SecretLetterType_Unknow;
//    NSLog(@"%ld",status);
    if (status == 999) {
        return;
    }
    //测试框
//    dispatch_queue_t mainQueue = dispatch_get_main_queue();
//    dispatch_async(mainQueue, ^{
//        if ([UseTest isEqualToString:@"0"]) {
//            [self setAlertView:MsgDic IsRequest:NO];
//        }
////        [self.myManage setAlertView:message IsRequest:NO];
//    });
    
    //当有返回值饿初始化
    NSLog(@"MsgDic = %@",MsgDic);
    TimeOutCount = 0;
    reconnectCount = 0;
    [NFUserEntity shareInstance].timeOutCountBegin = NO;
    self.isConnected = YES; //当收到消息 设置为已连接
    if ([NFUserEntity shareInstance].IsRecovering && status != 4012 && status != 5028) {//正在恢复聊天数据 限制操作
        //正在恢复中、如果不是4012、5028 则限制操作
        return;
    }
    
    switch (status) {
//            break;
        case 9001:{
#pragma mark - 9001充值成功
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_rechargeSuccess;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
        }
            break;
        case 9002:{
            [SVProgressHUD dismiss];
            //充值失败
            messageType = SecretLetterType_rechargeFail;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
        }
            break;
        case 9003:{
            //开户成功
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_kaihuSuccess;
            //通知代理
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
        }
            break;
        case  9004:{
            //开户失败
            [SVProgressHUD dismiss];
//            messageType = SecretLetterType_setMypassword;
//            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
//                dispatch_queue_t mainQueue = dispatch_get_main_queue();
//                dispatch_async(mainQueue, ^{
//                    [self.delegate didReceiveMessage:@"" type:messageType];
//                });
//            }
        }
            break;
        case 9005:{
            [SVProgressHUD dismiss];
            //查询余额成功
            messageType = SecretLetterType_checkAmount;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:MsgDic[@"result"] type:messageType];
                });
            }
        }
            break;
        case 9006:{
            [SVProgressHUD dismiss];
            //查询余额失败
            messageType = SecretLetterType_checkAmountFail;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
        }
            
            break;
            case 9008:{
                [SVProgressHUD dismiss];
                //余额不足
                messageType = SecretLetterType_checkAmountFail;
                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [SVProgressHUD showInfoWithStatus:@"余额不足"];
                    });
                }
            }
                break;
        case 9011:{
            [SVProgressHUD dismiss];
            //发送红包成功
            messageType = SecretLetterType_sendPacketSuccess;
            
            NSDictionary *personalDict = MsgDic[@"result"];
            NSDictionary *dict = personalDict[@"messageContent"];
            if([[[dict objectForKey:@"isGroup"] description] isEqualToString:@"0"]){
                //单聊红包 直接插入sendtimes缓存
                
                //检查数据库表字段
                [self.fmdbServicee IsExistSingleChatHistory:[[dict objectForKey:@"toUserId"] description]];
                
                NSDictionary *returnDcit = @{@"chatId":@"0",@"strContent":[dict objectForKey:@"content"],@"type":[[dict objectForKey:@"type"] description],@"userName":[personalDict objectForKey:@"toName"],@"userId":[personalDict objectForKey:@"toId"],@"singleRed":@"0",@"from":@"1",@"strIcon":@"",@"redpacketString":[dict objectForKey:@"redpacketId"],@"userNickName":[personalDict objectForKey:@"toNickName"],@"appMsgId":[personalDict objectForKey:@"messageId"],@"sendtimes":[[dict objectForKey:@"sendtimes"] description]};
                
                UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
                UUMessage *message = [[UUMessage alloc] init];
                [message setWithDict:returnDcit];
                message.redpacketString = [[dict objectForKey:@"redpacketId"] description];
                message.chatId = [[personalDict objectForKey:@"messageId"] description];
                NSDate *currentDate = [NSDate date];//获取当前时间，日期
                NSTimeInterval interval = [currentDate timeIntervalSince1970];
                message.strTime = [[NFbaseViewController new] timestampSwitchTime:[[returnDcit objectForKey:@"sendtimes"] integerValue] anddFormatter:@"HH:mm"];
                NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:interval];
                if (![confromTimesp isThisYear]) {
                    message.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:interval anddFormatter:@"YYYY年MM月dd日"];
                }else{
                    message.strTimeHeader = [[NFbaseViewController new] timestampSwitchTime:interval anddFormatter:@"MM月dd日"];
                }
                message.localReceiveTime = [[returnDcit objectForKey:@"sendtimes"] integerValue];
                message.localReceiveTimeString = [returnDcit objectForKey:@"sendtimes"];
                if([[[returnDcit objectForKey:@"type"] description] isEqualToString:@"2"]){
                    message.type = UUMessageTypeTransfer;
                    NSDictionary *dicttt = [personalDict objectForKey:@"messageContent"];
                    message.priceAccount = [NSString stringWithFormat:@"%.2f",[[[dicttt objectForKey:@"totalMoney"] description] floatValue]/100];
                    message.strContent = [returnDcit objectForKey:@"strContent"];
                }else{
                    message.type = UUMessageTypeRed;
                    message.strContent = [returnDcit objectForKey:@"strContent"];
                    if([returnDcit objectForKey:@"singleRed"]){
                        message.priceAccount = [returnDcit objectForKey:@"singleRed"];
                    }else if([returnDcit objectForKey:@"groupRed"]){
                        message.priceAccount = [returnDcit objectForKey:@"groupRed"];
                        message.redCount = [returnDcit objectForKey:@"groupRedCount"];
                    }
                }
                
                [messageFrame setMessage:message];
                MessageChatEntity *entity = [self.fmdbServicee UUMessageFrameToMessageChatEntity:messageFrame];
                
                entity.IsSingleChat = YES;
                __weak typeof(self)weakSelf=self;
                __block NSArray *lastArr = [NSArray new];
                __block int dataaCount = 0;
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    //userId = userId order by id desc limit 5
                    dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:[dict objectForKey:@"toUserId"]];
                    lastArr = [strongSelf ->jqFmdb jq_lookupTable:[dict objectForKey:@"toUserId"] dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,1]];
                    
                }];
                //重复消息 单聊
                if(lastArr.count == 1){
                    MessageChatEntity *lastEntity = [lastArr firstObject];
                    if ([entity.message_content isEqualToString:lastEntity.message_content] && [entity.localReceiveTimeString isEqualToString:lastEntity.localReceiveTimeString] && [entity.chatId isEqualToString:lastEntity.chatId]) {
                        //如果有相同消息 则return
                        return;
                    }
                }
                //
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    NSLog(@"strongSelf ->");
                    BOOL rett = [strongSelf ->jqFmdb jq_insertTable:[dict objectForKey:@"toUserId"] dicOrModel:entity];
                    if (!rett) {
                        [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
                        return;
                    }
                    //        NSArray *arr = [weakSelf showHistoryData];
                }];
                
            }
            
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:MsgDic[@"result"] type:messageType];
                });
            }
        }
            break;
        case 9012:{
            [SVProgressHUD dismiss];
            //发送红包失败
            messageType = SecretLetterType_sendRedFaill;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:MsgDic[@"result"] type:messageType];
                });
            }
        }
            break;
        case 9013:{
#pragma mark - 收到红包消息 【群】
            //如果是自己发的，
            messageType = SecretLetterType_receiveRedpacket;
            [NFUserEntity shareInstance].isNeedRefreshLocalChatList = YES;
            if (![NFUserEntity shareInstance].appStatus || [[NFUserEntity shareInstance].PushQRCode isEqualToString:@"2"] || [[NFUserEntity shareInstance].PushQRCode isEqualToString:@"3"]) {//如果是点击推送群聊单聊进来的 则不走
                //app在后台 或点击推送、二维码扫描进来 不处理单聊、群聊消息，走消息历史
                return;
            }
            //消息通知相关
            if (![self.myManage IsCanReveive]) {
                //如果设置了不提醒 收到消息不提示
                return;
            }
            NSDictionary *resulyDict = [MsgDic objectForKey:@"result"];
            
            //收到群消息相关]
            [self receiveRedpacketMessage:resulyDict];
            
            return;
        }
            break;
        case 9014:{
            [SVProgressHUD dismiss];
            //红包检查
            
            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
            
            messageType = SecretLetterType_packetCheck;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:MsgDic[@"result"] type:messageType];
                });
            }
        }
            break;
        case 9015:{
            [SVProgressHUD dismiss];
            //红包检查、 也是领取红包成功返回
            messageType = SecretLetterType_openPacketSuccess;
            
            NSDictionary *resulyDict = [MsgDic objectForKey:@"result"];
            UUMessageFrame *messageFrame = [MessageParser RobOtherRedPacketParser:MsgDic[@"result"]];
            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
            //领取别人红包 不可能在群聊界面
//            if ([[NFUserEntity shareInstance].currentChatId isEqualToString:[[resulyDict objectForKey:@"groupId"] description]] && [[NFUserEntity shareInstance].isSingleChat isEqualToString:@"2"] && messageFrame.message.pulledMemberString.length > 0 && ![messageFrame.message.userId isEqualToString:[NFUserEntity shareInstance].userId]) {
//                //是否正在和当前群聊天
//                SecretLetterModel messageType = SecretLetterType_ReceiveGroupMessage;
//                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
//                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
//                    dispatch_async(mainQueue, ^{
//                        [self.delegate didReceiveMessage:messageFrame type:SecretLetterType_ReceiveGroupMessage];
//                    });
//                }
//                return;
//            }
            //自己领取了自己的红包 或者 不在当前群聊天界面 缓存群聊消息到消息记录
            MessageChatEntity *GroupEntity = [MessageChatEntity new];
            GroupEntity.user_id = messageFrame.message.userId;
            GroupEntity.user_name = messageFrame.message.userName;
            GroupEntity.pulledMemberString = messageFrame.message.pulledMemberString;
            GroupEntity.create_time_head = messageFrame.message.strTimeHeader;
            GroupEntity.create_time = messageFrame.message.strTime;
            GroupEntity.type = @"5";
            GroupEntity.isSelf = messageFrame.message.from == UUMessageFromMe?@"0":@"1";
            
            GroupEntity.redpacketString = messageFrame.message.redpacketString;
            GroupEntity.headPicPath = messageFrame.message.priceAccount;
            //GroupEntity.redpacketString = @"";
            
            if ([[[resulyDict objectForKey:@"groupId"] description] isEqualToString:@"0"]) {
                GroupEntity.IsSingleChat = YES;
            }
            
            if([messageFrame.message.userId isEqualToString:[NFUserEntity shareInstance].userId]){
                GroupEntity.pulledMemberString = @"  你领取了自己发的红包  ";
                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [self.delegate didReceiveMessage:MsgDic[@"result"] type:messageType];
                    });
                }
                return;
                //自己领取自己的红包 走9035 不走 9015这里 不可能走这里。自己不能领取自己的红包
            }
            if (GroupEntity.pulledMemberString.length == 0 || GroupEntity.user_name.length == 0) {
                return;//如果领取红包 为空 则不缓存
            }
            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
            //查看该表里面的消息历史
            //            NSArray *axdrrs = [jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunzu%@",[[MsgDic[@"result"] objectForKey:@"groupId"] description]] dicOrModel:[MessageChatEntity class] whereFormat:@""];
            //插入数据 群聊消息
            __weak typeof(self)weakSelf=self;
            
            //重复消息
            __block NSArray *lastArr = [NSArray new];
            __block int dataaCount = 0;
            
            if(GroupEntity.IsSingleChat){
                NSDictionary *grabinfo = [resulyDict objectForKey:@"grabinfo"];
                NSDictionary *senderInfo = [resulyDict objectForKey:@"senderInfo"];
                GroupEntity.localReceiveTimeString = [NSString stringWithFormat:@"%@#%@",[[senderInfo objectForKey:@"user_id"] description],[[grabinfo objectForKey:@"money"] description]];
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    //userId = userId order by id desc limit 5
                    dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:[[senderInfo objectForKey:@"user_id"] description]];
                    lastArr = [strongSelf ->jqFmdb jq_lookupTable:[[senderInfo objectForKey:@"user_id"] description] dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,1]];
                    
                }];
                //重复消息 单聊
                if(lastArr.count == 1){
                    MessageChatEntity *lastEntity = [lastArr firstObject];
                    if ([GroupEntity.localReceiveTimeString isEqualToString:lastEntity.localReceiveTimeString]) {
                        //如果有相同消息 则return
                        //这里需要后台给一个消息id
                        //return;
                    }
                }
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    NSLog(@"strongSelf ->");
                    BOOL rett = [strongSelf ->jqFmdb jq_insertTable:[[senderInfo objectForKey:@"user_id"] description] dicOrModel:GroupEntity];
                    if (!rett) {
                        [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
                        return;
                    }
                    //        NSArray *arr = [weakSelf showHistoryData];
                }];
                
            }else{
                //检查表
                [self.fmdbServicee IsExistGroupChatHistory:[[resulyDict objectForKey:@"groupId"] description] ISNeedAppend:YES];
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    //userId = userId order by id desc limit 5
                    dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:[NSString stringWithFormat:@"qunzu%@",[[resulyDict objectForKey:@"groupId"] description]]];
                    lastArr = [strongSelf ->jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunzu%@",[[resulyDict objectForKey:@"groupId"] description]] dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,1]];
                    
                }];
                if(lastArr.count == 1){
                    MessageChatEntity *lastEntity = [lastArr firstObject];
                    if ([GroupEntity.pulledMemberString isEqualToString:lastEntity.pulledMemberString] && [GroupEntity.pullType isEqualToString:lastEntity.pullType]) {
                        //如果有相同消息 则return
                        return;
                    }
                }
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    BOOL rett = [strongSelf ->jqFmdb jq_insertTable:[NSString stringWithFormat:@"qunzu%@",[[resulyDict objectForKey:@"groupId"] description]] dicOrModel:GroupEntity];
                    if (!rett) {
                        [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
                        return;
                    }
                }];
            }
            
            //否则 记录通知刷新
            [NFUserEntity shareInstance].isNeedRefreshLocalChatList = YES;
            
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:MsgDic[@"result"] type:messageType];
                });
            }
        }
            break;
        case 9017:{
            [SVProgressHUD dismiss];
            //红包过期
            messageType = SecretLetterType_RedOverdue;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:MsgDic[@"result"] type:messageType];
                });
            }
        }
            break;
        case 9018:{
            [SVProgressHUD dismiss];
            //红包详情
            messageType = SecretLetterType_lookPacket;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:MsgDic[@"result"] type:messageType];
                });
            }
        }
            break;
        case 9019:{
            [SVProgressHUD dismiss];
            //红包详情
            messageType = SecretLetterType_cashResult;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:MsgDic[@"result"] type:messageType];
                });
            }
        }
            break;
        case 9020:{
            [SVProgressHUD dismiss];
            //红包详情
            messageType = SecretLetterType_cashRecord;
            NSArray *arr= [RedParser tixianRecodManagerParser:MsgDic[@"result"]];
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:arr type:messageType];
                });
            }
        }
            break;
        case 9021:{
            [SVProgressHUD dismiss];
            // 用户未开户
            messageType = SecretLetterType_UserNotOpenHuiFu;
            [SVProgressHUD showInfoWithStatus:@"请点击充值，完成实名认证"];
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
        }
            break;
//        case 9022:{
//            //提现密码设置检查
//            messageType = SecretLetterType_tixianPwdCheck;
//            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
//                dispatch_queue_t mainQueue = dispatch_get_main_queue();
//                dispatch_async(mainQueue, ^{
//                    [self.delegate didReceiveMessage:MsgDic type:messageType];
//                });
//            }
//        }
//            break;
        case 9022:{
            //免密支付 设置检查
            messageType = SecretLetterType_mianmiPayCheck;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:[MsgDic objectForKey:@"result"] type:messageType];
                });
            }
        }
            break;
        case 9023:{
            //设置过 汇付支付密码
            messageType = SecretLetterType_HuifuPasswordSeted;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:MsgDic type:messageType];
                });
            }
        }
            break;
        case 9024:{
            // 没有设置过 汇付支付密码
            messageType = SecretLetterType_HuifuPasswordNOSeted;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:MsgDic type:messageType];
                });
            }
        }
            break;
        case 9025:{
            // 验证码发送成功 返回
            messageType = SecretLetterType_NoPasswordSendSuccess;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:[MsgDic objectForKey:@"result"] type:messageType];
                });
            }
        }
            break;
        case 9026:{
            // 免密支付 设置成功
            messageType = SecretLetterType_NoPasswordSetSuccess;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:[MsgDic objectForKey:@"result"] type:messageType];
                });
            }
        }
            break;
        case 9027:{
            // 免密支付 关闭成功
            messageType = SecretLetterType_NoPasswordCancelSuccess;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:[MsgDic objectForKey:@"result"] type:messageType];
                });
            }
        }
            break;
        case 9029:{
            // 红包记录 发出的
            messageType = SecretLetterType_RedRecordList;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:[MsgDic objectForKey:@"result"] type:messageType];
                });
            }
        }
            break;
        case 9030:{
            // 红包记录 收到的
            messageType = SecretLetterType_RedRecordAcceptList;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:[MsgDic objectForKey:@"result"] type:messageType];
                });
            }
        }
            break;
        case 9031:{
            // 我的 银行卡列表
            messageType = SecretLetterType_BankCardList;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:[MsgDic objectForKey:@"result"] type:messageType];
                });
            }
        }
            break;
        case 9032:{
            // 银行卡绑定结果
            messageType = SecretLetterType_BankCardBindResult;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:[MsgDic objectForKey:@"result"] type:messageType];
                });
            }
        }
            break;
        case 9033:{
            // 银行卡绑定结果
            messageType = SecretLetterType_BankCardCutResult;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:[MsgDic objectForKey:@"result"] type:messageType];
                });
            }
        }
            break;
        case 9034:{
            // 抢红包失败
            messageType = SecretLetterType_qianghongbaoFail;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:[MsgDic objectForKey:@"result"] type:messageType];
                });
            }
        }
            break;
        case 9035:{
            // 抢红包 通知
            messageType = SecretLetterType_RobredPacketRecord;
            [NFUserEntity shareInstance].isNeedRefreshLocalChatList = YES;
            
//            if (![NFUserEntity shareInstance].appStatus || [[NFUserEntity shareInstance].PushQRCode isEqualToString:@"2"] || [[NFUserEntity shareInstance].PushQRCode isEqualToString:@"3"]) {//如果是点击推送群聊单聊进来的 则不走
//                //app在后台 或点击推送、二维码扫描进来 不处理单聊、群聊消息，走消息历史
//                return;
//            }
            //消息通知相关
            if (![self.myManage IsCanReveive]) {
                //如果设置了不提醒 收到消息不提示
                return;
            }
            
            NSDictionary *resulyDict = [MsgDic objectForKey:@"result"];
            
            UUMessageFrame *messageFrame = [MessageParser RobRedPacketParser:MsgDic[@"result"]];
            
            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
            if([MsgDic[@"result"] objectForKey:@"groupId"]){
                if ([[NFUserEntity shareInstance].currentChatId isEqualToString:[[MsgDic[@"result"] objectForKey:@"groupId"] description]] && [[NFUserEntity shareInstance].isSingleChat isEqualToString:@"2"] && messageFrame.message.pulledMemberString.length > 0 && ![messageFrame.message.userId isEqualToString:[NFUserEntity shareInstance].userId]) {
                    //是否正在和当前群聊天
                    SecretLetterModel messageType = SecretLetterType_ReceiveGroupMessage;
                    if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                        dispatch_queue_t mainQueue = dispatch_get_main_queue();
                        dispatch_async(mainQueue, ^{
                            [self.delegate didReceiveMessage:messageFrame type:SecretLetterType_ReceiveGroupMessage];
                        });
                    }
                    return;
                }
            }else if([MsgDic[@"result"] objectForKey:@"userId"] && [[NFUserEntity shareInstance].currentChatId isEqualToString:[[MsgDic[@"result"] objectForKey:@"userId"] description]] && [[NFUserEntity shareInstance].isSingleChat isEqualToString:@"1"] && messageFrame.message.pulledMemberString.length > 0 && ![messageFrame.message.userId isEqualToString:[NFUserEntity shareInstance].userId]){
                //单聊。别人领取了我的红包 并且在在聊天界面
                if([[MsgDic[@"result"] objectForKey:@"type"] description] && [[[MsgDic[@"result"] objectForKey:@"type"] description] isEqualToString:@"2"]){
                    messageFrame.message.pulledMemberString = @"对方确认了你的转账";
                    messageFrame.message.type = UUMessageTypeRedRobRecord;
                    messageFrame.message.redpacketString = [[MsgDic[@"result"] objectForKey:@"redpacketId"] description];
                    messageFrame.message.priceAccount = [NSString stringWithFormat:@"%.2f",[[[MsgDic[@"result"] objectForKey:@"money"] description] floatValue]/100];
                    messageFrame.message.from = UUMessageFromOther;
                    
                }else{
                    messageFrame.message.pulledMemberString = @"对方领取了你的红包";
                    messageFrame.message.type = UUMessageTypeSystem;
                }
                
                SecretLetterModel messageType = SecretLetterType_Normal;
                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [self.delegate didReceiveMessage:messageFrame type:SecretLetterType_Normal];
                    });
                }
                return;
            }else if([MsgDic[@"result"] objectForKey:@"userId"]  && messageFrame.message.pulledMemberString.length > 0){
                //单聊。别人领取了我的红包 并且不在聊天界面
                MessageChatEntity *GroupEntity = [MessageChatEntity new];
                GroupEntity.user_id = messageFrame.message.userId;//服务器 只给我了一个userid
//                GroupEntity.user_name = messageFrame.message.userName;
//                GroupEntity.create_time_head = messageFrame.message.strTimeHeader;
//                GroupEntity.create_time = messageFrame.message.strTime;
                
                if([[MsgDic[@"result"] objectForKey:@"type"] description] && [[[MsgDic[@"result"] objectForKey:@"type"] description] isEqualToString:@"2"]){
                    GroupEntity.pulledMemberString = @"对方确认了您的转账";
                    GroupEntity.type = @"5";
                    GroupEntity.redpacketString = [[MsgDic[@"result"] objectForKey:@"redpacketId"] description];
                    GroupEntity.headPicPath = [NSString stringWithFormat:@"%.2f",[[[MsgDic[@"result"] objectForKey:@"money"] description] floatValue]/100];
                    GroupEntity.isSelf = @"1";
                }else{
                    GroupEntity.pulledMemberString = @"对方领取了你的红包";
                    GroupEntity.type = @"5";
                    GroupEntity.redpacketString = @"";
                }
                
                GroupEntity.IsSingleChat = YES;
                jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
                __weak typeof(self)weakSelf=self;
                
                //重复消息
                __block NSArray *lastArr = [NSArray new];
                __block int dataaCount = 0;
                GroupEntity.localReceiveTimeString = [NSString stringWithFormat:@"%@#",[[MsgDic[@"result"] objectForKey:@"userId"] description]];
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    //userId = userId order by id desc limit 5
                    dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:[[MsgDic[@"result"] objectForKey:@"userId"] description]];
                    lastArr = [strongSelf ->jqFmdb jq_lookupTable:[[MsgDic[@"result"] objectForKey:@"userId"] description] dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,1]];
                    
                }];
                //重复消息 单聊
                if(lastArr.count == 1){
                    MessageChatEntity *lastEntity = [lastArr firstObject];
                    if ([GroupEntity.localReceiveTimeString isEqualToString:lastEntity.localReceiveTimeString]) {
                        //如果有相同消息 则return
                        return;
                    }
                }
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    NSLog(@"strongSelf ->");
                    BOOL rett = [strongSelf ->jqFmdb jq_insertTable:[[MsgDic[@"result"] objectForKey:@"userId"] description] dicOrModel:GroupEntity];
                    if (!rett) {
                        [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
                        return;
                    }
                    //        NSArray *arr = [weakSelf showHistoryData];
                }];
                return;
            }
            
            //自己领取了自己的红包 或者 不在当前群聊天界面 缓存群聊消息到消息记录
            MessageChatEntity *GroupEntity = [MessageChatEntity new];
            GroupEntity.user_name = messageFrame.message.userName;
            GroupEntity.pulledMemberString = messageFrame.message.pulledMemberString;
            GroupEntity.create_time_head = messageFrame.message.strTimeHeader;
            GroupEntity.create_time = messageFrame.message.strTime;
            GroupEntity.type = @"5";
            GroupEntity.redpacketString = @"";
            if([messageFrame.message.userId isEqualToString:[NFUserEntity shareInstance].userId]){
                GroupEntity.pulledMemberString = @"  你领取了自己发的红包  ";
            }
            if (GroupEntity.pulledMemberString.length == 0 || GroupEntity.user_name.length == 0) {
                return;//如果领取红包 为空 则不缓存
            }
            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
            //检查表
            [self.fmdbServicee IsExistGroupChatHistory:[[MsgDic[@"result"] objectForKey:@"groupId"] description] ISNeedAppend:YES];
            //查看该表里面的消息历史
            //            NSArray *axdrrs = [jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunzu%@",[[MsgDic[@"result"] objectForKey:@"groupId"] description]] dicOrModel:[MessageChatEntity class] whereFormat:@""];
            //插入数据 群聊消息
            __weak typeof(self)weakSelf=self;
            
            //重复消息
            __block NSArray *lastArr = [NSArray new];
            __block int dataaCount = 0;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                //userId = userId order by id desc limit 5
                dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:[NSString stringWithFormat:@"qunzu%@",[[MsgDic[@"result"] objectForKey:@"groupId"] description]]];
                lastArr = [strongSelf ->jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunzu%@",[[MsgDic[@"result"] objectForKey:@"groupId"] description]] dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,1]];
                
            }];
            if(lastArr.count == 1){
                MessageChatEntity *lastEntity = [lastArr firstObject];
                if ([GroupEntity.pulledMemberString isEqualToString:lastEntity.pulledMemberString]&& [GroupEntity.pullType isEqualToString:lastEntity.pullType]) {
                    //如果有相同消息 则return
                    return;
                }
            }
            
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                BOOL rett = [strongSelf ->jqFmdb jq_insertTable:[NSString stringWithFormat:@"qunzu%@",[[MsgDic[@"result"] objectForKey:@"groupId"] description]] dicOrModel:GroupEntity];
                if (!rett) {
                    [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
                    return;
                }
            }];
            if ([currentVC isKindOfClass:[MessageChatListViewController class]]) {
                //当在会话列表界面。通知刷新
                SecretLetterModel messageType = SecretLetterType_notifyRefreshChatSessionList;
                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [self.delegate didReceiveMessage:@"" type:messageType];
                    });
                }
            }else{
                //否则 记录通知刷新
                [NFUserEntity shareInstance].isNeedRefreshLocalChatList = YES;
            }
            
        }
            break;
        case 9036:{
            [SVProgressHUD dismiss];
            //红包详情
            messageType = SecretLetterType_cashRecord;
            NSArray *arr= [RedParser MoneyRecordManagerParser:MsgDic[@"result"]];
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:arr type:messageType];
                });
            }
        }
            break;
        case 9037:{
            [SVProgressHUD dismiss];
            //账单
            messageType = SecretLetterType_BillList;
            NSDictionary *billListDict= [RedParser BillListManagerParser:MsgDic[@"result"]];
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:billListDict type:messageType];
                });
            }
        }
            break;
        case 9039:{
            [SVProgressHUD dismiss];
            //单聊收到红包
            messageType = SecretLetterType_SingleChatRedPacket;
            //消息通知相关 所有
            if (![self.myManage IsCanReveive]) {
                //如果设置了不提醒 收到消息不提示
                return;
            }
            NSDictionary *resulyDict = [MsgDic objectForKey:@"result"];
            //检查数据库表字段
            [self.fmdbServicee IsExistSingleChatHistory:[[resulyDict objectForKey:@"fromId"] description]];
            //判断是否屏蔽该人
            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
            __block NSArray *contactArr = [NSArray new];
            [jqFmdb jq_inDatabase:^{
                contactArr = [jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact new] whereFormat:@" where friend_userid = '%@'",[[resulyDict objectForKey:@"fromId"] description]];
            }];
            if (contactArr.count == 1) {
                ZJContact *contact = [contactArr firstObject];
                if (contact.IsShield) {
                    return;
                }
            }
            NSDictionary *personalDict = MsgDic[@"result"];
            NSDictionary *dict = personalDict[@"messageContent"];
            NSDictionary *returnDcit = @{@"strContent":[dict objectForKey:@"content"],@"type":@"3",@"userName":[personalDict objectForKey:@"fromName"],@"userId":[personalDict objectForKey:@"fromId"],@"singleRed":@"0",@"from":@"1",@"strTime":[[NSDate date] description],@"strIcon":@"",@"redpacketString":[dict objectForKey:@"redpacketId"],@"userNickName":[personalDict objectForKey:@"fromNickName"],@"appMsgId":[personalDict objectForKey:@"messageId"]};
            
            UUMessageFrame *messageFrame = [[UUMessageFrame alloc]init];
            UUMessage *message = [[UUMessage alloc] init];
            [message setWithDict:returnDcit];
            message.from = UUMessageFromOther;
            message.redpacketString = [[dict objectForKey:@"redpacketId"] description];
            message.chatId = [[personalDict objectForKey:@"messageId"] description];
            message.strTime = [[NFbaseViewController new] timestampSwitchTime:[[[dict objectForKey:@"sendtimes"] description] integerValue] anddFormatter:@"HH:mm"];
            message.localReceiveTime = [[[dict objectForKey:@"sendtimes"] description] integerValue];
            message.localReceiveTimeString = [[dict objectForKey:@"sendtimes"] description];
            if([[[dict objectForKey:@"type"] description] isEqualToString:@"2"]){
                message.type = UUMessageTypeTransfer;
                NSDictionary *dicttt = [personalDict objectForKey:@"messageContent"];
                message.priceAccount = [NSString stringWithFormat:@"%.2f",[[[dicttt objectForKey:@"totalMoney"] description] floatValue]/100];
                message.strContent = [returnDcit objectForKey:@"content"];
            }else{
                //message.type = UUMessageTypeRed;
            }  
            [messageFrame setMessage:message];
            MessageChatEntity *entity = [self.fmdbServicee UUMessageFrameToMessageChatEntity:messageFrame];
            entity.IsSingleChat = YES;
            __weak typeof(self)weakSelf=self;
            __block NSArray *lastArr = [NSArray new];
            __block int dataaCount = 0;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                //userId = userId order by id desc limit 5
                dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:[dict objectForKey:@"senduserId"]];
                lastArr = [strongSelf ->jqFmdb jq_lookupTable:[dict objectForKey:@"senduserId"] dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,1]];
                
            }];
            //重复消息 单聊
            if(lastArr.count == 1){
                MessageChatEntity *lastEntity = [lastArr firstObject];
                if ([entity.message_content isEqualToString:lastEntity.message_content] && [entity.localReceiveTimeString isEqualToString:lastEntity.localReceiveTimeString]) {
                    //如果有相同消息 则return
                    return;
                }
            }
            
            if (![[NFUserEntity shareInstance].currentChatId isEqualToString:[[resulyDict objectForKey:@"fromId"] description]] && ![[NFUserEntity shareInstance].isSingleChat isEqualToString:@"1"]) {
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    NSLog(@"strongSelf ->");
                    BOOL rett = [strongSelf ->jqFmdb jq_insertTable:[dict objectForKey:@"senduserId"] dicOrModel:entity];
                    if (!rett) {
                        [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
                        return;
                    }
                    //        NSArray *arr = [weakSelf showHistoryData];
                }];
            }
            
            if ([[NFUserEntity shareInstance].currentChatId isEqualToString:[[resulyDict objectForKey:@"fromId"] description]] && [[NFUserEntity shareInstance].isSingleChat isEqualToString:@"1"]) {
                //设置角标+1 正在和该人聊天中 无需设置为度+1
                //                [[NFbaseViewController new] setBadgeCountWithCount:1 AndIsAdd:YES];
                //回到会话界面设置刷新会话列表
                [NFUserEntity shareInstance].isNeedRefreshLocalChatList = YES;
#pragma msrk - 设置消息已读
                [self readedRequest:[resulyDict objectForKey:@"messageId"] AndReceiveName:[resulyDict objectForKey:@"fromName"]];
                messageType = SecretLetterType_Normal;
                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [self.delegate didReceiveMessage:messageFrame type:messageType];
                    });
                }
            }else{
                //设置刷新会话列表为yes
                [NFUserEntity shareInstance].isNeedRefreshChatList = YES;
                //当没和该信息发出者聊天中时
                //[self WhenNotChatWithThisMessageUser:resulyDict];
#warning 声音提醒
                if ([self.myManage respondsToSelector:@selector(notifySet)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.myManage performSelector:@selector(notifySet) withObject:nil afterDelay:notifyDelayTime];
                    });
                }
                //通知消息tabbar角标改变
                //获取当前显示的viewcontroller
                UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
                //再进单聊需要请求历史消息 【如果从会话列表进去 事实不需要的话 下面属性会成为no的】
                //    if ([currentVC isKindOfClass:[SingleChatDetailTableViewController class]]) {
                [NFUserEntity shareInstance].isNeedRefreshChatData = YES;
                [NFUserEntity shareInstance].isNeedRefreshSingleChatHistory = YES;
                //当前页面不是消息或其子类界面 显示红点
                if (currentVC.navigationController.tabBarItem.tag != 1) {
                    //当不在会话列表界面 则改变角标 进行缓存消息 messageFrame 这里需要缓存 因为当先收到对方发的消息后 再收到web端自己发的消息 如果这里不缓存 那么自己发的消息则会在对方先发的消息上面
                    [[NFbaseViewController new] setBadgeCountWithCount:1 AndIsAdd:YES];
                    //        UUMessageFrame *messageFrame = [MessageParser GotNormalMessageContantParser:data];
                    //        MessageChatEntity *entity = [self.fmdbServicee UUMessageFrameToMessageChatEntity:messageFrame];
                    //        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
                    //        //插入数据
                    //        [jqFmdb jq_inDatabase:^{
                    //            BOOL rett = [jqFmdb jq_insertTable:[[data objectForKey:@"fromId"] description] dicOrModel:entity];
                    //            if (!rett) {
                    //                [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
                    //                //                return;
                    //            }
                    //        }];
                    
                    
                }else{
                    //在会话列表界面 通知刷新会话列表
                    SecretLetterModel messageType = SecretLetterType_notifyRefreshChatSessionList;
                    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                    UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
                    if ([currentVC isKindOfClass:[MessageChatListViewController class]]) {
                        [NFUserEntity shareInstance].showPrompt = YES;
                    }
                    if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                        dispatch_queue_t mainQueue = dispatch_get_main_queue();
                        dispatch_async(mainQueue, ^{
                            [self.delegate didReceiveMessage:@"" type:messageType];
                        });
                    }
                    //再会话列表同样需要改变角标 无需再这里改变角标，当刷新会话列表时候 会改变角标
                    //        [[NFbaseViewController new] setBadgeCountWithCount:1 AndIsAdd:YES];
                }
                
                //设置已收到 需要一个contantid
                //                [self haveReceived:[resulyDict objectForKey:@""]];
            }
            
//            NSDictionary *billListDict= [RedParser BillListManagerParser:MsgDic[@"result"]];
//            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
//                dispatch_queue_t mainQueue = dispatch_get_main_queue();
//                dispatch_async(mainQueue, ^{
//                    [self.delegate didReceiveMessage:billListDict type:messageType];
//                });
//            }
        }
            break;
        case 9040:{
            //[SVProgressHUD dismiss];
            //
            messageType = SecretLetterType_SubAmountOpenSuccess;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:[MsgDic objectForKey:@"result"] type:messageType];
                });
            }
        }
            break;
        case 9041:{
            //[SVProgressHUD dismiss];
            //
            messageType = SecretLetterType_OpenAmountSuccess;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:[MsgDic objectForKey:@"result"] type:messageType];
                });
            }
        }
            break;
        case 9042:{
            //[SVProgressHUD dismiss];
            //用户已开户
            messageType = SecretLetterType_UserOpenHuiFued;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
        }
            break;
        case 9043:{//提现返回 银行卡不存在
            messageType = SecretLetterType_cardNotExist;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
        }
            break;
        case 9044:{//提现返回 提现失败
            messageType = SecretLetterType_tixianFail;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
        }
            break;
        case 9045:{//提现返回 提现审核中
            messageType = SecretLetterType_tixianShenhezhong;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
        }
            break;
            case 9046:{//重复添加银行卡
                messageType = SecretLetterType_repeatAddCardTip;
                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [SVProgressHUD showInfoWithStatus:@"该银行卡已添加"];
                        //[self.delegate didReceiveMessage:@"" type:messageType];
                    });
                }
            }
                break;
            case 9047:{//单笔充值限额
                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [SVProgressHUD showInfoWithStatus:@"单笔充值限额"];
                        //[self.delegate didReceiveMessage:@"" type:messageType];
                    });
                }
            }
                break;
                case 9048:{//当天充值限额
                    if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                        dispatch_queue_t mainQueue = dispatch_get_main_queue();
                        dispatch_async(mainQueue, ^{
                            [SVProgressHUD showInfoWithStatus:@"当天充值限额"];
                            //[self.delegate didReceiveMessage:@"" type:messageType];
                        });
                    }
                }
                    break;
                    case 9049:{//单笔提现限额
                        if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                            dispatch_queue_t mainQueue = dispatch_get_main_queue();
                            dispatch_async(mainQueue, ^{
                                [SVProgressHUD showInfoWithStatus:@"单笔提现限额"];
                                //[self.delegate didReceiveMessage:@"" type:messageType];
                            });
                        }
                    }
                        break;
                        case 9050:{//当天提现限额
                            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                                dispatch_async(mainQueue, ^{
                                    [SVProgressHUD showInfoWithStatus:@"当天提现限额"];
                                    //[self.delegate didReceiveMessage:@"" type:messageType];
                                });
                            }
                        }
                            break;
                            case 9051:{//当天提现次数上限
                                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                                    dispatch_async(mainQueue, ^{
                                        [SVProgressHUD showInfoWithStatus:@"当天提现次数上限"];
                                        //[self.delegate didReceiveMessage:@"" type:messageType];
                                    });
                                }
                            }
                                break;
        case 9000:{
            //[SVProgressHUD dismiss];
            //
            messageType = SecretLetterType_checkGet;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:[MsgDic objectForKey:@"result"] type:messageType];
                });
            }
        }
            break;
        case 1001:{
            
        }
            break;
            //
        case 1002:{
#pragma mark - 1002登陆成功
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_LoginReceipt;
            NSLog(@"1002");
            LoginEntity *entityy = [LoginParser loginRequestManagerParser:MsgDic[@"result"]];
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:entityy type:messageType];
                });
            }
            //通知界面 刷新请求
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"" type:SecretLetterType_SocketConnectChanged];
                });
            }
            //通知刷新会话列表的界面【去除连接失败】 socket连接成功 还需要登录成功才能成功发送消息
            if (![NFUserEntity shareInstance].userIsConncected) {
                NSLog(@"1002 connectSuccess ");
                [self connectSuccess];//当为连接失败状态 才进行通知界面 防止多次进行登录
            }
            //记录用户为登录状态
            [NFUserEntity shareInstance].userIsConncected = YES;
            loginRequestTime = 0;//登录成功设置
            
        }
            break;
        case 1003:{
#pragma mark - 1003登陆失败 登录失败后不能立马进行重连 需要等1秒 防止真的断开 而重连还需要一小段时间 这个时间内 将进行了多次连接
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_LoginReceipt;
            NSLog(@"1003");
            [NFUserEntity shareInstance].userIsConncected = NO;//记录登录状态为NO 
//            reconnectCount++;
//            if (reconnectCount > 50) {
//                return;
//            }
//            [SVProgressHUD showErrorWithStatus:@"聊天系统未连接"];
            //判断有无网络
            if ([ClearManager getNetStatus]) {
                //有网 进行重连
                if ([NFUserEntity shareInstance].userType == NFUserWX && ![NFUserEntity shareInstance].userIsConncected) {
                    [self weixinLoginRequest];
                }else if ([NFUserEntity shareInstance].userType == NFUserGeneral && ![NFUserEntity shareInstance].userIsConncected){
                    [self loginWithDefaultType];
                }else if (![NFUserEntity shareInstance].userIsConncected){
                    
                    [self loginWithDefaultType];
                }
                
//                dispatch_queue_t mainQueue = dispatch_get_main_queue();
//                dispatch_async(mainQueue, ^{
//                    [self performSelector:@selector(loginWithDefaultType) withObject:nil afterDelay:0.2];
//                });
            }
//            LoginEntity *entityy = [[LoginEntity alloc] init];
//            entityy.wrongMessage = @"登陆失败";
//            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
//                dispatch_queue_t mainQueue = dispatch_get_main_queue();
//                dispatch_async(mainQueue, ^{
//                    [self.delegate didReceiveMessage:entityy type:messageType];
//                });
//            }
        }
            break;
        case 1004:{
#pragma mark - 1004密码错误
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_LoginReceipt;
            LoginEntity *entityy = [[LoginEntity alloc] init];
            entityy.wrongMessage = @"用户名或密码错误";
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:entityy type:messageType];
                });
            }
        }
            break;
        case 1008:{
#pragma mark - 1008用户已存在
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_LoginReceipt;
            [SVProgressHUD showInfoWithStatus:@"账号已存在"];
        }
            break;
        case 1009:{
#pragma mark - 1009注册成功
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_RegisterReceipt;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"registerSucceed" type:messageType];
                });
            }
        }
            break;
        case 1010:{
#pragma mark - 1010注册失败
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:@"注册失败"];
        }
            break;
        case 1011:{
#pragma mark - 1011 数据格式错误
            [SVProgressHUD showErrorWithStatus:@"数据格式错误"];
            
        }
            break;
            #pragma mark - 1012 请求个人信息详情
                    case 1012://
                    {
                        [SVProgressHUD dismiss];
                        messageType = SecretLetterType_PersonalInfoDetail;
                        PersonalInfoDetailEntity *entity = [NFMineParser PersonalInfoDetailParser:MsgDic[@"result"]];
            //            NSLog(@"\n%@\n%@\n%@\n%@",entity.nick_name,entity.sex,entity.area,entity.sign);
                        if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                            dispatch_queue_t mainQueue = dispatch_get_main_queue();
                            dispatch_async(mainQueue, ^{
                                [self.delegate didReceiveMessage:entity type:messageType];
                            });
                        }
                    }
                        break;
        case 1014:{
#pragma mark - 1014验证码发送成功s
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_RegisterVerication;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:MsgDic[@"result"] type:messageType];
                });
            }
        }
            break;
        case 1015:{
#pragma mark - 1015 短信发送失败
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_RegisterVericationFail;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:MsgDic[@"result"] type:messageType];
                });
            }
        }
            break;
        case 1016:{
#pragma mark - 1016 验证码发送频繁
                [SVProgressHUD dismiss];
                messageType = SecretLetterType_RegisterVericationOften;
                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [self.delegate didReceiveMessage:MsgDic[@"result"] type:messageType];
                    });
                }
            }
            break;
        case 1017:{
#pragma mark - 1017 验证码错误
//            [SVProgressHUD dismiss];
            messageType = SecretLetterType_RegisterVericationAlreadyError;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:MsgDic[@"result"] type:messageType];
                });
            }
        }
            break;
        case 1018:{
#pragma mark - 1018 重置密码
            [SVProgressHUD showInfoWithStatus:@"手机号不存在"];
//            messageType = SecretLetterType_RegisterVericationAlreadyError;
//            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
//                dispatch_queue_t mainQueue = dispatch_get_main_queue();
//                dispatch_async(mainQueue, ^{
//                    [self.delegate didReceiveMessage:MsgDic[@"result"] type:messageType];
//                });
//            }
        }
            break;
        case 1019:{
#pragma mark - 1019 该账号已经被某账号绑定
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_RegisterVericationAlreadyBinging;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:MsgDic[@"result"] type:messageType];
                });
            }
        }
            break;
        case 1020:{
#pragma mark - 1020 重置密码成功
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_RegisterVericationRetSuccess;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:MsgDic[@"result"] type:messageType];
                });
            }
        }
            break;
        case 1021:{
#pragma mark - 1021 重置密码失败
            [SVProgressHUD dismiss];
            [SVProgressHUD showInfoWithStatus:@"重置密码失败"];
//            messageType = SecretLetterType_RegisterVericationRetSuccess;
//            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
//                dispatch_queue_t mainQueue = dispatch_get_main_queue();
//                dispatch_async(mainQueue, ^{
//                    [self.delegate didReceiveMessage:MsgDic[@"result"] type:messageType];
//                });
//            }
        }
            break;
            //SecretLetterType_RegisterVericationBingingSuccess
        case 1023:{
#pragma mark - 1023 绑定多信账号成功
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_RegisterVericationBingingSuccess;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:MsgDic[@"result"] type:messageType];
                });
            }
        }
            break;
        case 1024:{
#pragma mark - 1024 绑定多信账号失败
            [SVProgressHUD showInfoWithStatus:@"绑定失败"];
//            messageType = SecretLetterType_RegisterVericationBingingSuccess;
//            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
//                dispatch_queue_t mainQueue = dispatch_get_main_queue();
//                dispatch_async(mainQueue, ^{
//                    [self.delegate didReceiveMessage:MsgDic[@"result"] type:messageType];
//                });
//            }
        }
            break;
        case 1025:{
#pragma mark - 1025 密码错误次数过多
            [SVProgressHUD showInfoWithStatus:@"操作频繁,请稍后重试"];
            
        }
            break;//
        case 1027:{
#pragma mark - 1027
            NSLog(@"");
            
        }
            break;//
        case 1028:{
#pragma mark - 1028 扫码登录反馈 成功
            //SecretLetterType_QRCodeLoginSuccess
            messageType = SecretLetterType_QRCodeLoginFeedBack;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    //result:0成功 1失败
                    [self.delegate didReceiveMessage:@{@"result":@"0"} type:messageType];
                });
            }
        }
            break;
        case 1029:{
#pragma mark - 1028 扫码登录反馈 失败
            //SecretLetterType_QRCodeLoginSuccess
            messageType = SecretLetterType_QRCodeLoginFeedBack;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    //result:0成功 1失败
                    [self.delegate didReceiveMessage:@{@"result":@"1"} type:messageType];
                });
            }
        }
            break;
        case 1030:{
#pragma mark - 1030 设置支付密码成功
            //SecretLetterType_QRCodeLoginSuccess
            messageType = SecretLetterType_setPasswordSuccess;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    //result:0成功 1失败
                    [self.delegate didReceiveMessage:@{@"errcode":@"0"} type:messageType];
                });
            }
        }
            break;
        case 1031:{
#pragma mark - 1031 设置支付密码重复
            //SecretLetterType_QRCodeLoginSuccess
            messageType = SecretLetterType_setPasswordRepeat;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    //result:0成功 1失败
                    [self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
        }
            break;
        case 1032:{
#pragma mark - 1032 支付密码错误
            //SecretLetterType_QRCodeLoginSuccess
            messageType = SecretLetterType_passwordError;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    //result:0成功 1失败
                    [self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
        }
            break;
        case 1033:{
#pragma mark - 1033 
            //验证码正确
            messageType = SecretLetterType_checkPayCodeSuccess;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    //result:0成功 1失败
                    [self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
        }
            break;
        case 1034:{
#pragma mark - 1034
            // 登录成功 返回1002之前 踢出所有登录账号
            NSDictionary *loginCheckDict  = MsgDic[@"result"];
            NSString *LoginIp = [NFUserEntity shareInstance].netIP.length > 0?[NFUserEntity shareInstance].netIP:[SystemInfo shareSystemInfo].DeviceIPAddresses;//ip地址
            NSString *osVersion = [SystemInfo shareSystemInfo].OSVersion;//系统版本
            if([NFUserEntity shareInstance].userId.length > 0 && ![[[loginCheckDict objectForKey:@"loginIp"] description] isEqualToString:LoginIp] && ![[[loginCheckDict objectForKey:@"osVersion"] description] isEqualToString:osVersion]){
                [NFUserEntity shareInstance].userId = @"";
                [KeepAppBox keepVale:@"" forKey:kLoginPassWord];
                [KeepAppBox keepVale:@"" forKey:kLoginWeixinUserName];
                [NFUserEntity shareInstance].userName = @"";
                [NFUserEntity shareInstance].JPushId = @"";
                //退出登录 销毁定时请求
                [[GCDTimerManager sharedInstance] cancelTimerWithName:@"checkHeartTuikuan"];
                [NFUserEntity shareInstance].isTiXianPassWord = NO;
                [NFUserEntity shareInstance].isTiXianPassWord = NO;
                [NFUserEntity shareInstance].isShouquanCancelPwd = NO;
                [self disConnect];//断开链接	7
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您的账户在其他地方登录，如不是您本人操作，请您更换密码!" preferredStyle:UIAlertControllerStyleAlert];
//                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您在其他设备登录，请重新登录" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *actionSure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    //退出登录请求 不需要收到退出消息
                    [self quitSocketRequestDing];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kGoto_Login_Rootview object:kGoto_Login_Rootview_LgoinHome];
                }];
                
                [alertController addAction:actionSure];
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [[KeepAppBox topViewController] presentViewController:alertController animated:YES completion:nil];
                });
            }
            
            
        }
            break;
        case 1035:{
            #pragma mark - 1035
                        //手机号换绑成功
                        messageType = SecretLetterType_UserHuanBingSuccess;
                        if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                            dispatch_queue_t mainQueue = dispatch_get_main_queue();
                            dispatch_async(mainQueue, ^{
                                //result:0成功 1失败
                                [self.delegate didReceiveMessage:@"" type:messageType];
                            });
                        }
                    }
                        break;
        case 2002:{
#pragma mark - 2002获取会话列表
            messageType = SecretLetterType_getChatSessionList;
            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//            MessageChatListEntity *entity = [MessageChatListEntity new];
            __block NSMutableArray *backArr = [NSMutableArray new];
            dispatch_group_t group = dispatch_group_create();
            dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
                dispatch_group_enter(group);
                NSDictionary *ConversationDict  = MsgDic[@"result"];
                backArr = [MessageParser ConvasationListParser:ConversationDict];
                dispatch_group_leave(group);
            });
            dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
#warning 拉黑 先注释
            
            //收到会话列表 看看该联系人是否被拉黑，拉黑则移除该条数据
//            NSMutableArray *removeIndex = [NSMutableArray new];
//            for (int i = 0; i<backArr.count; i++) {
//                MessageChatListEntity *entity = backArr[i];
//                NSArray *contactArr = [jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact new] whereFormat:@" where friend_userid = '%@'",entity.conversationId];
//                if (contactArr.count > 0) {
//                    ZJContact *contact = [contactArr firstObject];
//                    if (contact.IsShield) {
//                        [removeIndex addObject:[NSString stringWithFormat:@"%d",i]];
//                    }
//                }
//            }
//            for (NSString *i in removeIndex) {
//                int a = [i intValue];
//                MessageChatListEntity *entity = backArr[a];
//                [backArr removeObject:entity];
//            }
            //在会话列表界面初始化角标
//            NSLog(@"%ld",[NFUserEntity shareInstance].badgeCount);
            
//            if (backArr.count == 0) {
//                return;//当收到的会话列表为nil 则不提醒刷新 【声音是在4002中的 设置设置无效 4002种无法知道该消息是否已读所以无法进行判断不提示声音】
//            }
            if(backArr.count > 0){
                // 根据tabbarcontroller 获取到会话列表界面进行刷新数据
                MessageChatListViewController *firstTabbarVC = (MessageChatListViewController *)[[ClearManager new] getRootViewControllerOfTabbarRootIndex:0];
                //看看是否不需要请求历史消息
                NSArray *arr = [self checkIsNotRequestHistory:backArr];
                [firstTabbarVC conversationListRefresh:arr];
            }
            
//            }
            
//            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
//                dispatch_queue_t mainQueue = dispatch_get_main_queue();
//                dispatch_async(mainQueue, ^{
//                    [self.delegate didReceiveMessage:backArr type:messageType];
//                });
//            }
        }
            break;
        case 3001:
#pragma mark - 添加好友请求
            break;
        case 3002:
        {
#pragma mark - 3002接收到好友请求 {"status":3002,"result":{"sendUid":20}}
            //收到消息会通知界面 只有联系人界面会接收这个type的提醒
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_FriendAddRequest;
            __block UIViewController *currentVC;
            __block UIViewController *rootViewController;
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
            });
//            NSLog(@"%ld",currentVC.navigationController.tabBarItem.tag);
            //如果是选中在联系人tabbar 则上面会通知到 在界面修改 直接return
//            if ([currentVC isKindOfClass:[ZJContactViewController class]]) {
//                return;
//            }
            NSInteger count = 0;
            NSArray *addFriendList;
            id obj = MsgDic[@"result"];
            if ([obj isKindOfClass:[NSString class]]) {
                count = [MsgDic[@"result"] integerValue];
            }else if ([obj isKindOfClass:[NSArray class]]){
                addFriendList = MsgDic[@"result"];
                count = addFriendList.count;
            }
            //在除了联系人界面 立马记录申请与通知单例，并当currentVC不是联系人tabbar及push的子视图时 进行设置tabar角标
            __block UITabBarItem *tabBarItemWillBadge;
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                tabBarItemWillBadge = currentVC.navigationController.tabBarController.tabBar.items[1];
            });
            //设置 是否有通知为yes
            [NFUserEntity shareInstance].IsApplyAndNotify = YES;
//            if (currentVC.navigationController.tabBarItem.tag != 2) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    //改变tabbaritem角标
                    [[NFbaseViewController new] setContactBadgeCountWithCount:count];
                    if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                        [self.delegate didReceiveMessage:@"yes" type:messageType];
                    }
//                    [tabBarItemWillBadge yee_MakeRedBadge:4 color:[UIColor redColor]];
                });
//            }
        }
            break;
        case 3003:
#pragma mark -3003 接收好友请求
        {
            NSLog(@"3003");
        }
            break;
        case 3004:
#pragma mark - 拒绝好友请求
        {
            
        }
            break;
        case 3005://永远拒绝好友请求
        {
            
        }
            break;
        case 3006:
#pragma mark - 3006接受好友请求成功
        {
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_Promet;
            WrongMessageAddFriendEntity *entity = [WrongMessageAddFriendEntity new];
            entity.backMessage = @"接受成功";
            entity.messageType = @"1";
            NSDictionary *backDict = MsgDic[@"result"];
            entity.backId = [backDict objectForKey:@"friend_userid"];
            entity.backName = [backDict objectForKey:@"friend_username"];
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:entity type:messageType];
                });
            }
        }
            break;
        case 3007:
#pragma mark - 3007接收好友请求失败
        {
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_Promet;
            WrongMessageAddFriendEntity *entity = [WrongMessageAddFriendEntity new];
            entity.IsSuccess = NO;
            entity.backMessage = @"接受失败";
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:entity type:messageType];
                });
            }
        }
            break;
        case 3008://好友拉黑
        {
            //SecretLetterType_PullBlack
            NSLog(@"好友拉黑");
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_PullBlack;
            SingleDetailEntity *entity = [SingleDetailEntity new];
            entity.IsPullBlack = YES;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:entity type:messageType];
                });
            }
        }
            break;
        case 3009://取消好友拉黑
        {
            NSLog(@"取消好友拉黑");
        }
            break;
#pragma mark - 3010发送好友请求成功
        case 3010://发送好友请求成功
        {
//            [SVProgressHUD showInfoWithStatus:@"发送请求成功"];
            NSDictionary *backDict = MsgDic[@"result"];
            messageType = SecretLetterType_FriendAddSendSuccess;
            [NFUserEntity shareInstance].isNeedRefreshFriendList = YES;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
        }
            break;
        case 3011:
        {
#pragma mark - 已发送过好友请求
            //已发送过好友请求
            [SVProgressHUD showInfoWithStatus:@"已发送过好友请求"];
        }
            break;
        case 3012:{
#pragma mark - 3012添加不存在的用户
            [SVProgressHUD dismiss];
            [SVProgressHUD showInfoWithStatus:@"添加不存在的用户"];
        }
            break;
        case 3013:{
#pragma mark - 3013接收好友请求列表
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_FriendAddList;
            __block NSArray *retArr = [NSArray new];
            dispatch_group_t group = dispatch_group_create();
            dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
                dispatch_group_enter(group);
                retArr = [NewHomeParser FriendAddListParser:MsgDic[@"result"]];
                dispatch_group_leave(group);
            });
            dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
            //通知代理
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:retArr type:messageType];
                });
            }
        }
            break;
        case 3014:
        {
#pragma mark - 3014好友已在列表中
            [SVProgressHUD showInfoWithStatus:@"好友已在列表中"];
            [NFUserEntity shareInstance].isNeedRefreshFriendList = YES;
        }
            break;
        case 3015:
#pragma mark - 3015拒绝好友请求成功
        {
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_Promet;
            WrongMessageAddFriendEntity *entity = [WrongMessageAddFriendEntity new];
            entity.IsSuccess = YES;
            entity.backMessage = @"拒绝成功";
            entity.messageType = @"2";
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:entity type:messageType];
                });
            }
        }
            break;
        case 3016:
#pragma mark - 3016拒绝好友请求失败
        {
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_Promet;
            WrongMessageAddFriendEntity *entity = [WrongMessageAddFriendEntity new];
            entity.IsSuccess = NO;
            entity.backMessage = @"拒绝失败";
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:entity type:messageType];
                });
            }
        }
            break;
        case 3017:
#pragma mark - 3017获取联系人列表、好友列表成功
        {
            messageType = SecretLetterType_FriendList;
            __block NSArray *resultArr = [NSArray new];
            __block NSArray *backArr = [NSArray new];
            //收到联系人列表 缓存联系人
            dispatch_group_t group = dispatch_group_create();
            dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
                dispatch_group_enter(group);
                resultArr = MsgDic[@"result"];
                backArr = [NewHomeParser contantListManagerParserr:MsgDic[@"result"]];
                UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
                //当前界面不是联系人列表 则走下面
                if (![currentVC isKindOfClass:[ZJContactViewController class]]) {
                    [self.fmdbServicee cacheZJContactListWithArr:backArr];
                }
                dispatch_group_leave(group);
            });
            dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
            //通知代理
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:backArr type:messageType];
                });
            }
        }
            break;
        case 3018://获取联系人列表失败
        {
            [SVProgressHUD showInfoWithStatus:@"获取联系人列表失败"];
        }
            break;
            //
#pragma mark - 3019://删除、忽略申请成功
        case 3019://删除、忽略申请成功
        {
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_FriendAddIgnoreSuccess;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
        }
            break;
#pragma mark - 3020://对方已同意您的好友请求
        case 3020://
        {
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_FriendAddAlreadyAgree;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
            if ([currentVC isKindOfClass:[ZJContactViewController class]]) {
                return;
            }
            //当不在联系人列表界面。记录刷新
            [NFUserEntity shareInstance].isNeedRefreshFriendList = YES;
            UITabBarItem *tabBarItemWillBadge = currentVC.navigationController.tabBarController.tabBar.items[1];
            //设置 是否有通知为yes
            [NFUserEntity shareInstance].IsApplyAndNotify = YES;
            if (currentVC.navigationController.tabBarItem.tag != 2) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [tabBarItemWillBadge yee_MakeRedBadge:4 color:[UIColor redColor]];
                });
            }
            //请求一下好友列表 缓存
            [self getFriendList];
            
        }
            break;
#pragma mark -3021 您已不在对方好友列表
        case 3021://您已不在对方好友列表 【当发消息的时候 可能走这里 返回一条特殊消息 提示你不在对方好友列表】
        {
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_FriendNotExist;
            UUMessageFrame *messageFrame = [UUMessageFrame new];
            UUMessage *message = [UUMessage new];
            message.chatId = @"x";
            [messageFrame setMessage:message];
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:messageFrame type:messageType];
                });
            }
        }
            break;
#pragma mark - 3022删除好友成功
        case 3022://删除好友成功
        {
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_FriendDeleteSuccess;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
                     }
            break;
#pragma mark -3023 搜索好友成功搜到
        case 3023://搜索好友回调
        {
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_FriendSearchResult;
            FriendSearchResultEntity *entity = [NewHomeParser FriendSearchResultListParser:MsgDic[@"result"]];
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:entity type:messageType];
                });
            }
        }
            break;
#pragma mark - 3024搜索好友 没有该id
        case 3024:
        {
            messageType = SecretLetterType_FriendSearchResult;
            [SVProgressHUD showInfoWithStatus:@"未搜索到该用户"];
            FriendSearchResultEntity *entity = [FriendSearchResultEntity new];
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:entity type:messageType];
                });
            }
        }
            break;
#pragma mark - 3025设置个人信息
        case 3025://设置个人信息
        {
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_PersonalInfoSet;
            NSDictionary *info = [NFMineParser PersonalInfoSetParser:MsgDic[@"result"]];
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:info type:messageType];
                });
            }
        }
            break;
#pragma mark - 3027修改好友备注成功
        case 3027://修改好友备注
        {
            [SVProgressHUD dismiss];
            NSDictionary *info = MsgDic[@"result"];
            
            //更改会话列表
            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
            __weak typeof(self)weakSelf=self;
            //将本地缓存取出来 用于与服务器的进行对比
            __block NSArray *localChatListArr = [NSArray new];
            __block NSArray *localContactListArr = [NSArray new];
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                localChatListArr = [strongSelf ->jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@"where conversationId = '%@' and IsSingleChat = '1'",[[info objectForKey:@"user_id"] description]];
                localContactListArr = [strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact new] whereFormat:@" where friend_userid = '%@'",[[info objectForKey:@"user_id"] description]];
            }];
            if(localChatListArr.count > 0){
                MessageChatListEntity *entity = [localChatListArr firstObject];
                if([entity.nickName isEqualToString:[[info objectForKey:@"friend_comment_name"] description]] && [entity.nickName length] > 0){
                    break;
                }
                entity.nickName = [[[info objectForKey:@"friend_comment_name"] description] length]>0?[[info objectForKey:@"friend_comment_name"] description]:[[info objectForKey:@"nickname"] description];
                //更新缓存
                [[NFMyManage new] changeFMDBData:entity KeyWordKey:@"conversationId" KeyWordValue:[[info objectForKey:@"user_id"] description] FMDBID:@"tongxun.sqlite" secondKeyWordKey:@"IsSingleChat" secondKeyWordValue:@"1" TableName:@"huihualiebiao"];
            }
            if(localContactListArr.count > 0){
                ZJContact *entity = [localContactListArr firstObject];
                entity.friend_nickname = [[[info objectForKey:@"friend_comment_name"] description] length]>0?[[info objectForKey:@"friend_comment_name"] description]:[[info objectForKey:@"nickname"] description];
                entity.friend_comment_name = [[[info objectForKey:@"friend_comment_name"] description] length]>0?[[info objectForKey:@"friend_comment_name"] description]:[[info objectForKey:@"nickname"] description];
                //更新缓存
                [[NFMyManage new] changeFMDBData:entity KeyWordKey:@"friend_userid" KeyWordValue:[[info objectForKey:@"user_id"] description] FMDBID:@"tongxun.sqlite" TableName:@"lianxirenliebiao"];
            }
            
            NSLog(@"");
        }
            break;
#pragma mark - 3028修改好友备注失败
        case 3028://修改好友备注
        {
            [SVProgressHUD dismiss];
            NSDictionary *info = MsgDic[@"result"];
            
            NSLog(@"");
        }
            break;
        #pragma mark -3029 拉黑成功
        case 3029://修改好友备注
        {
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_PullBlackSuccess;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
        }
            break;
            #pragma mark - 3030取消拉黑成功/
           case 3030:
           {
               [SVProgressHUD dismiss];
               messageType = SecretLetterType_CancelPullBlackSuccess;
               if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                   dispatch_queue_t mainQueue = dispatch_get_main_queue();
                   dispatch_async(mainQueue, ^{
                       [self.delegate didReceiveMessage:@"" type:messageType];
                   });
               }
           }
               break;
            #pragma mark -3031 是否拉黑
           case 3031:
           {
               [SVProgressHUD dismiss];
               messageType = SecretLetterType_friendBlackState;
               if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                   dispatch_queue_t mainQueue = dispatch_get_main_queue();
                   dispatch_async(mainQueue, ^{
                       [self.delegate didReceiveMessage:MsgDic[@"result"] type:messageType];
                   });
               }
           }
               break;
             #pragma mark -3032 拉黑列表
            case 3032:
            {
                [SVProgressHUD dismiss];
                messageType = SecretLetterType_friendBlackList;
                 NSArray *resultArr = [NSArray new];
                 NSArray *backArr = [NSArray new];
                 resultArr = MsgDic[@"result"];
                 backArr = [NewHomeParser contantListManagerParserr:MsgDic[@"result"]];
                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [self.delegate didReceiveMessage:backArr type:messageType];
                    });
                }
            }
                break;
                 #pragma mark - 3033发消息失败  被拉黑
                case 3033:
                {
                    [SVProgressHUD dismiss];
                    messageType = SecretLetterType_sendMessageFailBlack;
                     NSArray *resultArr = [NSArray new];
                     NSArray *backArr = [NSArray new];
//                     resultArr = MsgDic[@"result"];
//                     backArr = [NewHomeParser contantListManagerParserr:MsgDic[@"result"]];
                    
                    MessageChatEntity *GroupEntity = [MessageChatEntity new];
                    GroupEntity.pulledMemberString = @"    消息已发出，但是被对方拒收了。";
                    GroupEntity.type = @"7";
                    GroupEntity.redpacketString = @"";
                    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
                    if(![MsgDic[@"result"] objectForKey:@"friendId"]){
                        return;
                    }
                    __weak typeof(self)weakSelf=self;
                    [jqFmdb jq_inDatabase:^{
                        __strong typeof(weakSelf)strongSelf=weakSelf;
                        NSLog(@"strongSelf ->");
                        BOOL rett = [strongSelf ->jqFmdb jq_insertTable:[[MsgDic[@"result"] objectForKey:@"friendId"] description] dicOrModel:GroupEntity];
                        if (!rett) {
                            [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
                            return;
                        }
                        //        NSArray *arr = [weakSelf showHistoryData];
                    }];
                    
                    UUMessageFrame *messageF = [UUMessageFrame new];
                    UUMessage *message = [UUMessage new];
                    message.pulledMemberString = GroupEntity.pulledMemberString;
                    message.type = UUMessageTypeSystem;
                    message.userId = [[MsgDic[@"result"] objectForKey:@"friendId"] description];
                    [messageF setMessage:message];
                    
                    if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                        dispatch_queue_t mainQueue = dispatch_get_main_queue();
                        dispatch_async(mainQueue, ^{
                            [self.delegate didReceiveMessage:messageF type:SecretLetterType_systemMessage];
                        });
                    }
                }
                    break;
#pragma mark - 4001发送远程消息回执是否成功
        case 4001://发送远程消息回执是否成功 这里需要考虑到添加好友的情况 SecretLetterType_NormalReceipt
        {
            messageType = SecretLetterType_NormalReceipt;
            if (![NFUserEntity shareInstance].appStatus || [[NFUserEntity shareInstance].PushQRCode isEqualToString:@"2"] || [[NFUserEntity shareInstance].PushQRCode isEqualToString:@"3"]) {//如果是点击推送群聊单聊进来的 则不走
                //app在后台 或点击推送、二维码扫描进来 不处理单聊、群聊消息，走消息历史
                return;
            }
            NSDictionary *dataDict = MsgDic[@"result"];
            [self.fmdbServicee IsExistSingleChatHistory:[dataDict objectForKey:@"toId"]];//检查表存在
            //当是同意对方的好友请求。不需要缓存
//            if ([[dataDict objectForKey:@"messageContent"] containsString:@"点击发送好友请求"]) {
//                break;
//            }
            //发送单聊消息后，根据服务器提供的消息 进行显示【单聊消息走服务器】
            __block NSDictionary *returnDcit = [NSDictionary new];
            dispatch_group_t group = dispatch_group_create();
            dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
                dispatch_group_enter(group);
                // 任务代码i 假定任务 是异步执行block回调
                returnDcit = [self whenReveiveSingleMessageBackLetter:dataDict];
                
                jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
                __block NSArray *existArr = [NSArray new];
                __weak typeof(self)weakSelf=self;
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    //                __strong typeof(weakSelf)strongSelf=weakSelf;
                    existArr = [strongSelf ->jqFmdb jq_lookupTable:[returnDcit objectForKey:@"userId"] dicOrModel:[MessageChatEntity class] whereFormat:@"where appMsgId = '%@'",[[returnDcit objectForKey:@"appMsgId"] description]];
                }];
                if (existArr.count == 1) {//收到自己发的消息回执。将数据库的是否发出字段更新
                    MessageChatEntity *changeEntity = [existArr lastObject];
                    changeEntity.chatId = [[returnDcit objectForKey:@"chatId"] description];
                    changeEntity.failStatus = @"0";
                    changeEntity.fileId = [[returnDcit objectForKey:@"fileId"] description];
                    [self.myManage changeFMDBData:changeEntity KeyWordKey:@"appMsgId" KeyWordValue:[[returnDcit objectForKey:@"appMsgId"] description] FMDBID:@"tongxun.sqlite" TableName:[returnDcit objectForKey:@"userId"]];
                }else{
                    //收到回执在本地没有 说明为转发的 【不对】
                    //判断 看下面【当web端发消息 这里收到自己的消息 resultDict中的name 和 单例username一样时]】
                }
                // block 回调执行
                dispatch_group_leave(group);
                // block 回调执行
            });
            dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
            //单聊发送消息收到回执 正在和该人聊天中 【正在和该人聊天中,可能是app聊天、web端聊天】
            if ([[NFUserEntity shareInstance].currentChatId isEqualToString:[returnDcit objectForKey:@"userId"]] && [[NFUserEntity shareInstance].isSingleChat isEqualToString:@"1"]) {
                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [self.delegate didReceiveMessage:returnDcit type:messageType];
                    });
                }
            }else if ([[dataDict objectForKey:@"messageContent"] isKindOfClass:[NSString class]] && ![[dataDict objectForKey:@"messageContent"] isEqualToString:@"我已通过你的好友请求，我们现在可以聊天了"]){//这里判断是否不是加好友【能到这里肯定是自己发的消息，转发、收到web端自己发的消息】
                //不在和该人聊天中,当web端子自己发送消息 这时候直接缓存
                //如果不在和4001的聊天对象聊天中 则缓存 【这里是app端收到在网页端自己发送的消息】
                if ([[returnDcit objectForKey:@"IsServer"] isEqualToString:@"1"]) {
                    //wen端自己发的消息 只需要缓存 和通知会话列表取本地缓存 ／／目前只有消息
                    NSLog(@"");
                    NSDictionary *dic = @{@"strContent": [returnDcit objectForKey:@"strContent"], @"type":@(UUMessageTypeText),@"userName":[NFUserEntity shareInstance].userName,@"chatId":[returnDcit objectForKey:@"chatId"],@"userNickName":[NFUserEntity shareInstance].nickName,@"appMsgId": @"",@"IsServer":@"1",@"userName":[returnDcit objectForKey:@"userName"],@"userId":[returnDcit objectForKey:@"userId"]};
//                    [self addSpecifiedItem:dic];
                    [self.fmdbServicee IsExistSingleChatHistory:[returnDcit objectForKey:@"userId"]];//检查表存在
                    [self.fmdbServicee addSingleSpecifiedItem:dic];//缓存消息到单聊表
                    //插一条数据到会话列表 后面会对其进行核查显示准确的
                    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
                    __block NSArray *conversationExistArr;
                    [jqFmdb jq_inDatabase:^{
                        conversationExistArr = [jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@"where %@ = '%@' and %@ = '%@'",@"conversationId",[returnDcit objectForKey:@"userId"],@"IsSingleChat",@"1"];
                    }];
                    if (conversationExistArr.count == 0) {//如果没有该条会话 那么insert一条
                        dic = @{@"userName":[returnDcit objectForKey:@"userName"],@"type":@"0",@"strContent":[returnDcit objectForKey:@"strContent"],@"last_message_id":[[returnDcit objectForKey:@"chatId"] description],@"update_time":[ClearManager getCurrentTimeStamp],@"nickName":[returnDcit objectForKey:@"nickName"]};
                        __block NSArray *contactArr = [NSArray new];
                        [jqFmdb jq_inDatabase:^{
                            contactArr = [jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact new] whereFormat:@" where friend_userid = '%@'",[[returnDcit objectForKey:@"userId"] description]];
                        }];
                        if (contactArr.count == 1) {//查出联系人并进行缓存会话列表【为了获取到头像】
                            ZJContact *contact = [contactArr firstObject];
                            [self.fmdbServicee cacheChatListWithZJContact:contact AndDic:dic];
                        }else if(contactArr.count == 0){//没查出来 就没有头像 没办法 除非让服务器加上头像
                            ZJContact *friendContact = [ZJContact new];
                            friendContact.friend_userid = [[returnDcit objectForKey:@"userId"] description];
                            friendContact.friend_username = [[returnDcit objectForKey:@"userName"] description];
                            [self.fmdbServicee cacheChatListWithZJContact:friendContact AndDic:dic];
                        }
                    }
                    
                    //获取tabbar的index为0的根视图
                    MessageChatListViewController *firstTabbarVC = (MessageChatListViewController *)[[ClearManager new] getRootViewControllerOfTabbarRootIndex:0];
                    [firstTabbarVC checkChatListCorrect];
                    [firstTabbarVC conversationListRefresh:@[]];
                    
                }else{//否则通知界面刷新 【当为app转发时 需要走这里 通知pop回去刷新即可】
                    //转发
                    if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                        dispatch_queue_t mainQueue = dispatch_get_main_queue();
                        dispatch_async(mainQueue, ^{
                            [self.delegate didReceiveMessage:returnDcit type:messageType];
                        });
                    }
                }
            }else if([[dataDict objectForKey:@"messageContent"] isKindOfClass:[NSString class]] && [[dataDict objectForKey:@"messageContent"] isEqualToString:@"我已通过你的好友请求，我们现在可以聊天了"]){
                //当收到自己发送消息后的单聊回执 不在和该人聊天中 则为下面几个特殊情况
                //同意好友申请走这里 【因为同意好友请求，也是发送一条消息 只是接受delegate为ApplyViewDetailViewController】，通知代理【将单聊界面的代理拉到 同意好友请求里面 保留缓存的逻辑】
                //当单聊转发的时候 【转发时候发出去消息已经缓存了 上面只要对缓存中数据进行更改为收到状态即可】
                NSString *type;
                if ([[dataDict objectForKey:@"msgType"] isEqualToString:@"normal"]) {
                    type = @"0";
                }else if ([[dataDict objectForKey:@"msgType"] isEqualToString:@"image"]){
                    type = @"1";
                }else if ([[dataDict objectForKey:@"msgType"] isEqualToString:@"audio"]){
                    type = @"2";
                }
                //当为转发时，会话界面的self.forwardContent中有text的，如果为转发图片 则单例中也会有image
//                returnDcit = @{@"chatId":[[dataDict objectForKey:@"messageId"] description],@"strContent":@"我已经同意你为好友,我们现在可以聊天了",@"type":type,@"userName":[[dataDict objectForKey:@"toName"] description],@"nickName":[[dataDict objectForKey:@"fromNickName"] description],@"userId":[[dataDict objectForKey:@"toId"] description],@"receiveNickName":[[dataDict objectForKey:@"toNickName"] description],@"receiveName":[[dataDict objectForKey:@"toNickName"] description],@"receiveId":[[dataDict objectForKey:@"toId"] description]};
                returnDcit = @{@"chatId":[[dataDict objectForKey:@"messageId"] description],@"strContent":@"我已经同意你为好友,我们现在可以聊天了",@"receiveNickName":[[dataDict objectForKey:@"toNickName"] description],@"receiveName":[[dataDict objectForKey:@"toName"] description],@"receiveId":[[dataDict objectForKey:@"toId"] description],@"type":@"0"};
                
                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [self.delegate didReceiveMessage:returnDcit type:messageType];
                    });
                }
            }else if([[dataDict objectForKey:@"messageContent"] isKindOfClass:[NSDictionary class]]){
                //我 推荐 名片成功返回
                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [self.delegate didReceiveMessage:dataDict type:messageType];
                    });
                }
                
            }
        }
            break;
        case 4002:
#pragma mark - 4002收到远程消息  判断是不是语音
        {
//            [NFUserEntity shareInstance].PushQRCode = @"0";//设置app跳转状态为正常
            messageType = SecretLetterType_Normal;
            if (! [NFUserEntity shareInstance].appStatus || [[NFUserEntity shareInstance].PushQRCode isEqualToString:@"2"] || [[NFUserEntity shareInstance].PushQRCode isEqualToString:@"3"]) {//如果是点击推送群聊单聊进来的 则不走
                //app在后台 或点击推送、二维码扫描进来 不处理单聊、群聊消息，走消息历史
                return;
            }
            //消息通知相关 所有
            if (![self.myManage IsCanReveive]) {
                //如果设置了不提醒 收到消息不提示
                return;
            }
            NSDictionary *resulyDict = [MsgDic objectForKey:@"result"];
            if([[resulyDict objectForKey:@"content"] isKindOfClass:[NSDictionary class]] && ![[resulyDict objectForKey:@"msgType"] isEqualToString:@"card"]){
                //这里为什么 是字典就return 名片消息就是字典啊
                return;
            }
            //检查数据库表字段
            [self.fmdbServicee IsExistSingleChatHistory:[[resulyDict objectForKey:@"fromId"] description]];
            //判断如果这个消息为添加好友消息 那么记录刷新好友列表
            if ([[resulyDict objectForKey:@"content"] isKindOfClass:[NSString class]] && [[resulyDict objectForKey:@"content"] isEqualToString:@"我已通过你的好友请求，我们现在可以聊天了"]) {
                UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
                if ([currentVC isKindOfClass:[ZJContactViewController class]]) {
                    //在的话 应该返回3020 status
                }else{
                    //当不在联系人列表界面。记录刷新 这里雨3020重复 由于服务器没有返回3020
                    [NFUserEntity shareInstance].isNeedRefreshFriendList = YES;
                }
            }
            //判断是否屏蔽该人
            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
            __block NSArray *contactArr = [NSArray new];
            [jqFmdb jq_inDatabase:^{
                contactArr = [jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact new] whereFormat:@" where friend_userid = '%@'",[[resulyDict objectForKey:@"fromId"] description]];
            }];
            if (contactArr.count == 1) {
                ZJContact *contact = [contactArr firstObject];
                if (contact.IsShield) {
                    return;
                }
            }
            
            //筛选 诈骗信息 进行提示
//            if([[resulyDict objectForKey:@"content"] isKindOfClass:[NSString class]] || [[[resulyDict objectForKey:@"content"] description] containsString:@"兼"] || [[[resulyDict objectForKey:@"content"] description] containsString:@"职"]  || [[[resulyDict objectForKey:@"content"] description] containsString:@"赚"]  || [[[resulyDict objectForKey:@"content"] description] containsString:@"钱"] || [[[resulyDict objectForKey:@"content"] description] containsString:@"转账"]){
//
//
//            }
            
            //兼容安卓表情
//            if([[resulyDict objectForKey:@"content"] isKindOfClass:[NSString class]] && [NFMyManage validateContainsEmoji:[resulyDict objectForKey:@"content"]]){
//                NSString *str = [resulyDict objectForKey:@"content"];
//                str = [str stringByReplacingOccurrencesOfString:@"[" withString:@""];
//                str = [str stringByReplacingOccurrencesOfString:@"]" withString:@""];5
//                NSMutableDictionary *diccc = [NSMutableDictionary dictionaryWithDictionary:resulyDict];
//                [diccc setValue:str forKey:@"content"];
//                resulyDict = [NSDictionary dictionaryWithDictionary:diccc];
//            }else if([[resulyDict objectForKey:@"content"] isKindOfClass:[NSString class]] && [[resulyDict objectForKey:@"content"] length] <= 4 && [[[resulyDict objectForKey:@"content"] description] containsString:@"["]&& [[[resulyDict objectForKey:@"content"] description] containsString:@"]"]){
//                NSString *str = [resulyDict objectForKey:@"content"];
//                str = [str stringByReplacingOccurrencesOfString:@"[" withString:@""];
//                str = [str stringByReplacingOccurrencesOfString:@"]" withString:@""];
//                NSMutableDictionary *diccc = [NSMutableDictionary dictionaryWithDictionary:resulyDict];
//                [diccc setValue:str forKey:@"content"];
//                resulyDict = [NSDictionary dictionaryWithDictionary:diccc];
//            }else
                if([[resulyDict objectForKey:@"content"] isKindOfClass:[NSString class]] && [[[resulyDict objectForKey:@"content"] description] containsString:@"["]&& [[[resulyDict objectForKey:@"content"] description] containsString:@"]"]){
                NSString *str = [resulyDict objectForKey:@"content"];
                str = [str stringByReplacingOccurrencesOfString:@"[" withString:@""];
                str = [str stringByReplacingOccurrencesOfString:@"]" withString:@""];
                NSMutableDictionary *diccc = [NSMutableDictionary dictionaryWithDictionary:resulyDict];
                [diccc setValue:str forKey:@"content"];
                resulyDict = [NSDictionary dictionaryWithDictionary:diccc];
            }
            
#pragma mark - 本地推送
//            NSString *notificateString = [NSString stringWithFormat:@"%@:%@",[resulyDict objectForKey:@"fromName"],[resulyDict objectForKey:@"content"]];
//            [ClearManager notificateBadge:notificateString infoDict:@{@"id":[resulyDict objectForKey:@"fromId"],@"name":[resulyDict objectForKey:@"fromName"]}];
            //当正在和该该人进行聊天
            if ([[NFUserEntity shareInstance].currentChatId isEqualToString:[[resulyDict objectForKey:@"fromId"] description]] && [[NFUserEntity shareInstance].isSingleChat isEqualToString:@"1"]) {
                //设置角标+1 正在和该人聊天中 无需设置为度+1
//                [[NFbaseViewController new] setBadgeCountWithCount:1 AndIsAdd:YES];
                //回到会话界面设置刷新会话列表
                [NFUserEntity shareInstance].isNeedRefreshLocalChatList = YES;
#pragma msrk - 设置消息已读
                [self readedRequest:[resulyDict objectForKey:@"messageId"] AndReceiveName:[resulyDict objectForKey:@"fromName"]];
                __block UUMessageFrame *messageFrame = [UUMessageFrame new];
                dispatch_group_t group = dispatch_group_create();
                dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
                    dispatch_group_enter(group);
                    messageFrame = [MessageParser GotNormalMessageContantParser:resulyDict];
                    dispatch_group_leave(group);
                });
                dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
                
                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [self.delegate didReceiveMessage:messageFrame type:messageType];
                    });
                }
            }else{
                //设置刷新会话列表为yes
                [NFUserEntity shareInstance].isNeedRefreshChatList = YES;
                //当没和该信息发出者聊天中时
                [self WhenNotChatWithThisMessageUser:resulyDict];
                //设置已收到 需要一个contantid
//                [self haveReceived:[resulyDict objectForKey:@""]];
            }
        }
            break;
        case 4003:
#pragma mark - 4003历史聊天消息 获取消息列表
        {
            messageType = SecretLetterType_ChatHistory;
//            [SVProgressHUD dismiss];
//            NSArray *chatContantArr;
            NSArray *resulyArr = MsgDic[@"result"];
            if (resulyArr.count > 0) {
                NSDictionary *resulyDict = [resulyArr firstObject];
            //检查表字段
                [self.fmdbServicee IsExistSingleChatHistory:[resulyDict objectForKey:@"user_id"]];
#warning 拉黑
                //判断是否屏蔽该人
                jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
                __block NSArray *contactArr = [NSArray new];
                __weak typeof(self)weakSelf=self;
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    contactArr = [strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact new] whereFormat:@" where friend_userid = '%@'",[[resulyDict objectForKey:@"user_id"] description]];
                }];
//                NSArray *contactArrr = [jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact new] whereFormat:@""];
                if (contactArr.count == 1) {
                    ZJContact *contact = [contactArr firstObject];
                    if (contact.IsShield) {
                        dispatch_queue_t mainQueue = dispatch_get_main_queue();
                        dispatch_async(mainQueue, ^{
                            [self.delegate didReceiveMessage:@[] type:messageType];
                            return ;
                        });
                    }else{
                        //当没有屏蔽 走向else 也行
                        __block NSArray *chatContantArr = [NSArray new];
                        dispatch_group_t group = dispatch_group_create();
                    dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
                            dispatch_group_enter(group);
                            // 任务代码i 假定任务 是异步执行block回调
                            chatContantArr = [MessageParser ConvasationHistoryChatContantParser:MsgDic[@"result"]];
//                            sleep(2);
                            // block 回调执行
                            dispatch_group_leave(group);
                            // block 回调执行
                        });
                        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
                        NSDictionary *firstD;
                        firstD = [resulyArr firstObject];
                        NSDictionary *finnalDict = @{@"singleId":[[firstD objectForKey:@"user_id"] description],@"singleArr":chatContantArr};
                        if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                            dispatch_queue_t mainQueue = dispatch_get_main_queue();
                            dispatch_async(mainQueue, ^{
                                [self.delegate didReceiveMessage:finnalDict type:messageType];
                            });
                        }
                    }
                }else{
                    //解析消息历史
                    __block NSArray *chatContantArr = [NSArray new];
                    dispatch_group_t group = dispatch_group_create();
                    dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
                        dispatch_group_enter(group);
                        // 任务代码i 假定任务 是异步执行block回调
                        chatContantArr = [MessageParser ConvasationHistoryChatContantParser:MsgDic[@"result"]];
                        //                            sleep(2);
                        // block 回调执行
                        dispatch_group_leave(group);
                        // block 回调执行
                    });
                    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
                    
                    NSDictionary *firstD;
                    firstD = [resulyArr firstObject];
                    NSDictionary *finnalDict = @{@"singleId":[[firstD objectForKey:@"user_id"] description],@"singleArr":chatContantArr};
                    if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                        dispatch_queue_t mainQueue = dispatch_get_main_queue();
                        dispatch_async(mainQueue, ^{
                            [self.delegate didReceiveMessage:finnalDict type:messageType];
                        });
                    }
                }
            }else{
                //请求消息历史 请求为空则返回空
                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [self.delegate didReceiveMessage:@{@"singleArr":@[],@"singleId":@""} type:messageType];
                    });
                }
            }
        }
            break;
        case 4004:{
#pragma mark - 已收到
            NSLog(@"已收到");
        }
            break;
        case 4005:{
            #pragma mark - 4005已读
            {
//                [SVProgressHUD dismiss];
                messageType = SecretLetterType_ChatAlreadyRead;
                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [self.delegate didReceiveMessage:@"" type:messageType];
                    });
                }
            }
        }
            break;
        case 4006:{
#pragma mark - 登陆超时
            NSLog(@"登陆超时");
        }
            break;
        case 4007:{
#pragma mark - 4007正在输入
            //SecretLetterType_ChatEntering
            messageType = SecretLetterType_ChatEntering;
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
                NSString *a = [MsgDic[@"result"] objectForKey:@"userId"];
                if ([[NFUserEntity shareInstance].currentChatId isEqualToString:[MsgDic[@"result"] objectForKey:@"userId"]]){
                    if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                        dispatch_queue_t mainQueue = dispatch_get_main_queue();
                        dispatch_async(mainQueue, ^{
                            [self.delegate didReceiveMessage:@"" type:messageType];
                        });
                    }
                }
            });
        }
            break;
        case 4008:{
#pragma mark - 4008结束输入
            //可能有很多人请求这个方法 所以我们放在多线程中 当真正需要通知界面 再屌用主线程进行通知
            messageType = SecretLetterType_ChatEndEnter;
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
                NSString *a = [MsgDic[@"result"] objectForKey:@"userId"];
                if ([[NFUserEntity shareInstance].currentChatId isEqualToString:[MsgDic[@"result"] objectForKey:@"userId"]]){
                    if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                        dispatch_queue_t mainQueue = dispatch_get_main_queue();
                        dispatch_async(mainQueue, ^{
                            [self.delegate didReceiveMessage:@"" type:messageType];
                        });
                    }
                }
            });
        }
            break;
        case 4009:{
#pragma mark - 4009群组消息撤回成功
            //SecretLetterType_ChatEndEnter
            messageType = SecretLetterType_GroupMessageDrowSuccess;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:self.groupCreateSuccess type:messageType];
                });
            }
        }
            break;
        case 4010:{
#pragma mark - 4010群组消息撤回失败
            //SecretLetterType_ChatEndEnter
            messageType = SecretLetterType_GroupMessageDrowFailed;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:self.groupCreateSuccess type:messageType];
                });
            }
        }
            break;
        case 4011:{
#pragma mark - 4011消息发送太快
            //SecretLetterType_ChatEndEnter
            [SVProgressHUD showInfoWithStatus:@"消息发送太快"];
//            messageType = SecretLetterType_GroupMessageDrowFailed;
//            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
//                dispatch_queue_t mainQueue = dispatch_get_main_queue();
//                dispatch_async(mainQueue, ^{
//                    [self.delegate didReceiveMessage:self.groupCreateSuccess type:messageType];
//                });
//            }
        }case 4012:{
            #pragma mark - 4012 恢复聊天数据
            //恢复聊天数据
            messageType = SecretLetterType_ChatAllHistory;
            //            [SVProgressHUD dismiss];
            //            NSArray *chatContantArr;
            NSArray *resulyArr = MsgDic[@"result"];
            if (![NFUserEntity shareInstance].IsRecovering) {//当接收到 单聊所有聊天消息 但是不在恢复数据中 则return不再进行解析
                return;
            }
            NSDictionary *resulyDict = [resulyArr firstObject];
            //检查表字段
            [self.fmdbServicee IsExistSingleChatHistory:[resulyDict objectForKey:@"user_id"]];
            __block NSArray *chatContantArr = [NSArray new];
            dispatch_group_t group = dispatch_group_create();
            dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
                dispatch_group_enter(group);
                // 任务代码i 假定任务 是异步执行block回调
                //引用4003 解析单聊历史消息
                chatContantArr = [MessageParser ConvasationHistoryChatContantParser:MsgDic[@"result"]];
                //                            sleep(2);
                // block 回调执行
                dispatch_group_leave(group);
                // block 回调执行
            });
            //receive_user_id 是聊天对象【恢复消息 应该取对方的id为一个表】
            
            NSDictionary *finnalDict = @{@"singleArr":chatContantArr};
            
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:finnalDict type:messageType];
                });
            }
        }
            break;
        case 4013:{
#pragma mark - 4013发消息失败 群禁言中
            //SecretLetterType_ChatEndEnter
            messageType = SecretLetterType_GroupForbidden;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:nil type:messageType];
                });
            }
        }
            break;
        case 4014:{
#pragma mark - 4014 小助手消息列表
            //SecretLetterType_ChatEndEnter
            messageType = SecretLetterType_HelperMessageList;
            NSDictionary *billListDict= [MessageParser helperList:MsgDic[@"result"]];
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:billListDict type:messageType];
                });
            }
        }
            break;
        case 4016:{
#pragma mark - 4016 收到撤回消息
            //SecretLetterType_ChatEndEnter
            messageType = SecretLetterType_receiveBackMessage;
            NSDictionary *resulyDict = [MsgDic objectForKey:@"result"];
            
            
        if([[[resulyDict objectForKey:@"groupId"] description] integerValue] > 0){
                            //改变数据库
            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
            //    themeSelectedImageName
            __block NSArray *arrs = [NSArray new];
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                //qunzu
                arrs = [strongSelf ->jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunzu%@",[[resulyDict objectForKey:@"groupId"] description]] dicOrModel:[MessageChatEntity class] whereFormat:@"where chatId = '%@'",[[resulyDict objectForKey:@"msgId"] description]];
//                    arrs = [strongSelf ->jqFmdb jq_lookupTable:[resulyDict objectForKey:@"userId"] dicOrModel:[MessageChatEntity class] whereFormat:@""];
            }];
            if(arrs.count == 0){
                [SVProgressHUD showInfoWithStatus:@"出现错误：4016"];
                return;
            }
            MessageChatEntity *changeEntity = [arrs lastObject];
            changeEntity.type = @"7";
            changeEntity.pulledMemberString = @"对方撤回了一条消息";
            [self.myManage changeFMDBData:changeEntity KeyWordKey:@"chatId" KeyWordValue:[[resulyDict objectForKey:@"msgId"] description] FMDBID:@"tongxun.sqlite" TableName:[NSString stringWithFormat:@"qunzu%@",[[resulyDict objectForKey:@"groupId"] description]]];
            if ([[NFUserEntity shareInstance].currentChatId isEqualToString:[[resulyDict objectForKey:@"groupId"] description]] && [[NFUserEntity shareInstance].isSingleChat isEqualToString:@"2"]) {
                //正在群聊聊天中 通知界面
                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [self.delegate didReceiveMessage:resulyDict type:messageType];
                    });
                }
            }else{

                //    [SVProgressHUD show];
                [self.parms removeAllObjects];
                self.parms[@"action"] = @"getConversationListNew";
                self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
                self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
                NSString *Json = [JsonModel convertToJsonData:self.parms];
                [self ping];
                if ([self isConnected]) {
                    [self sendMsg:Json];
                }else{
                    //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
                }
                
                
            }
            
        }else if([[[resulyDict objectForKey:@"userId"] description] integerValue] > 0){
            //改变数据库
            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
            //    themeSelectedImageName
            __block NSArray *arrs = [NSArray new];
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                arrs = [strongSelf ->jqFmdb jq_lookupTable:[resulyDict objectForKey:@"userId"] dicOrModel:[MessageChatEntity class] whereFormat:@"where chatId = '%@'",[[resulyDict objectForKey:@"msgId"] description]];
    //                    arrs = [strongSelf ->jqFmdb jq_lookupTable:[resulyDict objectForKey:@"userId"] dicOrModel:[MessageChatEntity class] whereFormat:@""];
            }];
            if(arrs.count == 0){
                [SVProgressHUD showInfoWithStatus:@"出现错误：4016"];
                return;
            }
            MessageChatEntity *changeEntity = [arrs lastObject];
            changeEntity.type = @"7";
            changeEntity.pulledMemberString = @"对方撤回了一条消息";
            [self.myManage changeFMDBData:changeEntity KeyWordKey:@"chatId" KeyWordValue:[[resulyDict objectForKey:@"msgId"] description] FMDBID:@"tongxun.sqlite" TableName:[resulyDict objectForKey:@"userId"]];
            
            if ([[NFUserEntity shareInstance].currentChatId isEqualToString:[[resulyDict objectForKey:@"userId"] description]] && [[NFUserEntity shareInstance].isSingleChat isEqualToString:@"1"]) {
                //正在单聊聊天中 通知界面
                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [self.delegate didReceiveMessage:nil type:messageType];
                    });
                }
            }else{
                
                //    [SVProgressHUD show];
                [self.parms removeAllObjects];
                self.parms[@"action"] = @"getConversationListNew";
                self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
                self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
                NSString *Json = [JsonModel convertToJsonData:self.parms];
                [self ping];
                if ([self isConnected]) {
                    [self sendMsg:Json];
                }else{
                    //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
                }
                
                
            }
            
        }
            
            
        }
            break;
//        case 4014:{
//#pragma mark - 4014收到红包消息 【单聊】
//            messageType = SecretLetterType_receiveRedpacket;
//
//            if (![NFUserEntity shareInstance].appStatus || [[NFUserEntity shareInstance].PushQRCode isEqualToString:@"2"] || [[NFUserEntity shareInstance].PushQRCode isEqualToString:@"3"]) {//如果是点击推送群聊单聊进来的 则不走
//                //app在后台 或点击推送、二维码扫描进来 不处理单聊、群聊消息，走消息历史
//                return;
//            }
//            //消息通知相关 所有
//            if (![self.myManage IsCanReveive]) {
//                //如果设置了不提醒 收到消息不提示
//                return;
//            }
//            NSDictionary *resulyDict = [MsgDic objectForKey:@"result"];
//            //检查数据库表字段
//            [self.fmdbServicee IsExistSingleChatHistory:[[resulyDict objectForKey:@"fromId"] description]];
//            //判断如果这个消息为添加好友消息 那么记录刷新好友列表
//            if ([[resulyDict objectForKey:@"content"] isKindOfClass:[NSString class]] && [[resulyDict objectForKey:@"content"] isEqualToString:@"我已通过你的好友请求，我们现在可以聊天了"]) {
//                UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
//                UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
//                if ([currentVC isKindOfClass:[ZJContactViewController class]]) {
//                    //在的话 应该返回3020 status
//                }else{
//                    //当不在联系人列表界面。记录刷新 这里雨3020重复 由于服务器没有返回3020
//                    [NFUserEntity shareInstance].isNeedRefreshFriendList = YES;
//                }
//            }
//            //判断是否屏蔽该人
//            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//            __block NSArray *contactArr = [NSArray new];
//            [jqFmdb jq_inDatabase:^{
//                contactArr = [jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact new] whereFormat:@" where friend_userid = '%@'",[[resulyDict objectForKey:@"fromId"] description]];
//            }];
//            if (contactArr.count == 1) {
//                ZJContact *contact = [contactArr firstObject];
//                if (contact.IsShield) {
//                    return;
//                }
//            }
//            if ([[NFUserEntity shareInstance].currentChatId isEqualToString:[[resulyDict objectForKey:@"fromId"] description]] && [[NFUserEntity shareInstance].isSingleChat isEqualToString:@"1"]) {
//                [NFUserEntity shareInstance].isNeedRefreshLocalChatList = YES;
//
//#pragma msrk - 设置消息已读
//                [self readedRequest:[resulyDict objectForKey:@"messageId"] AndReceiveName:[resulyDict objectForKey:@"fromName"]];
//                __block UUMessageFrame *messageFrame = [UUMessageFrame new];
//                dispatch_group_t group = dispatch_group_create();
//                dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
//                    dispatch_group_enter(group);
//                    messageFrame = [MessageParser GotNormalRedPacketMessageContantParser:resulyDict];
//                    dispatch_group_leave(group);
//                });
//                dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
//
//                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
//                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
//                    dispatch_async(mainQueue, ^{
//                        [self.delegate didReceiveMessage:messageFrame type:messageType];
//                    });
//                }
//            }else{
//                //设置刷新会话列表为yes
//                [NFUserEntity shareInstance].isNeedRefreshChatList = YES;
//                //当没和该信息发出者聊天中时
//                [self receiveSingleRedpacketMessage:resulyDict];
//            }
//
//        }
//            break;
        case 5001:{
#pragma mark - 5001群组创建请求成功返回
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_groupCreateSuccess;
            self.groupCreateSuccess = [MessageParser groupCreateSuccessManagerParserr:MsgDic[@"result"]];
            //如果不是创建者 收到消息了
            if (![self.groupCreateSuccess.creatorName isEqualToString:[NFUserEntity shareInstance].userName]) {
                //则立马进行缓存 会话列表
                [self.fmdbServicee cacheChatGroupCreateList:self.groupCreateSuccess];
                //数组详情缓存到数据库表
                [self.fmdbServicee cacheGroupDetail:self.groupCreateSuccess];
                UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
                if ([currentVC isKindOfClass:[MessageChatListViewController class]]) {
                    //当在会话列表界面。通知刷新
                    SecretLetterModel messageType = SecretLetterType_notifyRefreshChatSessionList;
                    if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                        dispatch_queue_t mainQueue = dispatch_get_main_queue();
                        dispatch_async(mainQueue, ^{
                            [self.delegate didReceiveMessage:@"" type:messageType];
                        });
                    }
                }else{
                    //否则 记录通知刷新
                    [NFUserEntity shareInstance].isNeedRefreshLocalChatList = YES;
                }
            }else{
                //创建者 创建成功 在这里处理通知【跳转到聊天界面】
                //则立马进行缓存 会话列表
                [self.fmdbServicee cacheChatGroupCreateList:self.groupCreateSuccess];
                
                //数组详情缓存到数据库表
                [self.fmdbServicee cacheGroupDetail:self.groupCreateSuccess];
                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [self.delegate didReceiveMessage:self.groupCreateSuccess type:messageType];
                    });
                }
            }
        }
            break;
        case 5002:{
#pragma mark - 5002创建群组失败【重复创建群组】 5002
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_GroupCreateRepeat;
            self.groupCreateSuccess = [MessageParser groupCreateRepeatManagerParserr:MsgDic[@"result"]];
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:self.groupCreateSuccess type:messageType];
                });
            }
        }
            break;
        case 5003:{
#pragma mark - 5003 收到群消息
//            [SVProgressHUD dismiss];
            //设置刷新会话列表为yes
            [NFUserEntity shareInstance].isNeedRefreshLocalChatList = YES;
            if (![NFUserEntity shareInstance].appStatus || [[NFUserEntity shareInstance].PushQRCode isEqualToString:@"2"] || [[NFUserEntity shareInstance].PushQRCode isEqualToString:@"3"]) {//如果是点击推送群聊单聊进来的 则不走
                //app在后台 或点击推送、二维码扫描进来 不处理单聊、群聊消息，走消息历史
                return;
            }
            //消息通知相关
            if (![self.myManage IsCanReveive]) {
                //如果设置了不提醒 收到消息不提示
                return;
            }else if(NO){
                
            }
            messageType = SecretLetterType_ReceiveGroupMessage;
            NSDictionary *resulyDict = [MsgDic objectForKey:@"result"];
            //收到群消息相关]
            [self receiveGroupMessage:resulyDict];
        }
            break;
        case 5004:{
            //群组拉人成功 这里与 5011 重复 【这里主要是拉人的人会收到】
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_GroupAddMemberSuccess;
            GroupCreateSuccessEntity *groupCreateSuccessEntity = [MessageParser groupCreateSuccessManagerParserr:MsgDic[@"result"]];
            //SecretLetterType_GroupAddMemberSuccess groupCreateSEntity
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:groupCreateSuccessEntity type:messageType];
                });
            }
        }
            break;
        case 5005:{
#pragma mark - 5005收到群详情
//            [SVProgressHUD dismiss];
            messageType = SecretLetterType_GroupDetail;
            self.groupCreateSuccess = [MessageParser groupDetailManagerParserr:MsgDic[@"result"]];
            //数组详情缓存到数据库表
//            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
                [self.fmdbServicee cacheGroupDetail:self.groupCreateSuccess];
//            });
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:self.groupCreateSuccess type:messageType];
                });
            }
        }
            break;
        case 5006:{
#pragma mark - 5006 群组列表
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_GroupList;
            __block NSArray *backArr = [NSArray new];
            dispatch_group_t group = dispatch_group_create();
            dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
                dispatch_group_enter(group);
                backArr = [MessageParser groupListManagerParserr:MsgDic[@"result"]];
                dispatch_group_leave(group);
            });
            dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
            
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:backArr type:messageType];
                });
            }
        }
            break;
        case 5007:{
#pragma mark - 5007解散成功返回
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_GroupBreak;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:self.groupCreateSuccess type:messageType];
                });
            }
        }
            break;
        case 5009:{
#pragma mark - 5009个人退群
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_GroupExit;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:self.groupCreateSuccess type:messageType];
                });
            }
        }
            break;
        case 5010:{
#pragma mark - 5010 保存\取消保存群到列表成功
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_GroupSaveSuccess;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:MsgDic[@"result"] type:messageType];
                });
            }
        }
            break;
        case 5011:{
#pragma mark - 5011 拉人进群 全体收到消息【用于让被拉的人创建会话】
            //这里是被拉的人也会收到
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_groupCreateSuccess;
            //            id pulledArr = [data objectForKey:@"invitedUser"];
//            NSDictionary *backDict = MsgDic[@"result"];
//            NSArray *pulledUsers =  [backDict objectForKey:@"invitedUser"];
//            if (pulledUsers.count == 0) {
//                [SVProgressHUD showInfoWithStatus:@"已在群聊!"];
//                return;
//            }
            self.groupCreateSuccess = [MessageParser groupCreateSuccessManagerParserr:MsgDic[@"result"]];
            [self.fmdbServicee cacheGroupDetail:self.groupCreateSuccess];
                //则立马进行缓存 会话列表 dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
            [self.fmdbServicee cacheChatGroupCreateList:self.groupCreateSuccess];
            //缓存某某某拉谁进群到缓存
                UUMessageFrame *messageFrame = [MessageParser PullUserParser:MsgDic[@"result"]];
                //数组详情缓存到数据库表 dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
//                [self.fmdbServicee cacheGroupDetail:self.groupCreateSuccess];
                //                });
                UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
            
            //如果正在和该群租聊天 则通知界面刷新
            if ([[NFUserEntity shareInstance].currentChatId isEqualToString:[[MsgDic[@"result"] objectForKey:@"groupId"] description]] && [[NFUserEntity shareInstance].isSingleChat isEqualToString:@"2"] && messageFrame.message.pulledMemberString.length > 0) {
                //是否正在和当前群聊天
                SecretLetterModel messageType = SecretLetterType_ReceiveGroupMessage;
                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [self.delegate didReceiveMessage:messageFrame type:SecretLetterType_ReceiveGroupMessage];
                    });
                }
                return;
            }
            
            //否则 缓存群聊消息到消息记录
            MessageChatEntity *GroupEntity = [MessageChatEntity new];
            GroupEntity.invitor = messageFrame.message.invitor;
            GroupEntity.pulledMemberString = messageFrame.message.pulledMemberString;
            GroupEntity.create_time_head = messageFrame.message.strTimeHeader;
            GroupEntity.create_time = messageFrame.message.strTime;
            GroupEntity.pullType = @"0";
            GroupEntity.redpacketString = @"";
            if (GroupEntity.invitor.length == 0 || GroupEntity.pulledMemberString.length == 0) {
                return;//如果拉人者或被拉人有一人为空 则不进行缓存
            }
            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
            //检查表
            [self.fmdbServicee IsExistGroupChatHistory:[[MsgDic[@"result"] objectForKey:@"groupId"] description] ISNeedAppend:YES];
            //查看该表里面的消息历史
//            NSArray *axdrrs = [jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunzu%@",[[MsgDic[@"result"] objectForKey:@"groupId"] description]] dicOrModel:[MessageChatEntity class] whereFormat:@""];
            //插入数据 群聊消息
            __weak typeof(self)weakSelf=self;
            
            __block NSArray *lastArr = [NSArray new];
            __block int dataaCount = 0;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                //userId = userId order by id desc limit 5
                dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:[NSString stringWithFormat:@"qunzu%@",[[MsgDic[@"result"] objectForKey:@"groupId"] description]]];
                lastArr = [strongSelf ->jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunzu%@",[[MsgDic[@"result"] objectForKey:@"groupId"] description]] dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,1]];
                
            }];
            //重复消息
            if(lastArr.count == 1){
                MessageChatEntity *lastEntity = [lastArr firstObject];
                if ([GroupEntity.pulledMemberString isEqualToString:lastEntity.pulledMemberString]&& [GroupEntity.pullType isEqualToString:lastEntity.pullType]) {
                    //如果有相同消息 则return
                    return;
                }
            }
            
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                BOOL rett = [strongSelf ->jqFmdb jq_insertTable:[NSString stringWithFormat:@"qunzu%@",[[MsgDic[@"result"] objectForKey:@"groupId"] description]] dicOrModel:GroupEntity];
                if (!rett) {
                    [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
                    return;
                }
            }];
            if ([currentVC isKindOfClass:[MessageChatListViewController class]]) {
                //当在会话列表界面。通知刷新
                SecretLetterModel messageType = SecretLetterType_notifyRefreshChatSessionList;
                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [self.delegate didReceiveMessage:@"" type:messageType];
                    });
                }
            }else{
                //否则 记录通知刷新
                [NFUserEntity shareInstance].isNeedRefreshLocalChatList = YES;
            }
        }
            break;
        case 5012:{//群历史消息
            messageType = SecretLetterType_GroupChatHistory;
//            if (resulyArr.count > 0) {
            __block NSArray *chatContantArr = [NSArray new];
            NSArray *resulyArr = MsgDic[@"result"];
            dispatch_group_t group = dispatch_group_create();
            dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
                dispatch_group_enter(group);
                // 任务代码i 假定任务 是异步执行block回调
                NSMutableArray *arrr = [NSMutableArray new];
                for (NSDictionary *dicc in resulyArr) {
                    //jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
                    __block NSMutableArray *contacts = [NSMutableArray new];
                    //这里重新去缓存联系人
                    __weak typeof(self)weakSelf=self;
                    [jqFmdb jq_inDatabase:^{
                        __strong typeof(weakSelf)strongSelf=weakSelf;
                        contacts = [NSMutableArray arrayWithArray:[strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact class] whereFormat:@"where friend_userid = '%@'",[[dicc objectForKey:@"group_msg_sender"] description]]];
                    }];
                    if(contacts.count > 0){
                        ZJContact *contacttt = [contacts firstObject];
                        if(contacttt.friend_comment_name.length > 0){
                            NSMutableDictionary *diccc = [NSMutableDictionary dictionaryWithDictionary:dicc];
                            [diccc setValue:[[[dicc objectForKey:@"nickname"] description] length] >0?[[dicc objectForKey:@"nickname"] description]:[[dicc objectForKey:@"senderNickName"] description] forKey:@"group_msg_sender_original_name"];
                            [diccc setValue:contacttt.friend_comment_name forKey:@"senderCommentName"];
                            [diccc setValue:contacttt.friend_comment_name forKey:@"senderNickName"];
                            [arrr addObject:[NSDictionary dictionaryWithDictionary:diccc]];
                            
                        }else{
                            [arrr addObject:dicc];
//                            NSMutableDictionary *diccc = [NSMutableDictionary dictionaryWithDictionary:dicc];
//                            [diccc setValue:[[[dicc objectForKey:@"nickname"] description] length] >0?[[dicc objectForKey:@"nickname"] description]:[[dicc objectForKey:@"senderNickName"] description] forKey:@"group_msg_sender_original_name"];
//                            [arrr addObject:[NSDictionary dictionaryWithDictionary:diccc]];
                        }
                    }else{
                        [arrr addObject:dicc];
//                        NSMutableDictionary *diccc = [NSMutableDictionary dictionaryWithDictionary:dicc];
//                        [diccc setValue:[[[dicc objectForKey:@"nickname"] description] length] >0?[[dicc objectForKey:@"nickname"] description]:[[dicc objectForKey:@"senderNickName"] description] forKey:@"group_msg_sender_original_name"];
//                        [arrr addObject:[NSDictionary dictionaryWithDictionary:diccc]];
                    }
                    
                }
                
                chatContantArr = [MessageParser ConvasationGroupHistoryChatContantParser:arrr];
                //                            sleep(2);
                // block 回调执行
                dispatch_group_leave(group);
                // block 回调执行
            });
            dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
            NSDictionary *firstD;
            if (resulyArr.count > 0) {
                firstD = [resulyArr firstObject];
            }
            
            NSDictionary *finnalDict = @{@"groupId":firstD?[[firstD objectForKey:@"group_id"] description]:@"",@"groupArr":chatContantArr};
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [self.delegate didReceiveMessage:finnalDict type:messageType];
                    });
                }
            });
//            }
        }
            break;
        case 5028:{//某个群所有历史消息
                messageType = SecretLetterType_GroupChatAllHistory;
                NSArray *resulyArr = MsgDic[@"result"];
                if (![NFUserEntity shareInstance].IsRecovering) {//当接收到单聊所有聊天消息 但是不在恢复数据中 则return不再进行解析 否则return
                    return;
                }
                NSDictionary *resulyDict = [resulyArr firstObject];
                __block NSArray *chatContantArr = [NSArray new];
                dispatch_group_t group = dispatch_group_create();
                dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
                    dispatch_group_enter(group);
                    // 任务代码i 假定任务 是异步执行block回调
                    //引用 5012 解析群聊历史
                    chatContantArr = [MessageParser ConvasationGroupHistoryChatContantParser:resulyArr];
                    // sleep(2);
                    // block 回调执行
                    dispatch_group_leave(group);
                    // block 回调执行
                });
                NSDictionary *finnalDict = @{@"groupArr":chatContantArr};
                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [self.delegate didReceiveMessage:finnalDict type:messageType];
                    });
                }
            }
            break;
        case 5029:{//所有参与聊天的群组
            messageType = SecretLetterType_AllGroupList;
            NSDictionary *resuly = MsgDic[@"result"];
            __block NSArray *allGroupArr = [NSArray new];
            dispatch_group_t group = dispatch_group_create();
            dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
                dispatch_group_enter(group);
                // 任务代码i 假定任务 是异步执行block回调
                //返回 ZJContact 取friend_username、friend_userid、friend_nickname
                allGroupArr = [NewHomeParser allGroupListManagerParserr:MsgDic[@"result"]];
                sleep(1);//沉睡0.5秒 显示检查网络环境
                // block 回调执行
                dispatch_group_leave(group);
                // block 回调执行
            });
            NSDictionary *finnalDict = @{@"groupArr":allGroupArr};
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:finnalDict type:messageType];
                });
            }
        }
            break;
        case 5013:{//群消息已读
            messageType = SecretLetterType_ChatAlreadyRead;
            id resuly = MsgDic[@"result"];
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
        }
            break;
        case 5015:{//群设置信息成功
            messageType = SecretLetterType_GroupSetPersonalInfo;
            id resuly = MsgDic[@"result"];
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:resuly type:messageType];
                });
            }
        }
            break;
        case 5016:{//设置群属性失败
            [SVProgressHUD showInfoWithStatus:@"设置群属性失败"];
        }
            break;
        case 5017:{//扫码进群成功
            messageType = SecretLetterType_GroupQRCodeInviteSuccess;
            id resuly = MsgDic[@"result"];
            GroupCreateSuccessEntity *groupCreateSuccessEntity = [MessageParser groupCreateSuccessManagerParserr:MsgDic[@"result"]];
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:groupCreateSuccessEntity type:messageType];
                });
            }
        }
            break;
        case 5018:{//扫码进群失败
            messageType = SecretLetterType_GroupQRCodeInviteFail;
            id resuly = MsgDic[@"result"];
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:resuly type:messageType];
                });
            }
        }
            break;
        case 5019:{//用户已经在群里
            messageType = SecretLetterType_GroupQRCodeAlreadyExist;
//            [SVProgressHUD showInfoWithStatus:@"你已在该群聊中"];
            id resuly = MsgDic[@"result"];
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:resuly type:messageType];
                });
            }
        }
            break;
        case 5020:{
            //有用户通过扫码进群 【群里其他人会收到】
            //messageType = SecretLetterType_GroupQRCodeInviteSuccessNotificate;
            //这里是被拉的人也会收到
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_groupCreateSuccess;
            self.groupCreateSuccess = [MessageParser groupCreateSuccessManagerParserr:MsgDic[@"result"]];
            //群组详情缓存
            [self.fmdbServicee cacheGroupDetail:self.groupCreateSuccess];
            //则立马进行缓存 会话列表 dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
            [self.fmdbServicee cacheChatGroupCreateList:self.groupCreateSuccess];
            //缓存某某某拉谁进群到缓存
            UUMessageFrame *messageFrame = [MessageParser PullUserParser:MsgDic[@"result"]];
            messageFrame.message.pullType = @"1";
            //数组详情缓存到数据库表 dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
            //                [self.fmdbServicee cacheGroupDetail:self.groupCreateSuccess];
            //                });
            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
            
            //如果正在和该群租聊天 则通知界面刷新
            if ([[NFUserEntity shareInstance].currentChatId isEqualToString:[[MsgDic[@"result"] objectForKey:@"groupId"] description]] && [[NFUserEntity shareInstance].isSingleChat isEqualToString:@"2"]) {
                //是否正在和当前群聊天
                SecretLetterModel messageType = SecretLetterType_ReceiveGroupMessage;
                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [self.delegate didReceiveMessage:messageFrame type:SecretLetterType_ReceiveGroupMessage];
                    });
                }
                return;
            }
            //否则 缓存群聊消息到消息记录
            MessageChatEntity *GroupEntity = [MessageChatEntity new];
            GroupEntity.invitor = [NSString stringWithFormat:@"%@通过二维码扫描",messageFrame.message.invitor];
            GroupEntity.invitor = messageFrame.message.invitor;
            GroupEntity.pulledMemberString = messageFrame.message.pulledMemberString;
            GroupEntity.create_time_head = messageFrame.message.strTimeHeader;
            GroupEntity.create_time = messageFrame.message.strTime;
            GroupEntity.pullType = @"1";
            GroupEntity.redpacketString = @"";
            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
            //建表
            __weak typeof(self)weakSelf=self;
            
            [self.fmdbServicee IsExistGroupChatHistory:[NSString stringWithFormat:@"qunzu%@",[[MsgDic[@"result"] objectForKey:@"groupId"] description]] ISNeedAppend:NO];
            
            
            //查看该表里面的消息历史
//            NSArray *axdrrs = [jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunzu%@",[[MsgDic[@"result"] objectForKey:@"groupId"] description]] dicOrModel:[MessageChatEntity class] whereFormat:@""];
            //插入数据 群聊消息
            
            __block NSArray *lastArr = [NSArray new];
            __block int dataaCount = 0;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                //userId = userId order by id desc limit 5
                dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:[NSString stringWithFormat:@"qunzu%@",[[MsgDic[@"result"] objectForKey:@"groupId"] description]]];
                lastArr = [strongSelf ->jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunzu%@",[[MsgDic[@"result"] objectForKey:@"groupId"] description]] dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,1]];
            }];
            //重复消息
            if(lastArr.count == 1){
                MessageChatEntity *lastEntity = [lastArr firstObject];
                if ([GroupEntity.pulledMemberString isEqualToString:lastEntity.pulledMemberString]&& [GroupEntity.pullType isEqualToString:lastEntity.pullType]) {
                    //如果有相同消息 则return
                    return;
                }
            }
            
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                BOOL rett = [strongSelf ->jqFmdb jq_insertTable:[NSString stringWithFormat:@"qunzu%@",[[MsgDic[@"result"] objectForKey:@"groupId"] description]] dicOrModel:GroupEntity];
                if (!rett) {
                    [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
                    return;
                }
            }];
            if ([currentVC isKindOfClass:[MessageChatListViewController class]]) {
                //当在会话列表界面。通知刷新
                SecretLetterModel messageType = SecretLetterType_notifyRefreshChatSessionList;
                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [self.delegate didReceiveMessage:@"" type:messageType];
                    });
                }
            }else{
                //否则 记录通知刷新
                [NFUserEntity shareInstance].isNeedRefreshLocalChatList = YES;
                //收到5020的这个人为邀请人 则设置回去刷新本地消息历史
                if ([messageFrame.message.invitor isEqualToString:[NFUserEntity shareInstance].nickName]) {
                    [NFUserEntity shareInstance].isNeedRefreshChatData = YES;
                }
            }
        }
            break;
        case 5021:{
#pragma mark - 5021 群成员改变
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_GroupDetailChanged;
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
                NSDictionary *changeDict = MsgDic[@"result"];
                GroupCreateSuccessEntity *groupCreateS = [MessageParser groupDetailManagerParserr:MsgDic[@"result"]];
                //群组详情缓存
                [self.fmdbServicee cacheGroupDetail:self.groupCreateSuccess];
                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [self.delegate didReceiveMessage:@"" type:messageType];
                    });
                }
            });
        }
            break;
        case 5022:{
#pragma mark - 5022 已经不是群成员 后面为 群已经解散的逻辑
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_GroupBreak;
            self.groupCreateSuccess.exit_group = @"1";
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:self.groupCreateSuccess type:messageType];
                });
            }
        }
            break;
        case 5023:{
#pragma mark - 5023 群主踢人成功
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_GroupDropSuccess;
//            NSDictionary *changeDict = MsgDic[@"result"];
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
        }
            break;
            case 5024:{
#pragma mark - 5024 群主踢人失败
                [SVProgressHUD dismiss];
                messageType = SecretLetterType_DynamicSuccess;
//                NSDictionary *changeDict = MsgDic[@"result"];
                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [self.delegate didReceiveMessage:@"" type:messageType];
                    });
                }
            }
            break;
        case 5025:{
#pragma mark - 5025 群里有人被踢出
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_GroupMemberDrop;
//            NSDictionary *changeDict = MsgDic[@"result"];
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
        }
            break;
        case 5030:{//设置群管理成功
            messageType = SecretLetterType_GroupSetManageSucess;
            id resuly = MsgDic[@"result"];
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
        }
            break;
        case 5031:{//取消群管理成功
            messageType = SecretLetterType_GroupDelManageSucess;
            id resuly = MsgDic[@"result"];
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
        }
            break;
        case 5032:{//设置群禁言成功
            messageType = SecretLetterType_GroupSetForbid;
            id result = MsgDic[@"result"];
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
        }
            break;
        case 5033:{//取消群禁言成功
            messageType = SecretLetterType_GroupDelForbid;
            id resuly = MsgDic[@"result"];
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
        }
            break;
        case 5036:{//群免打扰
            messageType = SecretLetterType_GroupDelForbid;
            
        }
            break;
        case 5038:{//换让群主成功
            messageType = SecretLetterType_zhuanrangSuccess;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
        }
            break;
        case 5040:{//举报
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_jubao;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
        }
            break;
        case 5042:{////开启加群验证成功
            [SVProgressHUD dismiss];
            
        }
            break;
        case 5043:{////关闭加群验证成功
            [SVProgressHUD dismiss];
            
        }
            break;
        case 5045:{////
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_yanzheng;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
        }
            break;
            case 5047:{////
                [SVProgressHUD dismiss];
                messageType = SecretLetterType_yanzheng;
                [SVProgressHUD showInfoWithStatus:@"用户已在群组中"];
                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [self.delegate didReceiveMessage:@"" type:messageType];
                    });
                }
            }
                break;
        case 5048:{////
           // [SVProgressHUD dismiss];
            [SVProgressHUD showInfoWithStatus:@"该请求已过期"];
            messageType = SecretLetterType_yanzhengOver;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    //[self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
        }
            break;
        case 5049:{////
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_yanzhengReject;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
        }
            break;
        case 5050:{////
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_yanzhengAccept;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
        }
            break;
        case 5051:{////
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_FriendAddIgnoreSuccess;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
        }
            break;
            case 5052:{//管理员收到进群申请
                [SVProgressHUD dismiss];
                messageType = SecretLetterType_ValidateManager;
                NSDictionary *allDict = MsgDic[@"result"];
                self.groupCreateSuccess = [MessageParser groupCreateSuccessManagerParserr:allDict[@"groupinfo"]];
                //[self.fmdbServicee cacheGroupDetail:self.groupCreateSuccess];
                    //则立马进行缓存 会话列表 dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
                [self.fmdbServicee cacheChatGroupCreateList:self.groupCreateSuccess];
                //缓存某某某拉谁进群到缓存
                
                UUMessageFrame *messageFrame = [MessageParser PullUserManageParser:MsgDic[@"result"]];
                //数组详情缓存到数据库表 dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
//                [self.fmdbServicee cacheGroupDetail:self.groupCreateSuccess];
                //                });
                UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];

                //如果正在和该群租聊天 则通知界面刷新
                if ([[NFUserEntity shareInstance].currentChatId isEqualToString:[[allDict[@"groupInfo"] objectForKey:@"groupId"] description]] && [[NFUserEntity shareInstance].isSingleChat isEqualToString:@"2"] && messageFrame.message.pulledMemberString.length > 0) {
                    //是否正在和当前群聊天
                    SecretLetterModel messageType = SecretLetterType_ReceiveGroupMessage;
                    if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                        dispatch_queue_t mainQueue = dispatch_get_main_queue();
                        dispatch_async(mainQueue, ^{
                            [self.delegate didReceiveMessage:messageFrame type:SecretLetterType_ReceiveGroupMessage];
                        });
                    }
                    return;
                }
                //否则 缓存群聊消息到消息记录
                MessageChatEntity *GroupEntity = [MessageChatEntity new];
                GroupEntity.invitor = messageFrame.message.invitor;
                GroupEntity.pulledMemberString = messageFrame.message.pulledMemberString;
                GroupEntity.create_time_head = messageFrame.message.strTimeHeader;
                GroupEntity.create_time = messageFrame.message.strTime;
                GroupEntity.pullType = @"3";
                GroupEntity.redpacketString = @"";
                GroupEntity.fileId = messageFrame.message.fileId;
                if (GroupEntity.invitor.length == 0 || GroupEntity.pulledMemberString.length == 0) {
                    return;//如果拉人者或被拉人有一人为空 则不进行缓存
                }
                jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
                //检查表
                [self.fmdbServicee IsExistGroupChatHistory:[[allDict[@"groupInfo"] objectForKey:@"groupId"] description] ISNeedAppend:YES];
                //查看该表里面的消息历史
    //            NSArray *axdrrs = [jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunzu%@",[[MsgDic[@"result"] objectForKey:@"groupId"] description]] dicOrModel:[MessageChatEntity class] whereFormat:@""];
                //插入数据 群聊消息
                __weak typeof(self)weakSelf=self;
                
                __block NSArray *lastArr = [NSArray new];
                __block int dataaCount = 0;
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    //userId = userId order by id desc limit 5
                    dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:[NSString stringWithFormat:@"qunzu%@",[[allDict[@"groupInfo"] objectForKey:@"groupId"] description]]];
                    lastArr = [strongSelf ->jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunzu%@",[[allDict[@"groupInfo"] objectForKey:@"groupId"] description]] dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,1]];
                    
                }];
                //重复消息
                if(lastArr.count == 1){
                    MessageChatEntity *lastEntity = [lastArr firstObject];
                    if ([GroupEntity.pulledMemberString isEqualToString:lastEntity.pulledMemberString]&& [GroupEntity.pullType isEqualToString:lastEntity.pullType]) {
                        //如果有相同消息 则return
                        return;
                    }
                }
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    BOOL rett = [strongSelf ->jqFmdb jq_insertTable:[NSString stringWithFormat:@"qunzu%@",[[allDict[@"groupInfo"] objectForKey:@"groupId"] description]] dicOrModel:GroupEntity];
                    if (!rett) {
                        [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
                        return;
                    }
                }];
                if ([currentVC isKindOfClass:[MessageChatListViewController class]]) {
                    //当在会话列表界面。通知刷新
                    SecretLetterModel messageType = SecretLetterType_notifyRefreshChatSessionList;
                    if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                        dispatch_queue_t mainQueue = dispatch_get_main_queue();
                        dispatch_async(mainQueue, ^{
                            [self.delegate didReceiveMessage:@"" type:messageType];
                        });
                    }
                }else{
                    //否则 记录通知刷新
                    [NFUserEntity shareInstance].isNeedRefreshLocalChatList = YES;
                }
            }
                break;
                    case 5054:{
            #pragma mark - 5054 请求所有群成员id
                        messageType = SecretLetterType_GroupAllMemberId;
                        NSDictionary *dict =  MsgDic[@"result"];
                        NSArray *memberArr = [MessageParser groupmemberManagerParserr:[dict objectForKey:@"groupAllUser"]];
                        if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                            dispatch_queue_t mainQueue = dispatch_get_main_queue();
                            dispatch_async(mainQueue, ^{
                                [self.delegate didReceiveMessage:@{@"groupid":[[dict objectForKey:@"groupId"] description],@"groupUser":memberArr} type:messageType];
                            });
                        }
                    }
                        break;
                case 5055:{
        #pragma mark - 5055 群成员 信息数组返回
                    messageType = SecretLetterType_GrouppartMemberDetail;
                    NSDictionary *dict =  MsgDic[@"result"];
                    NSArray *memberArr = [MessageParser groupmemberManagerParserr:[dict objectForKey:@"groupUser"]];
                    if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                        dispatch_queue_t mainQueue = dispatch_get_main_queue();
                        dispatch_async(mainQueue, ^{
                            [self.delegate didReceiveMessage:@{@"groupid":[[dict objectForKey:@"groupId"] description],@"groupUser":memberArr} type:messageType];
                        });
                    }
                }
                        break;
                case 5555:{// 群组系统通知
                    //[SVProgressHUD dismiss];
                    messageType = SecretLetterType_GroupNoticeMessage;
                    NSDictionary *dict =  MsgDic[@"result"];
                    UUMessageFrame *messageFrame = [MessageParser GroupNoticeParser:dict];
                    if ([[NFUserEntity shareInstance].currentChatId isEqualToString:[[dict objectForKey:@"groupId"] description]] && [[NFUserEntity shareInstance].isSingleChat isEqualToString:@"2"] && messageFrame.message.pulledMemberString.length > 0 && ![messageFrame.message.userId isEqualToString:[NFUserEntity shareInstance].userId]) {
                        //是否正在和当前群聊天
                        SecretLetterModel messageType = SecretLetterType_ReceiveGroupMessage;
                        if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                            dispatch_queue_t mainQueue = dispatch_get_main_queue();
                            dispatch_async(mainQueue, ^{
                                [self.delegate didReceiveMessage:messageFrame type:SecretLetterType_ReceiveGroupMessage];
                            });
                        }
                        return;
                    }else{
                        //不在群聊界面 缓存群组系统通知
                        MessageChatEntity *GroupEntity = [MessageChatEntity new];
                        GroupEntity.user_name = messageFrame.message.userName;
                        GroupEntity.pulledMemberString = messageFrame.message.pulledMemberString;
                        GroupEntity.create_time_head = messageFrame.message.strTimeHeader;
                        GroupEntity.create_time = messageFrame.message.strTime;
                        GroupEntity.type = @"7";
                        GroupEntity.redpacketString = @"";
//                        NSMutableString *pulledPerson = [NSMutableString new];
//                        if([[[dict objectForKey:@"type"] description] isEqualToString:@"3"]){
//                            //设置了管理员
//                            pulledPerson = [NSMutableString stringWithFormat:@"群主设置了%@为管理员",[[dict objectForKey:@"nickname"] description]];
//                        }else if([[[dict objectForKey:@"type"] description] isEqualToString:@"1"]){
//                            //转让群主
//                            NSDictionary *newCreator =[dict objectForKey:@"newCreator"];
//                            pulledPerson = [NSMutableString stringWithFormat:@"%@被转让成为新的群主",[dict objectForKey:@"nickname"]];
//                        }
//                        GroupEntity.pulledMemberString = [NSString stringWithFormat:@"  %@  ",pulledPerson];
                        
                        if (GroupEntity.pulledMemberString.length == 0 ) {
                            return;//如果领取红包 为空 则不缓存
                        }
                        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
                        //检查表
                        [self.fmdbServicee IsExistGroupChatHistory:[[MsgDic[@"result"] objectForKey:@"groupId"] description] ISNeedAppend:YES];
                        //查看该表里面的消息历史
                        //            NSArray *axdrrs = [jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunzu%@",[[MsgDic[@"result"] objectForKey:@"groupId"] description]] dicOrModel:[MessageChatEntity class] whereFormat:@""];
                        //插入数据 群聊消息
                        __weak typeof(self)weakSelf=self;
                        
                        //重复消息
                        __block NSArray *lastArr = [NSArray new];
                        __block int dataaCount = 0;
                        [jqFmdb jq_inDatabase:^{
                            __strong typeof(weakSelf)strongSelf=weakSelf;
                            //userId = userId order by id desc limit 5
                            dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:[NSString stringWithFormat:@"qunzu%@",[[MsgDic[@"result"] objectForKey:@"groupId"] description]]];
                            lastArr = [strongSelf ->jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunzu%@",[[MsgDic[@"result"] objectForKey:@"groupId"] description]] dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,1]];
                            
                        }];
                        if(lastArr.count == 1){
                            MessageChatEntity *lastEntity = [lastArr firstObject];
                            if ([GroupEntity.pulledMemberString isEqualToString:lastEntity.pulledMemberString]&& [GroupEntity.pullType isEqualToString:lastEntity.pullType]) {
                                //如果有相同消息 则return
                                return;
                            }
                        }
                        
                        [jqFmdb jq_inDatabase:^{
                            __strong typeof(weakSelf)strongSelf=weakSelf;
                            BOOL rett = [strongSelf ->jqFmdb jq_insertTable:[NSString stringWithFormat:@"qunzu%@",[[MsgDic[@"result"] objectForKey:@"groupId"] description]] dicOrModel:GroupEntity];
                            if (!rett) {
                                [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
                                return;
                            }
                        }];
                    }
                    if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                        dispatch_queue_t mainQueue = dispatch_get_main_queue();
                        dispatch_async(mainQueue, ^{
                            [self.delegate didReceiveMessage:@"" type:messageType];
                        });
                    }
                }
                    break;
        case 6001:{
#pragma mark - 6001 发布动态成功
            //发布动态成功返回
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_DynamicSuccess;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
        }
            break;
        case 6002:{
#pragma mark - 6002 点赞成功  【点赞成功返回大于0的likeid 取消点赞 返回likeid0】
            //发布动态成功返回
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_DynamicDianzan;
            
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    NSMutableDictionary *dictt = [NSMutableDictionary new];
                    dictt[@"type"] = @"6002";
                    dictt[@"result"] = [MsgDic[@"result"] description];
                    [self.delegate didReceiveMessage:dictt type:messageType];
                });
            }
        }
            break;
        case 6003:{
#pragma mark - 6003 评论成功
            //发布动态成功返回
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_DynamicSuccess;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                NSMutableDictionary *dictt = [NSMutableDictionary new];
                dictt[@"type"] = @"6003";
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:dictt type:messageType];
                });
            }
        }
            break;
        case 6010:{
#pragma mark - 6010  取消点赞 【点赞成功返回大于0的likeid 取消点赞 返回likeid0】
            //发布动态成功返回
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_DynamicDianzan;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    NSMutableDictionary *dictt = [NSMutableDictionary new];
                    dictt[@"type"] = @"6010";
                    dictt[@"result"] = [MsgDic[@"result"] description];
                    [self.delegate didReceiveMessage:dictt type:messageType];
                });
            }
        }
            break;
        case 6004:{
#pragma mark - 6004 获取动态列表
            //发布动态成功返回
            //NFShowImageView 62行 安卓null图片就能显示了
            messageType = SecretLetterType_DynamicList;
            //            id data = MsgDic[@"result"];
            
            __block NSMutableArray *backArr = [NSMutableArray new];
            dispatch_group_t group = dispatch_group_create();
            dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
                dispatch_group_enter(group);
                backArr = [NFDynamicParser noteListParser:MsgDic[@"result"]];
                dispatch_group_leave(group);
            });
            dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
            
//            NSMutableArray *needShieldArr = [NSMutableArray new];
//            for (NoteListEntity *dynamic in backArr) {
//                jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//                NSArray *contactArr = [jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact new] whereFormat:@" where friend_userid = '%@' and IsShieldDynamic = '%@'",dynamic.user_id,@"1"];
//                if (contactArr.count > 0) {
//                    [needShieldArr addObject:dynamic];
//                }
//            }
//            for (NoteListEntity *dynamic in needShieldArr){
//                [backArr removeObject:dynamic];
//            }
//            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
//            NSLog(@"%@",[NFMyManage getCurrentVCFrom:rootViewController]);
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:backArr type:messageType];
                });
            }
        }
            break;
        case 6006:{
#pragma mark - 6006 点赞失败
            //发布动态成功返回
//            [SVProgressHUD showErrorWithStatus:@"点赞失败"];
            messageType = SecretLetterType_DynamicDianzan;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    NSMutableDictionary *dictt = [NSMutableDictionary new];
                    dictt[@"type"] = @"6006";
                    dictt[@"result"] = [MsgDic[@"result"] description];
                    [self.delegate didReceiveMessage:dictt type:messageType];
                });
            }
        }
            break;
        case 6009:{
#pragma mark - 6009删除动态返回
            //
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_DynamicReturnDict;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    NSMutableDictionary *dictt = [NSMutableDictionary new];
                    dictt[@"type"] = @"6009";
                    dictt[@"result"] = [MsgDic[@"result"] description];
                    [self.delegate didReceiveMessage:dictt type:messageType];
                });
            }
        }
            break;
        case 6011:{
#pragma mark - 6011删除动态评论成功返回
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_DynamicReturnDict;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    NSMutableDictionary *dictt = [NSMutableDictionary new];
                    dictt[@"type"] = @"6011";
                    dictt[@"result"] = [MsgDic[@"result"] description];
                    [self.delegate didReceiveMessage:dictt type:messageType];
                });
            }
        }
            break;
        case 6013:{
#pragma mark - 6013 取消点赞失败
            //发布动态成功返回
//            [SVProgressHUD showErrorWithStatus:@"取消点赞失败"];
            messageType = SecretLetterType_DynamicDianzan;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    NSMutableDictionary *dictt = [NSMutableDictionary new];
                    dictt[@"type"] = @"6013";
                    dictt[@"result"] = [MsgDic[@"result"] description];
                    [self.delegate didReceiveMessage:dictt type:messageType];
                });
            }
        }
            break;
            //
        case 6014:{
#pragma mark - 6014 删除评论失败
            messageType = SecretLetterType_DynamicFail;
                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    NSMutableDictionary *dictt = [NSMutableDictionary new];
                    dictt[@"type"] = @"6018";
                    dispatch_async(mainQueue, ^{
                        [self.delegate didReceiveMessage:dictt type:messageType];
                    });
                }
            }
            break;
        case 6015:{
#pragma mark - 6015 获取动态详情成功
            [SVProgressHUD dismiss];
            messageType = SecretLetterType_DynamicDetail;
            NoteListEntity *backEntity = [NFDynamicParser detailNoteParser:MsgDic[@"result"]];
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:backEntity type:messageType];
                });
            }
        }
            break;
        case 6016:{
#pragma mark - 6016 获取动态详情失败
            messageType = SecretLetterType_DynamicFail;
            NSMutableDictionary *dictt = [NSMutableDictionary new];
            [SVProgressHUD showErrorWithStatus:@"获取详情失败"];
            dictt[@"type"] = @"6016";
            dictt[@"result"] = [MsgDic[@"result"] description];
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:dictt type:messageType];
                });
            }
        }
            break;
        case 6017:{
#pragma mark - 6017 动态评论提醒 角标
            messageType = SecretLetterType_receiveDynamicCount;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                NSDictionary *dict = MsgDic[@"result"];
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                    UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
                    [NFUserEntity shareInstance].dynamicBadgeCount = [[dict objectForKey:@"unread"] integerValue];
                    UITabBarItem *tabBarItemWillBadge = currentVC.navigationController.tabBarController.tabBar.items[2];
                    if([[[dict objectForKey:@"unread"] description] integerValue] == 0){
                        if([[[dict objectForKey:@"new"] description] integerValue] > 0){
                            [tabBarItemWillBadge yee_MakeRedBadge:4 color:[UIColor redColor]];
                        }else{
                            [tabBarItemWillBadge removeBadgeView];
                        }
                    }else{
                        [tabBarItemWillBadge yee_MakeBadgeTextNum:[NFUserEntity shareInstance].dynamicBadgeCount textColor:[UIColor whiteColor] backColor:[UIColor redColor] Font:[UIFont fontSectionBigBadge]];
                    }
                    [self.delegate didReceiveMessage:nil type:messageType];
                });
            }
        }
            break;
        case 6018:{
#pragma mark - 6018 有朋友发布新动态
            messageType = SecretLetterType_receiveNewDynamicOrNewcomment;
            [self getCircleMsgRequest];
//                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
//                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
//                    dispatch_async(mainQueue, ^{
//                        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
//                        UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
//                        if([NFUserEntity shareInstance].dynamicBadgeCount == 0){
//                            UITabBarItem *tabBarItemWillBadge = currentVC.navigationController.tabBarController.tabBar.items[2];
//                            [tabBarItemWillBadge yee_MakeRedBadge:4 color:[UIColor redColor]];
//                        }
//                        [self.delegate didReceiveMessage:nil type:messageType];
//                    });
//                }
            }
        break;
        case 6019:{
        #pragma mark - 6019 动态评论提醒 列表
                    messageType = SecretLetterType_receiveDynamicCommentList;
                    if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
//                        NSDictionary *dict = MsgDic[@"result"];
                        NSArray *arr = [NFDynamicParser dynamicCommentListParser:MsgDic[@"result"]];
                        dispatch_queue_t mainQueue = dispatch_get_main_queue();
                        dispatch_async(mainQueue, ^{
                            [self.delegate didReceiveMessage:arr type:messageType];
                        });
                    }
                }
                    break;
        case 6053:{
#pragma mark - 6053 收藏图片列表返回
            //svp在controll界面展示
            messageType = SecretLetterType_collectPicture;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:MsgDic[@"result"] type:messageType];
                });
            }
        }
            break;
        case 8001:{
            [SVProgressHUD showInfoWithStatus:@"提交参数异常"];
        }
            //暂时修改成 普通消息
            //            messageType = ChatMessageType_Normal;
            //            entity.chatContant = MsgDic[@"result"];
            //            [[NFbaseViewController new] insertContantDataToFMDBCacheData:@{@"contant":@"消息内容",@"otherId":@"123"} isSelf:NO];
            break;
        case 8002:{
            [SVProgressHUD showInfoWithStatus:@"您的账号因违反多信用户手册，现已被封停，请联系客服处理！"];
            
        }case 8003:{
#pragma mark - 8003
            messageType = SecretLetterType_ReportIllegal;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:MsgDic[@"result"] type:messageType];
                });
            }
        }
            break;
        case 8888:{
        #pragma mark - 8008
                    messageType = SecretLetterType_logoffSuccess;
                    if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                        dispatch_queue_t mainQueue = dispatch_get_main_queue();
                        dispatch_async(mainQueue, ^{
                            [self.delegate didReceiveMessage:nil type:messageType];
                        });
                    }
                }
                    break;
        case 9101:{//充值发送短信
        #pragma mark - 9101
                    messageType = SecretLetterType_chagemoneySendcode;
                    if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                        dispatch_queue_t mainQueue = dispatch_get_main_queue();
                        dispatch_async(mainQueue, ^{
                            [self.delegate didReceiveMessage:MsgDic[@"result"] type:messageType];
                        });
                    }
                }
                    break;
        case 9102:{//充值验证短信
        #pragma mark - 9102
                    messageType = SecretLetterType_chagemoneyCheckcode;
                    if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                        dispatch_queue_t mainQueue = dispatch_get_main_queue();
                        dispatch_async(mainQueue, ^{
                            [self.delegate didReceiveMessage:MsgDic[@"result"] type:messageType];
                        });
                    }
                }
                    break;
        default:
            break;
    }
#pragma mark - 超时提醒 【当超时的时候 并且 界面在菊花转中 发出提醒】
//    [self timeOutCountCaculation:status];
}

#pragma mark - 连接成功
-(void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"连接成功 webSocketDidOpen");
    reConnecTime = 0;
    //可以在这里处理断线重连情况，除了从登陆到这里是正常的连接成功，后面都是因为断线重连成功才能到这里
    //在这里进行某个请求会走到登录成功界面
    //初始化超时计算
    TimeOutCount = 0;
    reconnectCount = 0;
    //连接成功
    self.isConnected = YES;
    [NFUserEntity shareInstance].isNeedRefreshChatList = YES;
    //连接成功 开始发送心跳
    [self initHearBeat];
    //首次登录连接成功 不需要登录
    if ([NFUserEntity shareInstance].userType == NFUserWX && ![NFUserEntity shareInstance].userIsConncected) {
        [self weixinLoginRequest];
    }else if ([NFUserEntity shareInstance].userType == NFUserGeneral && ![NFUserEntity shareInstance].userIsConncected){
        [self loginWithDefaultType];
    }else if( ![NFUserEntity shareInstance].userIsConncected){
        [self loginWithDefaultType];
    }//连接成功 进行重连
    //通知刷新会话列表的界面【去除连接失败】 这里知识socket连接成功 而还需要登录成功才能成功发送消息
//    [self connectSuccess];
    
    //当有该block 再进行回调 应该在1002 登录成功中调用
//    if (self.ConnectSucceedBlock) {
//        self.ConnectSucceedBlock();
//    }
    
}



-(void)sendMessageWith:(NSString *)json{
    reconnectCount++;
    if (self.isConnected && a <= 10) {
        [self sendMsg:json];
    }
//    else{
//        [self performSelector:@selector(sendMessageWith:) withObject:nil afterDelay:0.2];
//    }
}

//open失败时调用
#pragma mark - 服务器通讯断开链接
-(void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@"连接失败。。。。。%@",error);
    //标记用户为非登录状态
    [NFUserEntity shareInstance].userIsConncected = NO;
    if (reConnecTime == 6) {
        [self showBreak];
    }else{
        if (![[NFUserEntity shareInstance].connectStatus isEqualToString:@"2"]) {
            //如果连接状态未 非【未连接状态 则通知服务器断开，已经断开则不管】
            [self showConnecting];
        }
    }
    
    if (!IsReconnecting) {
//        NSLog(@"%d",TimeOutCount);
//        [SVProgressHUD showInfoWithStatus:@"服务器正在开小差"];
    }else{
        //通知界面结束刷新
        //请求接口进行重连 【假断开可以重连上，如果真断开那么不能连上】
//        [self getAddFriendList];
//        if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
//            dispatch_queue_t mainQueue = dispatch_get_main_queue();
//            dispatch_async(mainQueue, ^{
//                [self.delegate didReceiveMessage:@"" type:SecretLetterType_SocketRequestFailed];
//            });
//        }
    }
    
    //非连接状态
    self.isConnected = NO;
    [self reConnect];
    
}
//网络连接中断被调用
#pragma mark - 网络中断
-(void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    NSLog(@"被关闭连接，code:%ld,reason:%@,wasClean:%d",code,reason,wasClean);
    //标记用户为非登录状态
    [NFUserEntity shareInstance].userIsConncected = NO;
    //非连接状态
    self.isConnected = NO;
    //如果是被用户自己中断的那么直接断开连接，否则开始重连 1001也属于手动断开
//    if (code == disConnectByServer) {
//        NSLog(@"");
//    }else if (code == disConnectByUser){
//        NSLog(@"");
//    }
    if (code == disConnectByUser || code == 1001) {
//        [self disConnect];
        [self reConnect];
    }else{
        [self reConnect];
    }
    
    //断开连接时销毁心跳
    [self destoryHeartBeat];
    
//    if (reConnecTime > 10) {
//        [self showBreak];
//    }else{
        if (![[NFUserEntity shareInstance].connectStatus isEqualToString:@"2"]) {
            //如果连接状态未 非【未连接状态 则通知服务器断开，已经断开则不管】
            [self showConnecting];
        }
//    }
    
}
//sendPing的时候，如果网络通的话，则会收到回调，但是必须保证ScoketOpen，否则会crash
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload
{
    self.isConnected  = YES;
    //NSLog(@"收到ping回调");
    
}

#pragma mark - 已读
-(void)readedRequest:(NSString *)messageId AndReceiveName:(NSString *)receiveName{
    [self.parms removeAllObjects];
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"action"] = @"setMessageRead";
    self.parms[@"messageId"] = messageId;
    self.parms[@"receiveName"] = receiveName;
//    parms[@"receiveName"] = self.singleContactEntity.friend_username;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [self ping];
    if ([self isConnected]) {
        [self sendMsg:Json];
    }else{
//        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 群消息已读
-(void)readedGroupRequest:(NSString *)messageId AndGroupId:(NSString *)groupId{
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"setGroupMsgRead";
    self.parms[@"lastGroupMsgId"] = messageId;
    self.parms[@"groupId"] = groupId;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    //    parms[@"receiveName"] = self.singleContactEntity.friend_username;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [self ping];
    if ([self isConnected]) {
        [self sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}



#pragma mark - 已收到
-(void)readedRequest:(NSString *)messageId receiveName:(NSString *)receiveName{
    [self.parms removeAllObjects];
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"action"] = @"setMessageReceived";
    self.parms[@"messageId"] = messageId;
    self.parms[@"receiveName"] = receiveName;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [self ping];
    if ([self isConnected]) {
        [self sendMsg:Json];
    }else{
//        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

//退出登陆
-(void)quitSocketRequestDing{
    //请求人列表获取
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"userLogout";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [self ping];
    if ([self isConnected]) {
        [self sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

//请求  getCircleMsg ，获取朋友圈提醒数量
-(void)getCircleMsgRequest{
    //请求人列表获取
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"getCircleMsg";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [self ping];
    if ([self isConnected]) {
        [self sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 当没和该信息发出者聊天中时 单聊
-(void)WhenNotChatWithThisMessageUser:(NSDictionary *)data{
    NSString *messageHeadString = [data objectForKey:@"content"];
//    if (messageHeadString.length > 10) {
//        messageHeadString = [[data objectForKey:@"content"] substringToIndex:10];
//    }else{
//        messageHeadString = @"";
//    }
    
    //声音提醒
#warning 声音提醒
    if ([self.myManage respondsToSelector:@selector(notifySet)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.myManage performSelector:@selector(notifySet) withObject:nil afterDelay:notifyDelayTime];
        });
    }
    
    //通知消息tabbar角标改变
    //获取当前显示的viewcontroller
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
    //再进单聊需要请求历史消息 【如果从会话列表进去 事实不需要的话 下面属性会成为no的】
//    if ([currentVC isKindOfClass:[SingleChatDetailTableViewController class]]) {
        [NFUserEntity shareInstance].isNeedRefreshChatData = YES;
        [NFUserEntity shareInstance].isNeedRefreshSingleChatHistory = YES;
//    }
    
    //为什么收到 对方单聊消息就缓存要缓存 【这样的话在详情界面收到消息 pop回去将不会有消息add到界面】
    UUMessageFrame *messageFrame = [MessageParser GotNormalMessageContantParser:data];
    MessageChatEntity *entity = [self.fmdbServicee UUMessageFrameToMessageChatEntity:messageFrame];
    if(![entity.type isEqualToString:@"4"]){
        entity.redpacketString = @"";
    }
    
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    
    //
    __weak typeof(self)weakSelf=self;
    __block NSArray *lastArr = [NSArray new];
    __block int dataaCount = 0;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        //userId = userId order by id desc limit 5
        dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:[[data objectForKey:@"fromId"] description]];
        lastArr = [strongSelf ->jqFmdb jq_lookupTable:[[data objectForKey:@"fromId"] description] dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,1]];
        
    }];
    //重复消息 单聊
    if(lastArr.count == 1){
        MessageChatEntity *lastEntity = [lastArr firstObject];
        if ([entity.chatId isEqualToString:lastEntity.chatId] && entity.chatId.length > 0) {
            //如果有相同消息 则return
            return;
        }
    }
    
    
    //插入数据
    [jqFmdb jq_inDatabase:^{
        BOOL rett = [jqFmdb jq_insertTable:[[data objectForKey:@"fromId"] description] dicOrModel:entity];
        if (!rett) {
            [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
            //                return;
        }
    }];
    
    //当前页面不是消息或其子类界面 显示红点
    if (currentVC.navigationController.tabBarItem.tag != 1) {
        //当不在会话列表界面 则改变角标 进行缓存消息 messageFrame 这里需要缓存 因为当先收到对方发的消息后 再收到web端自己发的消息 如果这里不缓存 那么自己发的消息则会在对方先发的消息上面
        [[NFbaseViewController new] setBadgeCountWithCount:1 AndIsAdd:YES];
//        UUMessageFrame *messageFrame = [MessageParser GotNormalMessageContantParser:data];
//        MessageChatEntity *entity = [self.fmdbServicee UUMessageFrameToMessageChatEntity:messageFrame];
//        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//        //插入数据
//        [jqFmdb jq_inDatabase:^{
//            BOOL rett = [jqFmdb jq_insertTable:[[data objectForKey:@"fromId"] description] dicOrModel:entity];
//            if (!rett) {
//                [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
//                //                return;
//            }
//        }];
        
    }else{
        //在会话列表界面 通知刷新会话列表
        SecretLetterModel messageType = SecretLetterType_notifyRefreshChatSessionList;
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
        if ([currentVC isKindOfClass:[MessageChatListViewController class]]) {
            [NFUserEntity shareInstance].showPrompt = YES;
        }
        if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
            dispatch_queue_t mainQueue = dispatch_get_main_queue();
            dispatch_async(mainQueue, ^{
                [self.delegate didReceiveMessage:@"" type:messageType];
            });
        }
        //再会话列表同样需要改变角标 无需再这里改变角标，当刷新会话列表时候 会改变角标
//        [[NFbaseViewController new] setBadgeCountWithCount:1 AndIsAdd:YES];
    }
}

#pragma mark - 当没和该信息发出者聊天中时 红包 单聊
-(void)receiveSingleRedpacketMessage:(NSDictionary *)data{
    NSString *messageHeadString = [data objectForKey:@"content"];
    //    if (messageHeadString.length > 10) {
    //        messageHeadString = [[data objectForKey:@"content"] substringToIndex:10];
    //    }else{
    //        messageHeadString = @"";
    //    }
    
    //声音提醒
#warning 声音提醒
    if ([self.myManage respondsToSelector:@selector(notifySet)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.myManage performSelector:@selector(notifySet) withObject:nil afterDelay:notifyDelayTime];
        });
    }
    
    //通知消息tabbar角标改变
    //获取当前显示的viewcontroller
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
    //再进单聊需要请求历史消息 【如果从会话列表进去 事实不需要的话 下面属性会成为no的】
    //    if ([currentVC isKindOfClass:[SingleChatDetailTableViewController class]]) {
    [NFUserEntity shareInstance].isNeedRefreshChatData = YES;
    [NFUserEntity shareInstance].isNeedRefreshSingleChatHistory = YES;
    //    }
    
    //为什么收到 对方单聊消息就缓存要缓存 【这样的话在详情界面收到消息 pop回去将不会有消息add到界面】
    UUMessageFrame *messageFrame = [MessageParser GotNormalRedPacketMessageContantParser:data];
    MessageChatEntity *entity = [self.fmdbServicee UUMessageFrameToMessageChatEntity:messageFrame];
    
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __weak typeof(self)weakSelf=self;
    __block NSArray *lastArr = [NSArray new];
    __block int dataaCount = 0;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        //userId = userId order by id desc limit 5
        dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:[[data objectForKey:@"fromId"] description]];
        lastArr = [strongSelf ->jqFmdb jq_lookupTable:[[data objectForKey:@"fromId"] description] dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,1]];
        
    }];
    //重复消息 单聊
    if(lastArr.count == 1){
        MessageChatEntity *lastEntity = [lastArr firstObject];
        if ([entity.chatId isEqualToString:lastEntity.chatId] && entity.chatId.length > 0) {
            //如果有相同消息 则return
            return;
        }
    }
    //插入数据
    [jqFmdb jq_inDatabase:^{
        BOOL rett = [jqFmdb jq_insertTable:[[data objectForKey:@"fromId"] description] dicOrModel:entity];
        if (!rett) {
            [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
            //                return;
        }
    }];
    
    //当前页面不是消息或其子类界面 显示红点
    if (currentVC.navigationController.tabBarItem.tag != 1) {
        //当不在会话列表界面 则改变角标 进行缓存消息 messageFrame 这里需要缓存 因为当先收到对方发的消息后 再收到web端自己发的消息 如果这里不缓存 那么自己发的消息则会在对方先发的消息上面
        [[NFbaseViewController new] setBadgeCountWithCount:1 AndIsAdd:YES];
        //        UUMessageFrame *messageFrame = [MessageParser GotNormalMessageContantParser:data];
        //        MessageChatEntity *entity = [self.fmdbServicee UUMessageFrameToMessageChatEntity:messageFrame];
        //        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        //        //插入数据
        //        [jqFmdb jq_inDatabase:^{
        //            BOOL rett = [jqFmdb jq_insertTable:[[data objectForKey:@"fromId"] description] dicOrModel:entity];
        //            if (!rett) {
        //                [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
        //                //                return;
        //            }
        //        }];
        
    }else{
        //在会话列表界面 通知刷新会话列表
        SecretLetterModel messageType = SecretLetterType_notifyRefreshChatSessionList;
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
        if ([currentVC isKindOfClass:[MessageChatListViewController class]]) {
            [NFUserEntity shareInstance].showPrompt = YES;
        }
        if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
            dispatch_queue_t mainQueue = dispatch_get_main_queue();
            dispatch_async(mainQueue, ^{
                [self.delegate didReceiveMessage:@"" type:messageType];
            });
        }
        //再会话列表同样需要改变角标 无需再这里改变角标，当刷新会话列表时候 会改变角标
        //        [[NFbaseViewController new] setBadgeCountWithCount:1 AndIsAdd:YES];
    }
}

#pragma mark - 收到群组消息
-(void)receiveGroupMessage:(NSDictionary *)resulyDict{
    //如果为本人发的消息 可能为 发送、转发消息所产生的 需要更改本地的mesId 并且不是web端自己的消息才进行查找 web端自己的消息本地是没有的
    if ([[[resulyDict objectForKey:@"group_msg_sender"] description] isEqualToString:[NFUserEntity shareInstance].userId] && ![[[resulyDict objectForKey:@"group_msg_client"] description] isEqualToString:@"web"]) {
        //如果是自己发的消息 【可能正在聊天中、可能是转发】
        //如果是自己发的消息 则需要改变数据库里面的字段failStatus和chatId。
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        //检查群组消息历史字段
        __weak typeof(self)weakSelf=self;
        __block NSArray *existArr = [NSArray new];
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            existArr = [strongSelf ->jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunzu%@",[[resulyDict objectForKey:@"group_id"] description]] dicOrModel:[MessageChatEntity class] whereFormat:@"where appMsgId = '%@'",[[resulyDict objectForKey:@"appMsgId"] description]];
        }];
        //聊天记录表真有该条消息 则进行更改chatId和failStatus为0成功
        if (existArr.count == 1) {
            MessageChatEntity *changeEntity = [existArr lastObject];
            changeEntity.chatId = [[resulyDict objectForKey:@"group_msg_id"] description];
            changeEntity.failStatus = @"0";
            changeEntity.fileId = [[resulyDict objectForKey:@"group_file_id"] description];
            [self.myManage changeFMDBData:changeEntity KeyWordKey:@"appMsgId" KeyWordValue:[[resulyDict objectForKey:@"appMsgId"] description] FMDBID:@"tongxun.sqlite" TableName:[NSString stringWithFormat:@"qunzu%@",[[resulyDict objectForKey:@"group_id"] description]]];
        }
    }
    
    //兼容安卓表情
//    if([[resulyDict objectForKey:@"group_msg_content"] isKindOfClass:[NSString class]] && [NFMyManage validateContainsEmoji:[resulyDict objectForKey:@"group_msg_content"]]){
//        NSString *str = [resulyDict objectForKey:@"group_msg_content"];
//        str = [str stringByReplacingOccurrencesOfString:@"[" withString:@""];
//        str = [str stringByReplacingOccurrencesOfString:@"]" withString:@""];
//        NSMutableDictionary *diccc = [NSMutableDictionary dictionaryWithDictionary:resulyDict];
//        [diccc setValue:str forKey:@"group_msg_content"];
//        resulyDict = [NSDictionary dictionaryWithDictionary:diccc];
//    }else if([[resulyDict objectForKey:@"group_msg_content"] isKindOfClass:[NSString class]] && [[resulyDict objectForKey:@"group_msg_content"] length] <= 4 && [[[resulyDict objectForKey:@"group_msg_content"] description] containsString:@"["]&& [[[resulyDict objectForKey:@"group_msg_content"] description] containsString:@"]"]){
//        NSString *str = [resulyDict objectForKey:@"group_msg_content"];
//        str = [str stringByReplacingOccurrencesOfString:@"[" withString:@""];
//        str = [str stringByReplacingOccurrencesOfString:@"]" withString:@""];
//        NSMutableDictionary *diccc = [NSMutableDictionary dictionaryWithDictionary:resulyDict];
//        [diccc setValue:str forKey:@"group_msg_content"];
//        resulyDict = [NSDictionary dictionaryWithDictionary:diccc];
//    }else
        if([[resulyDict objectForKey:@"group_msg_content"] isKindOfClass:[NSString class]] && [[[resulyDict objectForKey:@"group_msg_content"] description] containsString:@"["]&& [[[resulyDict objectForKey:@"group_msg_content"] description] containsString:@"]"]){
        NSString *str = [resulyDict objectForKey:@"group_msg_content"];
        str = [str stringByReplacingOccurrencesOfString:@"[" withString:@""];
        str = [str stringByReplacingOccurrencesOfString:@"]" withString:@""];
        NSMutableDictionary *diccc = [NSMutableDictionary dictionaryWithDictionary:resulyDict];
        [diccc setValue:str forKey:@"group_msg_content"];
        resulyDict = [NSDictionary dictionaryWithDictionary:diccc];
    }
    
    //jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __block NSMutableArray *contacts = [NSMutableArray new];
    //这里重新去缓存联系人
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        contacts = [NSMutableArray arrayWithArray:[strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact class] whereFormat:@"where friend_userid = '%@'",[[resulyDict objectForKey:@"group_msg_sender"] description]]];
    }];
    if(contacts.count > 0){
        ZJContact *contacttt = [contacts firstObject];
        if(contacttt.friend_comment_name.length > 0){
            NSMutableDictionary *diccc = [NSMutableDictionary dictionaryWithDictionary:resulyDict];
//            [diccc setValue:[resulyDict objectForKey:@"nickname"] forKey:@"group_msg_sender_original_name"];
            [diccc setValue:[resulyDict objectForKey:@"group_msg_sender_nick_name"] forKey:@"group_msg_sender_original_name"];
            [diccc setValue:contacttt.friend_comment_name forKey:@"group_msg_sender_nick_name"];
            resulyDict = [NSDictionary dictionaryWithDictionary:diccc];
        }else{
//            NSMutableDictionary *diccc = [NSMutableDictionary dictionaryWithDictionary:resulyDict];
//            [diccc setValue:[resulyDict objectForKey:@"nickname"] forKey:@"group_msg_sender_original_name"];
//            resulyDict = [NSDictionary dictionaryWithDictionary:diccc];
        }
    }else{
//        NSMutableDictionary *diccc = [NSMutableDictionary dictionaryWithDictionary:resulyDict];
//        [diccc setValue:[resulyDict objectForKey:@"nickname"] forKey:@"group_msg_sender_original_name"];
//        resulyDict = [NSDictionary dictionaryWithDictionary:diccc];
    }
    
    
    //收到群组消息，检查是否存在群组消息表
    if(![jqFmdb jq_isExistTable:[NSString stringWithFormat:@"qunzu%@",[resulyDict objectForKey:@"group_id"]]]){
        BOOL ret = [jqFmdb jq_createTable:[NSString stringWithFormat:@"qunzu%@",[resulyDict objectForKey:@"group_id"]] dicOrModel:[MessageChatEntity class]];
    }
    
    //查看是否改名
//    __weak typeof(self)weakSelf=self;
    __block NSArray *messageArr = [NSArray new];
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        messageArr = [jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunzu%@",[[resulyDict objectForKey:@"group_id"] description]] dicOrModel:[MessageChatEntity class] whereFormat:@"where %@ != '%@' and %@ = '%@' ",@"nickName",[resulyDict objectForKey:@"group_msg_sender_nick_name"],@"user_name",[[resulyDict objectForKey:@"group_msg_sender_name"] description]];
    }];
    //NSLog(@"messageArr = %@",messageArr);
    //for循环 将缓存改过来
    for (MessageChatEntity *entity in messageArr) {
        entity.nickName = [[resulyDict objectForKey:@"group_msg_sender_nick_name"] description];
        if (entity.localReceiveTimeString.length > 0 && entity.user_name.length > 0 ) {
            [jqFmdb jq_inDatabase:^{
                BOOL ret = [jqFmdb jq_updateTable:[NSString stringWithFormat:@"qunzu%@",[[resulyDict objectForKey:@"group_id"] description]] dicOrModel:entity whereFormat:@"where user_name = '%@' and localReceiveTimeString = '%@'",entity.user_name,entity.localReceiveTimeString];
                if (ret) {
                    NSLog(@"c更新成功");
                }else{
                    NSLog(@"c更新失败");
                }
            }];
        }
    }
    
    //如果正在群组会话中
    if ([[NFUserEntity shareInstance].currentChatId isEqualToString:[[resulyDict objectForKey:@"group_id"] description]] && [[NFUserEntity shareInstance].isSingleChat isEqualToString:@"2"]) {
        //不能卸写在外面  因为里面有缓存图片，下面也会调用该方法 避免缓存两次 【单纯设置messageframe】
        dispatch_group_t group = dispatch_group_create();
        __block UUMessageFrame *messageFrame = [UUMessageFrame new];
        dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            dispatch_group_enter(group);
            messageFrame = [MessageParser GotGroupNormalMessageContantParser:resulyDict];
            dispatch_group_leave(group);
            
        });
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        //回到会话界面设置刷新会话列表
        [NFUserEntity shareInstance].isNeedRefreshLocalChatList = YES;
#pragma msrk - 设置群消息已读
        [self readedGroupRequest:[resulyDict objectForKey:@"group_msg_id"] AndGroupId:[resulyDict objectForKey:@"group_id"]];
        if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
            dispatch_queue_t mainQueue = dispatch_get_main_queue();
            dispatch_async(mainQueue, ^{
                [self.delegate didReceiveMessage:messageFrame type:SecretLetterType_ReceiveGroupMessage];
            });
        }
    }else{
        //当没有在群聊界面
        //设置提醒
//        NSString *messageHeadString = [resulyDict objectForKey:@"group_msg_content"];
//        if (messageHeadString.length > 10) {
//            messageHeadString = [[resulyDict objectForKey:@"group_msg_content"] substringToIndex:10];
//        }else{
//            messageHeadString = @"";
//        }
        
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        __block NSArray *groupArrs = [NSArray new];
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            groupArrs = [strongSelf ->jqFmdb jq_lookupTable:@"groupDetailliebiao" dicOrModel:[GroupCreateSuccessEntity class] whereFormat:@"where groupId = '%@'",[resulyDict objectForKey:@"group_id"]];
        }];
        BOOL IsAllowPush = YES;
        if(groupArrs.count > 0){
            GroupCreateSuccessEntity *pushCheckEntity = [groupArrs firstObject];
            if ([pushCheckEntity.allow_push isEqualToString:@"0"]) {
                IsAllowPush = NO;
            }
        }
        NSString *sendName =[[resulyDict objectForKey:@"group_msg_sender_name"] description];
        if (![sendName isEqualToString:[NFUserEntity shareInstance].userName] && IsAllowPush) {
            [self.myManage notifySet];
        }
        //通知消息tabbar角标改变
        //获取当前显示的viewcontroller
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
#warning 当有会话列表和消息历史 这里注释掉 记录会话列表更新状态
        //当没和该群组聊天中时 【里面进行缓存】【同时缓存会话列表和消息】 已经将缓存消息、会话列表去掉 这里计算出list为了下面弹窗
        //缓存群组会话列表 【不需要，如果在会话界面会通知请求会话 如果不在，每次显示会请求会话】
//        [self.fmdbServicee receiveGroupMessageChangeChatListCache:resulyDict];
        //检查表存在
        [self.fmdbServicee IsExistGroupChatHistory:[[resulyDict objectForKey:@"group_msg_sender"] description] ISNeedAppend:YES];
        [NFUserEntity shareInstance].isNeedRefreshChatData = YES;//记录刷新会话列表
        [NFUserEntity shareInstance].isNeedRefreshGroupChatHistory = YES;
        //判断是否是web端自己发的消息 是的话则缓存 【因为会话列表需要实时更新】【可以只在会话界面时候 进行insert ，在详情等界面不insert 等到界面显示了再和其他消息按顺序显示】
        if ([sendName isEqualToString:[NFUserEntity shareInstance].userName] && [[resulyDict objectForKey:@"group_msg_client"] isEqualToString:@"web"] && [currentVC isKindOfClass:[MessageChatListViewController class]]) {
            UUMessageFrame *messageFrame = [MessageParser GotGroupNormalMessageContantParser:resulyDict];
            MessageChatEntity *entity = [self.fmdbServicee UUMessageFrameToMessageChatEntity:messageFrame];
            //插入数据到该群组表中
            __weak typeof(self)weakSelf=self;
            
            __block NSArray *lastArr = [NSArray new];
            __block int dataaCount = 0;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                //userId = userId order by id desc limit 5
                dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:[NSString stringWithFormat:@"qunzu%@",[[resulyDict objectForKey:@"group_id"] description]]];
                lastArr = [strongSelf ->jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunzu%@",[[resulyDict objectForKey:@"group_id"] description]] dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,1]];
                
            }];
            //重复消息
            if(lastArr.count == 1){
                MessageChatEntity *lastEntity = [lastArr firstObject];
                if ([entity.chatId isEqualToString:lastEntity.chatId] && entity.chatId.length > 0) {
                    //如果有相同消息 则return
                    return;
                }
            }
            
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                BOOL rett = [strongSelf ->jqFmdb jq_insertTable:[NSString stringWithFormat:@"qunzu%@",[[resulyDict objectForKey:@"group_id"] description]] dicOrModel:entity];
                if (!rett) {
                    [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
                    return;
                }
            }];
            
            //查看会话列表是否有该条会话 没有则insert
            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
            __block NSArray *conversationExistArr;
            [jqFmdb jq_inDatabase:^{
                conversationExistArr = [jqFmdb jq_lookupTable:@"huihualiebiao" dicOrModel:[MessageChatListEntity class] whereFormat:@"where %@ = '%@' and %@ = '%@'",@"conversationId",[resulyDict objectForKey:@"group_id"],@"IsSingleChat",@"0"];
            }];
            if (conversationExistArr.count == 0) {//当没有该群组会话 则insert一条道 huihualiebiao
                NSDictionary *dic = @{@"group_id":[resulyDict objectForKey:@"group_id"],@"group_msg_content":[resulyDict objectForKey:@"group_msg_content"],@"last_message_id":[resulyDict objectForKey:@"group_msg_id"],@"group_msg_time":[resulyDict objectForKey:@"group_create_time"],@"group_name":[resulyDict objectForKey:@"group_name"],@"group_msg_type":@"normal",@"photo":[NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[resulyDict objectForKey:@"group_msg_sender_photo"]]};
                [self.fmdbServicee receiveGroupMessageChangeChatListCache:dic];
            }
            //刷新会话列表界面数据
            MessageChatListViewController *firstTabbarVC = (MessageChatListViewController *)[[ClearManager new] getRootViewControllerOfTabbarRootIndex:0];
            //如果该视图是会话列表界面 则让其刷新数据 下面再reload 如果不是则不需要考虑 因为在willappear时会进行核查
            [firstTabbarVC checkChatListCorrect];//核实会话列表数据是否正确
        }
        //当前页面不是消息或其子类界面 显示红点
        if (currentVC.navigationController.tabBarItem.tag != 1) {
            //当不在会话列表界面 则改变角标 并且不是自己发送的消息
            if (![sendName isEqualToString:[NFUserEntity shareInstance].userName]) {
                
                __block NSArray *groupDetailArr = [NSArray new];
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    groupDetailArr = [strongSelf ->jqFmdb jq_lookupTable:@"groupDetailliebiao" dicOrModel:[GroupCreateSuccessEntity class] whereFormat:[NSString stringWithFormat:@"where %@ = '%@'",@"groupId",[[resulyDict objectForKey:@"group_id"] description]]];
                }];
                GroupCreateSuccessEntity *entity= [groupDetailArr firstObject];
                if (![entity.allow_push isEqualToString:@"0"]) {
                    [[NFbaseViewController new] setBadgeCountWithCount:1 AndIsAdd:YES];
                }
                
//            进行缓存群组单次消息 messageFrame 这里需要缓存 因为当先收到其他人发的消息后 再收到web端自己发的消息 如果这里不缓存 那么自己发的消息则会在别人先发的消息上面
                //【这里不需要缓存了 因为收到自己web发的消息不回进行缓存】
//                UUMessageFrame *messageFrame = [MessageParser GotGroupNormalMessageContantParser:resulyDict];
//                MessageChatEntity *entity = [self.fmdbServicee UUMessageFrameToMessageChatEntity:messageFrame];
//                //插入数据到该群组表中
//                __weak typeof(self)weakSelf=self;
//                [jqFmdb jq_inDatabase:^{
//                    __strong typeof(weakSelf)strongSelf=weakSelf;
//                    BOOL rett = [strongSelf ->jqFmdb jq_insertTable:[NSString stringWithFormat:@"qunzu%@",[[resulyDict objectForKey:@"group_id"] description]] dicOrModel:entity];
//                    if (!rett) {
//                        [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
//                        return;
//                    }
//                }];
            }else{
                
                //从联系人群组进去转发名片会走到这里
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    //当为转发界面并且隐藏了tabbar 则为转发界面
                    //当增加转发图片功能 这里需要修改
                    if ((currentVC.tabBarController.tabBar.hidden && [currentVC isKindOfClass:[MessageChatListViewController class]]) ||[currentVC isKindOfClass:[GroupListViewController class]]) {
                        if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                            [self.delegate didReceiveMessage:@"" type:SecretLetterType_ReceiveGroupMessage];
                        }
                        return;
                    }else if([currentVC isKindOfClass:[GroupAddMemberViewController class]]){
                        if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                            [self.delegate didReceiveMessage:@"" type:SecretLetterType_ReceiveGroupMessage];
                        }
                        return;
                    }
                });
            }
        }else{
            //在会话列表界面 通知刷新会话列表 【请求并缓存、展示】
            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
            if (currentVC.tabBarController.tabBar.hidden == YES) {
                //当会话列表界面没有tabbar 则为转发界面
                if (![sendName isEqualToString:[NFUserEntity shareInstance].userName]) {
                    //当在聊天界面 并且不是与该群聊聊天 则发一个消息
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                            [self.delegate didReceiveMessage:@"" type:SecretLetterType_ReceiveGroupMessage];
                        }
                    });
                    //转发界面如果消息发送者和userid不是同一个人 说明只是收到了群消息 不是转发收到回执 不做处理s
                    return;
                }
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    //当为转发界面并且隐藏了tabbar 则为转发界面
                    //当增加转发图片功能 这里需要修改
                    if ((currentVC.tabBarController.tabBar.hidden && [currentVC isKindOfClass:[MessageChatListViewController class]]) ||[currentVC isKindOfClass:[GroupListViewController class]]) {
                        if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                            [self.delegate didReceiveMessage:@"" type:SecretLetterType_ReceiveGroupMessage];
                        }
                        return;
                    }else if([currentVC isKindOfClass:[GroupAddMemberViewController class]]){
                        if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                            [self.delegate didReceiveMessage:@"" type:SecretLetterType_ReceiveGroupMessage];
                        }
                        return;
                    }
                });
            }else{
                SecretLetterModel messageType = SecretLetterType_notifyRefreshChatSessionList;
                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [self.delegate didReceiveMessage:@"" type:messageType];
                    });
                }
            }
        }
    }
}


#pragma mark - 收到红包消息 群组
-(void)receiveRedpacketMessage:(NSDictionary *)resulyDict{
    //查看是否改名
    __weak typeof(self)weakSelf=self;
    __block NSArray *messageArr = [NSArray new];
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        messageArr = [jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunzu%@",[[resulyDict objectForKey:@"group_id"] description]] dicOrModel:[MessageChatEntity class] whereFormat:@"where %@ != '%@' and %@ = '%@' ",@"nickName",[resulyDict objectForKey:@"group_msg_sender_nick_name"],@"user_name",[[resulyDict objectForKey:@"group_msg_sender_name"] description]];
    }];
    //NSLog(@"messageArr = %@",messageArr);
    //for循环 将缓存改过来
    for (MessageChatEntity *entity in messageArr) {
        entity.nickName = [[resulyDict objectForKey:@"group_msg_sender_nick_name"] description];
        if (entity.localReceiveTimeString.length > 0 && entity.user_name.length > 0 ) {
            [jqFmdb jq_inDatabase:^{
                BOOL ret = [jqFmdb jq_updateTable:[NSString stringWithFormat:@"qunzu%@",[[resulyDict objectForKey:@"group_id"] description]] dicOrModel:entity whereFormat:@"where user_name = '%@' and localReceiveTimeString = '%@'",entity.user_name,entity.localReceiveTimeString];
                if (ret) {
                    NSLog(@"c更新成功");
                }else{
                    NSLog(@"c更新失败");
                }
            }];
        }
    }
    

    __block NSMutableArray *contacts = [NSMutableArray new];
    //这里重新去缓存联系人
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        contacts = [NSMutableArray arrayWithArray:[strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact class] whereFormat:@"where friend_userid = '%@'",[[resulyDict objectForKey:@"group_msg_sender"] description]]];
    }];
    if(contacts.count > 0){
        ZJContact *contacttt = [contacts firstObject];
        if(contacttt.friend_comment_name.length > 0){
            NSMutableDictionary *diccc = [NSMutableDictionary dictionaryWithDictionary:resulyDict];
            [diccc setValue:[[resulyDict objectForKey:@"group_msg_sender_nick_name"] description] forKey:@"group_msg_sender_original_name"];
            [diccc setValue:contacttt.friend_comment_name forKey:@"senderCommentName"];
            [diccc setValue:contacttt.friend_comment_name forKey:@"group_msg_sender_nick_name"];
            resulyDict = [NSDictionary dictionaryWithDictionary:diccc];
            
        }
    }
    
    //如果正在群组会话中
    if ([[NFUserEntity shareInstance].currentChatId isEqualToString:[[resulyDict objectForKey:@"group_id"] description]] && [[NFUserEntity shareInstance].isSingleChat isEqualToString:@"2"]) {
        //不能卸写在外面  因为里面有缓存图片，下面也会调用该方法 避免缓存两次 【单纯设置messageframe】
        dispatch_group_t group = dispatch_group_create();
        __block UUMessageFrame *messageFrame = [UUMessageFrame new];
        dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            dispatch_group_enter(group);
            messageFrame = [MessageParser GotGroupRedpacketMessageContantParser:resulyDict];
            dispatch_group_leave(group);
        });
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        //回到会话界面设置刷新会话列表
        [NFUserEntity shareInstance].isNeedRefreshLocalChatList = YES;
#pragma msrk - 设置群消息已读
        [self readedGroupRequest:[resulyDict objectForKey:@"group_msg_id"] AndGroupId:[resulyDict objectForKey:@"group_id"]];
        if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
            dispatch_queue_t mainQueue = dispatch_get_main_queue();
            dispatch_async(mainQueue, ^{
                [self.delegate didReceiveMessage:messageFrame type:SecretLetterType_ReceiveGroupMessage];
            });
        }
    }else{
        // 收到红包消息 当没有在群聊界面 让会话界面处理这个逻辑 【会话列表就是显示一下最后一条消息 具体缓存在进入聊天做】
        jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
        __block NSArray *groupArrs = [NSArray new];
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            groupArrs = [strongSelf ->jqFmdb jq_lookupTable:@"groupDetailliebiao" dicOrModel:[GroupCreateSuccessEntity class] whereFormat:@"where groupId = '%@'",[resulyDict objectForKey:@"group_id"]];
        }];
        BOOL IsAllowPush = YES;
        if(groupArrs.count > 0){
            GroupCreateSuccessEntity *pushCheckEntity = [groupArrs firstObject];
            if ([pushCheckEntity.allow_push isEqualToString:@"0"]) {
                IsAllowPush = NO;
            }
        }
        
        NSString *sendName =[[resulyDict objectForKey:@"group_msg_sender_name"] description];
        if (![sendName isEqualToString:[NFUserEntity shareInstance].userName] && IsAllowPush) {
            [self.myManage notifySet];
        }
        
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
        [self.fmdbServicee IsExistGroupChatHistory:[[resulyDict objectForKey:@"group_msg_sender"] description] ISNeedAppend:YES];
        [NFUserEntity shareInstance].isNeedRefreshChatData = YES;//记录刷新会话列表
        [NFUserEntity shareInstance].isNeedRefreshGroupChatHistory = YES;
        
        dispatch_group_t group = dispatch_group_create();
        __block UUMessageFrame *messageFrame = [UUMessageFrame new];
        dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            dispatch_group_enter(group);
            messageFrame = [MessageParser GotGroupRedpacketMessageContantParser:resulyDict];
            dispatch_group_leave(group);
        });
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        
        MessageChatEntity *entity = [self.fmdbServicee UUMessageFrameToMessageChatEntity:messageFrame];
        
        __weak typeof(self)weakSelf=self;
        
        __block NSArray *lastArr = [NSArray new];
        __block int dataaCount = 0;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            //userId = userId order by id desc limit 5
            dataaCount = [strongSelf ->jqFmdb jq_tableItemCount:[NSString stringWithFormat:@"qunzu%@",[[resulyDict objectForKey:@"group_id"] description]]];
            lastArr = [strongSelf ->jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunzu%@",[[resulyDict objectForKey:@"group_id"] description]] dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"limit %d,%d",dataaCount - 1,1]];
            
        }];
        //重复消息
        if(lastArr.count == 1){
            MessageChatEntity *lastEntity = [lastArr firstObject];
            if ([entity.chatId isEqualToString:lastEntity.chatId] && entity.chatId.length > 0) {
                //如果有相同消息 则return
                return;
            }
        }
        
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            BOOL rett = [strongSelf ->jqFmdb jq_insertTable:[NSString stringWithFormat:@"qunzu%@",[[resulyDict objectForKey:@"group_id"] description]] dicOrModel:entity];
            if (!rett) {
                [SVProgressHUD showInfoWithStatus:@"缓存消息失败"];
                return;
            }
        }];
        
        
        if (currentVC.navigationController.tabBarItem.tag != 1) {
            //当不在会话列表界面 则改变角标 并且不是自己发送的消息
            if (![sendName isEqualToString:[NFUserEntity shareInstance].userName]) {
                __block NSArray *groupDetailArr = [NSArray new];
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    groupDetailArr = [strongSelf ->jqFmdb jq_lookupTable:@"groupDetailliebiao" dicOrModel:[GroupCreateSuccessEntity class] whereFormat:[NSString stringWithFormat:@"where %@ = '%@'",@"groupId",[[resulyDict objectForKey:@"group_id"] description]]];
                }];
                GroupCreateSuccessEntity *entity= [groupDetailArr firstObject];
                if (![entity.allow_push isEqualToString:@"0"]) {
                    [[NFbaseViewController new] setBadgeCountWithCount:1 AndIsAdd:YES];
                }
            }else{
                SecretLetterModel messageType = SecretLetterType_notifyRefreshChatSessionList;
                if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                    dispatch_queue_t mainQueue = dispatch_get_main_queue();
                    dispatch_async(mainQueue, ^{
                        [self.delegate didReceiveMessage:@"" type:messageType];
                    });
                }
            }
        }else{
            //在会话列表界面 通知刷新
            SecretLetterModel messageType = SecretLetterType_notifyRefreshChatSessionList;
            if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
                dispatch_queue_t mainQueue = dispatch_get_main_queue();
                dispatch_async(mainQueue, ^{
                    [self.delegate didReceiveMessage:@"" type:messageType];
                });
            }
            
        }
        
    }
    
}


#pragma mark - 收到领取红包消息
-(void)receiveGroupRedRobedMessage:(NSDictionary *)resulyDict{
    if ([[NFUserEntity shareInstance].currentChatId isEqualToString:[[resulyDict objectForKey:@"group_id"] description]] && [[NFUserEntity shareInstance].isSingleChat isEqualToString:@"2"]) {
        //不能卸写在外面  因为里面有缓存图片，下面也会调用该方法 避免缓存两次 【单纯设置messageframe】
        dispatch_group_t group = dispatch_group_create();
        __block UUMessageFrame *messageFrame = [UUMessageFrame new];
        dispatch_sync(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            dispatch_group_enter(group);
            messageFrame = [MessageParser GotGroupNormalMessageContantParser:resulyDict];
            dispatch_group_leave(group);
        });
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        //回到会话界面设置刷新会话列表
        [NFUserEntity shareInstance].isNeedRefreshLocalChatList = YES;
#pragma msrk - 设置群消息已读
        [self readedGroupRequest:[resulyDict objectForKey:@"group_msg_id"] AndGroupId:[resulyDict objectForKey:@"group_id"]];
        if ([self.delegate respondsToSelector:@selector(didReceiveMessage:type:)]) {
            dispatch_queue_t mainQueue = dispatch_get_main_queue();
            dispatch_async(mainQueue, ^{
                [self.delegate didReceiveMessage:messageFrame type:SecretLetterType_ReceiveGroupMessage];
            });
        }
    }
    
    
    
}



#pragma mark - 发送单聊消息的回执
-(NSDictionary *)whenReveiveSingleMessageBackLetter:(NSDictionary *)dataDict{
    NSDictionary *returnDcit = [NSDictionary new];
    NSString *type = @"";
    if (![[dataDict objectForKey:@"msgType"] isKindOfClass:[NSString class]] || [[dataDict objectForKey:@"msgType"] isEqualToString:@"normal"]) {
        type = @"0";
        //                BOOL ret = [ClearManager stringContainsEmoji:[[dataDict objectForKey:@"messageContent"] description]];
        NSString *content;
        //是否含有表情 通过是否含有[]判断绝大多数情况
//        if ([[dataDict objectForKey:@"messageContent"] containsString:@"["] && [[dataDict objectForKey:@"messageContent"] containsString:@"]"]) {
//            content = [EmojiShift stringShiftemoji:[[dataDict objectForKey:@"messageContent"] description]];
//        }else{
            content = [[dataDict objectForKey:@"messageContent"] description];
//        }
        NSString *IsServerString = @"";
        
        if ([[[dataDict objectForKey:@"msgClient"] description] isEqualToString:@"web"]) {
            IsServerString = @"1";
        }else{
            IsServerString = @"0";
        }
        returnDcit = @{@"chatId":[[dataDict objectForKey:@"messageId"] description],@"strContent":content,@"type":type,@"userName":[[dataDict objectForKey:@"toName"] description],@"nickName":[[dataDict objectForKey:@"toNickName"] description],@"userId":[[dataDict objectForKey:@"toId"] description],@"appMsgId":[[dataDict objectForKey:@"appMsgId"] description],@"IsServer":IsServerString};
    }else if ([[dataDict objectForKey:@"msgType"] isEqualToString:@"image"]){
        type = @"1";
//        returnDcit = @{@"chatId":[[dataDict objectForKey:@"messageId"] description],@"picture": [ClearManager Base64StringToImage:[dataDict objectForKey:@"messageContent"]],@"type":type,@"userName":[[dataDict objectForKey:@"toName"] description],@"nickName":[[dataDict objectForKey:@"toNickName"] description],@"userId":[[dataDict objectForKey:@"toId"] description]};
        if ([dataDict objectForKey:@"fileInfo"]) {
            NSDictionary *fileInfo = [dataDict objectForKey:@"fileInfo"];
            NSString *IsServerString = @"";
            if ([[[dataDict objectForKey:@"msgClient"] description] isEqualToString:@"web"]) {
                IsServerString = @"1";
            }else{
                IsServerString = @"0";
            }
            returnDcit = @{@"chatId":[[dataDict objectForKey:@"messageId"] description],@"picture": [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[fileInfo objectForKey:@"filePath"]],@"type":type,@"userName":[[dataDict objectForKey:@"toName"] description],@"nickName":[[dataDict objectForKey:@"toNickName"] description],@"userId":[[dataDict objectForKey:@"toId"] description],@"imgRatio":[[fileInfo objectForKey:@"imgRatio"] description],@"fileId":[[fileInfo objectForKey:@"fileId"] description],@"appMsgId":[[dataDict objectForKey:@"appMsgId"] description],@"IsServer":IsServerString};
        }else{
            NSString *IsServerString = @"";
            if ([[[dataDict objectForKey:@"msgClient"] description] isEqualToString:@"web"]) {
                IsServerString = @"1";
            }else{
                IsServerString = @"0";
            }
            returnDcit = @{@"chatId":[[dataDict objectForKey:@"messageId"] description],@"picture": [dataDict objectForKey:@"messageContent"],@"type":type,@"userName":[[dataDict objectForKey:@"toName"] description],@"nickName":[[dataDict objectForKey:@"toNickName"] description],@"userId":[[dataDict objectForKey:@"toId"] description],@"imgRatio":@"1",@"appMsgId":[[dataDict objectForKey:@"appMsgId"] description],@"IsServer":IsServerString};
        }
    }else if ([[dataDict objectForKey:@"msgType"] isEqualToString:@"audio"]){
        type = @"2";
        NSString *voiceTime = [[dataDict objectForKey:@"audioTime"] description];
        if (voiceTime.length == 0) {
            voiceTime = @"";
        }
        NSString *IsServerString = @"";
        if ([[[dataDict objectForKey:@"msgClient"] description] isEqualToString:@"web"]) {
            IsServerString = @"1";
        }else{
            IsServerString = @"0";
        }
        returnDcit = @{@"chatId":[[dataDict objectForKey:@"messageId"] description],@"voice":[[NSData alloc] initWithBase64Encoding:[dataDict objectForKey:@"messageContent"]],@"type":type,@"userName":[[dataDict objectForKey:@"toName"] description],@"nickName":[[dataDict objectForKey:@"toNickName"] description],@"userId":[[dataDict objectForKey:@"toId"] description],@"strVoiceTime":voiceTime,@"appMsgId":[[dataDict objectForKey:@"appMsgId"] description],@"IsServer":IsServerString};
    }
    return returnDcit;
}

//会话列表 检查是否需要请求历史记录
-(NSArray *)checkIsNotRequestHistory:(NSArray *)arr{
    NSMutableArray *backArr = [NSMutableArray new];
    for (MessageChatListEntity *entity in arr) {
        if([entity.unread_message_count integerValue] > 0 || [entity.msgType isEqualToString:@"system"]){
            //检查最后一条消息 有没有被缓存。如果缓存了 则改 遍历请求为NO
            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
            if (entity.IsSingleChat && ![entity.IsNotRequestHistory isEqualToString:@"1"]) {
                __block NSArray *arr = [NSArray new];
                [jqFmdb jq_inDatabase:^{
                    arr = [jqFmdb jq_lookupTable:entity.conversationId dicOrModel:[MessageChatEntity class] whereFormat:@"where chatId = '%@'",entity.last_message_id];
                }];
                if (arr.count > 0) {
                    //如果有 则说明已经缓存 下次不再请求
                    //IsRequestHistory
                    entity.IsNotRequestHistory = @"1";
                }
            }else if(!entity.IsSingleChat && ![entity.IsNotRequestHistory isEqualToString:@"1"]){
                
                __block NSArray *arr = [NSArray new];
                [jqFmdb jq_inDatabase:^{
                    arr = [jqFmdb jq_lookupTable:[NSString stringWithFormat:@"qunzu%@",entity.conversationId] dicOrModel:[MessageChatEntity class] whereFormat:@"where chatId = '%@'",entity.last_message_id];
                }];
                if (arr.count > 0) {
                    //如果有 则说明已经缓存 下次不再请求
                    //IsRequestHistory
                    entity.IsNotRequestHistory = @"1";
                    
                }
            }
            [backArr addObject:entity];
        }
    }
    return backArr;
}

//懒加载 fmdbServicee
-(FMDBService *)fmdbServicee{
    if (!_fmdbServicee) {
        _fmdbServicee = [[FMDBService alloc] init];
    }
    return _fmdbServicee;
}
//懒加载
-(NSMutableDictionary *)parms{
    if (!_parms) {
        _parms = [[NSMutableDictionary alloc] init];
    }
    if (![_parms isKindOfClass:[NSMutableDictionary class]]) {
        _parms = [[NSMutableDictionary alloc] init];
    }
    
    return _parms;
}

//GroupCreateSuccessEntity *groupCreateSuccess;
-(GroupCreateSuccessEntity *)groupCreateSuccess{
    if (!_groupCreateSuccess) {
        _groupCreateSuccess = [[GroupCreateSuccessEntity alloc] init];
    }
    return _groupCreateSuccess;
}

-(NFMyManage *)myManage{
    if (!_myManage) {
        _myManage = [[NFMyManage alloc] init];
    }
    return _myManage;
}
#pragma mark - 收到消息提示群组或单聊
-(void)showMessagePopView:(MessageChatListEntity *)message{
    //接收到消息
    //显示前先重置
    //主线程修改界面
    [[FLStatusBarHUD shareStatusBar] fl_reset];
    FLAnimationDirection type = FLAnimationDirectionFromTop;
    [FLStatusBarHUD shareStatusBar].animationDirection = type;
    [FLStatusBarHUD shareStatusBar].statusBarHeight = 64;
    [FLStatusBarHUD shareStatusBar].messageDuration = 3.5;
    //当是自定义的view 这里设置则无效
    [FLStatusBarHUD shareStatusBar].messageColor = [UIColor redColor];
    [FLStatusBarHUD shareStatusBar].messageFont = [UIFont systemFontOfSize:9];
    [FLStatusBarHUD shareStatusBar].position = CGPointMake(0, 64);
    popView = [[[NSBundle mainBundle]loadNibNamed:@"PopMessageView" owner:nil options:nil] firstObject];
    popView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 50);
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
    //    [currentVC.view addSubview:popView];
    popView.nameLabel.text = message.nickName;
    popView.nameLabel.textColor = [UIColor blackColor];
    //    popView.nameLabel.font = [UIFont systemFontOfSize:16];
    popView.messageContant.text = message.messageContant;
    popView.messageContant.textColor = [UIColor blackColor];
    [popView.headImageV sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
    popView.backgroundColor = SecondGray;
    popView.alpha = 0.7;
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        [[FLStatusBarHUD shareStatusBar] fl_showCustomView:popView atView:currentVC.view animateDirection:type autoDismiss:_flag];
        //搜索栏-拷贝 设置背景图片
        //    [FLStatusBarHUD shareStatusBar].backgroundImage = [UIImage imageNamed:@"登陆确认button"];
        
    });
    if (_clicked) {
        //当点击了提醒框
        [FLStatusBarHUD shareStatusBar].statusBarTapOpreationBlock = ^{
            [[FLStatusBarHUD shareStatusBar] fl_hide];
            //            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"点我啦" message:nil delegate:nil cancelButtonTitle:@"恩恩~" otherButtonTitles:nil];
            //            [alertView show];
            //            NSLog(@"%@",message.receive_user_name);
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
            if (message.IsSingleChat) {
                JQFMDB *jqFmdb = [JQFMDB shareDatabase];
                __block NSArray *arrss = [NSArray new];
                __weak typeof(self)weakSelf=self;
                [jqFmdb jq_inDatabase:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    arrss = [strongSelf ->jqFmdb jq_lookupTable:message.conversationId dicOrModel:[MessageChatEntity class] whereFormat:@""];
                }];
                MessageChatViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"MessageChatViewController"];
                toCtrol.titleName = message.nickName;
                toCtrol.conversationId = message.conversationId;
                ZJContact *contact = [ZJContact new];
//                contact.chatId = message.conversationId;
                contact.friend_username = message.receive_user_name;
                contact.friend_nickname = message.nickName;
                contact.friend_userid = message.conversationId;
                toCtrol.singleContactEntity = contact;
//                toCtrol.group = message.receive_user_name;
                UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
                [currentVC.navigationController pushViewController:toCtrol animated:YES];
            }else{
                GroupChatViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"GroupChatViewController"];
                //                toCtrol.titleName = message.receive_user_name;
                toCtrol.conversationId = message.conversationId;
                self.groupCreateSuccess.groupId = message.conversationId;
                self.groupCreateSuccess.groupName = message.nickName;
                //主要使用
                toCtrol.groupCreateSEntity = self.groupCreateSuccess;
                toCtrol.groupName = message.nickName;
                UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
                [currentVC.navigationController pushViewController:toCtrol animated:YES];
            }
        };
    }
}



-(void)quitttt{
    
    //请求人列表获取
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"userLogout";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [self ping];
    [self sendMsg:Json];
    
}

#pragma mark - 登陆
- (void)loginWithDefaultType
{
   // [self quitttt];
    
    [NFUserEntity shareInstance].userType = NFUserGeneral;
    loginRequestTime += 1;
    NSString *phone = [KeepAppBox checkValueForkey:kLoginUserName];
    NSString *password = [KeepAppBox checkValueForkey:kLoginPassWord];
    [self.parms removeAllObjects];
    self.parms[@"username"] = phone;
    if (password.length == 0) {
        return;
    }
    NSString *pwd = [Data_MD5 MD5ForUpper32Bate:password];
//    NSLog(@"上传服务器验证的密码:%@",pwd);
    self.parms[@"password"] = pwd;
    self.parms[@"action"] = @"userLogin";
    self.parms[@"adCode"] = [SystemInfo shareSystemInfo].deviceId; //广告码
    self.parms[@"phoneType"] = [SystemInfo shareSystemInfo].deviceType;//设备类型
    self.parms[@"osVersion"] = [SystemInfo shareSystemInfo].OSVersion;//系统版本
//    self.parms[@"loginIp"] = [SystemInfo shareSystemInfo].DeviceIPAddresses;//ip地址
    self.parms[@"loginIp"] = [NFUserEntity shareInstance].netIP.length > 0?[NFUserEntity shareInstance].netIP:[SystemInfo shareSystemInfo].DeviceIPAddresses;//ip地址
    
    self.parms[@"apns_production"] = APNSEnvironmental;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    //for 循环请求 当连接时候进行发送
    [self ping];
    [self sendMessageWith:Json];
    
}

#pragma mark - 不做任何连接判断 强行连接
-(void)loginWithDefaultTypeStrong{
    [NFUserEntity shareInstance].userType = NFUserGeneral;
    NSString *phone = [KeepAppBox checkValueForkey:kLoginUserName];
    NSString *password = [KeepAppBox checkValueForkey:kLoginPassWord];
    [self.parms removeAllObjects];
    self.parms[@"username"] = phone;
    if (!password) {
        return;
    }
    NSString *pwd = [Data_MD5 MD5ForUpper32Bate:password];
    //    NSLog(@"上传服务器验证的密码:%@",pwd);
    self.parms[@"password"] = pwd;
    self.parms[@"action"] = @"userLogin";
    self.parms[@"adCode"] = [SystemInfo shareSystemInfo].deviceId; //广告码
    self.parms[@"phoneType"] = [SystemInfo shareSystemInfo].deviceType;//设备类型
    self.parms[@"osVersion"] = [SystemInfo shareSystemInfo].OSVersion;//系统版本
//    self.parms[@"loginIp"] = [SystemInfo shareSystemInfo].DeviceIPAddresses;//ip地址
    self.parms[@"loginIp"] = [NFUserEntity shareInstance].netIP.length > 0?[NFUserEntity shareInstance].netIP:[SystemInfo shareSystemInfo].DeviceIPAddresses;//ip地址
    self.parms[@"apns_production"] = APNSEnvironmental;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
//    NSLog(@"%d",self.webSocket.readyState);
    if (self.webSocket.readyState == 0) {
        NSLog(@"loginWithDefaultTypeStrong 111");
        [self initSocket];
    }else{
        NSLog(@"loginWithDefaultTypeStrong 2222");
        [self sendMsg:Json];
    }
}

#pragma mark - 微信登录
-(void)weixinLoginRequest{
    [NFUserEntity shareInstance].userType = NFUserWX;
    loginRequestTime += 1;
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"wxLogin";
    
//    self.parms[@"headimgurl"] = [userInfo objectForKey:@"headimgurl"];
//    self.parms[@"nickname"] = [userInfo objectForKey:@"nickname"];
//    self.parms[@"openid"] = [userInfo objectForKey:@"openid"];
    
    self.parms[@"headimgurl"] = [KeepAppBox checkValueForkey:kLoginWeixinUserHeadIcon]?[KeepAppBox checkValueForkey:kLoginWeixinUserHeadIcon]:@"";
    self.parms[@"nickname"] = [KeepAppBox checkValueForkey:kLoginWeixinUserNickName]?[KeepAppBox checkValueForkey:kLoginWeixinUserNickName]:@"";
    NSString *weixinId = [KeepAppBox checkValueForkey:kLoginWeixinUserName];
    if (weixinId.length > 0) {
        self.parms[@"openid"] = weixinId;
    }else{
        return;
    }
    self.parms[@"openid"] = weixinId;
    
    self.parms[@"adCode"] = [SystemInfo shareSystemInfo].deviceId; //广告码
    self.parms[@"phoneType"] = [SystemInfo shareSystemInfo].deviceType;//设备类型
    self.parms[@"osVersion"] = [SystemInfo shareSystemInfo].OSVersion;//系统版本
//    self.parms[@"loginIp"] = [SystemInfo shareSystemInfo].DeviceIPAddresses;//ip地址
    self.parms[@"loginIp"] = [NFUserEntity shareInstance].netIP.length > 0?[NFUserEntity shareInstance].netIP:[SystemInfo shareSystemInfo].DeviceIPAddresses;//ip地址
    
    self.parms[@"apns_production"] = APNSEnvironmental;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    if (self.webSocket.readyState == 0) {
        [self initSocket];
    }else{
        [self sendMsg:Json];
    }
}

#pragma mark - 请求好友列表
-(void)getFriendList{
    [self.parms removeAllObjects];
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"action"] = @"getFriendList";
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [self ping];
    if ([self isConnected]) {
        [self sendMsg:Json];
    }else{
    }
}

#pragma mark - 为了重新建立服务器链接
-(void)getAddFriendList{
    //请求人列表获取
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"getFriendRequestUnread";
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [self ping];
    if ([self isConnected]) {
        [self sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

-(NSString *) getIPWithHostName:(const NSString *)hostName
{
    struct addrinfo * result;
    struct addrinfo * res;
    char ipv4[128];
    char ipv6[128];
    int error;
    BOOL IS_IPV6 = FALSE;
    bzero(&ipv4, sizeof(ipv4));
    bzero(&ipv4, sizeof(ipv6));
    
    error = getaddrinfo([hostName UTF8String], NULL, NULL, &result);
    if(error != 0) {
        NSLog(@"error in getaddrinfo:%d", error);
        return nil;
    }
    for(res = result; res!=NULL; res = res->ai_next) {
        char hostname[1025] = "";
        error = getnameinfo(res->ai_addr, res->ai_addrlen, hostname, 1025, NULL, 0, 0);
        if(error != 0) {
            NSLog(@"error in getnameifno: %s", gai_strerror(error));
            continue;
        }
        else {
            switch (res->ai_addr->sa_family) {
                case AF_INET:
                    memcpy(ipv4, hostname, 128);
                    break;
                case AF_INET6:
                    memcpy(ipv6, hostname, 128);
                    IS_IPV6 = TRUE;
                default:
                    break;
            }
//            NSLog(@"hostname: %s ", hostname);
        }
    }
    freeaddrinfo(result);
    if(IS_IPV6 == TRUE) {
//        NSLog(@"%@",[NSString stringWithUTF8String:ipv6]);
        return [NSString stringWithUTF8String:ipv6];
    }
//    NSLog(@"%@",[NSString stringWithUTF8String:ipv4]);
    return [NSString stringWithUTF8String:ipv4];
}

//connectStatus :1断开 2接受中 0成功
-(void)showBreak{
    [NFUserEntity shareInstance].connectStatus = @"1";
    [[NSNotificationCenter defaultCenter] postNotificationName:@"connectBreak" object:@{@"connectStatus":@"1"}];
    
}

-(void)showConnecting{
    [NFUserEntity shareInstance].connectStatus = @"1";
    [[NSNotificationCenter defaultCenter] postNotificationName:@"connectBreak" object:@{@"connectStatus":@"2"}];
    
}

-(void)connectSuccess{
    [NFUserEntity shareInstance].connectStatus = @"0";
    [[NSNotificationCenter defaultCenter] postNotificationName:@"connectBreak" object:@{@"connectStatus":@"0"}];
}



@end
