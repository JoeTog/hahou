//
//  RegSetImageViewCtroller.m
//  nationalFitness
//
//  Created by Joe on 2017/9/12.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "RegSetImageViewCtroller.h"

@interface RegSetImageViewCtroller (){
    BOOL isUpdating_;
    NSDictionary * imageDic_;
}
@property (nonatomic, strong) UIImage *editedImage;
@property (nonatomic, strong) UIImage *gettedImage;

@property (nonatomic, strong) UIImageView *showImgView;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIView *ratioView;

@property (nonatomic) CGRect oldFrame;
@property (nonatomic) CGRect largeFrame;
@property (nonatomic) CGFloat limitRatio;
@property (nonatomic) CGRect latestFrame;
@property (nonatomic) CGRect cropFrame;
@end

@implementation RegSetImageViewCtroller

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.limitRatio = 3.0f;
    switch (_cutType)
    {
        case CutUserHeadImage:
        {
            self.title = @"选择头像";
            self.cropFrame = CGRectMake((SCREEN_WIDTH-300.f)/2.0, 150.0f, 300.0f, 300.0f);
        }
            break;
        case CutActivityHeadImag:
        {
            self.title = @"选择活动图片";
            self.cropFrame = CGRectMake((SCREEN_WIDTH-300.f)/2.0, 150.0f, 300.0f, 300.0f);
        }
            break;
        case CutThemeShowImag:
        {
            self.title = @"选择主题秀封面";
            self.cropFrame = CGRectMake((SCREEN_WIDTH-280.f)/2.0, 200.0f, 280.0f, 158.0f);
        }
            break;
            
        case CutClubBadgeImage:
        {
            self.title = @"选择徽章";
            self.cropFrame = CGRectMake((SCREEN_WIDTH-300.f)/2.0, 150.0f, 300.0f, 300.0f);
        }
            break;
        case CutClubHeadImage:
        {
            self.title = @"选择社团图片";
            self.cropFrame = CGRectMake((SCREEN_WIDTH-300.f)/2.0, 150.0f, 300.0f, 300.0f);
        }
            break;
        case CutOnlyCutImage:
        {
            self.title = @"编辑图片";
            self.cropFrame = CGRectMake(0.0f, 150.0f, SCREEN_WIDTH, SCREEN_WIDTH * 0.73);
        }
            break;
        case CutReportImage:
        {
            self.title = @"选择举报图片";
            self.cropFrame = CGRectMake((SCREEN_WIDTH-300.f)/2.0, 150.0f, 300.0f, 300.0f);
        }
            break;
        default:
            break;
    }
    self.showImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.showImgView setMultipleTouchEnabled:YES];
    [self.showImgView setUserInteractionEnabled:YES];
    [self.showImgView setImage:self.originalImage];
    [self.showImgView setUserInteractionEnabled:YES];
    [self.showImgView setMultipleTouchEnabled:YES];
    
    CGFloat oriWidth = self.cropFrame.size.width;
    CGFloat oriHeight = self.originalImage.size.height * (oriWidth / self.originalImage.size.width);
    CGFloat oriX = self.cropFrame.origin.x + (self.cropFrame.size.width - oriWidth) / 2;
    CGFloat oriY = self.cropFrame.origin.y + (self.cropFrame.size.height - oriHeight) / 2;
    self.oldFrame = CGRectMake(oriX, oriY, oriWidth, oriHeight);
    self.latestFrame = self.oldFrame;
    self.showImgView.frame = self.oldFrame;
    
    self.largeFrame = CGRectMake(0, 0, self.limitRatio * self.oldFrame.size.width, self.limitRatio * self.oldFrame.size.height);
    
    [self addGestureRecognizers];
    [self.view addSubview:self.showImgView];
    
    self.overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.overlayView.backgroundColor = [UIColor blackColor];
    self.overlayView.alpha = 0.5f;
    self.overlayView.userInteractionEnabled = NO;
    self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.overlayView];
    
    self.ratioView = [[UIView alloc] initWithFrame:self.cropFrame];
    self.ratioView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.ratioView.layer.borderWidth = 1.0f;
    self.ratioView.autoresizingMask = UIViewAutoresizingNone;
    [self.view addSubview:self.ratioView];
    
    [self overlayClipping];
    
    [self setNavBarButton];
    
}


- (void)setNavBarButton
{
    // 设置 navigation bar 右侧按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(handleRightBtn) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0.0f, 0.0f, 40.0f, 30.0f);
    button.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = buttonItem;
}

