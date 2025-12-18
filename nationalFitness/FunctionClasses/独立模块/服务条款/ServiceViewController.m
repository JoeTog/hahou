//
//  ServiceViewController.m
//  nationalFitness
//
//  Created by 童杰 on 2016/12/19.
//  Copyright © 2016年 chenglong. All rights reserved.
//

#import "ServiceViewController.h"
#import <WebKit/WebKit.h>


#import "SocketModel.h"
#import "SocketRequest.h"



@interface ServiceViewController ()<UITextViewDelegate,WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler,ChatHandlerDelegate>{
    
    __weak IBOutlet UITextView *serviceTextView;
    
    
    __weak IBOutlet UIButton *backBtn;
    
    
    
}

@property(nonatomic,strong)WKWebView *webView;
@property(nonatomic,strong)UIProgressView *progressView;

@end

@implementation ServiceViewController{
    
    SocketModel * socketModel;
    SocketRequest *socketRequest;
    
    BOOL IsAllOver;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (socketModel.delegate != self) {
        socketModel.delegate = self;
    }
    
    [self initScoket];
    
    
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
            //余额查询
            //[socketRequest accountDetail];
            
        }else{
            //设置本地数据
        }
    }else{
        //设置本地数据
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"服务条款";
    if (self.isPay) {
        self.title = @"充值";
    }else if (self.isCash){
        self.title = @"提现";
    }else if (self.isPassword){
        self.title = @"充值提现密码";
    }else if (self.isCancelPwd){
        self.title = @"授权免密支付";
    }
    if (self.isShowBack) {
        backBtn.hidden = NO;
    }else{
        backBtn.hidden = YES;
    }
    
    [self initUI];
    
    if(self.isFouBack){
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 100, 45)];
        [button setTitle:@"返回" forState:(UIControlStateNormal)];
        [button setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        button.backgroundColor = [UIColor lightGrayColor];
        [button addTarget:self action:@selector(backkkk) forControlEvents:(UIControlEventTouchUpInside)];
        [self.view addSubview:button];
        
    }
    
    
    serviceTextView.hidden = YES;
    serviceTextView.delegate = self;
    serviceTextView.text = @"服务条款，，服务条款，，服务条款，，";
    serviceTextView.showsVerticalScrollIndicator = NO;
//    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 34)];
//    [backBtn setImage:[UIImage imageNamed:@"FH_"] forState:UIControlStateNormal];
//    [backBtn addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
//    self.navigationItem.leftBarButtonItem = backButtonItem;
    
    
    
}

//- (void)backClicked
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}

- (void)backClicked:(id)sender
{
    
//    if (!IsAllOver) {
//        //如果没有全部完成 则不允许退出
//        [SVProgressHUD showInfoWithStatus:@"请依次完成设置密码、免密支付操作"];
//        return;
//    }
    
    if(self.isPay || self.isCash || self.isPassword || self.isCancelPwd){
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您确认结束本次操作么？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionCannel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            return ;
        }];
        UIAlertAction *actionSure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }];
        [alertController addAction:actionSure];
        [alertController addAction:actionCannel];
        [self presentViewController:alertController animated:YES completion:nil];
        
        
    }else{
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}



//原生 返回按钮 直接返回
- (IBAction)backBtnClick:(id)sender {
    
    
    [self.navigationController popViewControllerAnimated:YES];
    
    
    
}

-(void)backkkk{
    
    
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
    
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return NO;
}

