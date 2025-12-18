//
//  YTMoreView.m
//  YTChatDemo
//
//  Created by TI on 15/9/1.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import "YTDeviceTest.h"
#import "YTMoreView.h"

@interface YTIcons : UIButton

@end

@implementation YTIcons
#define BT_IMG_WH 50.0f //自身宽和内部image宽高
#define BT_H      70.0f //自身高

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return self;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    contentRect = CGRectMake(0, 0, BT_IMG_WH, BT_IMG_WH);
    return contentRect;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    contentRect = CGRectMake(0, BT_IMG_WH, BT_IMG_WH, BT_H-BT_IMG_WH);
    return contentRect;
}

@end

@interface YTMoreView(){
    NSArray *images;
    NSArray *hightImages;
    NSArray *titles;
    NSArray *types;
}

@end

@implementation YTMoreView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
    }
    return self;
}

- (void)initUI{
    [self addResource];
    [self addScrollView];
    [self addIcons];
}

- (void)addResource{
    
    if(self.IsGroup){
//        images = @[@"photo_nomal",@"camera_nomal",@"hongbao_huabanfuben"];
//        hightImages = @[@"photo_down",@"camera_down",@"hongbao_huabanfuben"];
//        titles = @[@"图片",@"照相",@"发红包"];
//        types = @[@(YTMoreViewTypeActionPhoto),@(YTMoreViewTypeActionCamera),@(YTMoreViewTypeActionRed)];
        
        
        images = @[@"photo_nomal",@"camera_nomal",@"hongbao_huabanfuben",@"mingpianCard"];
        hightImages = @[@"photo_down",@"camera_down",@"hongbao_huabanfuben",@"mingpianCard"];
        titles = @[@"图片",@"照相",@"发红包",@"名片"];
        
        images = @[@"photo_nomal",@"camera_nomal",@"hongbao_huabanfuben",@"mingpianCard",@"邀请"];
        hightImages = @[@"photo_down",@"camera_down",@"hongbao_huabanfuben",@"mingpianCard",@"邀请"];
        titles = @[@"图片",@"照相",@"发红包",@"名片",@"邀请"];
        types = @[@(YTMoreViewTypeActionPhoto),@(YTMoreViewTypeActionCamera),@(YTMoreViewTypeActionRed),@(YTMoreViewTypeActionCard),@(YTMoreViewTypeActionInvite)];
        
        
    }else{
        
//        images = @[@"photo_nomal",@"camera_nomal"];
//        hightImages = @[@"photo_down",@"camera_down"];
//        titles = @[@"图片",@"照相"];
//        types = @[@(YTMoreViewTypeActionPhoto),@(YTMoreViewTypeActionCamera)];
        
//        images = @[@"photo_nomal",@"camera_nomal",@"hongbao_huabanfuben"];
//        hightImages = @[@"photo_down",@"camera_down",@"hongbao_huabanfuben"];
//        titles = @[@"图片",@"照相",@"发红包"];
//        types = @[@(YTMoreViewTypeActionPhoto),@(YTMoreViewTypeActionCamera),@(YTMoreViewTypeActionRed)];
        
//        images = @[@"photo_nomal",@"camera_nomal",@"hongbao_huabanfuben",@"zhuanzhang"];
//        hightImages = @[@"photo_down",@"camera_down",@"hongbao_huabanfuben",@"zhuanzhang"];
//        titles = @[@"图片",@"照相",@"发红包",@"转账"];
//        types = @[@(YTMoreViewTypeActionPhoto),@(YTMoreViewTypeActionCamera),@(YTMoreViewTypeActionRed),@(YTMoreViewTypeActionTransfer)];
        
        images = @[@"photo_nomal",@"camera_nomal",@"hongbao_huabanfuben",@"zhuanzhang",@"mingpianCard"];
        hightImages = @[@"photo_down",@"camera_down",@"hongbao_huabanfuben",@"zhuanzhang",@"mingpianCard"];
        titles = @[@"图片",@"照相",@"发红包",@"转账",@"名片"];
        types = @[@(YTMoreViewTypeActionPhoto),@(YTMoreViewTypeActionCamera),@(YTMoreViewTypeActionRed),@(YTMoreViewTypeActionTransfer),@(YTMoreViewTypeActionCard)];
        
        
    }
}