- (void)overlayClipping
{
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef path = CGPathCreateMutable();
    // Left side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0, 0,
                                        self.ratioView.frame.origin.x,
                                        self.overlayView.frame.size.height));
    // Right side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(
                                        self.ratioView.frame.origin.x + self.ratioView.frame.size.width,
                                        0,
                                        self.overlayView.frame.size.width - self.ratioView.frame.origin.x - self.ratioView.frame.size.width,
                                        self.overlayView.frame.size.height));
    // Top side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0, 0,
                                        self.overlayView.frame.size.width,
                                        self.ratioView.frame.origin.y));
    // Bottom side of the ratio view
    CGPathAddRect(path, nil, CGRectMake(0,
                                        self.ratioView.frame.origin.y + self.ratioView.frame.size.height,
                                        self.overlayView.frame.size.width,
                                        self.overlayView.frame.size.height - self.ratioView.frame.origin.y + self.ratioView.frame.size.height));
    maskLayer.path = path;
    self.overlayView.layer.mask = maskLayer;
    CGPathRelease(path);
}

- (void) addGestureRecognizers
{
    // add pinch gesture
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:pinchGesture];
    
    // add pan gesture
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.view addGestureRecognizer:panGesture];
}


#pragma mark - UIGestureRecognizer

- (void)handlePinch:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    UIView *view = self.showImgView;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        pinchGestureRecognizer.scale = 1;
    }
    else if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGRect newFrame = self.showImgView.frame;
        newFrame = [self handleScaleOverflow:newFrame];
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:0.3f animations:^{
            self.showImgView.frame = newFrame;
            self.latestFrame = newFrame;
        }];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = self.showImgView;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        // calculate accelerator
        CGFloat absCenterX = self.cropFrame.origin.x + self.cropFrame.size.width / 2;
        CGFloat absCenterY = self.cropFrame.origin.y + self.cropFrame.size.height / 2;
        CGFloat scaleRatio = self.showImgView.frame.size.width / self.cropFrame.size.width;
        CGFloat acceleratorX = 1 - ABS(absCenterX - view.center.x) / (scaleRatio * absCenterX);
        CGFloat acceleratorY = 1 - ABS(absCenterY - view.center.y) / (scaleRatio * absCenterY);
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x * acceleratorX, view.center.y + translation.y * acceleratorY}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        // bounce to original frame
        CGRect newFrame = self.showImgView.frame;
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:0.3f animations:^{
            self.showImgView.frame = newFrame;
            self.latestFrame = newFrame;
        }];
    }
}

- (CGRect)handleScaleOverflow:(CGRect)newFrame
{
    // bounce to original frame
    CGPoint oriCenter = CGPointMake(newFrame.origin.x + newFrame.size.width/2, newFrame.origin.y + newFrame.size.height/2);
    if (newFrame.size.width < self.oldFrame.size.width) {
        newFrame = self.oldFrame;
    }
    if (newFrame.size.width > self.largeFrame.size.width) {
        newFrame = self.largeFrame;
    }
    newFrame.origin.x = oriCenter.x - newFrame.size.width/2;
    newFrame.origin.y = oriCenter.y - newFrame.size.height/2;
    return newFrame;
}

- (CGRect)handleBorderOverflow:(CGRect)newFrame
{
    // horizontally
    if (newFrame.origin.x > self.cropFrame.origin.x) newFrame.origin.x = self.cropFrame.origin.x;
    if (CGRectGetMaxX(newFrame) < self.cropFrame.size.width) newFrame.origin.x = self.cropFrame.size.width - newFrame.size.width;
    // vertically
    if (newFrame.origin.y > self.cropFrame.origin.y) newFrame.origin.y = self.cropFrame.origin.y;
    if (CGRectGetMaxY(newFrame) < self.cropFrame.origin.y + self.cropFrame.size.height) {
        newFrame.origin.y = self.cropFrame.origin.y + self.cropFrame.size.height - newFrame.size.height;
    }
    // adapt horizontally rectangle
    if (self.showImgView.frame.size.width > self.showImgView.frame.size.height && newFrame.size.height <= self.cropFrame.size.height) {
        newFrame.origin.y = self.cropFrame.origin.y + (self.cropFrame.size.height - newFrame.size.height) / 2;
    }
    return newFrame;
}

- (UIImage *)getSubImage
{
    CGRect squareFrame = self.cropFrame;
    
    CGFloat scaleRatio = self.latestFrame.size.width / self.originalImage.size.width;
    CGFloat x = (squareFrame.origin.x - self.latestFrame.origin.x) / scaleRatio;
    CGFloat y = (squareFrame.origin.y - self.latestFrame.origin.y) / scaleRatio;
    CGFloat w = squareFrame.size.width / scaleRatio;
    CGFloat h = squareFrame.size.height / scaleRatio;
    if (self.latestFrame.size.width < self.cropFrame.size.width) {
        CGFloat newW = self.originalImage.size.width;
        CGFloat newH = newW * (self.cropFrame.size.height / self.cropFrame.size.width);
        x = 0; y = y + (h - newH) / 2;
        w = newH; h = newH;
    }
    if (self.latestFrame.size.height < self.cropFrame.size.height) {
        CGFloat newH = self.originalImage.size.height;
        CGFloat newW = newH * (self.cropFrame.size.width / self.cropFrame.size.height);
        x = x + (w - newW) / 2; y = 0;
        w = newW; h = newH;
    }
    CGRect myImageRect = CGRectMake(x, y, w, h);
    CGImageRef imageRef = self.originalImage.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
    CGSize size;
    size.width = myImageRect.size.width;
    size.height = myImageRect.size.height;
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, myImageRect, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    UIGraphicsEndImageContext();
    return smallImage;
}

