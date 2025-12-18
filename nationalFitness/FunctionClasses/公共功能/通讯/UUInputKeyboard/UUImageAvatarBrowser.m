//
//  UUAVAudioPlayer.m
//  BloodSugarForDoc
//
//  Created by shake on 14-9-1.
//  Copyright (c) 2014年 shake. All rights reserved.
//

#import "UUImageAvatarBrowser.h"

static UIImageView *orginImageView;

static CGRect orginFrame; //原始界面 cgrect

@implementation UUImageAvatarBrowser

+(void)showImage:(UIImageView *)avatarImageView{
    UIImage *image=avatarImageView.image;
    orginImageView = avatarImageView;
    orginImageView.alpha = 0;
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    UIView *backgroundView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    CGRect oldframe=[avatarImageView convertRect:avatarImageView.bounds toView:window];
//    CGRect oldframe=[avatarImageView convertRect:CGRectMake(0, 0, avatarImageView.frame.size.width - 20, avatarImageView.frame.size.height) toView:window];
    backgroundView.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.7];
    backgroundView.alpha=1;
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:oldframe];
    
    imageView.image=image;
    imageView.tag=1;
    [backgroundView addSubview:imageView];
    [window addSubview:backgroundView];
    
    //点击返回
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [backgroundView addGestureRecognizer: tap];
    
    //方法缩小
//    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinches:)];
//    [backgroundView addGestureRecognizer:pinch];
    
    [UIView animateWithDuration:0.3 animations:^{
        if (image) {
            //步骤1  设置imageview在view上的frame
            imageView.frame=CGRectMake(([UIScreen mainScreen].bounds.size.width-image.size.width*SCREEN_WIDTH/image.size.width)/2,([UIScreen mainScreen].bounds.size.height-image.size.height*SCREEN_WIDTH/image.size.width)/2, [UIScreen mainScreen].bounds.size.width, image.size.height*SCREEN_WIDTH/image.size.width);
        }
        backgroundView.alpha=1;
    } completion:^(BOOL finished) {
        //步骤2 记录原始imageV的frame
        orginFrame = imageView.frame;
    }];
    
    // 旋转手势
    imageView.userInteractionEnabled = YES;
//    UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateView:)];
//    [imageView addGestureRecognizer:rotationGestureRecognizer];
    
    //步骤3 添加手势
    // 缩放手势
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [imageView addGestureRecognizer:pinchGestureRecognizer];
    
    // 移动手势
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [imageView addGestureRecognizer:panGestureRecognizer];
    
}

-(void)addGesture:(UIImageView *)imageView{
//    // 旋转手势
//    UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateView:)];
//    [imageView addGestureRecognizer:rotationGestureRecognizer];
//
//    // 缩放手势
//    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
//    [imageView addGestureRecognizer:pinchGestureRecognizer];
//
//    // 移动手势
//    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
//    [imageView addGestureRecognizer:panGestureRecognizer];
}

+(void)handlePinches:(UIPinchGestureRecognizer *)pinch{
    UIView *backgroundView=pinch.view;
    UIImageView *imageView = (UIImageView*)[pinch.view viewWithTag:1];
    if (pinch.state == UIGestureRecognizerStateBegan || pinch.state == UIGestureRecognizerStateChanged) {
        imageView.transform = CGAffineTransformScale(imageView.transform, pinch.scale, pinch.scale);
        pinch.scale = 1;
    }
    else if (pinch.state == UIGestureRecognizerStateEnded) {
        
        
        
    }
}

+(void)hideImage:(UITapGestureRecognizer*)tap{
    UIView *backgroundView=tap.view;
    UIImageView *imageView=(UIImageView*)[tap.view viewWithTag:1];
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame=[orginImageView convertRect:orginImageView.bounds toView:[UIApplication sharedApplication].keyWindow];
    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
        orginImageView.alpha = 1;
        backgroundView.alpha=0;
    }];
}


