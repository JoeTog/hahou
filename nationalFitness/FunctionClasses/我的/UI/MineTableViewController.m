//
//  MineTableViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/7/14.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "MineTableViewController.h"
#import "NFHeadImageView.h"



@interface MineTableViewController ()<UINavigationControllerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,ChatHandlerDelegate,UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate>

@property (strong, nonatomic) CADisplayLink *displayLink;

@property (strong, nonatomic) CAShapeLayer *shapeLayer;

@property (strong, nonatomic) UIBezierPath *path;

@property (strong, nonatomic) CAShapeLayer *shapeLayer2;

@property (strong, nonatomic) UIBezierPath *path2;

@end



@implementation MineTableViewController{
    //没用到
    __weak IBOutlet NFHeadImageView *headImageBV;
    //没用到
    __weak IBOutlet UIView *mineHeadView;
    
    //昵称宽度约束 没用到
    __weak IBOutlet NSLayoutConstraint *nickNameWidthConstaint;
    
    //用户名
    __weak IBOutlet UILabel *userNameLabel;
    
    BOOL reloading_;
    BOOL needReloading_;
    //下滑到最后是否能刷新数据
    BOOL canRefreshLash_;
    //下滑到最后是否正在刷新
    BOOL isRefreshLashing_;
    
    EGORefreshTableHeaderView * refreshHeaderView_;
    
    //单独的xib headview
    MineTableHeadView *headView;
    SocketModel * socketModel;
    SocketRequest *socketRequest;
    
    JQFMDB *jqFmdb;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (socketModel.delegate != self) {
        socketModel.delegate = self;
    }
    if (self.navigationController.viewControllers.count == 1) {
        self.tabBarController.tabBar.hidden =NO;
    }
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.translucent = translucentBOOL;
    
    [self initColor];
    
    if ([NFUserEntity shareInstance].mineHeadView.length > 0) {
        [headView.headImageView ShowHeadImageWithUrlStr:[NFUserEntity shareInstance].mineHeadView withUerId:nil completion:^(BOOL success, UIImage *image) {
            if (success) {
                [NFUserEntity shareInstance].mineHeadViewImage = image;
            }
        }];
    }
    if ([NFUserEntity shareInstance].nickName.length > 0) {
        headView.nickNameLabel.text = [NFUserEntity shareInstance].nickName;
    }else{
        headView.nickNameLabel.text = @"未设置昵称";
    }
//    if ([NFUserEntity shareInstance].userName.length > 0) {
//        self.userLabel.text = [NFUserEntity shareInstance].userName;
//    }else{
//        self.userLabel.text = @"??????";
//    }
    //headView
    if ([NFUserEntity shareInstance].signText.length > 0) {
        headView.signLabel.text = [NFUserEntity shareInstance].signText;
    }else{
        headView.signLabel.text = @"";
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    //在didappear中设置刷新
    //self.tableView.backgroundView=[[NFbaseViewController new] setThemeBackgroundImage];
    [self.tableView reloadData];
    [SVProgressHUD dismiss];
    
    headView.frame = CGRectMake(0, 0, SCREEN_WIDTH, kPLUS_SCALE_X(305));
    self.tableView.tableHeaderView = headView;
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    //取消cell选中状态
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.translucent = translucentBOOL;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];//界面消失 状态栏为白色
}



- (void)viewDidLoad {
    [super viewDidLoad];
    //从状态栏下面开始布局
//    self.edgesForExtendedLayout = UIRectEdgeNone;
//    self.automaticallyAdjustsScrollViewInsets = NO;
//     self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    //    if (UIDeviceCurrentDevice >= 11) {
//        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//    }
    
    xInsets_NO(self.tableView, self);
//    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0);
    self.title = @"我的";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.tableView.tableFooterView = [UIView new];
    
    [self initUI];
    [self initScoket];
    
    
    //支付按钮
    UIButton *payBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    [payBtn setTitle:@"支付" forState:(UIControlStateNormal)];
    payBtn.backgroundColor = [UIColor lightGrayColor];
    [payBtn addTarget:self action:@selector(payClick) forControlEvents:(UIControlEventTouchUpInside)];
    
    UIWindow *win = [[[UIApplication sharedApplication] windows] firstObject];
    
    //[win addSubview:payBtn];
    
    
    
    
    
}


