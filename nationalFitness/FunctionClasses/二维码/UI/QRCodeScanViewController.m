//
//  QRCodeScanViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/7/12.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "QRCodeScanViewController.h"
#import "PublicDefine.h"
#import "QRCodeManager.h"
#import "YinDaoViewController.h"
#import "DirectSeeViewController.h"
#import "QRCodeShowViewController.h"
#import "SaoMiaoAddFriendViewController.h"
#import "MessageEntity.h"

@interface QRCodeScanViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,ChatHandlerDelegate>

@end

@implementation QRCodeScanViewController{
    
    NSTimer * timer;
    BOOL upOrdown;
    NSInteger num;
    
    AVCaptureSession * session;
    AVCaptureVideoPreviewLayer * preview;
    AVCaptureVideoPreviewLayer *previewLayer;
    
    //扫码结果
    NSString *stringValue;
    YinDaoViewController *yindao;
    BOOL isCaptureOutput_;
    
    FriendSearchResultEntity *searchResultEntity;
    
    SocketModel * socketModel;
    SocketRequest *socketRequest;
    
    NSDictionary *QRResultInfoDict;
    
    JQFMDB *jqFmdb;
    GroupCreateSuccessEntity *groupCreateSEntity;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setCamera];
    if (socketModel.delegate != self) {
        socketModel.delegate = self;
    }
    if (!timer) {
        timer = [NSTimer scheduledTimerWithTimeInterval:.02 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
    }
    [timer fireDate];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor clearColor];
    //相册按钮
    [self createNaviGationbarItemWithTitleImage:nil andTitleText:@"相册" andTag:1 isLeft:NO];
    
    self.title = @"二维码扫描";
    //控制扫描线上下
    upOrdown = NO;
    
    num = 0;
    
    if (![KeepAppBox checkValueForkey:@"QRCodeScanViewController"])
    {
        yindao = [[YinDaoViewController alloc] init];
        yindao.typeStr = @"QRCodeScanViewController";
        [[[[[UIApplication sharedApplication] delegate] window] viewForBaselineLayout] addSubview:yindao.view];
    }
    
    [NFUserEntity shareInstance].PushQRCode = @"0";
    
    [self initScoket];
    
}

-(void)initScoket{
    //取单例
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    socketRequest = [SocketRequest share];
    
    [socketModel getAddFriendList];
}

#pragma mark - 更改群组头像
//-(void)headPicPathUpLoad:(UIImage *)image{
//    [SVProgressHUD show];
//    //上传头像
//    NSMutableDictionary *sendDic = [[NSMutableDictionary alloc] initWithCapacity:3];
//    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
//    //    imageData = UIImagePNGRepresentation(image);
//    
//    NSString *type = [LoginManager typeForImageData:imageData];
//    [sendDic setObject:type forKey:@"imgaeType"];
//    [LoginManager execute:@selector(changeHeadPicpathManager) target:self callback:@selector(changeHeadPicpathManagerCallBack:) args:sendDic,imageData,nil];
//}
//
//- (void)changeHeadPicpathManagerCallBack:(id)data
//{
//    if (data)
//    {
//        if ([data objectForKey:@"error"]) {
//            [SVProgressHUD showInfoWithStatus:[data objectForKey:@"error"]];
//            return;
//        }else{
//            
//            //图片上传成功 设置群组头像信息
//            
//            [self setGroupInfoOfHeadPic:[data objectForKey:@"filePath"]];
//            
//        }
//    }
//    else
//    {
//        [SVProgressHUD showInfoWithStatus:@"上传失败"];
//    }
//}
//
//
//#pragma mark - 设置群组头像信息
//-(void)setGroupInfoOfHeadPic:(NSString *)headUrl{
//    [self.parms removeAllObjects];
//    self.parms[@"action"] = @"setGroupInfo";
//    self.parms[@"data"] = @{@"photo":headUrl};
//    self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
//    self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
//    self.parms[@"groupId"] = [[QRResultInfoDict objectForKey:@"groupId"] description];
//    NSString *Json = [JsonModel convertToJsonData:self.parms];
//    if ([socketModel isConnected]) {
//        [socketModel ping];
//    }
//    if ([socketModel isConnected]) {
//        [socketModel sendMsg:Json];
//    }else{
//        //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
//    }
//}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [timer invalidate];
    
    timer = nil;
}

