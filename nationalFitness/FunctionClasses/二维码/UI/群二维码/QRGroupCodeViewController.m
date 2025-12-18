



//
//  QRGroupCodeViewController.m
//  nationalFitness
//
//  Created by joe on 2018/1/8.
//  Copyright © 2018年 chenglong. All rights reserved.
//

#import "QRGroupCodeViewController.h"

@interface QRGroupCodeViewController ()<ChatHandlerDelegate>

@end

@implementation QRGroupCodeViewController{
    
    //群聊头像
    
    __weak IBOutlet NFShowImageView *groupHeadImageV;
    
    //背景y约束
    __weak IBOutlet NSLayoutConstraint *backImageVYConstaint;
    
    UIImage *showQRCode;
    SocketModel * socketModel;
    
    //s
    
    __weak IBOutlet NSLayoutConstraint *QGBackWidthConstant;
    
    
    __weak IBOutlet NSLayoutConstraint *QRBackheightConstant;
    
    
    
    __weak IBOutlet NSLayoutConstraint *QRIamgeWidthConstant;
    
    
    __weak IBOutlet NSLayoutConstraint *QRImageHeightConstant;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"群二维码名片";
    
    QGBackWidthConstant.constant = SCREEN_WIDTH - SCREEN_WIDTH/18;
    QRBackheightConstant.constant = SCREEN_HEIGHT/3*2;
    
    QRIamgeWidthConstant.constant = SCREEN_WIDTH/7*5;
    QRImageHeightConstant.constant = SCREEN_WIDTH/7*5;
    
    
    
    UIButton * rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 27)];
    //        [rightBtn setTitle:@"转发" forState:(UIControlStateNormal)];
    [rightBtn setImage:[UIImage imageNamed:@"chatMore"] forState:(UIControlStateNormal)];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [rightBtn addTarget:self action:@selector(handleRightBtn) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    //延迟1毫秒执行 svphud 可以调用主线程成功，如果不延迟 直接调用的话 svphud不能正常调用主线程
    [self performSelector:@selector(GenerateQRCode) withObject:nil afterDelay:0.01];
    
    [groupHeadImageV ShowImageWithUrlStr:self.groupIconUrl placeHoldName:defaultHeadImaghe completion:^(BOOL success, UIImage *image) {
        
    }];
    
    socketModel = [SocketModel share];
    socketModel.delegate = self;
    
    
    
    
}

#pragma mark - 收到服务器消息
-(void)didReceiveMessage:(id)chatModel type:(SecretLetterModel)messageType{
    if (messageType == SecretLetterType_GroupQRCodeInviteSuccessNotificate || messageType == SecretLetterType_GroupDetailChanged) {
        //当有人扫描二维码进群了 通知刷新详情
        self.returnRefreshBlock(YES);
    }
}


#pragma mark - 生成二维码
-(void)GenerateQRCode{
    NSMutableDictionary *infoDict = [NSMutableDictionary new];
    infoDict[@"groupId"] = self.groupId;
    infoDict[@"userId"] = [NFUserEntity shareInstance].userId;
    infoDict[@"userName"] = [NFUserEntity shareInstance].userName;
    infoDict[@"type"] = @"group";
    infoDict[@"nickname"] = [NFUserEntity shareInstance].nickName;;
    
//    infoDict[@"logo"] = [NFUserEntity shareInstance].mineHeadView;
//    NSString *headPic = [NSString stringWithFormat:@"logo=%@",[NFUserEntity shareInstance].mineHeadView];
    
    NSString *Json = [JsonModel convertToJsonData:infoDict];
    
//    [NFUserEntity shareInstance].groupMatrixPicUrl = [NSString stringWithFormat:@"http://qr.liantu.com/api.php?text=%@",Json];
    
    [SVProgressHUD showWithStatus:@"二维码加载中。。。"];
    //        });
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
        //主要是生成二维码需要时间
        showQRCode = [[LogoQR new] QRurl:self.groupIconUrl messages:Json];
        //二维码生成好后 调用主线程设置二维码
        dispatch_async(dispatch_get_main_queue(), ^{
            self.groupQRCodeImageV.image = showQRCode;
            [SVProgressHUD dismiss];
        });
    });
    
    ViewRadius(self.backView, 3);
//    if ([NFUserEntity shareInstance].nickName) {
        self.groupNameLabel.text = self.groupName;
        self.groupNameLabel.textColor = [UIColor colorThemeColor];
//    }
    
    //背景图片约束
    backImageVYConstaint.constant = kPLUS_SCALE_X(-40);
    
    [MBProgressHUD hideHUDForView:self.view];
}

#pragma mark - 右侧关闭
- (void)handleRightBtn
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]] == YES) {
        LWWeChatActionSheet *sheet = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:nil otherButtonTitles:[NSArray arrayWithObjects:@"转发到微信",@"保存图片", nil] btnClickBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                //1.创建多媒体消息结构体
                WXMediaMessage *mediaMsg = [WXMediaMessage message];
                //2.创建多媒体消息中包含的图片数据对象
                WXImageObject *imgObj = [WXImageObject object];
                //图片真实数据
                //    imgObj.imageData = [NSData dataWithContentsOfURL:@""];
                imgObj.imageData = UIImageJPEGRepresentation(self.groupQRCodeImageV.image, 1.0);
                //多媒体数据对象
                mediaMsg.mediaObject = imgObj;
                SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
                //多媒体消息的内容
                req.message = mediaMsg;
                //指定为发送多媒体消息（不能同时发送文本和多媒体消息，两者只能选其一）
                req.bText = NO;
                //指定发送到会话(聊天界面)
                req.scene = WXSceneSession;
                [WXApi sendReq:req];
            }else if (buttonIndex == 1){
                UIImageWriteToSavedPhotosAlbum(self.groupQRCodeImageV.image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
            }
        }];
        [sheet show];
    }else{
        LWWeChatActionSheet *sheet = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:nil otherButtonTitles:[NSArray arrayWithObjects:@"保存图片", nil] btnClickBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                UIImageWriteToSavedPhotosAlbum(self.groupQRCodeImageV.image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
            }
        }];
        [sheet show];
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (!error) {
        [SVProgressHUD showSuccessWithStatus:@"已保存到系统相册"];
    }else{
//        NSDictionary *errorDict = error.userInfo;
//        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@\n%@",[errorDict objectForKey:@"NSLocalizedRecoverySuggestion"],[errorDict objectForKey:@"NSLocalizedDescription"]]];
        int author = [ALAssetsLibrary authorizationStatus];
        NSLog(@"author type:%d",author);
        if(author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"无法使用相册" message:@"请在iPhone的\"设置-隐私-照片\"中允许访问照片。" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionCannel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            UIAlertAction *actionSure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alertController addAction:actionSure];
            [alertController addAction:actionCannel];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
    
}

#pragma mark - 代码块传值相关
//是否需要刷新详情
-(void)returnRefreshBlockk:(ReturnRefreshBlock)block{
    if (self.returnRefreshBlock != block) {
        self.returnRefreshBlock = block;
    }
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
