//
//  NFbaseViewController.m
//  nationalFitness
//
//  Created by 程long on 14-10-22.
//  Copyright (c) 2014年 chenglong. All rights reserved.
//

#import "NFbaseViewController.h"
//#import "BaiduMobStat.h"
#import "SystemInfo.h"
#import <objc/runtime.h>
#import "AppDelegate.h"
#import "JQFMDB.h"


@interface NFbaseViewController ()

@end

@implementation NFbaseViewController{
    
    
    JQFMDB *jqFmdb;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [UIView setAnimationsEnabled:YES];
    if (self.navigationController.viewControllers.count == 1) {
        self.tabBarController.tabBar.hidden =NO;
    }else{
        self.tabBarController.tabBar.hidden =YES;
    }
    //界面刚显示 0.6秒内不允许点击返回
//    self.backBtn.userInteractionEnabled = NO;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.backBtn.userInteractionEnabled = YES;
//    });
    
//    self.tabBarController.tabBar.hidden = NO;
//    self.navigationController.navigationBarHidden = NO;
//    self.navigationController.navigationBar.translucent = translucentBOOL;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
//    [UIView setAnimationsEnabled:YES];
//    if (self.navigationController.viewControllers.count == 1) {
//        self.tabBarController.tabBar.hidden =NO;
//    }else{
//        self.tabBarController.tabBar.hidden =YES;
//    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
  @{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
//    isConnectNet = ([self currentNetworkStatus] == 0 ? NO :YES);
    if (self.navigationController && self.navigationController.viewControllers.count > 1)
    {
        if (kTopHeight > 69) {
            self.backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 40)];
        }else{
            self.backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 34)];
        }
        [self.backBtn setImage:[UIImage imageNamed:@"everyday1_return"] forState:UIControlStateNormal];
        [self.backBtn addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
//        backBtn.timeInterval = 2;
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.backBtn];
        self.navigationItem.leftBarButtonItem = backButtonItem;
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    orepationType = [NFUserEntity shareInstance].orepationType;

    if (@available(iOS 13.0, *)) {
        //UIModalPresentationFullScreen
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    // Do any additional setup after loading the view.
}

//界面将要消失时消隐当前界面的hud
-(void)viewWillDisappear:(BOOL)animated{
//    [SVProgressHUD dismiss];
    
}

-(void)initUI{}

//自定义NAV返回按钮
- (void)backClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"\n\n\n\n\ndidReceiveMemoryWarning\n\n\n\n\n");
    // Dispose of any resources that can be recreated.
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    
//    NSString* cName;
//    if (self.title)
//    {
//        cName = self.title;
////        [[BaiduMobStat defaultStat] pageviewStartWithName:cName];
//    }
//}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    NSString* cName;
    if (self.title)
    {
        cName = self.title;
//        [[BaiduMobStat defaultStat] pageviewEndWithName:cName];
    }
}


#pragma mark - show alert hud

-(void)showAlertHud:(CGPoint)point withStr:(NSString *)message
{
    if([SVProgressHUD isVisible])
    {
        [SVProgressHUD setStatus:message];
    }
    else
    {
        [SVProgressHUD showInfoWithStatus:message];
    }
}

#pragma mark - showHUD
- (void)showHUD
{
    [SVProgressHUD show];
}

#pragma mark - hideHud
-(void)hideHud
{
    [SVProgressHUD dismiss];
}

- (UIViewController*)topViewController {
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

/**
 *  返回当前网络状态
 *
 *  @return     NotReachable = 0,
 ReachableViaWiFi,
 ReachableViaWWAN
 */
//- (NetworkStatus)currentNetworkStatus
//{
//    return [[SystemInfo shareSystemInfo] currentNetworkStatus];
//}

#pragma mark - joe添加
-(void)createNaviGationbarItemWithTitle:(NSString *)title{//attributes
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, JOESIZE.width, kTopHeight)];
    label.text = title;
    label.textColor = [UIColor colorWithRed:0.17 green:0.55 blue:0.87 alpha:1.00];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:20];
    label.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = label;
}