- (UIImage *)fixOrientation:(UIImage *)srcImg
{
    if (srcImg.imageOrientation == UIImageOrientationUp) return srcImg;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (srcImg.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (srcImg.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, srcImg.size.width, srcImg.size.height,
                                             CGImageGetBitsPerComponent(srcImg.CGImage), 0,
                                             CGImageGetColorSpace(srcImg.CGImage),
                                             CGImageGetBitmapInfo(srcImg.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (srcImg.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.height,srcImg.size.width), srcImg.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.width,srcImg.size.height), srcImg.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


#pragma mark - Action Message
-(void)backClicked:(id)sender{
    if (_backToVC && [_backToVC isKindOfClass:[MineTableViewController class]]) {
//        if ([_backToVC respondsToSelector:@selector(updateImageInfo:)]) {
//            [_backToVC performSelector:@selector(updateImageInfo:) withObject:imageDic_];
//        }
        [self.navigationController popToViewController:_backToVC animated:NO];
    }else {
        [self.navigationController popViewControllerAnimated:NO];
    }
}
- (void)handleBackButton
{
    if (_backToVC && [_backToVC isKindOfClass:[MineTableViewController class]]) {
        
//        if ([_backToVC respondsToSelector:@selector(updateImageInfo:)]) {
//            [_backToVC performSelector:@selector(updateImageInfo:) withObject:imageDic_];
//        }
        [self.navigationController popToViewController:_backToVC animated:NO];
        
    }else {
        [self.navigationController popViewControllerAnimated:NO];
    }
    
}

#pragma mark - 确定上传头像
- (void)handleRightBtn
{
    self.gettedImage = [self getSubImage];
    [SVProgressHUD show];
    if (_backToVC && [_backToVC isKindOfClass:[MineTableViewController class]]) {
        
        
//        NSData * imageData = UIImageJPEGRepresentation(self.gettedImage, 1);
//        self.gettedImage = [UIImage imageWithData:imageData];
        
        CGSize size = self.gettedImage.size;
        [[AliyunOSSUpload aliyunInit] uploadImage:@[self.gettedImage] success:^(NSArray<NSString *> * _Nonnull nameArray) {
                if(nameArray.count == 0){
                    [SVProgressHUD showErrorWithStatus:@"图片上传失败"];
                    return;
                }
            
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showSuccessWithStatus:@"上传头像成功"];
                });
                if (self.ReturnPictureBlock) {
                    self.ReturnPictureBlock([nameArray firstObject]);
                }
            
            }];
        
        
        
        
        
        return;
        
        //上传头像
//        NSMutableDictionary *sendDic = [[NSMutableDictionary alloc] initWithCapacity:3];
//
//        NSData *imageData = UIImageJPEGRepresentation(self.gettedImage, 0.5);
//        //    imageData = UIImagePNGRepresentation(image);
//
//        NSString *type = [LoginManager typeForImageData:imageData];
//        [sendDic setObject:type forKey:@"imgaeType"];
//        [LoginManager execute:@selector(changeHeadPicpathManager) target:self callback:@selector(changeHeadPicpathManagerCallBack:) args:sendDic,imageData,nil];
        
        
        
    }
}
- (void)changeHeadPicpathManagerCallBack:(id)data
{
    if (data)
    {
        if ([data objectForKey:@"error"]) {
            [SVProgressHUD showInfoWithStatus:[data objectForKey:@"error"]];
            return;
        }else{
            if ([data objectForKey:@"filePath"]) {
                NSLog(@"%@",[NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[data objectForKey:@"filePath"]]);
                [NFUserEntity shareInstance].mineHeadView = [NSString stringWithFormat:@"%@%@",[NFUserEntity shareInstance].HeadPicpathAppendingString,[data objectForKey:@"filePath"]];
                //头像与用户绑定请求 socket
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showSuccessWithStatus:@"上传头像成功"];
                });
                if (self.ReturnPictureBlock) {
                    self.ReturnPictureBlock([data objectForKey:@"filePath"]);
                }
            }else{
                [SVProgressHUD showSuccessWithStatus:@"上传头像失败"];
                
            }
            
//            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {
        [SVProgressHUD showInfoWithStatus:@"上传失败"];
    }
}

-(void)ReturnPicPathManager:(ReturnPicPath)block{
    if (self.ReturnPictureBlock != block) {
        self.ReturnPictureBlock = block;
    }
}


//获取图片后缀
- (NSString *)typeForImageData:(NSData *)data {
    uint8_t c;
    
    [data getBytes:&c length:1];
    
    switch (c) {
            
        case 0xFF:
            
            return @"jpeg";
            
        case 0x89:
            
            return @"png";
            
        case 0x47:
            
            return @"gif";
            
        case 0x49:
            
        case 0x4D:
            
            return @"tiff";
            
    }
    
    return nil;
    
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