//-(void)addResourceUpdateisGroup:(BOOL)ret{
//    if(ret){
//        images = @[@"photo_nomal",@"camera_nomal",@"hongbao_huabanfuben"];
//        hightImages = @[@"photo_down",@"camera_down",@"hongbao_huabanfuben"];
//        titles = @[@"图片",@"照相",@"发红包"];
//        types = @[@(YTMoreViewTypeActionPhoto),@(YTMoreViewTypeActionCamera),@(YTMoreViewTypeActionRed)];
//    }else{
//        images = @[@"photo_nomal",@"camera_nomal"];
//        hightImages = @[@"photo_down",@"camera_down"];
//        titles = @[@"图片",@"照相"];
//        types = @[@(YTMoreViewTypeActionPhoto),@(YTMoreViewTypeActionCamera)];
//    }
//
//}



- (void)addScrollView{
    UIScrollView * scroll = [[UIScrollView alloc]initWithFrame:self.bounds];
    scroll.bounces = NO;
    scroll.pagingEnabled = YES;
    scroll.showsVerticalScrollIndicator = NO;
    scroll.showsHorizontalScrollIndicator = NO;
    [self addSubview:scroll];
    self.scrollView = scroll;
}

- (void)addIcons{
    CGSize size = self.bounds.size;
    CGFloat spaceV = (size.width-BT_IMG_WH*4.0f)/5.0f;
    CGFloat spaceH = (size.height-BT_H*2.0f)/3.0f;
    
    CGRect rect = CGRectMake(0, 0, BT_IMG_WH, BT_H);
    for (int i =0; i < images.count; i++) {//暂时不考虑第二页
        NSInteger V = i%4;
        NSInteger H = i/4;
        rect.origin.x = spaceV+V*(spaceV+BT_IMG_WH);
        rect.origin.y = spaceH+H*(spaceH+BT_H);
        YTIcons * icon = [[YTIcons alloc]initWithFrame:rect];
        icon.tag = ((NSNumber *)types[i]).integerValue;
        [icon setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        [icon setImage:[UIImage imageNamed:hightImages[i]] forState:UIControlStateHighlighted];
        [icon setTitle:titles[i] forState:UIControlStateNormal];
        [icon addTarget:self action:@selector(iconsAction:) forControlEvents:UIControlEventTouchUpInside];
        NSLog(@"%d",icon.userInteractionEnabled);
        [self.scrollView addSubview:icon];
        
    }
}

- (void)iconsAction:(UIButton *)icon{
    switch ((YTMoreViewTypeAction)icon.tag) {
        case YTMoreViewTypeActionPhoto:
            if ([YTDeviceTest userAuthorizationPhotoStatus]) {
                [self sourceType:YTMoreViewTypeActionPhoto];
            }
            break;
        case YTMoreViewTypeActionCamera:
            if ([YTDeviceTest userAuthorizationCameraStatus]) {
                [self sourceType:YTMoreViewTypeActionCamera];
            }else{
                [SVProgressHUD showErrorWithStatus:@"相机不可用"];
            }
            break;
        case YTMoreViewTypeActionRed:
            [self sourceType:YTMoreViewTypeActionRed];
            break;
        case YTMoreViewTypeActionTransfer:
            [self sourceType:YTMoreViewTypeActionTransfer];
            break;
        case YTMoreViewTypeActionCard:
            [self sourceType:YTMoreViewTypeActionCard];
            break;
        case YTMoreViewTypeActionInvite:
                [self sourceType:YTMoreViewTypeActionInvite];
                break;
        default:
            break;
    }
}

#pragma mark - delegate
- (void)sourceType:(YTMoreViewTypeAction)type{
    if ([self.delegate respondsToSelector:@selector(moreViewType:)]) {
        [self.delegate moreViewType:type];
    }
}

@end