-(void)payClick{
    
    
    // 快捷支付
//    [[ZFJPlugin shareInstance]startPayWithPayInfo:[self getPayInfo:PayTypeQuickpass] viewController:self callback:^(NSString * _Nonnull errCode, NSDictionary * _Nonnull info) {
//        //        NSString *str = [NSString stringWithFormat:@"errcode...%@",errCode];
//        //        popError(str);
//        //        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[NSString stringWithFormat:@"errCode%@",errCode] message:[NSString stringWithFormat:@"%@",[info JSONString]] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        //        [alert show];
//        NSLog(@"code...%@,\n\n...info...%@",errCode,info);
//    }];
    
    
    NSDictionary *patD = @{@"mer_cust_id":@"6666000000134024",//商户客户号
                           @"version":@"10",//版本 传10
                           @"order_date":@"20191107",//订单日期
                           @"order_id":@"11111111111",//订单号
                           @"user_cust_id":@"B00024928",//用户客户号
                           @"biz_trans_type":@"R",//支付 P。充值 R
                           @"trans_amt":@"1",//交易金额
                           @"dev_info_json":@"{‘ipAddr’:‘10.99.195.11’,’devType’:‘2’,’MAC’:’D4-81-D7-F0-42-F8’,’IMEI’:‘3553200846666033’}"};
    
    //开户
    
    
    
//    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"NFQRCodeStoryboard" bundle:nil];
//    QRCodeShowViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"QRCodeShowViewController"];
//    [self.navigationController pushViewController:toCtrol animated:YES];
    
    
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"HuiFuPayStoryboard" bundle:nil];
    OpenAccountViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"OpenAccountViewController"];
    [self.navigationController pushViewController:toCtrol animated:YES];
    
    
    
    
    
    
}

//-(PayInfoData *)getPayInfo:(PayType)paytype{
//
//    // 初始化支付+数据
//    PayInfoData *payInfo = [[PayInfoData alloc]init];
//    payInfo.merchantId = @"HF0079";
//    payInfo.customId = @"6666000000134024";
//    payInfo.merchantkey = @""; //商户密钥
//    payInfo.transAmt = @"1";
//    payInfo.orderId = @"";
//    payInfo.orderDate = @"";
//    payInfo.bgRetUrl = @"";
//    payInfo.retUrl = @"";
//    payInfo.goodsDesc = @"";
//    payInfo.payType = PayTypeQuickpass;
//    ////    payInfo.inAcctId =
//    ////        payInfo.inAcctId = @"79506";
//    ////        payInfo.inCustId = @"6666000000026086";
//    //    payInfo.buyerID = buyerIDTextField.text;
//    payInfo.divDetail = @"";
//
//    //    payInfo.merchantId = @"6666000008922319";
//    //    payInfo.merchantkey = @"rVg8nnIvjns2yT71giqSvQ==";
//    //    payInfo.transAmt = @"0.02";
//    //    payInfo.orderId = @"188179999897090";
//    //    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    //    [formatter setDateFormat:@"YYYYMMdd"];
//    //    NSString *orderDate = [formatter stringFromDate:[NSDate date]];
//    //    payInfo.orderDate = orderDate;
//    //    payInfo.payType = PayTypeAlipay;
//    //    payInfo.bgRetUrl = @"http://www.baidu.com/";
//    //    payInfo.retUrl = @"http://www.baidu.com/";
//    //    payInfo.goodsDesc = @"充值";
//    //    payInfo.divDetail = @"[{'divCustId':'6666000011114873','divAcctId':'14691473','divAmt':'0.02','divFreezeFg':'01'}]" ;
//
//    return payInfo;
//}

-(void)imageWithImage:(UIImage *)image imageWidth:(CGFloat)imageWidth imageHeight:(CGFloat)imageHeight borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor{
    CGSize size = CGSizeMake(imageWidth + 2 * borderWidth, imageHeight + 2 * borderWidth);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, size.width, size.height)];
    [borderColor set];
    [path fill];
    path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(borderWidth, borderWidth, imageWidth, imageHeight)];
    [path addClip];
    [image drawInRect:CGRectMake(borderWidth, borderWidth, imageWidth, imageHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    image = newImage;
}

-(void)initUI{
    
    if (refreshHeaderView_ == nil)
    {
        EGORefreshTableHeaderView * refreshHeader = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0 - self.tableView.bounds.size.height, self.tableView.frame.size.width, self.tableView.bounds.size.height)];
        refreshHeader.delegate = self;
        reloading_ = NO;
        [self.tableView addSubview:refreshHeader];
        refreshHeaderView_ = refreshHeader;
    }
    [refreshHeaderView_ refreshLastUpdatedDate];
    
    
    headImageBV.userInteractionEnabled = NO;
    nickNameWidthConstaint.constant = 150;//设置昵称宽度约束
    
