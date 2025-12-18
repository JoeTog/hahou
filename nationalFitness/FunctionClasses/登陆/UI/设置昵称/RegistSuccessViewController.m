//
//  RegistSuccessViewController.m
//  newTestUe
//
//  Created by 林向阳 on 15/12/3.
//  Copyright © 2015年 程龙. All rights reserved.
//

#import "RegistSuccessViewController.h"
#import "HeadCircleCell.h"
#import "HJCarouselViewLayout.h"
//#import "NFLoginManger.h"
//#import "UserHeightViewController.h"
//#import "UserWeightViewController.h"
//#import "NFShareMoodManager.h"



@interface RegistSuccessViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UITextFieldDelegate,ChatHandlerDelegate>
{
    
    __weak IBOutlet UIButton *womanBtn;
    __weak IBOutlet UIButton *manBtn;
    __weak IBOutlet UIButton *weightBtn;
    __weak IBOutlet UIButton *heightBtn;
    __weak IBOutlet UITextField *nameTextField;
    __weak IBOutlet UIImageView *showImageView;
    __weak IBOutlet UICollectionView *headCollectionView;
    NSMutableArray * imageArr_;
    HJCarouselViewLayout * layout;
    //处于中间图片的index
    CGFloat index_;
    
    SocketModel * socketModel;
    //编辑中的类型【需要根据这个类型】
    EditType editingType;
    
}

@end

@implementation RegistSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ViewBorderRadius(showImageView, showImageView.frame.size.width/2, 1, [UIColor redColor]);
    imageArr_ = [[NSMutableArray alloc]initWithCapacity:0];
    headCollectionView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 80.0);
    [headCollectionView setContentOffset:CGPointMake(-SCREEN_WIDTH/2 + 40.0, 0.0)];
    showImageView.hidden = NO;
    for (int i = 0; i <= 39; i ++) {
        NSString * headStr;
  
        headStr = [NSString stringWithFormat:@"head_man%d.jpg",i];
        [imageArr_ addObject:headStr];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardHidden:) name:UIKeyboardWillHideNotification object:nil];
    UINib * nib = [UINib nibWithNibName:@"HeadCircleCell" bundle:[NSBundle mainBundle]];
    [headCollectionView registerNib:nib forCellWithReuseIdentifier:@"HeadCircleCell"];
    layout = [[HJCarouselViewLayout alloc] initWithAnim:HJCarouselAnimCarousel];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(80, 80);
    headCollectionView.collectionViewLayout = layout;
    index_ = 0;
    
    [NFUserEntity shareInstance].smallpicpath = [imageArr_ objectAtIndex:index_];
    
    [manBtn addTarget:self action:@selector(changeSex:) forControlEvents:UIControlEventTouchUpInside];
    [womanBtn addTarget:self action:@selector(changeSex:) forControlEvents:UIControlEventTouchUpInside];
    
    manBtn.selected = YES;
    [NFUserEntity shareInstance].sex = NFMan;
    //匿名
//    [self hotAnonyInfoListManager];
    // Do any additional setup after loading the view.
    [self initSocket];
    
}

-(void)initSocket{
    //初始化
    socketModel = [SocketModel share];
    socketModel.isNeedWake = YES;
    socketModel.delegate = self;
    
    
}

#pragma mark - 收到服务器消息
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    [SVProgressHUD dismiss];
    if (messageType == SecretLetterType_PersonalInfoSet){
        if ([chatModel isKindOfClass:[NSDictionary class]]) {
            NSDictionary *infoDict = chatModel;
            [NFUserEntity shareInstance].nickName = [[infoDict objectForKey:@"nickname"] description];
//            [NFUserEntity shareInstance].mineHeadView = [[infoDict objectForKey:@"photo"] description];
            if([[[infoDict objectForKey:@"photo"] description] containsString:@"http"]){
                [NFUserEntity shareInstance].mineHeadView = [[infoDict objectForKey:@"photo"] description];
            }else{[NFUserEntity shareInstance].mineHeadView = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[[infoDict objectForKey:@"photo"] description]];
            }
            
            [KeepAppBox keepVale:[[infoDict objectForKey:@"nickname"] description] forKey:@"userNickName"];
            
            [self.navigationController popViewControllerAnimated:NO];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kGoto_Login_Rootview object:kGoto_Login_Rootview_SportHome];
        }
        