-(void)animation1
{
    if (upOrdown == NO) {
        num ++;
        _lineImageView.frame = CGRectMake(_backimage.frame.origin.x+3, _backimage.frame.origin.y + 5 + 2*num, 185, 2);
        //扫描框的高度
        if (2*num == 180)
        {
            upOrdown = YES;
        }
    }
    else
    {
        num --;
        _lineImageView.frame = CGRectMake(_backimage.frame.origin.x+3, _backimage.frame.origin.y + 5 + 2*num, 185, 2);
        if (num == 0)
        {
            upOrdown = NO;
        }
    }
}

- (void)setCamera
{
    if (session)
    {
        [session startRunning];
        return;
    }
    //  摄像头设备
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError * error = nil;
    // 设置输入
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    //如果没摄像头 返回
    if (error)
    {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"设备摄像头不可用" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    //  设置输出(Metadata元数据)
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
    //设置线程代理
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    session = [[AVCaptureSession alloc]init];
    
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    
    if ([session canAddInput:input])
    {
        [session addInput:input];
    }
    
    if ([session canAddOutput:output])
    {
        [session addOutput:output];
    }
    //设置扫码类型 可以是条形码 二维码等
    output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    //限制二维码扫描区域
    //    [output setRectOfInterest:CGRectMake((_backimage.frame.origin.y + 20)/SCREEN_HEIGHT,
    //                                         ((SCREEN_WIDTH-_backimage.frame.size.width)/2)/SCREEN_WIDTH,
    //                                         _backimage.frame.size.width/SCREEN_HEIGHT,
    //                                         _backimage.frame.size.width/SCREEN_WIDTH)];
    //  设置预览图层
    if (!preview)
    {
        preview =[AVCaptureVideoPreviewLayer layerWithSession:session];
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        preview.frame =CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);
        [self.view.layer insertSublayer:preview atIndex:0];
    }
    [session startRunning];
}


#pragma mark AVCaptureMetadataOutputObjectsDelegate
#pragma mark - 扫码结束
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (isCaptureOutput_)
    {
        return;
    }
    isCaptureOutput_ = YES;
    
    if ([metadataObjects count] >0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        NSLog(@"这是扫描东西我先研究一下%@",metadataObject);
        //二维码地址
        stringValue = metadataObject.stringValue;
    }
    //
    
    //不是我们需要的格式就直接返回
    if (!stringValue)
    {
        //...s
    }
    //能打开就打开
    else
    {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:stringValue]])
        {
            [session stopRunning];
            DirectSeeViewController *derectCtrol = [[DirectSeeViewController alloc] init];
            derectCtrol.title = @"";
            derectCtrol.HtmlStr = stringValue;
//            derectCtrol.HtmlStr = @"https://www.baidu.com";
            [self.navigationController pushViewController:derectCtrol animated:YES];
            
            //餐厅
        }
        else if ([stringValue isEqualToString:[NFUserEntity shareInstance].userId])
        {
            //扫自己的二维码提示一个错误
            [SVProgressHUD showErrorWithStatus:@"你不能扫描自己哦"];
        }
        else
        {
            
            NSDictionary *infoDict = [JsonModel dictionaryWithJsonString:stringValue];
            QRResultInfoDict = infoDict;
            if ([[infoDict objectForKey:@"type"] isEqualToString:@"personal"]) {
                //根据扫描的结果跳转到添加好友界面
                UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
                AddFriendOrGroupdetailViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"AddFriendOrGroupdetailViewController"];
                toCtrol.addFriendId = [infoDict objectForKey:@"userId"];
                toCtrol.addFriendName = [infoDict objectForKey:@"userName"];
                toCtrol.headPicpath = [infoDict objectForKey:@"logo"];
                [self.navigationController pushViewController:toCtrol animated:YES];
                [session stopRunning];
            }else if ([[infoDict objectForKey:@"type"] isEqualToString:@"group"]){
                if (![ClearManager getNetStatus]) {
                    [SVProgressHUD showInfoWithStatus:@"请检查网络设置"];
                    return;
                }
                [session stopRunning];
                //扫描群组二维码 被拉进群
                //拉人进群请求
                [self.parms removeAllObjects];
                
                self.parms[@"action"] = @"scanCodeJoinGroup";
                self.parms[@"groupId"] = [[infoDict objectForKey:@"groupId"] description];
                
                self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
                self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
                self.parms[@"userNickname"] = [NFUserEntity shareInstance].nickName;
                
                self.parms[@"friendId"] = [[infoDict objectForKey:@"userId"] description];
                self.parms[@"friendName"] = [[infoDict objectForKey:@"userName"] description];
                self.parms[@"friendNickname"] = [[infoDict objectForKey:@"nickname"] description];
                
                
                NSString *Json = [JsonModel convertToJsonData:self.parms];
                [socketModel ping];
                if ([socketModel isConnected]) {
                    [socketModel sendMsg:Json];
                }else{
                    //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
                }
            }else if ([[[infoDict objectForKey:@"web_client_id"] description] length] > 0){
                //扫码登录
                //QRCodeLoginWithWebClientId
                [socketRequest QRCodeLoginWithWebClientId:[[infoDict objectForKey:@"web_client_id"] description]];
                
                
            }
        }
    }
    
    isCaptureOutput_ = NO;
}