-(void)createNaviGationbarItemWithTitleImage:(NSString *)titleImageName andTitleText:(NSString *)titleText andTag:(int)tag isLeft:(BOOL)left{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:17]};
    CGFloat length = [titleText boundingRectWithSize:CGSizeMake(2000, 30*JOESIZESCALE) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size.width;
    CGFloat height = 30;
    //判断titleTextlength 如果是三字一下高度就设置矮一点
    if (titleText.length <= 3) {
        height = 25;
    }
    button.frame = CGRectMake(0, 0, length, height);
    if (titleImageName.length) {
        [button setBackgroundImage:[[UIImage imageNamed:titleImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    }
    if (tag) {
        button.tag = tag;
    }
    button.titleLabel.font = JoeNAVIGATION_LEFTBARTEXSIZE;
    if (titleText.length != 0) {
        [button setTitle:titleText forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        button.frame = CGRectMake(0, 0, 30, 30);
    }
    [button addTarget:self action:@selector(barButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView: button];
    if (left) {
        self.navigationItem.leftBarButtonItem = item;
    }else{
        self.navigationItem.rightBarButtonItem = item;
    }
}

#pragma mark - navigation左右按钮点击事件
-(void)barButtonClick:(UIButton *)sender{
    
}

-(UIView *)JoeTitleImageViewWithTitle:(NSString *)title frame:(CGRect)frame imageName:(NSString *)name tag:(int)tag{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    UIImageView *imageV = [self JoeImageViewWithImage:name andFrame:CGRectMake(0, 0, frame.size.width, frame.size.width) tag:tag];
    view.userInteractionEnabled = YES;
    [view addSubview:imageV];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.width, frame.size.width, frame.size.height-frame.size.width)];
    label.text = title;
    label.font = [UIFont boldSystemFontOfSize:11];
    label.textAlignment = NSTextAlignmentCenter;
    //    label.adjustsFontSizeToFitWidth = YES;
    [view addSubview:label];
    return view;
}

-(UIImageView *)JoeImageViewWithImage:(NSString *)name andFrame:(CGRect)frame tag:(int)tag{
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:frame];
    //        imageV.image = [UIImage imageNamed:name];
    //        [imageV setImageWithURL:[NSURL URLWithString:name] placeholderImage:[UIImage imageNamed:@"picture17.png"]];
    if (name.length <= 20) {
        imageV.image = [UIImage imageNamed:name];
    }else{
        [imageV sd_setImageWithURL:[NSURL URLWithString:name] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
    }
    imageV.userInteractionEnabled = YES;
    imageV.layer.cornerRadius = 10;
    imageV.clipsToBounds = YES;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = imageV.bounds;
    if (tag) {
        button.tag = tag;
    }
    
    [button addTarget:self action:@selector(JoeImageClick:) forControlEvents:(UIControlEventTouchUpInside)];
    [imageV addSubview:button];
    return imageV;
}

-(void)JoeImageClick:(UIButton *)sender{}

-(UIView *)JoeTitleImageViewWithTitle:(NSString *)title frame:(CGRect)frame imageName:(NSString *)name tag:(int)tag cornerRadius:(CGFloat)cornerRadius{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    UIImageView *imageV = [self JoeImageViewWithImage:name andFrame:CGRectMake(0, 0, frame.size.width, frame.size.width) tag:tag cornerRadius:cornerRadius];
    view.userInteractionEnabled = YES;
    [view addSubview:imageV];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.width, frame.size.width, frame.size.height-frame.size.width)];
    label.text = title;
    label.font = [UIFont boldSystemFontOfSize:11];
    label.textAlignment = NSTextAlignmentCenter;
    //    label.adjustsFontSizeToFitWidth = YES;
    [view addSubview:label];
    return view;
}

-(UIImageView *)JoeImageViewWithImage:(NSString *)name andFrame:(CGRect)frame tag:(int)tag cornerRadius:(CGFloat)cornerRadius{
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:frame];
    //        imageV.image = [UIImage imageNamed:name];
    //        [imageV setImageWithURL:[NSURL URLWithString:name] placeholderImage:[UIImage imageNamed:@"picture17.png"]];
    [imageV sd_setImageWithURL:[NSURL URLWithString:name] placeholderImage:[UIImage imageNamed:defaultHeadImaghe]];
    imageV.userInteractionEnabled = YES;
    imageV.layer.cornerRadius = cornerRadius;
    imageV.clipsToBounds = YES;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = imageV.bounds;
    if (tag) {
        button.tag = tag;
    }
    
    [button addTarget:self action:@selector(JoeImageBringCornerRadiusClick:) forControlEvents:(UIControlEventTouchUpInside)];
    [imageV addSubview:button];
    return imageV;
}

-(void)JoeImageBringCornerRadiusClick:(UIButton *)sender{}

