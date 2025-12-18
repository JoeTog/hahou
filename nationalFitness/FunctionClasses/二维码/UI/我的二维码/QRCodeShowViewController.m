//
//  QRCodeShowViewController.m
//  nationalFitness
//
//  Created by Joe on 2017/7/12.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "QRCodeShowViewController.h"
#import "PublicDefine.h"
#import "NFShowImageView.h"
#import <CoreImage/CoreImage.h>

#import "PHProgressHUD.h"
#import "MBProgressHUD.h"
#import "MBProgressHUD+NHAdd.h"

@interface QRCodeShowViewController (){
    
    __weak IBOutlet NFShowImageView *showCodeView;
    
    __weak IBOutlet UILabel *nicklAB;
    
    //backImageV
    
    __weak IBOutlet UIImageView *backImageV;
    
    //图片y约束
    __weak IBOutlet NSLayoutConstraint *backImageVYConstaint;
    
    
    
    __weak IBOutlet NSLayoutConstraint *QRBackWidthConstant;
    
    __weak IBOutlet NSLayoutConstraint *QRBackHeightConstant;
    
    
    __weak IBOutlet NSLayoutConstraint *imageWidthConstant;
    
    __weak IBOutlet NSLayoutConstraint *ImageHeightConstant;
    
    
    
    
    UIImage *showQRCode;
    
}

@end

@implementation QRCodeShowViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
//    [SVProgressHUD showWithStatus:@"二维码加载中。。。"];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
//    [SVProgressHUD showWithStatus:@"二维码加载中。。。"];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"我的二维码";
    
    QRBackWidthConstant.constant = SCREEN_WIDTH - SCREEN_WIDTH/18;
    QRBackHeightConstant.constant = SCREEN_HEIGHT/3*2;
    
    imageWidthConstant.constant = SCREEN_WIDTH/7*5;
    ImageHeightConstant.constant = SCREEN_WIDTH/7*5;
    
//    [MBProgressHUD showLoadToView:self.view
//                       titleColor:[UIColor whiteColor]
//                   bezelViewColor:nil
//                  backgroundColor:[UIColorFromRGB(0x2e3132) colorWithAlphaComponent:1]
//                            title:@"二维码加载中。。。"];
    
    UIButton * rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 27)];
    //        [rightBtn setTitle:@"转发" forState:(UIControlStateNormal)];
    [rightBtn setImage:[UIImage imageNamed:@"show更多"] forState:(UIControlStateNormal)];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [rightBtn addTarget:self action:@selector(handleRightBtn) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    //延迟1毫秒执行 svphud 可以调用主线程成功，如果不延迟 直接调用的话 svphud不能正常调用主线程
    [self performSelector:@selector(GenerateQRCode) withObject:nil afterDelay:0.01];
    
}

- (void)backClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
    //NSLog(@"");
    
}


#pragma mark - 生成二维码
-(void)GenerateQRCode{
    NSMutableDictionary *infoDict = [NSMutableDictionary new];
    infoDict[@"userId"] = [NFUserEntity shareInstance].userId;
    infoDict[@"type"] = @"personal";
    infoDict[@"userName"] = [NFUserEntity shareInstance].userName;
    infoDict[@"logo"] = [NFUserEntity shareInstance].mineHeadView;
    NSString *headPic = [NSString stringWithFormat:@"logo=%@",[NFUserEntity shareInstance].mineHeadView];
    
    NSString *Json = [JsonModel convertToJsonData:infoDict];
    //
    //[NFUserEntity shareInstance].matrixPicUrl = [NSString stringWithFormat:@"http://qr.liantu.com/api.php?text=%@",Json];
    
    // 1. 创建一个二维码滤镜实例(CIFilter)
//    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
//    // 滤镜恢复默认设置
//    [filter setDefaults];
//    // 2. 给滤镜添加数据
//    NSString *string = Json;
//    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
//    // 使用KVC的方式给filter赋值
//    [filter setValue:data forKeyPath:@"inputMessage"];
//    // 3. 生成二维码
//    CIImage *image = [filter outputImage];
//    UIImage *showImage = [[UIImage alloc] init];
//    showImage = [self createNonInterpolatedUIImageFormCIImage:image withSize:showCodeView.frame.size.width];
    //    showCodeView.image = showImage;
    if ([NFUserEntity shareInstance].MineQRCodeImage) {
        
        showCodeView.image = [NFUserEntity shareInstance].MineQRCodeImage;
    }else{
//        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showWithStatus:@"二维码加载中。。。"];
//        });
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
            //主要是生成二维码需要时间
            showQRCode = [[LogoQR new] QRurl:[NFUserEntity shareInstance].mineHeadView messages:Json];
            //二维码生成好后 调用主线程设置二维码
            dispatch_async(dispatch_get_main_queue(), ^{
                showCodeView.image = showQRCode;
                
                [NFUserEntity shareInstance].MineQRCodeImage = showCodeView.image;
                [SVProgressHUD dismiss];
            });
        });
        
    }
    
    ViewRadius(backImageV, 3);
    if ([NFUserEntity shareInstance].nickName) {
        nicklAB.text = [NFUserEntity shareInstance].nickName;
        nicklAB.textColor = [UIColor colorThemeColor];
    }
    
    //背景图片约束
    backImageVYConstaint.constant = kPLUS_SCALE_X(-40);
    
    [MBProgressHUD hideHUDForView:self.view];
}



- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
    
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
                imgObj.imageData = UIImageJPEGRepresentation(showCodeView.image, 1.0);
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
                UIImageWriteToSavedPhotosAlbum(showCodeView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
            }
        }];
        [sheet show];
    }else{
        LWWeChatActionSheet *sheet = [[LWWeChatActionSheet alloc] initWithWeChatActionSheetCancelButtonTitle:@"取消" title:nil otherButtonTitles:[NSArray arrayWithObjects:@"保存图片", nil] btnClickBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
//                if ([[TZImageManager new] authorizationStatusAuthorized]) {
                    UIImageWriteToSavedPhotosAlbum(showCodeView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
//                }
                
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    
    
    [NSString stringWithString:@""];
    
    
}



@end