// 处理旋转手势
//+ (void) rotateView:(UIRotationGestureRecognizer *)rotationGestureRecognizer
//{
//    UIView *view = rotationGestureRecognizer.view;
//    if (rotationGestureRecognizer.state == UIGestureRecognizerStateBegan || rotationGestureRecognizer.state == UIGestureRecognizerStateChanged) {
//        view.transform = CGAffineTransformRotate(view.transform, rotationGestureRecognizer.rotation);
//        [rotationGestureRecognizer setRotation:0];
//    }
//}

//步骤4 处理手势
// 处理缩放手势
+ (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    UIView *view = pinchGestureRecognizer.view;
    UIImageView *imageView=(UIImageView*)[pinchGestureRecognizer.view viewWithTag:1];
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        pinchGestureRecognizer.scale = 1;
    }
    else if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        //
        //控制大小在一倍到三倍之间
        if (imageView.frame.size.width < orginFrame.size.width) {
            [UIView animateWithDuration:0.3 animations:^{
                /**
                 *  固定一倍
                 */
                imageView.transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
            } completion:^(BOOL finished) {
            }];
        }
        if (imageView.frame.size.width > orginFrame.size.width * 3) {
            [UIView animateWithDuration:0.3 animations:^{
                /**
                 *  固定三倍
                 */
                imageView.transform = CGAffineTransformMake(3, 0, 0, 3, 0, 0);
            } completion:^(BOOL finished) {
            }];
        }
        //控制左右不越界
        if (imageView.frame.origin.x > 0) {
            CGRect rect = imageView.frame;
            if (rect.size.width > SCREEN_WIDTH) {
                rect.origin.x = 0;
            }else{
                rect.origin.x = (SCREEN_WIDTH - rect.size.width)/2;
            }
            [UIView animateWithDuration:0.3 animations:^{
                imageView.frame = rect;
            } completion:^(BOOL finished) {
            }];
        }else if (CGRectGetMaxX(imageView.frame) < SCREEN_WIDTH){
            CGRect rect = imageView.frame;
            if (rect.origin.x > SCREEN_WIDTH) {
                rect.origin.x += (SCREEN_WIDTH - CGRectGetMaxX(imageView.frame));
            }else{
                rect.origin.x = (SCREEN_WIDTH - imageView.frame.size.width)/2;
            }
            [UIView animateWithDuration:0.3 animations:^{
                imageView.frame = rect;
            } completion:^(BOOL finished) {
            }];
        }
        //控制上下不越界
        if (imageView.frame.origin.y > 0 && CGRectGetMaxY(imageView.frame) > SCREEN_HEIGHT) {
            CGRect rect = imageView.frame;
            //            if (CGRectGetMidY(imageView.frame) > SCREEN_HEIGHT/2) {
            //                rect.origin.y -=  ((CGRectGetMaxY(imageView.frame) - SCREEN_HEIGHT));
            //            }else{
            //                rect.origin.y = 0;
            //            }
            
            if ((CGRectGetMaxY(imageView.frame) - SCREEN_HEIGHT) < CGRectGetMinY(imageView.frame)) {
                rect.origin.y -=  ((CGRectGetMaxY(imageView.frame) - SCREEN_HEIGHT));
            }else{
                rect.origin.y = 0;
            }
            [UIView animateWithDuration:0.3 animations:^{
                imageView.frame = rect;
            } completion:^(BOOL finished) {
            }];
        }else if (imageView.frame.origin.y < 0 && CGRectGetMaxY(imageView.frame) < SCREEN_HEIGHT){
            CGRect rect = imageView.frame;
            if ((SCREEN_HEIGHT - CGRectGetMaxY(imageView.frame))-(imageView.frame.size.height - CGRectGetMaxY(imageView.frame)) > 0) {
                rect.origin.y = 0;
            }else{
                rect.origin.y -=  ((CGRectGetMaxY(imageView.frame) - SCREEN_HEIGHT));
            }
            [UIView animateWithDuration:0.3 animations:^{
                imageView.frame = rect;
            } completion:^(BOOL finished) {
            }];
        }
    }
}

