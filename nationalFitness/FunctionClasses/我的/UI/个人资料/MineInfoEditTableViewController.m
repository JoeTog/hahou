//
//  MineInfoEditTableViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/7/14.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "MineInfoEditTableViewController.h"


@interface MineInfoEditTableViewController ()<UINavigationControllerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UITextViewDelegate,RegInSexViewControllerDelegate,ChatHandlerDelegate>

@end

@implementation MineInfoEditTableViewController{
    //头像
    __weak IBOutlet NFShowImageView *headImageV;
    
    //昵称
    __weak IBOutlet UILabel *nickNameLabel;
    //账号
    __weak IBOutlet UILabel *accountNumberLabel;
    //性别
    __weak IBOutlet UILabel *sexTypeLabel;
    //地区
    //self.areaLabel
    //个性签名
    __weak IBOutlet UILabel *personalSignatureLabel;
    
    
    __weak IBOutlet UILabel *phoneLabel;
    
    
    
    UIView * backgroundView;
    //选择地址的pickview
    MyPickerV *_pick;
    
    SocketModel * socketModel;
    SocketRequest *socketRequest;
    //个人信息详情实体
    PersonalInfoDetailEntity *detailInfoEntity;
    
    //编辑中的类型【需要根据这个类型】
    EditType editingType;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if (socketModel.delegate != self) {
        socketModel.delegate = self;
    }
    self.tabBarController.tabBar.hidden =YES;
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    //self.tableView.backgroundView=[[NFbaseViewController new] setThemeBackgroundImage];
    [self.tableView reloadData];
    [self initTextColor];
    
    if ([NFUserEntity shareInstance].mineHeadViewImage) {
        headImageV.image = [NFUserEntity shareInstance].mineHeadViewImage;
    }else{
        headImageV.image = [UIImage imageNamed:defaultHeadImaghe];
    }
    
    phoneLabel.text = [NFUserEntity shareInstance].phoneNum.length > 0?[NFUserEntity shareInstance].phoneNum:@"未设置";
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    if (!detailInfoEntity.isBang) {
        //如果没绑定的话就设置为显示
        self.eightthLabel.hidden = NO;
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"个人资料编辑";
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont boldSystemFontOfSize:fontSize],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self initUI];
    [self initScoket];
    [self initDataSource];
    
    
    //phoneLabel.text = [NFUserEntity shareInstance].phoneNum.length > 0?[NFUserEntity shareInstance].phoneNum:@"未设置";
    
    
}

-(void)initUI{
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 34)];
    [backBtn setImage:[UIImage imageNamed:@"everyday1_return"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    
//    ViewRadius(headImageV, headImageV.frame.size.width/2);
    ViewRadius(headImageV, 3);
    headImageV.userInteractionEnabled = NO;
    
    self.tableView.tableFooterView = [UIView new];
    
    
}

-(void)initDataSource{
    
    nickNameLabel.text = [NFUserEntity shareInstance].nickName;
    if ([[NFUserEntity shareInstance].userName containsString:@"hh_"]) {
        accountNumberLabel.text = @"未设置";
    }else{
        accountNumberLabel.text = [NFUserEntity shareInstance].userName;
    }
    if ([NFUserEntity shareInstance].sex == NFMan) {
        sexTypeLabel.text = @"男";
    }else if ([NFUserEntity shareInstance].sex == NFWoman){
        sexTypeLabel.text = @"女";
    }else{
        //默认为男
        sexTypeLabel.text = @"男";
    }
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
            [socketRequest requestPersonalInfoWithID:[NFUserEntity shareInstance].userId];
        }else{
            //设置本地数据
        }
    }else{
        //设置本地数据
    }
}

#pragma mark - 个人资料详情请求

#pragma mark - 设置个人信息
-(void)personalInfoSet:(EditType)type AndValue:(NSString *)value{
    editingType = type;
    [SVProgressHUD show];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"setUserInfo";
    if (type == EditNameType) {
        self.parms[@"data"] = @{@"nickname":value};
    }else if (type == EditTypePersonalSingature){
        self.parms[@"data"] = @{@"sign":value};
    }else if (type == EditTypeArea){
        self.parms[@"data"] = @{@"area":value};
    }else if (type == EditTypeSex){
        self.parms[@"data"] = @{@"sex":value};
    }
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
    self.parms[@"value"] = value;
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}