#pragma mark - scrollV封装(无限轮播图)如果同一控制器有两个 这是第一个
-(UIView *)createScrollViewWithImageArr:(NSArray *)imageArray andFrame:(CGRect)frame{
//    self.countOfImage = imageArray.count;
//    UIView *view = [[UIView alloc] initWithFrame:frame];
//    _boundlessScrollV = [[UIScrollView alloc] initWithFrame:frame];
//    _boundlessScrollV.tag = 701;
//    _boundlessScrollV.delegate = self;
//    _boundlessScrollV.contentSize = CGSizeMake((imageArray.count+2)*JOESIZE.width, frame.size.height);
//    _boundlessScrollV.contentOffset = CGPointMake(JOESIZE.width, 0);
//    _boundlessScrollV.bounces = NO;
//    _boundlessScrollV.pagingEnabled = YES;
//    for (int i=0; i<imageArray.count+2; i++) {
//        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectMake(JOESIZE.width*i, 0, frame.size.width, frame.size.height)];
//        if (i==0) {
//            imageV = [self JoeImageViewWithImage:imageArray.lastObject andFrame:CGRectMake(JOESIZE.width*i, 0, JOESIZE.width, JOESIZE.height/4) tag:i+1 cornerRadius:0];
//        }else if (i==imageArray.count+1){
//            imageV = [self JoeImageViewWithImage:imageArray.firstObject andFrame:CGRectMake(JOESIZE.width*i, 0, JOESIZE.width, JOESIZE.height/4) tag:i+1 cornerRadius:0];
//        }else{
//            imageV = [self JoeImageViewWithImage:imageArray[i-1] andFrame:CGRectMake(JOESIZE.width*i, 0, JOESIZE.width, JOESIZE.height/4) tag:i+1 cornerRadius:0];
//        }
//        imageV.userInteractionEnabled = YES;
//        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//        button.frame = imageV.bounds;
//        button.tag = i+1;
//        
//        [button addTarget:self action:@selector(JoeScrollViewImageClick:) forControlEvents:(UIControlEventTouchUpInside)];
//        [imageV addSubview:button];
//        [_boundlessScrollV addSubview:imageV];
//    }
//    UIView *view1 = [self decreatePageControlWithFrame:CGRectMake(0, CGRectGetMaxY(_boundlessScrollV.frame)-20*JoeSCREENSCALE, JOESIZE.width, 20*JoeSCREENSCALE)];
//    view.tag = 99;
//    [view addSubview:_boundlessScrollV];
//    [view addSubview:view1];
//    return view;
    return nil;
}