// 处理拖拉手势
+ (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = panGestureRecognizer.view;
    UIImageView *imageView=(UIImageView*)[panGestureRecognizer.view viewWithTag:1];
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (imageView.frame.origin.x == orginFrame.origin.x && imageView.frame.origin.y == orginFrame.origin.y) {
            //当没有放大缩小 不能拖动
            return;
        }
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x, view.center.y + translation.y}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        //控制左右不越界
        if (imageView.frame.origin.x > 0) {
            CGRect rect = imageView.frame;
            if (rect.size.width > SCREEN_WIDTH) {
                rect.origin.x = 0;
            }else{
                rect.origin.x = (SCREEN_WIDTH - rect.size.width)/2;
            }
            [UIView animateWithDuration:0.3 animations:^{
                imageView.frame = rect;
            } completion:^(BOOL finished) {
            }];
        }else if (CGRectGetMaxX(imageView.frame) < SCREEN_WIDTH){
            CGRect rect = imageView.frame;
            //判断
            if (rect.size.width > SCREEN_WIDTH) {
                rect.origin.x += (SCREEN_WIDTH - CGRectGetMaxX(imageView.frame));
            }else{
                rect.origin.x = (SCREEN_WIDTH - imageView.frame.size.width)/2;
            }
            [UIView animateWithDuration:0.3 animations:^{
                imageView.frame = rect;
            } completion:^(BOOL finished) {
            }];
        }
        //控制上下不越界
        if (imageView.frame.origin.y > 0 && CGRectGetMaxY(imageView.frame) > SCREEN_HEIGHT) {
            //超下边界
            CGRect rect = imageView.frame;
//            if (CGRectGetMidY(imageView.frame) > SCREEN_HEIGHT/2) {
//                rect.origin.y -=  ((CGRectGetMaxY(imageView.frame) - SCREEN_HEIGHT));
//            }else{
//                rect.origin.y = 0;
//            }
            if (imageView.frame.size.height > SCREEN_HEIGHT) {
                rect.origin.y = 0;
            }else{
                rect.origin.y = (CGRectGetMinY(imageView.frame) - (CGRectGetMaxY(imageView.frame) - SCREEN_HEIGHT))/2;
            }
            [UIView animateWithDuration:0.3 animations:^{
                imageView.frame = rect;
            } completion:^(BOOL finished) {
            }];
        }else if (imageView.frame.origin.y < 0 && CGRectGetMaxY(imageView.frame) < SCREEN_HEIGHT){
            //超上边界
            CGRect rect = imageView.frame;
            if ((SCREEN_HEIGHT - CGRectGetMaxY(imageView.frame))-(imageView.frame.size.height - CGRectGetMaxY(imageView.frame)) > 0) {
                //图片偏下
//                rect.origin.y = 0;
//                CGFloat Y = (SCREEN_HEIGHT - CGRectGetMaxY(imageView.frame))/2;
//                rect.origin.y = Y;
                
                if (imageView.frame.size.height > SCREEN_HEIGHT) {
                    rect.origin.y = (SCREEN_HEIGHT - CGRectGetMaxY(imageView.frame));
                }else{
                    rect.origin.y = (SCREEN_HEIGHT - CGRectGetMaxY(imageView.frame) - (imageView.frame.size.height - CGRectGetMaxY(imageView.frame)))/2;
                }
                
            }else{
                //图片偏上
//                rect.origin.y -=  ((CGRectGetMaxY(imageView.frame) - SCREEN_HEIGHT));
//                CGFloat Y = (CGRectGetMaxY(imageView.frame) - CGRectGetMinY(imageView.frame))/2;
                CGFloat Y = SCREEN_HEIGHT - CGRectGetMaxY(imageView.frame);
                rect.origin.y += Y;
                
            }
            [UIView animateWithDuration:0.3 animations:^{
                imageView.frame = rect;
            } completion:^(BOOL finished) {
            }];
        }
    }
}






@end
