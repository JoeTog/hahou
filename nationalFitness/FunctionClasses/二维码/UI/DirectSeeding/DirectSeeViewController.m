//
//  DirectSeeViewController.m
//  nationalFitness
//
//  Created by 程龙 on 15/4/27.
//  Copyright (c) 2015年 chenglong. All rights reserved.
//

#import "DirectSeeViewController.h"

#import <WebKit/WebKit.h>


@interface DirectSeeViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>
{
    __weak IBOutlet UIWebView *webView_;
    
    
    
    
    
    
    UIButton *backBtn;
}

@property(nonatomic,strong)UIProgressView *progressView;
@property(nonatomic,strong)WKWebView *webView;


@end

@implementation DirectSeeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"详情";
    [self initUi];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"\n\n\n\n\ndidReceiveMemoryWarning\n\n\n\n\n");
    // Dispose of any resources that can be recreated.
}

- (void)initUi
{
    
    
    backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 24, 24)];
    [backBtn setImage:[UIImage imageNamed:@"NavBack"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    
    UIButton *closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 24)];
    closeBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *closeBtnItem = [[UIBarButtonItem alloc]initWithCustomView:closeBtn];
    
    self.navigationItem.leftBarButtonItem = backButtonItem;
    self.navigationItem.rightBarButtonItem = closeBtnItem;
    
    
    

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

    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"dushiluolin" ofType:@"docx"];
     NSURL *url = [NSURL fileURLWithPath:path];
     
    // if(!_webView){
         _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT)];
     //}
    
     //[_webView loadRequest:[NSURLRequest requestWithURL:url]];
     [_webView sizeToFit];
     //    _webView.sizeToFit = YES;
     _webView.UIDelegate = self;
     self.webView.navigationDelegate = self;
     [self.view addSubview:_webView];
     
    
//    NSString *str1 = [_HtmlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    url = [NSURL URLWithString:str1];
//
//    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    
}

- (void)closeClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backClicked:(id)sender
{
//    if (webView_.canGoBack)
//    {
//        [webView_ goBack];
//    }
//    else
//    {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
    
    
    if (_webView.canGoBack)
    {
        [_webView goBack];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    
}

// 切换横竖屏 调用该方法  自动切换
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    BOOL landscape = (BOOL)UIInterfaceOrientationIsLandscape(toInterfaceOrientation); //判断是不是横屏
    if (landscape)
    {
        backBtn.hidden = YES;
    }
    else
    {
        backBtn.hidden = NO;;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *str1 = [_HtmlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:str1];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    if ([_HtmlStr containsString:@".jpg"] || [_HtmlStr containsString:@".png"])
    {
//        _webView.scalesPageToFit = YES;
        if (@available(iOS 13.0, *)) {
            _webView.scalesLargeContentImage = YES;
        }else{
//            webView.scalesLargeContentImage = YES;
        }
        
        
    }
//    [webView_ loadRequest:request];
    [_webView loadRequest:request];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    [webView_ stopLoading];
    [_webView stopLoading];
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
    
    
}



- (void)dealloc
{
    webView_.delegate = nil;
    webView_ = nil;
    
    _webView.UIDelegate = nil;
    _webView = nil;
    
}

@end