-(UIView *)decreatePageControlWithFrame:(CGRect)frame{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, JOESIZE.width, 20*JOESIZESCALE)];
    _pageControl.tintColor = [UIColor blueColor];
    _pageControl.pageIndicatorTintColor = [UIColor yellowColor];
    _pageControl.tintColor = [UIColor blueColor];
    _pageControl.numberOfPages = _countOfImage;
    _pageControl.currentPage = 0;
    [_pageControl addTarget:self action:@selector(pageControlChange:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:_pageControl];
    if (_timer) {
        
    }else{
        //        _timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timeRun) userInfo:nil repeats:YES];
        //        [_timer fire];
        _timer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(timeRun) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return view;
}

-(void)timeRun{
    if (_boundlessScrollV.contentOffset.x/JOESIZE.width == _boundlessScrollV.contentSize.width/JOESIZE.width-1) {
        _boundlessScrollV.contentOffset = CGPointMake(JOESIZE.width, 0);
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelay:0.1];
    [UIView setAnimationDuration:durationTime];
    _boundlessScrollV.contentOffset = CGPointMake(_boundlessScrollV.contentOffset.x+JOESIZE.width, 0);
    if (_boundlessScrollV.contentOffset.x == 0) {
        _pageControl.currentPage = _countOfImage-1;
    }else if (_boundlessScrollV.contentOffset.x/JOESIZE.width == _countOfImage+1){
        _pageControl.currentPage = 0;
    }else{
        _pageControl.currentPage = _boundlessScrollV.contentOffset.x/JOESIZE.width-1;
    }
    [UIView commitAnimations];
}


-(void)JoeScrollViewImageClick:(UIButton *)sender{}

//-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    if (scrollView.contentOffset.x/JOESIZE.width == _countOfImage-1) {
//        scrollView.contentOffset = CGPointMake(JOESIZE.width, 0);
//        _pageControl.currentPage = 1;
//    }else if (scrollView.contentOffset.x/JOESIZE.width == 0){
//        scrollView.contentOffset = CGPointMake(JOESIZE.width*(_countOfImage-2), 0);
//        _pageControl.currentPage = _countOfImage-1;
//    }else{
//        _pageControl.currentPage = scrollView.contentOffset.x/JOESIZE.width;
//    }
//}

#pragma mark - prepareData相关
-(void)prepareData{
}

-(void)getDataSourceWithObject:(id)object{
}


-(void)prepareDataGetURLWithString:(NSString *)string{
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
//    hud.label.text = @"加载中";
//    AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
//    manger.responseSerializer = [AFHTTPResponseSerializer serializer];
//    [manger GET:string parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
//        
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSError *error;
//        id object = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
//        if (error) {
//            hud.label.text = @"数据序列化失败";
//        }else{
//            hud.label.text = @"加载成功";
//            [self getDataSourceWithObject:object];
//            //            [self.tableV reloadData];
//        }
//        [hud hideAnimated:YES afterDelay:0.3];
//        [hud removeFromSuperview];
//        //        [_tableV.mj_header endRefreshing];
//        //        [_tableV.mj_footer endRefreshing];
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        hud.label.text = @"加载失败";
//        [hud hideAnimated:YES afterDelay:0.3];
//        [hud removeFromSuperview];
//        //        [_tableV.mj_header endRefreshing];
//        //        [_tableV.mj_footer endRefreshing];
//    }];
    
}

//UIRectCornerTopLeft     = 1 << 0,
//UIRectCornerTopRight    = 1 << 1,
//UIRectCornerBottomLeft  = 1 << 2,
//UIRectCornerBottomRight = 1 << 3,

#pragma mark - 设置不规则圆角 view  button
//-(void)setViewRound:(UIView *)view TopLeft:(BOOL)TopLeft TopRight:(BOOL)TopRight BottomLeft:(BOOL)BottomLeft BottomRight:(BOOL)BottomRight cornerRadii:(CGFloat)roundW{
//    UIRectCorner a;
//    UIRectCorner b;
//    UIRectCorner c;
//    UIRectCorner d;
//    if (TopLeft) {
//        a = UIRectCornerTopLeft;
//    }
//    //    else{
//    //        a = NULL;
//    //    }
//    if (TopRight){
//        b = UIRectCornerTopRight;
//    }
//    //    else{
//    //        b = NULL;
//    //    }
//    if (BottomLeft){
//        c = UIRectCornerBottomLeft;
//    }
//    //    else{
//    //        c = NULL;
//    //    }
//    if (BottomRight){
//        d = UIRectCornerBottomRight;
//    }
//    //    else{
//    //        d = NULL;
//    //    }
//    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:a | b | c | d cornerRadii:CGSizeMake(roundW, roundW)];
//    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//    maskLayer.frame = view.bounds;
//    maskLayer.path = maskPath.CGPath;
//    view.layer.mask = maskLayer;
//}
//
//-(void)setBtnRound:(UIButton *)sender TopLeft:(BOOL)TopLeft TopRight:(BOOL)TopRight BottomLeft:(BOOL)BottomLeft BottomRight:(BOOL)BottomRight cornerRadii:(CGFloat)roundW{
//    UIRectCorner a;
//    UIRectCorner b;
//    UIRectCorner c;
//    UIRectCorner d;
//    if (TopLeft) {
//        a = UIRectCornerTopLeft;
//    }
//    if (TopRight){
//        b = UIRectCornerTopRight;
//    }
//    if (BottomLeft){
//        c = UIRectCornerBottomLeft;
//    }
//    if (BottomRight){
//        d = UIRectCornerBottomRight;
//    }
//    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:sender.bounds byRoundingCorners:a | b | c | d cornerRadii:CGSizeMake(roundW, roundW)];
//    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//    maskLayer.frame = sender.bounds;
//    maskLayer.path = maskPath.CGPath;
//    sender.layer.mask = maskLayer;
//}

#pragma mark - 延迟n秒调用主线程
-(void)createDispatchWithDelay:(CGFloat)time block:(void(^)(void))block{
    //    if (self.TakeBlock != block) {
    //        self.TakeBlock = block;
    //    }
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
        sleep(time);
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    });
}

#pragma mark - 缓存联系人列表
-(void)CacheContantListDataToFMDBWithCacheNameCacheData:(NSDictionary *)data{
    NSError *parseError;
    NSData *saveData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&parseError];
    //加密
    //    saveData = [saveData AES256EncryptWithKey:[NSString stringWithFormat:@"%@%@",AES_KEY,systemInfo.deviceId] keyEncoding:NSUTF8StringEncoding];
    NSString *dataString = [NFPacketHandler stringWithHexBytes:saveData];
    BOOL ret = [NFDatabaseQueue insertManagerCache:[NFUserEntity shareInstance].contantList dataStr:dataString];
    if (ret) {
        NSLog(@"缓存成功");
    }else{
        NSLog(@"缓存失败");
    }
}

#pragma mark - 取联系人缓存 @{@"status":1001,@"result":@{@"7f0000010b560000000c":@[],@"7f0000010b560000000d":@[]}} data 为result为key的字典
-(NSDictionary *)getContantListFMDBDataWithCacheName{
    // @{@"rootDict":@[@{@"contant":text}]}
    NSString *dataStr = [NFDatabaseQueue selectManagerCache:[NFUserEntity shareInstance].contantList];
    NSData *strData = [NFPacketHandler hexStringToNSData:dataStr];
    //解密
    //    strData = [strData AES256DecryptWithKey:[NSString stringWithFormat:@"%@%@",AES_KEY,[SystemInfo shareSystemInfo].deviceId] keyEncoding:NSUTF8StringEncoding];
    NSString *aStr = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *parserDict = [parser objectWithString:aStr];
    return parserDict;
}