#pragma mark - 服务器返回
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_PersonalInfoDetail) {
        if ([chatModel isKindOfClass:[PersonalInfoDetailEntity class]]) {
            detailInfoEntity = chatModel;
            if ([detailInfoEntity.userHeadPicPath containsString:@"http"] || [detailInfoEntity.userHeadPicPath containsString:@"wx.qlogo.cn"]) {
                [headImageV ShowImageWithUrlStr:detailInfoEntity.userHeadPicPath completion:^(BOOL success, UIImage *image) {
                    [NFUserEntity shareInstance].mineHeadViewImage = image;
                }];
            }else{
                headImageV.image = [UIImage imageNamed:detailInfoEntity.userHeadPicPath];
                [NFUserEntity shareInstance].mineHeadViewImage = [UIImage imageNamed:detailInfoEntity.userHeadPicPath];
            }
            nickNameLabel.text = detailInfoEntity.nick_name;
            if ([detailInfoEntity.sex isEqualToString:@"女"]) {
                sexTypeLabel.text = @"女";
            }else{
                sexTypeLabel.text = @"男";
            }
            self.areaLabel.text = detailInfoEntity.area;
            personalSignatureLabel.text = detailInfoEntity.sign;
            [self.tableView reloadData];
        }
    }else if (messageType == SecretLetterType_PersonalInfoSet){
        if ([chatModel isKindOfClass:[NSDictionary class]]) {
            NSDictionary *infoDict = chatModel;
            //更改设置成功。根据记录的type值进行修改界面
            if (editingType == EditNameType) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    nickNameLabel.text = [[infoDict objectForKey:@"nickname"] description];
                    [NFUserEntity shareInstance].nickName = [[infoDict objectForKey:@"nickname"] description];
                });
            }else if (editingType == EditTypePersonalSingature){
                [NFUserEntity shareInstance].signText = [[infoDict objectForKey:@"sign"] description];
                dispatch_async(dispatch_get_main_queue(), ^{
                    personalSignatureLabel.text = [[infoDict objectForKey:@"sign"] description];
                    
                });
            }else if (editingType == EditTypeArea){
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.areaLabel.text = [[infoDict objectForKey:@"area"] description];
                });
            }
            
        }
    }
    
}

- (void)backClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

//cell设置成透明
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor whiteColor];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 1) {
        if (detailInfoEntity.isBang) {
            return 3;
        }else{
            return 4;
        }
    }
    return [super tableView:self.tableView numberOfRowsInSection:section];

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (indexPath.section == 1 && indexPath.row == 2) {
//        //个性签名
//        return 200;
//    }
    return [super tableView:self.tableView heightForRowAtIndexPath:indexPath];
}

//头高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
    
}

//设置headview 颜色
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
    [headerView setBackgroundColor:[UIColor colorSectionHeader]];
    return headerView;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (@available(iOS 13.0, *)) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell右箭头"]];
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
    }
    
    return cell;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            //头像 PersonalInfoChangeViewController