-(void)initUI{
    //dushiluolin
    NSString *path = [[NSBundle mainBundle] pathForResource:@"dushiluolin" ofType:@"docx"];
    NSURL *url = [NSURL fileURLWithPath:path];
    
   // if(!_webView){
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT)];
    //}
    if (self.isPay || self.isCash || self.isPassword || self.isCancelPwd) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - kTopHeight)];
    }
    //[_webView loadRequest:[NSURLRequest requestWithURL:url]];
    [_webView sizeToFit];
    //    _webView.sizeToFit = YES;
    _webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    [self.view addSubview:_webView];
    
    if (self.isPay|| self.isCash || self.isPassword || self.isCancelPwd) {
        //跳转到网页
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.requestUrl]]];
        
        
    }else{
        [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
    
    
    
    //进度条
    //if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 1, JOESIZE.width, 2)];
    //}
//    _progressView.backgroundColor = [UIColor colorThemeColor];
//    _progressView.tintColor = [UIColor colorThemeColor];
    _progressView.progressTintColor = [UIColor colorThemeColor];
    [self.view addSubview:_progressView];
    //为wkwebview添加观察者，观察estimatedProgress。
    [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
}

//观察者方法
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"estimatedProgress"]&&object == _webView) {
        [self.progressView setAlpha:1.0f];
        [self.progressView setProgress:_webView.estimatedProgress animated:YES];
        if (_webView.estimatedProgress == 1.0f) {
            [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
            //加载完毕后
        }
        
        if (_webView.estimatedProgress >= 0.8) {
            [SVProgressHUD dismiss];
        }
        
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *urlString = [[navigationAction.request URL] absoluteString];
    //NSLog(@"%@",urlString);
    urlString = [urlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //https://hfpay.testpnr.com/api/hfpayweb/integrationApp/result?mer_cust_id=6666000000134024
    
    //https://hfpay.testpnr.com/api/acou/pwd007
    if ([urlString containsString:@"/hfpayweb/integrationApp/result?"]) {
        //查询密码设置
        //请求个人信息
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           // [socketRequest requestPersonalInfoWithID:[NFUserEntity shareInstance].userId];
        });
        
    }else if ([urlString containsString:@"/acouweb/pwdSet/result?"]){
        //设置密码完成后 授权
        NSLog(@"sa");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //[socketRequest shouquanOut:@{}];
        });
        
        //跳转带授权
        
        
    }
    
    
    decisionHandler(WKNavigationActionPolicyAllow);
    
    
    return;
    if ([urlString containsString:@"weixin://wap/pay?"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        //解决wkwebview weixin://无法打开微信客户端的处理
        NSURL *url = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:url];
        //[[UIApplication sharedApplication]openURL:url options:@{UIApplicationOpenURLOptionUniversalLinksOnly: @NO} completionHandler:^(BOOL success) {
        
        //        }];
    }else{
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

//第一次支付成功
//https://hfpay.testpnr.com/api/hfpayweb/integrationApp/result?mer_cust_id=6666000000134024

//https://hfpay.testpnr.com/api/acou/pwd007



#pragma mark - 服务器返回
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    
    if (messageType == SecretLetterType_checkGet) {
        NSDictionary *dict = chatModel;
        if ([[[dict objectForKey:@"type"] description] isEqualToString:@"pwd"]){
            
            //isPassword
            self.isPay = NO;
            self.isCash = NO;
            self.isPassword = NO;
            self.isCancelPwd = NO;
            self.isPassword = YES;
            if (self.isPay) {
                self.title = @"充值";
            }else if (self.isCash){
                self.title = @"提现";
            }else if (self.isPassword){
                self.title = @"充值提现密码";
            }else if (self.isCancelPwd){
                self.title = @"授权免密支付";
            }
            [SVProgressHUD showWithStatus:@"加载中..."];
            self.requestUrl = [NSString stringWithFormat:@"http://121.43.116.159:7999/web_file/index.php/Huifu/Huifu/pay?check_value=%@&type=pwd",[dict objectForKey:@"check_value"]];
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.requestUrl]]];
            
        }else if ([[[dict objectForKey:@"type"] description] isEqualToString:@"nopwd"]){
            
            self.isPay = NO;
            self.isCash = NO;
            self.isPassword = NO;
            self.isCancelPwd = NO;
            self.isCancelPwd = YES;
            if (self.isPay) {
                self.title = @"充值";
            }else if (self.isCash){
                self.title = @"提现";
            }else if (self.isPassword){
                self.title = @"充值提现密码";
            }else if (self.isCancelPwd){
                self.title = @"授权免密支付";
            }
            
            IsAllOver = YES;
            
            [SVProgressHUD showWithStatus:@"加载中..."];
            self.requestUrl = [NSString stringWithFormat:@"http://121.43.116.159:7999/web_file/index.php/Huifu/Huifu/pay?check_value=%@&type=nopwd",[dict objectForKey:@"check_value"]];
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.requestUrl]]];
        }
        
    }else if(messageType == SecretLetterType_PersonalInfoDetail){
        
        PersonalInfoDetailEntity *personalinfo = chatModel;
        if(!personalinfo.isSetPwd){
            //没设置支付密码 跳转到网页设置密码
            if (socketModel.isConnected) {
                [socketModel ping];
                if (socketModel.isConnected) {
                    [socketRequest cashPassword];
                }else{
                    //设置本地数据
                }
            }
        }
        
    }else if(messageType == SecretLetterType_kaihuSuccess){
        NSLog(@"");
        
        //子账户相关
        LWWeChatActionSheet *sheet = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:@"请选择开户类型" otherButtonTitles:[NSArray arrayWithObjects:@"第一次开户",@"将此账户设置为子账户", nil] btnClickBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                
            }else if (buttonIndex == 1){
                
                NSMutableDictionary *sendDic = [[NSMutableDictionary alloc] initWithCapacity:8];
                [sendDic setObject:[NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].userId,[NFUserEntity shareInstance].nickName] forKey:@"acct_name"];
                //                        NSString *dev_info_json = [NSString stringWithFormat:@"{'ipAddr':'10.99.195.11','devType':'iOS','phoneName':'%@','phoneSystemName':'%@','phoneSystemVersion':'%@','ipAddr':'10.99.195.11','devType':'2','MAC':'D4-81-D7-F0-42-F8','IMEI':'3553200846666033'}",[[UIDevice currentDevice] name],[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] systemVersion]];
                //                        [sendDic setObject:dev_info_json forKey:@"dev_info_json"];
                
                if (socketModel.isConnected) {
                    [socketModel ping];
                    if (socketModel.isConnected) {
                        [socketRequest SubAccountRequest:sendDic];
                    }else{
                        //设置本地数据
                    }
                }else{
                    //设置本地数据
                    
                }
            }
        }];
        [sheet show];
        
        
    }
    
    
}


-(void)dealloc{
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [_webView setNavigationDelegate:nil];
    [_webView setUIDelegate:nil];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