#pragma mark - 取聊天记录缓存
-(NSDictionary *)getChatDataFMDBData{
    //@{rootDictionary:@{@[@"contantList":@[@{@"contant":@"",@"isSelf":@""}],@"otherId":self.chatId}]}
    NSString *dataStr = [NFDatabaseQueue selectManagerCache:[NFUserEntity shareInstance].contantData];
    NSData *strData = [NFPacketHandler hexStringToNSData:dataStr];
    //解密
    //    strData = [strData AES256DecryptWithKey:[NSString stringWithFormat:@"%@%@",AES_KEY,[SystemInfo shareSystemInfo].deviceId] keyEncoding:NSUTF8StringEncoding];
    NSString *aStr = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSDictionary *parserDict = [parser objectWithString:aStr];
    
    return parserDict;
}

#pragma mark - 最新取缓存 MessageChatEntity的数组
-(NSArray *)getChatDataFromFMDBWithUserId:(NSString *)userid{
    NSString *dataStr = [NFDatabaseQueue selectManagerCache:userid];
    NSData *strData = [NFPacketHandler hexStringToNSData:dataStr];
    //解密
    //    strData = [strData AES256DecryptWithKey:[NSString stringWithFormat:@"%@%@",AES_KEY,[SystemInfo shareSystemInfo].deviceId] keyEncoding:NSUTF8StringEncoding];
    NSString *aStr = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSArray *parserArr = [parser objectWithString:aStr];
    NSMutableArray *returnArr = [NSMutableArray new];;
    for (NSDictionary *dict in parserArr) {
        MessageChatEntity *entity = [MessageChatEntity new];
        entity.message_content = [dict objectForKey:@"message_content"];
        entity.message_read_time = [dict objectForKey:@"message_read_time"];
        entity.isSelf = [dict objectForKey:@"isSelf"];
        [returnArr addObject:entity];
    }
    return returnArr;
}

#pragma mark - 最新插入缓存
-(void)insertContantToFMDBWithEntity:(MessageChatEntity *)chatEntity UserId:(NSString *)userid IsSelf:(BOOL)isSelf{
    //先取出实体缓存数组
    NSMutableArray *cacheArr = [NSMutableArray arrayWithArray:[self getChatDataFromFMDBWithUserId:userid]];
    //将需要插入的实体add进去
    [cacheArr addObject:chatEntity];
    //再将实体数组转成 字典数组
//    NSMutableArray *dictArr = [NSMutableArray new];
//    for (MessageChatEntity *entity in cacheArr) {
//        
//        
//    }
    
    
    
}

//-(void)deleteChatDataFmdbWith