//            [self changeHeadClick];
            
            SGPhoto *temp = [[SGPhoto alloc] init];
            temp.identifier = @"";
            temp.thumbnail = [NFUserEntity shareInstance].mineHeadViewImage;
            temp.fullResolutionImage = [NFUserEntity shareInstance].mineHeadViewImage;
            HDPictureShowViewController *showImageViewCtrol = [[HDPictureShowViewController alloc] init];
            showImageViewCtrol.imageUrlList = @[temp];
            showImageViewCtrol.mainImageIndex = 0;
            showImageViewCtrol.isLuoYang = YES;
            showImageViewCtrol.isNeedNavigation = NO;
            [self.navigationController pushViewController:showImageViewCtrol animated:YES];
            
        }else if(indexPath.row == 1){
            [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
            //点击用户名 当为微信登录时病未绑定多信账号时 点击跳转到绑定界面
            if ([accountNumberLabel.text isEqualToString:@"未设置"]) {
                //绑定多信账号
                //BingingHaHouTableViewController
                UIStoryboard * sb = [UIStoryboard storyboardWithName:@"loginStoryboard" bundle:nil];
                BingingHaHouTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"BingingHaHouTableViewController"];
                [self.navigationController pushViewController:toCtrol animated:YES];
            }
        }else if (indexPath.row == 2){
            [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
            //点击用户名 当为微信登录时病未绑定多信账号时 点击跳转到绑定界面
            if ([phoneLabel.text isEqualToString:@"未设置"]) {
                //绑定多信账号
                //BingingHaHouTableViewController
                UIStoryboard * sb = [UIStoryboard storyboardWithName:@"loginStoryboard" bundle:nil];
                BingingHaHouTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"BingingHaHouTableViewController"];
                
                [self.navigationController pushViewController:toCtrol animated:YES];
            }else{
                //换绑手机号
                //
                
//                DCPaymentView *payAlert = [[DCPaymentView alloc]init];
//                payAlert.title = @"请输入支付密码";
//                CGFloat fellMoney = 0;
//                [payAlert show];
//                payAlert.completeHandle = ^(NSString *inputPwd) {
//                    [SVProgressHUD show];
//                    [socketRequest checkPayPasswordWithPassword:inputPwd];
//
//                };
//                payAlert.cancelHandle = ^{
//                    NSLog(@"");
//                };
                
                UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MineStoryboard" bundle:nil];
                ChangePhoneTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"ChangePhoneTableViewController"];
                [self.navigationController pushViewController:toCtrol animated:YES];
                
            }
        }
        else if (indexPath.row == 3){
            //昵称
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MineStoryboard" bundle:nil];
            PersonalInfoChangeViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"PersonalInfoChangeViewController"];
            toCtrol.editType = EditNameType;
            toCtrol.currentText = nickNameLabel.text;
            __weak typeof(self)weakSelf=self;
            [toCtrol returnInfoBlock:^(NSString *info, EditType type) {
                if (type == EditNameType) {
//                    nickNameLabel.text = info;
                    
                    [weakSelf personalInfoSet:EditNameType AndValue:info];
                    
                }
            }];
            [self.navigationController pushViewController:toCtrol animated:YES];
        }else if (indexPath.row == 2){
            //账号
//            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MineStoryboard" bundle:nil];
//            PersonalInfoChangeViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"PersonalInfoChangeViewController"];
//            toCtrol.editType = EditTypeAccount;
//            toCtrol.currentText = accountNumberLabel.text;
//            [toCtrol returnInfoBlock:^(NSString *info, EditType type) {
//                if (type == EditTypeAccount) {
//                    accountNumberLabel.text = info;
//                    
//                }
//            }];
//            [self.navigationController pushViewController:toCtrol animated:YES];
        }else if (indexPath.row == 4){
            //二维码
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"NFQRCodeStoryboard" bundle:nil];
            QRCodeShowViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"QRCodeShowViewController"];
            [self.navigationController pushViewController:toCtrol animated:YES];
        }
    }else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            //性别
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"loginStoryboard" bundle:nil];
            RegInSexViewController *sexCtrol = [sb instantiateViewControllerWithIdentifier:@"RegInSexViewController"];
            sexCtrol.isFromSet = YES;
            sexCtrol.delegate = self;
            if ([sexTypeLabel.text isEqualToString:@"男"]) {
                [NFUserEntity shareInstance].sex = NFMan;
            }else if ([sexTypeLabel.text isEqualToString:@"女"]){
                [NFUserEntity shareInstance].sex = NFWoman;
            }
            [self.navigationController pushViewController:sexCtrol animated:YES];
        }else if (indexPath.row == 1){
            //地区选择
            UIWindow *win = [[[UIApplication sharedApplication] windows] firstObject];
            backgroundView = [[UIView alloc] initWithFrame:win.bounds];
            backgroundView.backgroundColor = [UIColor darkGrayColor];
            backgroundView.alpha = 0.5;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackgroundClickk)];
            [backgroundView addGestureRecognizer:tap];
            [win addSubview:backgroundView];
            //创建pickview 点击确定，代码块回调
            //先设置为 150高度，因为如果设置2高度 pickview高度就成了2了，后面改变也很麻烦
            __weak typeof(self)weakSelf=self;
            _pick = [[MyPickerV alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 150, self.view.frame.size.width, 150) firstComponentW:0 secondComponentW:0 thirdComponentW:0 cancelBlock:^(NSError *error) {
                [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
                //取消按钮
                [UIView animateWithDuration:0.2 animations:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    _pick.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 2);
                } completion:^(BOOL finished) {
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    [backgroundView removeFromSuperview];
                    [_pick removeFromSuperview];
                    
                }];
            } sureBlock:^(NSString *areaString) {
                __strong typeof(weakSelf)strongSelf=weakSelf;
                [weakSelf.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
                
                //确定按钮
                strongSelf.areaLabel.text = areaString;
                //请求设置地区接口
                [strongSelf personalInfoSet:EditTypeArea AndValue:areaString];
#pragma mark - 进行请求街道 利用请求到的额数据进行创建选择街道的pickerview，请求完成再执行下面的
                [UIView animateWithDuration:0.2 animations:^{
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    _pick.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 2);
                } completion:^(BOOL finished) {
                    __strong typeof(weakSelf)strongSelf=weakSelf;
                    [backgroundView removeFromSuperview];
                    [_pick removeFromSuperview];
                }];
                
            }];
            //添加pickview到界面上
            //将创建好了的150高度的 pick 高度缩小为2，然后在加个动画让其高度变为150，实现动画效果。
            _pick.frame = CGRectMake(0, SCREEN_HEIGHT, self.view.frame.size.width, 2);
            [win addSubview:_pick];
            [UIView animateWithDuration:0.2 animations:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                strongSelf ->_pick.frame = CGRectMake(0, SCREEN_HEIGHT - 150, self.view.frame.size.width, 150);
            } completion:^(BOOL finished) {
                
            }];
        }else if (indexPath.row == 2){
            //个性签名
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MineStoryboard" bundle:nil];
            PersonalInfoChangeViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"PersonalInfoChangeViewController"];
            toCtrol.editType = EditTypePersonalSingature;
            toCtrol.currentText = personalSignatureLabel.text;
            __weak typeof(self)weakSelf=self;
            [toCtrol returnInfoBlock:^(NSString *info, EditType type) {
                if (type == EditTypePersonalSingature) {
                    personalSignatureLabel.text = info;
                    [weakSelf personalInfoSet:EditTypePersonalSingature AndValue:info];
                }
            }];
            [self.navigationController pushViewController:toCtrol animated:YES];
        }else if (indexPath.row == 3){
            //绑定多信账号
            //BingingHaHouTableViewController
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"loginStoryboard" bundle:nil];
            BingingHaHouTableViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"BingingHaHouTableViewController"];
            
            [self.navigationController pushViewController:toCtrol animated:YES];
        }
    }
}