//        if (editingType == EditTypeHeadPic) {
//            //头像成功 设置昵称
//            [self personalInfoSet:EditNameType AndValue:nameTextField.text];
//        }else if (editingType == EditNameType){
//            //昵称成功 设置性别
//            if ([NFUserEntity shareInstance].sex == 1) {
//                [self personalInfoSet:EditTypeSex AndValue:@"男"];
//            }else if ([NFUserEntity shareInstance].sex == 2){
//                [self personalInfoSet:EditTypeSex AndValue:@"女"];
//            }
//        }else if (editingType == EditTypeSex){
//            if ([chatModel isKindOfClass:[NSDictionary class]]) {
//                NSDictionary *infoDict = chatModel;
//                [NFUserEntity shareInstance].nickName = [[infoDict objectForKey:@"nickname"] description];
//                [NFUserEntity shareInstance].mineHeadView = [[infoDict objectForKey:@"photo"] description];
//                [[NSNotificationCenter defaultCenter] postNotificationName:kGoto_Login_Rootview object:kGoto_Login_Rootview_SportHome];
//            }
//            
//        }
        
    }else if (messageType == SecretLetterType_LoginReceipt){
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
        if ([currentVC isKindOfClass:[RegistSuccessViewController class]]) {
            
        }
        //断线重连
//        [self personalInfoSet:EditTypeHeadPic AndValue:[NFUserEntity shareInstance].smallpicpath];
    }
}

//更改性别
//每次更改性别 重新 请求接口
- (void)changeSex:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    if (btn.selected) {
        return;
    }
    if (btn == manBtn) {
        manBtn.selected = YES;
        womanBtn.selected = NO;
        [NFUserEntity shareInstance].sex = NFMan;
        [heightBtn setTitle:@"175cm" forState:UIControlStateNormal];
        [NFUserEntity shareInstance].userHeight = @"175";
        [weightBtn setTitle:@"65kg" forState:UIControlStateNormal];
        [NFUserEntity shareInstance].userWeight = @"65";
    }
    else
    {
        manBtn.selected = NO;
        womanBtn.selected = YES;
        [NFUserEntity shareInstance].sex = NFWoman;
        [heightBtn setTitle:@"165cm" forState:UIControlStateNormal];
        [NFUserEntity shareInstance].userHeight = @"165";
        [weightBtn setTitle:@"50kg" forState:UIControlStateNormal];
        [NFUserEntity shareInstance].userWeight = @"50";
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([NFUserEntity shareInstance].userHeight.length > 0) {
        [heightBtn setTitle:[NSString stringWithFormat:@"%@cm",[NFUserEntity shareInstance].userHeight] forState:UIControlStateNormal];
    }
    else
    {
        [heightBtn setTitle:@"175cm" forState:UIControlStateNormal];
        [NFUserEntity shareInstance].userHeight = @"175";
    }
    
    if ([NFUserEntity shareInstance].userWeight.length > 0) {
        [weightBtn setTitle:[NSString stringWithFormat:@"%@kg",[NFUserEntity shareInstance].userWeight] forState:UIControlStateNormal];
        
    }
    else
    {
        [weightBtn setTitle:@"65kg" forState:UIControlStateNormal];
        [NFUserEntity shareInstance].userWeight = @"65";
    }
}

#pragma mark - scrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    showImageView.hidden = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    showImageView.hidden = NO;
    index_ = layout.index;
    [NFUserEntity shareInstance].smallpicpath = [imageArr_ objectAtIndex:index_];
}