#pragma mark - 插入缓存 消息内容 @{@"contant":@"",@"otherId":@""}
-(void)insertContantDataToFMDBCacheData:(NSDictionary *)data isSelf:(BOOL)isSelf{
    //@{rootDictionary:@{@[@"contantList":@[@{@"contant":@"",@"isSelf":@""}],@"otherId":self.chatId}]}
    
    // @{@"rootDict":@[@{@"contant":text}]}
    //取
    NSDictionary *parserDict = [self getChatDataFMDBData];
    NSMutableArray *dataArr = [[NSMutableArray alloc] initWithCapacity:10];
    if (parserDict) {
        dataArr = [parserDict objectForKey:rootDictionary];
    }
    //存
    //@{@"rootDict":@[@{@"contant":@[],@"otherId":"@""}]}
    NSArray *saveArr = [NSArray new];
//    if (dataArr.count > 0) {
        //是否需要缓存新聊天 (在缓存中找 有没有消息历史 没有就添加新的缓存)
        BOOL IsFindContant = YES;
        for (int i = 0; i<dataArr.count; i++) {
            NSMutableDictionary *contantDict = dataArr[i];
            if ([[contantDict objectForKey:@"otherId"] isEqualToString:[data objectForKey:@"otherId"]]) {
                //            [dataArr removeObjectAtIndex:i];
                //  取该id的聊天记录
                NSMutableArray *arr = [contantDict objectForKey:@"contantList"];
//                [arr addObject:[data objectForKey:@"contant"]];
//                unsigned long myIndex = arr.count-1;
                //设置单条聊天记录
//                NSArray *afferentChatArr = [data objectForKey:@"contantList"];
                NSDictionary *addContant = @{@"contant":[data objectForKey:@"contant"],@"isSelf":isSelf?@"0":@"1"};
                [arr insertObject:addContant atIndex:arr.count];
//                if (isSelf) {
//                    //设置单条聊天记录
//                    [arr insertObject:@{@"contant":[data objectForKey:@"contant"],@"isSelf":@"0"} atIndex:myIndex];
//                }else{
//                    [arr insertObject:@{@"contant":[data objectForKey:@"contant"],@"isSelf":@"1"} atIndex:myIndex];
//                }
                NSArray *setArr = [NSArray arrayWithArray:arr];
                //聊天列表
                [contantDict setObject:setArr forKey:@"contantList"];
                
                IsFindContant = NO;
            }
        }
        saveArr = [NSArray arrayWithArray:dataArr];
        //如果需要新的缓存记录 则
        if (IsFindContant) {
            NSMutableDictionary *contantDic = [NSMutableDictionary new];
            NSMutableArray *arr = [NSMutableArray new];
            
            //单条聊天记录设置并添加
//            [arr insertObject:data atIndex:0];
            
            NSArray *afferentChatArr = [data objectForKey:@"contantList"];
            if (afferentChatArr[0]) {
                
                [arr addObject:afferentChatArr[0]];
            }
//            if (isSelf) {
//                //单条聊天记录设置并添加
//                [arr addObject:@{@"contant":[data objectForKey:@"contant"],@"isSelf":@"0"}];
//            }else{
//                [arr addObject:@{@"contant":[data objectForKey:@"contant"],@"isSelf":@"1"}];
//            }
            NSArray *savearr = [NSArray arrayWithArray:arr];
            //聊天记录设置
            [contantDic setObject:savearr forKey:@"contantList"];
            //聊天对象id设置
            [contantDic setObject:[data objectForKey:@"otherId"] forKey:@"otherId"];
            [dataArr addObject:contantDic];
            saveArr = [NSArray arrayWithArray:dataArr];
        }
//    }else{
//        //
//        NSDictionary *contantDict = @{@"otherId":[data objectForKey:@"otherId"],@"contant":@[[data objectForKey:@"contant"]]};
//        saveArr = @[contantDict];
//    }
    NSDictionary *saveDict = @{rootDictionary:saveArr};
    NSError *parseError;
    NSData *saveData = [NSJSONSerialization dataWithJSONObject:saveDict options:NSJSONWritingPrettyPrinted error:&parseError];
    //加密
    //    saveData = [saveData AES256EncryptWithKey:[NSString stringWithFormat:@"%@%@",AES_KEY,systemInfo.deviceId] keyEncoding:NSUTF8StringEncoding];
    
    NSString *dataString = [NFPacketHandler stringWithHexBytes:saveData];
    BOOL ret = [NFDatabaseQueue insertManagerCache:[NFUserEntity shareInstance].contantData dataStr:dataString];
    if (ret) {
        NSLog(@"缓存成功");
    }else{
        NSLog(@"缓存失败");
    }
}

#pragma mark - nsinteger转指定string
-(NSString *)timestampSwitchTime:(NSInteger)timestamp anddFormatter:(NSString *)format{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[[NSString stringWithFormat:@"%ld",timestamp] doubleValue]];
    [formatter setDateFormat:format]; // （@"YYYY-MM-dd hh:mm:ss"）----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    NSString *confromTimespStr = confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}


#pragma mark - nsinteger转string 昨天
-(NSString *)timestampSwitchTime:(NSInteger)timestamp{
    NSString *format = [NSString new];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timestamp];
    if (![confromTimesp isThisYear]) {
        format = @"yyyy-MM-dd HH:mm:ss";//不是今年
    }else{
        if (![confromTimesp isToday]) {
            //不是今天
            if ([confromTimesp isYesterday]) {
                format = @"yesterday";//是昨天
            }else{
                //format = @"MM-dd HH:mm:ss";//不是昨天
                format = @"M月d日";//不是昨天
            }
        }else{//是今天
            //format = @"HH:mm:ss";
            format = @"HH:mm";
        }
    }
    //当是昨天 则返回昨天
    if ([format isEqualToString:@"yesterday"]) {
        return @"昨天";
    }
    [formatter setDateFormat:format]; // （@"YYYY-MM-dd hh:mm:ss"）----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    NSString *confromTimespStr = confromTimespStr = [formatter stringFromDate:confromTimesp];
    
    return confromTimespStr;
}

#pragma mark - 比较消息是否需要隐藏 yes可以显示 no需要隐藏
+(BOOL)compaTodayDateWithDate:(NSInteger)aaa{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:aaa];
    NSTimeInterval time = [currentDate timeIntervalSinceDate:confromTimesp];
    NSInteger timme = time;
//    NSLog(@"%ld",timme/3600);
    //看看是否为不需要隐藏
    NSString *yuehouString = [KeepAppBox checkValueForkey:@"yuehouYincangStringCount"];
    if ([yuehouString isEqualToString:@"不隐藏"] || yuehouString.length == 0) {
        return YES;
    }
//    else if ([yuehouString isEqualToString:@"显示隐藏消息"]){
//        return YES;
//    }
    NSString *showString = [KeepAppBox checkValueForkey:@"yuehouYincang"];
    if (showString.length > 0) {
        if (timme <= [showString integerValue]) {
            return YES;
        }
    }else{
        //没有设置 一直返回yes
        return YES;
    }
        return NO;
}