#pragma mark - 地区选择
-(void)tapBackgroundClickk{
    
    __weak typeof(self)weakSelf=self;
    [UIView animateWithDuration:0.2 animations:^{
        __strong typeof(weakSelf)strongSelf=weakSelf;
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
        //将某个tableview 经过动画缩小到右上角一点
        //        tableView.transform = CGAffineTransformMakeScale(0.000001, 0.0001);
        _pick.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 2);
    } completion:^(BOOL finished) {
        __strong typeof(weakSelf)strongSelf=weakSelf;
        [backgroundView removeFromSuperview];
        [_pick removeFromSuperview];
    }];
    
}

#pragma mark - 性别修改
-(void)sendSexValue:(NFSex)value{
    if (value == 1) {
        sexTypeLabel.text = @"男";
        [NFUserEntity shareInstance].sex = NFMan;
        
        [self personalInfoSet:EditTypeSex AndValue:@"男"];
    }else if (value == 2){
        sexTypeLabel.text = @"女";
        [NFUserEntity shareInstance].sex = NFWoman;
        
        [self personalInfoSet:EditTypeSex AndValue:@"女"];
    }
    
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
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        headImageV.image = portraitImg;
        [NFUserEntity shareInstance].mineHeadViewImage = portraitImg;
        
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

-(void)initTextColor{
    self.fffFirstLabel.textColor = [UIColor colorMainTextColor];
    self.firstLabel.textColor = [UIColor colorMainTextColor];
    self.secondlabel.textColor = [UIColor colorMainTextColor];
    self.thirdLabel.textColor = [UIColor colorMainTextColor];
    self.forthLabel.textColor = [UIColor colorMainTextColor];
    self.areaLabel.textColor = [UIColor colorMainTextColor];
    self.sixthLanbel.textColor = [UIColor colorMainTextColor];
    self.secenthLabel.textColor = [UIColor colorMainTextColor];
    self.eightthLabel.textColor = [UIColor colorMainTextColor];
    self.ninthLabel.textColor = [UIColor colorMainTextColor];
    
    nickNameLabel.textColor = [UIColor colorMainTextColor];
    accountNumberLabel.textColor = [UIColor colorMainTextColor];
    sexTypeLabel.textColor = [UIColor colorMainTextColor];
    personalSignatureLabel.textColor = [UIColor colorMainTextColor];
    phoneLabel.textColor = [UIColor colorMainTextColor];
    
    self.fffFirstLabel.font = [UIFont fontMainText];
    self.firstLabel.font = [UIFont fontMainText];
    self.secondlabel.font = [UIFont fontMainText];
    self.thirdLabel.font = [UIFont fontMainText];
    self.forthLabel.font = [UIFont fontMainText];
    self.areaLabel.font = [UIFont fontMainText];
    self.sixthLanbel.font = [UIFont fontMainText];
    self.secenthLabel.font = [UIFont fontMainText];
    self.eightthLabel.font = [UIFont fontMainText];
    self.ninthLabel.font = [UIFont fontMainText];
    
//    self.areaLabel.text = @"";
    nickNameLabel.font = [UIFont fontMainText];
    accountNumberLabel.font = [UIFont fontMainText];
    sexTypeLabel.font = [UIFont fontMainText];
    personalSignatureLabel.font = [UIFont systemFontOfSize:13];
    phoneLabel.font = [UIFont fontMainText];
    
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