//    [self imageWithImage:headView.headImageView imageWidth:headImageBV.frame.size.width/2 imageHeight:headImageBV.frame.size.width/2 borderWidth:10 borderColor:[UIColor greenColor]];
    
    //MineTableHeadView
    headView = [[[NSBundle mainBundle]loadNibNamed:@"MineTableHeadView" owner:nil options:nil] firstObject];
    //需要在didappear中设置
//    ViewBorderRadius(headView.headImageView, headView.headImageView.frame.size.width/2, 3, [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6]);
    ViewBorderRadius(headView.headImageView, 6, 3, [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.6]);
    headView.nickNameWidthConstaint.constant = SCREEN_WIDTH/3;//设置昵称宽度约束
    headView.signWidthConstaint.constant = SCREEN_WIDTH/3*2;
    //头像点击 暂时注释 以后有接口再打开
    [headView.tapGestureClick addTarget:self action:@selector(editPersonalInfoTapGesture)];
    __weak typeof(self)weakSelf=self;
    [headView.headImageView afterClickHeadImage:^{
//        SGPhoto *temp = [[SGPhoto alloc] init];
//        temp.identifier = @"";
//        temp.thumbnail = [NFUserEntity shareInstance].mineHeadViewImage;
//        temp.fullResolutionImage = [NFUserEntity shareInstance].mineHeadViewImage;
//        HDPictureShowViewController *showImageViewCtrol = [[HDPictureShowViewController alloc] init];
//        showImageViewCtrol.imageUrlList = @[temp];
//        showImageViewCtrol.mainImageIndex = 0;
//        showImageViewCtrol.isLuoYang = YES;
//        showImageViewCtrol.isNeedNavigation = NO;
//        [self.navigationController pushViewController:showImageViewCtrol animated:YES];
        
        [weakSelf changeHeadClick];
    }];
//    self.tableView.tableHeaderView = headView;
    
}

- (void)drawPath {
    static double i = 0;
    
    CGFloat A = 10.f;//A振幅
    CGFloat k = 0;//y轴偏移
    CGFloat ω = 0.03;//角速度ω变大，则波形在X轴上收缩（波形变紧密）；角速度ω变小，则波形在X轴上延展（波形变稀疏）。不等于0
    CGFloat φ = 0 + i;//初相，x=0时的相位；反映在坐标系上则为图像的左右移动。
    //y=Asin(ωx+φ)+k
    
    _path = [UIBezierPath bezierPath];
    _path2 = [UIBezierPath bezierPath];
    
    [_path moveToPoint:CGPointZero];
    [_path2 moveToPoint:CGPointZero];
    for (int i = 0; i < SCREEN_WIDTH+1; i ++) {
        CGFloat x = i;
        CGFloat y = A * sin(ω*x+φ)+k;
        CGFloat y2 = A * cos(ω*x+φ)+k;
        [_path addLineToPoint:CGPointMake(x, y)];
        [_path2 addLineToPoint:CGPointMake(x, y2)];
    }
    [_path addLineToPoint:CGPointMake(SCREEN_WIDTH, -100)];
    [_path addLineToPoint:CGPointMake(0, -100)];
    _path.lineWidth = 1;
    
    _shapeLayer.path = _path.CGPath;
    
    [_path2 addLineToPoint:CGPointMake(SCREEN_WIDTH, -100)];
    [_path2 addLineToPoint:CGPointMake(0, -100)];
    _path2.lineWidth = 1;
    
    _shapeLayer2.path = _path2.CGPath;
    
    i += 0.1;
    if (i > M_PI * 2) {
        i = 0;//防止i越界
    }
}

-(void)initScoket{
    socketRequest = [SocketRequest share];
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    
    
}



#pragma mark - 设置头像请求


#pragma mark - 个人资料详情请求