#pragma mark UICollectionViewDataSource delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"click %ld", (long)indexPath.row);
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [imageArr_ count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HeadCircleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HeadCircleCell" forIndexPath:indexPath];
    cell.headImageView.image = [UIImage imageNamed:[imageArr_ objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - 键盘通知
- (void)keyBoardShow:(NSNotification *)notify
{
    NSDictionary* info = [notify userInfo];
    //获取键盘的尺寸
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat animationDuration= [[notify.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:animationDuration animations:^{
        self.view.frame = CGRectMake(0, - 30.0f, SCREEN_WIDTH, self.view.frame.size.height);
    } completion:nil];
}

- (void)keyBoardHidden:(NSNotification *)notify
{
    CGFloat animationDuration= [[notify.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:animationDuration animations:^{
        self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.view.frame.size.height);
    } completion:nil];
}


#pragma mark - 匿名接口请求

- (void)hotAnonyInfoListManager
{
    NSMutableDictionary *sendDic = [[NSMutableDictionary alloc] initWithCapacity:1];
    [sendDic setObject:[NSString stringWithFormat:@"%@",@([NFUserEntity shareInstance].sex)] forKey:@"sex"];
    
//    [NFShareMoodManager execute:@selector(hotAnonyInfoManager) target:self callback:@selector(hotAnonyInfoListCallBack:) args:sendDic,nil];
}

- (void)hotAnonyInfoListCallBack:(id)data
{
    if (data)
    {
//        _anonyInfoentity = [data objectForKey:@"info"];
//        nameTextField.text = _anonyInfoentity.anonyName;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

#pragma mark - 发送设置用户个性信息请求和回调
- (void)registerInfo
{
    NSMutableDictionary *sendDic = [[NSMutableDictionary alloc] initWithCapacity:8];
    [sendDic setObject:nameTextField.text forKey:@"nickName"];
    [sendDic setObject:[NSString stringWithFormat:@"%@",@([NFUserEntity shareInstance].sex)] forKey:@"sex"];
    [sendDic setObject:@"" forKey:@"birthDay"];
    [sendDic setObject:[NFUserEntity shareInstance].userHeight forKey:@"userHeight"];
    [sendDic setObject:[NFUserEntity shareInstance].userWeight forKey:@"userWeight"];
    [sendDic setObject:@"" forKey:@"headFromType"];
    if ([NFUserEntity shareInstance].smallpicpath)
    {
        if ([NFUserEntity shareInstance].smallpicpath.length <= 15
            )
        {
            [sendDic setObject:@"1" forKey:@"headFromType"];
        }
        [sendDic setObject:[NFUserEntity shareInstance].smallpicpath forKey:@"userHeadPath"];
    }
    else
    {
        [sendDic setObject:@"" forKey:@"userHeadPath"];
    }
    if ([NFUserEntity shareInstance].healthStatus.length > 0)
    {
        [sendDic setObject:[NFUserEntity shareInstance].healthStatus forKey:@"healthStatus"];
    }
    else
    {
        [sendDic setObject:@"3" forKey:@"healthStatus"];
    }
    
    [SVProgressHUD show];
    
//    [NFMineManager execute:@selector(registerInfoManager) target:self callback:@selector(registerInfoCallBack:) args:sendDic,nil];
}

- (void)registerInfoCallBack :(id)data
{
    if (data)
    {
        if ([data objectForKey:kWrongDlog])
        {
            [SVProgressHUD showErrorWithStatus:[data objectForKey:kWrongDlog]];
        }
        else
        {
            [SVProgressHUD dismiss];
            //保存用户登录返回的数据
            NSDictionary *infoDic = [data objectForKey:@"loginEntity"];
            [KeepAppBox keepVale:[[infoDic objectForKey:@"nickname"] description] forKey:@"nickname"];
            [KeepAppBox keepVale:[[infoDic objectForKey:@"mobile"] description] forKey:@"mobile"];
            [KeepAppBox keepVale:[[infoDic objectForKey:@"hdnumber"] description] forKey:@"hdnumber"];
            [KeepAppBox keepVale:[[infoDic objectForKey:@"userId"] description] forKey:@"userId"];
            [KeepAppBox keepVale:[[infoDic objectForKey:@"sex"] description] forKey:@"sex"];
            [KeepAppBox keepVale:[[infoDic objectForKey:@"userType"] description] forKey:@"userType"];
            [KeepAppBox keepVale:[[infoDic objectForKey:@"smallpicPath"] description] forKey:@"smallpicPath"];
            [KeepAppBox keepVale:[[infoDic objectForKey:@"bigpicPath"] description] forKey:@"bigpicPath"];
            [KeepAppBox keepVale:[[infoDic objectForKey:@"age"] description] forKey:@"age"];
            [KeepAppBox keepVale:[[infoDic objectForKey:@"birthday"] description] forKey:@"birthday"];
            [KeepAppBox keepVale:[[infoDic objectForKey:@"height"] description] forKey:@"height"];
            [KeepAppBox keepVale:[[infoDic objectForKey:@"weight"] description] forKey:@"weight"];
            [KeepAppBox keepVale:[[infoDic objectForKey:@"signature"] description] forKey:@"signature"];
            [KeepAppBox keepVale:[[infoDic objectForKey:@"qrbigpicPath"] description] forKey:@"qrbigpicPath"];
            [KeepAppBox keepVale:[[infoDic objectForKey:@"qrsmallpicPath"] description] forKey:@"qrsmallpicPath"];
            [KeepAppBox keepVale:[[infoDic objectForKey:@"hobby"] description] forKey:@"hobby"];
            [KeepAppBox keepVale:[[infoDic objectForKey:@"mobile"] description] forKey:kLoginUserName];
            [KeepAppBox keepVale:[[infoDic objectForKey:@"password"] description] forKey:kLoginPassWord];
            [KeepAppBox keepVale:[[data objectForKey:@"healthStatus"] description] forKey:@"healthStatus"];
            //直接登陆首页界面
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kGoto_Login_Rootview object:kGoto_Login_Rootview_SportHome];
        }
    }
    else
    {
        [SVProgressHUD dismiss];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 按钮点击事件
//身高界面
- (IBAction)height:(id)sender {
//    UserHeightViewController *heightCtrol = [[UserHeightViewController alloc] initWithNibName:@"UserHeightView" bundle:nil];
//    [self.navigationController pushViewController:heightCtrol animated:YES];
}

//体重
- (IBAction)weight:(id)sender {
//    UserWeightViewController *weiCtrol = [[UserWeightViewController alloc] initWithNibName:@"UserWeightView" bundle:nil];
//    [self.navigationController pushViewController:weiCtrol animated:YES];
}

//跳过
- (IBAction)tiaoguo:(id)sender {
    [NFUserEntity shareInstance].sex = NFMan;
    [NFUserEntity shareInstance].userHeight = @"175";
    [NFUserEntity shareInstance].userWeight = @"65";
    [self registerInfo];
}



//完成
- (IBAction)complite:(id)sender {
    [self.view endEditing:YES];
    if (nameTextField.text.length <=  0) {
        [SVProgressHUD showErrorWithStatus:@"请输入昵称"];
    }
    else{
        

            NSData *imageData;
            imageData = [ClearManager imageDataScale:[UIImage imageNamed:[NFUserEntity shareInstance].smallpicpath] scale:1];
            UIImage *image = [UIImage imageWithData:imageData];
            CGSize size = image.size;
            [[AliyunOSSUpload aliyunInit] uploadImage:@[image] success:^(NSArray<NSString *> * _Nonnull nameArray) {
                    if(nameArray.count == 0){
                        [SVProgressHUD showErrorWithStatus:@"图片上传失败"];
                        return;
                    }
                
                    [NFUserEntity shareInstance].smallpicpath = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[nameArray firstObject]];
                    //图片上传成功
                    [self personalInfoSet:EditTypeHeadPic AndValue:[NFUserEntity shareInstance].smallpicpath];
                }];
            
            
        return;
        //
//        [self registerInfo];
        if ([socketModel isConnected]) {
            [socketModel ping];
            if ([socketModel isConnected]) {
                [SVProgressHUD show];
                
                [self headPicPathUpLoad:[UIImage imageNamed:[NFUserEntity shareInstance].smallpicpath]];
                
                
            }
        }else{
            [socketModel initSocket];
            __weak typeof(self)weakSelf=self;
            [socketModel returnConnectSuccedd:^{
                __strong typeof(weakSelf)strongSelf=weakSelf;
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                    UIViewController *currentVC = [NFMyManage getCurrentVCFrom:rootViewController];
                    if (![currentVC isKindOfClass:[RegistSuccessViewController class]]) {
                        return ;
                    }
                    if ([strongSelf ->socketModel isConnected]) {
                        [strongSelf ->socketModel ping];
                    }
                    if (strongSelf ->socketModel.isConnected) {
                        [SVProgressHUD show];
                        [strongSelf personalInfoSet:EditTypeHeadPic AndValue:[NFUserEntity shareInstance].smallpicpath];
                    }
                });
                
            }];
        }
        
        
    }
}


-(void)headPicPathUpLoad:(UIImage *)image{
    [SVProgressHUD show];
    //上传头像
    NSMutableDictionary *sendDic = [[NSMutableDictionary alloc] initWithCapacity:3];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    //    imageData = UIImagePNGRepresentation(image);
    
    NSString *type = [LoginManager typeForImageData:imageData];
    [sendDic setObject:type forKey:@"imgaeType"];
    [LoginManager execute:@selector(changeHeadPicpathManager) target:self callback:@selector(changeHeadPicpathManagerCallBack:) args:sendDic,imageData,nil];
}

- (void)changeHeadPicpathManagerCallBack:(id)data
{
    if (data)
    {
        if ([data objectForKey:@"error"]) {
            [SVProgressHUD showInfoWithStatus:[data objectForKey:@"error"]];
            return;
        }else{
            
            [NFUserEntity shareInstance].smallpicpath = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[[data objectForKey:@"filePath"] description]];
            //图片上传成功 
            [self personalInfoSet:EditTypeHeadPic AndValue:[[data objectForKey:@"filePath"] description]];
            
        }
    }
    else
    {
        [SVProgressHUD showInfoWithStatus:@"上传失败"];
    }
}

#pragma mark - 循环设置个人信息
-(void)personalInfoSet:(EditType)type AndValue:(NSString *)value{
    editingType = type;
    [SVProgressHUD show];
    [self.parms removeAllObjects];
    self.parms[@"action"] = @"setUserInfo";
//    if (type == EditNameType) {
//        self.parms[@"type"] = @"nickname";
//    }else if (type == EditTypePersonalSingature){
//        self.parms[@"type"] = @"sign";
//    }else if (type == EditTypeArea){
//        self.parms[@"type"] = @"area";
//    }else if (type == EditTypeSex){
//        self.parms[@"type"] = @"sex";
//    }else if (type == EditTypeHeadPic){
//        self.parms[@"type"] = @"photo";
//    }
    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
//    self.parms[@"value"] = value;
    self.parms[@"data"] = @{@"nickname":nameTextField.text,@"sex":@"男",@"photo":value,@"reg_id":[JPUSHService registrationID]?[JPUSHService registrationID]:@""};
    
    NSString *Json = [JsonModel convertToJsonData:self.parms];
    [socketModel ping];
    if ([socketModel isConnected]) {
        [socketModel sendMsg:Json];
    }else{
        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
    }
}


//随机昵称
- (IBAction)suiji:(id)sender {
    [self hotAnonyInfoListManager];
}

//懒加载
-(NSMutableDictionary *)parms{
    if (!_parms) {
        _parms = [[NSMutableDictionary alloc] init];
    }
    return _parms;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardDidHideNotification object:nil];
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