#pragma mark - 比较消息是否需要删除
+(BOOL)compaTodayDateReturnDeleteWithDate:(NSInteger)aaa{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:aaa];
    NSTimeInterval time = [currentDate timeIntervalSinceDate:confromTimesp];
    NSInteger timme = time;
    //    NSLog(@"%ld",timme/3600);
    NSString *showString = [KeepAppBox checkValueForkey:@"guanjiQingkong"];
//    showString = @"5";
    //判断是否被删 yes 不需要删除。no删除
    if (timme <= [showString integerValue] || [showString integerValue] == 0) {
        return YES;
    }
    return NO;
}

#pragma mark - 返回收到消息距离今天的时长
+(NSInteger)returnTodayDateFromReceiveDate:(NSInteger)aaa{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:aaa];
    
    NSTimeInterval time = [currentDate timeIntervalSinceDate:confromTimesp];
    NSInteger timme = time;
    return timme;
}


#pragma mark - 更改缓存数据
-(void)changeFMDBData:(MessageChatEntity *)entity FMDBID:(NSString *)fmdbId{
    //    BOOL ret = [jqFmdb jq_insertTable:self.singleEntity.receive_user_name dicOrModel:entity];
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        BOOL rett = [strongSelf ->jqFmdb jq_updateTable:fmdbId dicOrModel:entity whereFormat:[NSString stringWithFormat:@"where chatId = '%@'",entity.chatId]];
        if (rett) {
            NSLog(@"更新success");
        }
    }];
    //测试查看数据用到的 下面
//    NSArray *yincangArrr = [jqFmdb jq_lookupTable:fmdbId dicOrModel:[MessageChatEntity class] whereFormat:@""];
//    NSArray *yincangArr = [jqFmdb jq_lookupTable:fmdbId dicOrModel:[MessageChatEntity class] whereFormat:[NSString stringWithFormat:@"where chatId = '%@'",entity.chatId]];
    
}





#pragma mark - 设置会话列表角标
-(void)setBadgeCountWithCount:(NSInteger)count AndIsAdd:(BOOL)ret{
    if (ret) {
        //将未读count加上
        [NFUserEntity shareInstance].badgeCount += count;
    }else{
        //将未读count减去
        [NFUserEntity shareInstance].badgeCount -= count;
        //如果未读小于0 则隐藏
        if ([NFUserEntity shareInstance].badgeCount <= 0) {
            [NFUserEntity shareInstance].badgeCount = 0;
        }
    }
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        //获取当前显示的viewcontroller
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
        UITabBarItem *tabBarItemWillBadge = currentVC.navigationController.tabBarController.tabBar.items[0];
        //            [tabBarItemWillBadge yee_MakeRedBadge:4 color:[UIColor redColor]];
        [tabBarItemWillBadge yee_MakeBadgeTextNum:[NFUserEntity shareInstance].badgeCount textColor:[UIColor whiteColor] backColor:[UIColor redColor] Font:[UIFont fontSectionBigBadge]];
    });
}

#pragma mark - 设置会话列表角标
//-(void)setBadgeCountZero{
//    [NFUserEntity shareInstance].badgeCount = 0;
//    dispatch_queue_t mainQueue = dispatch_get_main_queue();
//    dispatch_async(mainQueue, ^{
//        //获取当前显示的viewcontroller
//        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
//        UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
//        UITabBarItem *tabBarItemWillBadge = currentVC.navigationController.tabBarController.tabBar.items[0];
//        //            [tabBarItemWillBadge yee_MakeRedBadge:4 color:[UIColor redColor]];
//        [tabBarItemWillBadge yee_MakeBadgeTextNum:[NFUserEntity shareInstance].badgeCount textColor:[UIColor whiteColor] backColor:[UIColor redColor] Font:[UIFont fontSectionBigBadge]];
//    });
//}

#pragma mark - 设置联系人角标
-(void)setContactBadgeCountWithCount:(NSInteger)count AndIsAdd:(BOOL)ret{
    if (ret) {
        //将未读count加上
        [NFUserEntity shareInstance].contactBadgeCount += count;
    }else{
        //将未读count减去
        [NFUserEntity shareInstance].contactBadgeCount -= count;
        //如果未读小于0 则隐藏
        if ([NFUserEntity shareInstance].contactBadgeCount <= 0) {
            [NFUserEntity shareInstance].contactBadgeCount = 0;
            
        }
    }
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        //获取当前显示的viewcontroller
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
        UITabBarItem *tabBarItemWillBadge = currentVC.navigationController.tabBarController.tabBar.items[1];
        //            [tabBarItemWillBadge yee_MakeRedBadge:4 color:[UIColor redColor]];
        [tabBarItemWillBadge yee_MakeBadgeTextNum:[NFUserEntity shareInstance].contactBadgeCount textColor:[UIColor whiteColor] backColor:[UIColor redColor] Font:[UIFont fontSectionBigBadge]];
    });
}