#pragma mark - 收到服务器消息踢人
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    //这里不走
    if (messageType == SecretLetterType_PersonalInfoSet) {
//        [self doneLoadingTableViewData];
        [NFUserEntity shareInstance].IsUploadingPicture = NO;
        //设置成功
        [headView.headImageView ShowHeadImageWithUrlStr:[NFUserEntity shareInstance].mineHeadView withUerId:nil completion:^(BOOL success, UIImage *image) {
            if (success) {
                [NFUserEntity shareInstance].mineHeadViewImage = image;
            }
            [SVProgressHUD showSuccessWithStatus:@"上传头像成功"];
        }];
    }else if (messageType == SecretLetterType_PersonalInfoDetail) {
        //下啦刷新个人信息
        if ([chatModel isKindOfClass:[PersonalInfoDetailEntity class]]) {
            PersonalInfoDetailEntity *detailInfoEntity = chatModel;
            if ([detailInfoEntity.userHeadPicPath containsString:@"http"] || [detailInfoEntity.userHeadPicPath containsString:@"wx.qlogo.cn"]) {
                [headView.headImageView ShowHeadImageWithUrlStr:detailInfoEntity.userHeadPicPath withUerId:nil completion:^(BOOL success, UIImage *image) {
                    [NFUserEntity shareInstance].mineHeadViewImage = image;
                    [NFUserEntity shareInstance].mineHeadView = detailInfoEntity.userHeadPicPath;
                }];
            }else{
                headView.headImageView.image = [UIImage imageNamed:detailInfoEntity.userHeadPicPath];
                [NFUserEntity shareInstance].mineHeadViewImage = [UIImage imageNamed:detailInfoEntity.userHeadPicPath];
                [NFUserEntity shareInstance].mineHeadView = detailInfoEntity.userHeadPicPath;
            }
            headView.nickNameLabel.text = detailInfoEntity.nick_name;
        }
    }
}

#pragma mark - 编辑个人信心点击 用到的
-(void)editPersonalInfoTapGesture{
    //MineInfoEditTableViewController
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MineStoryboard" bundle:nil];
    MineInfoEditTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"MineInfoEditTableViewController"];
    [self.navigationController pushViewController:toCtrol animated:YES];
}

//没用到
#pragma mark - 编辑个人信心点击
- (IBAction)editPersonalInfoTapGesture:(UITapGestureRecognizer *)sender {
    //MineInfoEditTableViewController
    UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MineStoryboard" bundle:nil];
    MineInfoEditTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"MineInfoEditTableViewController"];
    [self.navigationController pushViewController:toCtrol animated:YES];
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    cell.backgroundColor = [UIColor clearColor];
//} Room 102 Unit 2 No. 45 chuzhoudadaoDaoli Qu  Haeri


//返回分区数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
//返回分区行数
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    if (section == 0) {
////        if ([NFUserEntity shareInstance].isBang) {
////            return 3;
////        }
//        return 6;
//    }
//    return 1;
//}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section == 0 && indexPath.row == 4) {
        if ([NFUserEntity shareInstance].isBang) {
            return 0.1;
        }
    }
//    else if (indexPath.section == 0 && indexPath.row == 3){
//        return 0.1;
//    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

//头高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0 && SCREEN_WIDTH == 320) {
        return 1;
    }
    if (section == 1) {
        if (SCREEN_WIDTH ==320) {
            return 30;
        }else if (SCREEN_WIDTH == 375){
            return 40;
        }
        return 50;
    }
    return 0.1;
}

//设置headview 颜色
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
//    [headerView setBackgroundColor:UIColorFromRGB(0xebebf1)];
    [headerView setBackgroundColor:[UIColor colorSectionHeader]];
    return headerView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (@available(iOS 13.0, *)) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell右箭头"]];
    }
    return cell;
    
}

//SetUpTableViewController
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            //点击用户信息
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MineStoryboard" bundle:nil];
            MineInfoEditTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"MineInfoEditTableViewController"];
            [self.navigationController pushViewController:toCtrol animated:YES];
        }else if (indexPath.row == 1) {
            //自己的二维码
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"NFQRCodeStoryboard" bundle:nil];
            QRCodeShowViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"QRCodeShowViewController"];
            [self.navigationController pushViewController:toCtrol animated:YES];
        }else if (indexPath.row == 2){
            //跳转扫描二维码
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"NFQRCodeStoryboard" bundle:nil];
            QRCodeScanViewController * qrcodeScanVC = [sb instantiateViewControllerWithIdentifier:@"QRCodeScanViewController"];
            [self.navigationController pushViewController:qrcodeScanVC animated:YES];
        }else if (indexPath.row == 3){
            //钱包
            
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"RedPacketStoryboard" bundle:nil];
            WalletTableViewController * qrcodeScanVC = [sb instantiateViewControllerWithIdentifier:@"WalletTableViewController"];
            [self.navigationController pushViewController:qrcodeScanVC animated:YES];
            