#pragma mark - 收到服务器消息  9001
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_GroupQRCodeInviteSuccess){
        groupCreateSEntity = chatModel;
        //拉人成功
        UIStoryboard * sb = [UIStoryboard storyboardWithName:@"MessageChatStoryboard" bundle:nil];
        GroupChatViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"GroupChatViewController"];
        toCtrol.groupCreateSEntity = groupCreateSEntity;//返回群详情 ，跳转后的逻辑和正常一样
        [self.navigationController pushViewController:toCtrol animated:YES];
    }else if (messageType == SecretLetterType_GroupSetPersonalInfo){
        //暂未用
    }else if (messageType == SecretLetterType_GroupQRCodeAlreadyExist){
        [SVProgressHUD showInfoWithStatus:@"你已在该群聊中"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }else if (messageType == SecretLetterType_SocketRequestFailed){
        [SVProgressHUD showInfoWithStatus:kWrongMessage];
        [self createDispatchWithDelay:1 block:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }else if (messageType == SecretLetterType_QRCodeLoginFeedBack){//1028 扫码登录反馈
        if ([chatModel isKindOfClass:[NSDictionary class]]) {
            NSDictionary *resultD = chatModel;
            if ([[resultD objectForKey:@"result"] isEqualToString:@"0"]) {
                [SVProgressHUD showInfoWithStatus:@"扫码登录成功"];
                [self createDispatchWithDelay:1 block:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }else if ([[resultD objectForKey:@"result"] isEqualToString:@"1"]){
                [SVProgressHUD showInfoWithStatus:@"扫码登录失败"];
                [self createDispatchWithDelay:1 block:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }
        }
    }else if(messageType == SecretLetterType_yanzheng){
        
        [SVProgressHUD showInfoWithStatus:@"已提交管理员审核"];
        
        if ([NFUserEntity shareInstance].IsAutoBack || YES) {
            [self createDispatchWithDelay:1 block:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }else{
            [NFUserEntity shareInstance].IsAutoBack = YES;
        }
        
        
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: UIApplicationOpenSettingsURLString]];
    }
}

- (IBAction)showMyQRCodeClick:(id)sender {
    QRCodeShowViewController * showVC = [self.storyboard instantiateViewControllerWithIdentifier:@"QRCodeShowViewController"];
    [self.navigationController pushViewController:showVC animated:YES];
}

#pragma mark - 选取相册
-(void)barButtonClick:(UIButton *)sender{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = true;

    if (@available(iOS 13.0, *)) {
        picker.modalPresentationStyle =UIModalPresentationFullScreen;
    }
    [self presentViewController:picker animated:true completion:nil];
}


#pragma mark -  imagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [SVProgressHUD showWithStatus:@"正在识别..."];
    [self dismissViewControllerAnimated:YES completion:^{
        UIImage *image = info[UIImagePickerControllerEditedImage];
        if (!image) {
            image = info[UIImagePickerControllerOriginalImage];
        }
        //图片二维码数据
        NSString *string = [self readQRCodeInfoFromImage:image];
        
        if (string.length == 0 ) {
            [SVProgressHUD dismiss];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"未识别到二维码" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionSure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alertController addAction:actionSure];
            if (@available(iOS 13.0, *)) {
                alertController.modalPresentationStyle =UIModalPresentationFullScreen;
            }
            [self presentViewController:alertController animated:YES completion:nil];
            return ;
        }
        NSDictionary *infoDict = [JsonModel dictionaryWithJsonString:string];
        if ([[infoDict objectForKey:@"type"] isEqualToString:@"personal"]) {
            if ([[[infoDict objectForKey:@"userId"] description] isEqualToString:[NFUserEntity shareInstance].userId]) {
                //如果扫描自己的二维码
                [SVProgressHUD showInfoWithStatus:@"这是您本人出示的二维码!"];
                return;
            }
            //根据扫描的结果跳转到添加好友界面
            UIStoryboard * sb = [UIStoryboard storyboardWithName:@"ContantStoryboard" bundle:nil];
            AddFriendOrGroupdetailViewController *toCtrol = [sb instantiateViewControllerWithIdentifier:@"AddFriendOrGroupdetailViewController"];
            toCtrol.addFriendId = [infoDict objectForKey:@"userId"];
            toCtrol.addFriendName = [infoDict objectForKey:@"userName"];
            toCtrol.headPicpath = [infoDict objectForKey:@"logo"];
            [self.navigationController pushViewController:toCtrol animated:YES];
            [session stopRunning];
        }else if ([[infoDict objectForKey:@"type"] isEqualToString:@"group"]){
            
            if (![ClearManager getNetStatus]) {
                [SVProgressHUD showInfoWithStatus:@"请检查网络设置"];
                return;
            }
            if ([[infoDict objectForKey:@"userId"] isEqualToString:[NFUserEntity shareInstance].userId]) {
                //如果扫描自己的二维码
                [SVProgressHUD showInfoWithStatus:@"这是您本人出示的二维码!"];
                return;
            }
            [session stopRunning];
            //扫描群组二维码 被拉进群
            //拉人进群请求
            [self.parms removeAllObjects];
            self.parms[@"action"] = @"scanCodeJoinGroup";
            self.parms[@"groupId"] = [[infoDict objectForKey:@"groupId"] description];
            self.parms[@"userId"] = [NFUserEntity shareInstance].userId;
            self.parms[@"userName"] = [NFUserEntity shareInstance].userName;
            self.parms[@"friendId"] = [[infoDict objectForKey:@"userId"] description];
            self.parms[@"friendName"] = [[infoDict objectForKey:@"userName"] description];
            
            self.parms[@"userNickname"] = [NFUserEntity shareInstance].nickName;
            self.parms[@"friendNickname"] = [[infoDict objectForKey:@"nickname"] description];
            
            //
            
            NSString *Json = [JsonModel convertToJsonData:self.parms];
            [socketModel ping];
            if ([socketModel isConnected]) {
                [socketModel sendMsg:Json];
            }else{
                //        [SVProgressHUD showInfoWithStatus:kWrongMessage];
            }
        }
    }];
}






- (NSString *)readQRCodeInfoFromImage:(UIImage *)image
{
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    
//    CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(true), kCIContextPriorityRequestLow : @(false)}];
    
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
    
    CIImage *ciImage = [CIImage imageWithData:imageData];
    NSArray *ar = [detector featuresInImage:ciImage];
    CIQRCodeFeature *feature = [ar firstObject];
    NSLog(@"context: %@", feature.messageString);
    return feature.messageString;
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