#pragma mark - 设置联系人角标
-(void)setContactBadgeCountWithCount:(NSInteger)count{
    [NFUserEntity shareInstance].contactBadgeCount = count;
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        //获取当前显示的viewcontroller
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
        UITabBarItem *tabBarItemWillBadge = currentVC.navigationController.tabBarController.tabBar.items[1];
        //            [tabBarItemWillBadge yee_MakeRedBadge:4 color:[UIColor redColor]];
        [tabBarItemWillBadge yee_MakeBadgeTextNum:[NFUserEntity shareInstance].contactBadgeCount textColor:[UIColor whiteColor] backColor:[UIColor redColor] Font:[UIFont fontSectionBigBadge]];
    });
}

#pragma mark - 获取当前视图
- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        
        rootVC = [rootVC presentedViewController];
    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
        
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
        
    } else {
        // 根视图为非导航类
        
        currentVC = rootVC;
    }
    
    return currentVC;
}

#pragma mark - 缓存实体
-(CacheKeepBoxEntity *)getAllCacheDataEntity{
    CacheKeepBoxEntity *entity;
    if ([NFUserEntity shareInstance].KeepBoxEntity) {
        entity = [NFUserEntity shareInstance].KeepBoxEntity;
        return entity;
    }
    //CacheKeepBoxEntity
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
    __block BOOL ret = NO;
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        ret = [strongSelf ->jqFmdb jq_isExistTable:@"keepBoxEntity"];
    }];
    if (!ret) {
        __block BOOL ret = NO;
        [jqFmdb jq_inDatabase:^{
            __strong typeof(weakSelf)strongSelf=weakSelf;
            ret = [strongSelf ->jqFmdb jq_createTable:@"keepBoxEntity" dicOrModel:[CacheKeepBoxEntity class]];
        }];
        if (ret) {
            CacheKeepBoxEntity *entity = [CacheKeepBoxEntity new];
            entity.keepBoxId = @"keepBoxId";
            entity.themeSelectedIndex = 1;
            entity.themeSelectedImageName = @"";
            __weak typeof(self)weakSelf=self;
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                BOOL rett = [strongSelf ->jqFmdb jq_insertTable:@"keepBoxEntity" dicOrModel:entity];
                if (rett) {
                }
            }];
            
        }
    }
    
//    NSArray *asrrs = [jqFmdb jq_lookupTable:@"keepBoxEntity" dicOrModel:[CacheKeepBoxEntity class] whereFormat:@""];
    __block NSArray *arrs = [NSArray new];
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        arrs = [strongSelf ->jqFmdb jq_lookupTable:@"keepBoxEntity" dicOrModel:[CacheKeepBoxEntity class] whereFormat:@"where keepBoxId = 'keepBoxId'"];
    }];
    
    if (arrs.count == 0) {
        //这时候可能要抱错了，加个判断
        entity = [NFUserEntity shareInstance].KeepBoxEntity;
    }else{
        entity = arrs[0];
        [NFUserEntity shareInstance].KeepBoxEntity = entity;
    }
    return entity;
}

-(BOOL)changeCachewithEntity:(CacheKeepBoxEntity *)entity{
    jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
//    themeSelectedImageName
    __block NSArray *arrs = [NSArray new];
    __weak typeof(self)weakSelf=self;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        arrs = [strongSelf ->jqFmdb jq_lookupTable:@"keepBoxEntity" dicOrModel:[CacheKeepBoxEntity class] whereFormat:@"where keepBoxId = 'keepBoxId'"];
    }];
    CacheKeepBoxEntity *entityy = arrs[0];
    //将原来的属性复制下来
    entity.keepBoxId = entityy.keepBoxId;
    //再进行缓存
    __block BOOL ret;
    [jqFmdb jq_inDatabase:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        ret= [strongSelf ->jqFmdb jq_updateTable:@"keepBoxEntity" dicOrModel:entity whereFormat:@"where keepBoxId = 'keepBoxId'"];
    }];
    if (ret) {
        return YES;
    }
    return NO;
}

#pragma mark - 设置背景图
-(UIImageView *)setThemeBackgroundImage{
    UIImageView *backImageView=[[UIImageView alloc] initWithFrame:self.view.bounds];
    CacheKeepBoxEntity *entityy = [[NFbaseViewController new] getAllCacheDataEntity];
    //图片名字
    NSString *backGroundImageName = [NSString new];
    if (entityy.themeSelectedIndex == 0) {
        //backGroundImageName = @"底";
        backGroundImageName = @"";
    }else if (entityy.themeSelectedIndex == 1){
        backGroundImageName = @"";
    }
    [backImageView setImage:[UIImage imageNamed:backGroundImageName]];
    return backImageView;
}


@end