//            RPFMyWalletVCSec * wallet = [[RPFMyWalletVCSec alloc] init];
//            wallet.groupId = @"";
//            //RPFOpenPacketViewController * openVC = [[RPFOpenPacketViewController alloc] initWithNibName:@"RPFOpenPacketViewController" bundle:nil];
//            [self.navigationController pushViewController:wallet animated:YES];
            
        }else if (indexPath.row == 4){
            //绑定多信账号
            //BingingHaHouTableViewController
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"loginStoryboard" bundle:nil];
            BingingHaHouTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"BingingHaHouTableViewController"];
            [self.navigationController pushViewController:toCtrol animated:YES];
        }else if (indexPath.row == 5){
            [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
            
            
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
            MessageChatViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"MessageChatViewController"];
            toCtrol.IsFromAdd = YES;
            jqFmdb = [JQFMDB shareDatabase:@"tongxun.sqlite"];
            __block NSMutableArray *contacts = [NSMutableArray new];
            __weak typeof(self)weakSelf=self;
            //这里重新去缓存联系人
            [jqFmdb jq_inDatabase:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                contacts = [NSMutableArray arrayWithArray:[strongSelf ->jqFmdb jq_lookupTable:@"lianxirenliebiao" dicOrModel:[ZJContact class] whereFormat:@""]];
            }];
            ZJContact *kefuContact = [ZJContact new];
            for (ZJContact *contact in contacts) {
                if ([contact.friend_username containsString:@"duoxinkefu"]) {
                    kefuContact = contact;
                    break;
                }
            }
            if (kefuContact.friend_username.length > 0) {
                if (kefuContact.friend_nickname.length > 0) {
                    toCtrol.titleName = kefuContact.friend_nickname;
                }else{
                    toCtrol.titleName = kefuContact.friend_username;
                }
                toCtrol.chatType = @"0";
                toCtrol.singleContactEntity = kefuContact;
                [weakSelf.navigationController pushViewController:toCtrol animated:YES];
                return;
            }
            
            
            [socketRequest sendFriendAddRequest:@"duoxinkefu"];
            
            [SVProgressHUD showInfoWithStatus:@"请确认客服在联系人中"];
            
            
            return;
            
            //复制 客服号
            UIPasteboard *pab = [UIPasteboard generalPasteboard];
            [pab setString:@"duoxinkefu"];
            UIPasteboard *pboard = [UIPasteboard generalPasteboard];
            if ([pboard.string isEqualToString:@"duoxinkefu"]) {
                [SVProgressHUD showInfoWithStatus:@"复制成功"];
            }
            
        }else if(indexPath.row == 6){
            //自动客服
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MineStoryboard" bundle:nil];
            HelpTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"HelpTableViewController"];
            
            [self.navigationController pushViewController:toCtrol animated:YES];
        }
    }else if (indexPath.section == 1){
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MineStoryboard" bundle:nil];
        SetUpTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"SetUpTableViewController"];
        [self.navigationController pushViewController:toCtrol animated:YES];
    }
}

-(void)initColor{
    self.firstLabel.textColor = [UIColor colorMainTextColor];
    self.userLabel.textColor = [UIColor colorMainTextColor];
    self.saoyisaoLabel.textColor = [UIColor colorMainTextColor];
    self.settingLabel.textColor = [UIColor colorMainTextColor];
    self.hahouLabel.textColor = [UIColor colorMainTextColor];
    self.qianbaolabel.textColor = [UIColor colorMainTextColor];
    self.kefuLabel.textColor = [UIColor colorMainTextColor];
    self.aotukefuLabel.textColor = [UIColor colorMainTextColor];
    
    self.nickNameLabel.textColor = [UIColor colorMainTextColor];
    self.accountNumberLabel.textColor = [UIColor colorMainTextColor];
    headView.nickNameLabel.font = [UIFont fontName_Courier_Size:17];
    
    
    
//    [[NFMyManage new] weakConnect];
    
}

#pragma mark - 拉伸图片
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat y = scrollView.contentOffset.y;
    CGRect frame = headView.frame;
    frame.origin.y = y;
    frame.size.height = - y;
//    headView.frame = frame;
    if (y < 0) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    
    [refreshHeaderView_ egoRefreshScrollViewDidScroll:scrollView];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
}

#pragma mark - 更改头像
- (void)changeHeadClick
{
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:@"取消"
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"拍照",@"从手机相册取", nil];
    
    action.actionSheetStyle = UIActionSheetStyleDefault;
    [action showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
        {
            [self takeCameral];
        }
            break;
        case 1:
        {
            [self searchLibrary];
        }
            break;
        default:
            break;
    }
}


#pragma mark - UIActionSheetDelegate
- (void)takeCameral
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        [imagePicker setAllowsEditing:NO];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        if (@available(iOS 13.0, *)) {
            imagePicker.modalPresentationStyle =UIModalPresentationFullScreen;
        }
        [self presentViewController:imagePicker animated:YES completion:nil];
    }else{
        [SVProgressHUD showInfoWithStatus:@"相机不可用"];
    }
}

- (void)searchLibrary
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        [imagePicker setAllowsEditing:NO];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        if (@available(iOS 13.0, *)) {
            imagePicker.modalPresentationStyle =UIModalPresentationFullScreen;
        }
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate
#pragma mark - 图片剪切相关
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
//        headView.headImageView.image = portraitImg;
//        [NFUserEntity shareInstance].mineHeadViewImage = portraitImg;
        //图片上传
        NSLog(@"");
        
//        [self upLoadPicth:portraitImg];
        
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"loginStoryboard" bundle:nil];
        RegSetImageViewCtroller *setCtrol = [story instantiateViewControllerWithIdentifier:@"RegSetImageViewCtroller"];
        setCtrol.originalImage = portraitImg;
        setCtrol.cutType = CutUserHeadImage;
        setCtrol.backToVC = self;
        __weak typeof(self)weakSelf=self;
        [setCtrol ReturnPicPathManager:^(NSString *pic) {
            NSLog(@"%@",pic);
            if(pic && pic.length > 0 && ![pic containsString:@"nil"]){
                [socketRequest setHeadPicthWithUr:pic];
            }else{
                [SVProgressHUD showErrorWithStatus:@"设置失败"];
            }
        }];
        [self.navigationController pushViewController:setCtrol animated:YES];
        
    }];
}


#pragma mark - Image Scale Utility

- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage
{
    if (sourceImage.size.width < SCREEN_WIDTH * 2) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = SCREEN_WIDTH * 2;
        btWidth = sourceImage.size.width * (SCREEN_WIDTH * 2 / sourceImage.size.height);
    } else {
        btWidth = SCREEN_WIDTH * 2;
        btHeight = sourceImage.size.height * (SCREEN_WIDTH * 2 / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

//懒加载
-(NSMutableDictionary *)parms{
    if (!_parms) {
        _parms = [[NSMutableDictionary alloc] init];
    }
    return _parms;
}



#pragma mark - 下拉刷新4
#pragma mark - scrollView Delegate
// 触摸屏幕并拖拽画面，再松开，最后停止时，触发该函数
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [refreshHeaderView_ egoRefreshScrollViewDidEndDragging:scrollView];
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    [refreshHeaderView_ egoRefreshScrollViewDidScroll:scrollView];
//}

#pragma mark - Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource
{
    reloading_ = YES;
}

- (void)doneLoadingTableViewData{
    
    //  model should call this when its done loading
    reloading_ = NO;
#pragma mark - 下拉刷新5
    [refreshHeaderView_ egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

#pragma mark - 下拉刷新委托回调

//调用结束刷新和刷新列表
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [self reloadTableViewDataSource];
#pragma mark - 下拉刷新6
    //此处刷新接口数据
    [socketRequest requestPersonalInfoWithID:[NFUserEntity shareInstance].userId];
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        [self doneLoadingTableViewData];
    });
    
    
    
}

// should return if data source model is reloading
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return reloading_;
}

// should return date data source was last changed
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    return [NSDate date];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"\n\n\n\n\ndidReceiveMemoryWarning\n\n\n\n\n");
    // Dispose of any resources that can be recreated.
}

@end
