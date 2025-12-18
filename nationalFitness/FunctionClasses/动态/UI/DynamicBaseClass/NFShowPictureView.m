//
//  NFShowPictureView.m
//  newTestUe
//
//  Created by 程龙 on 15/12/15.
//  Copyright © 2015年 程龙. All rights reserved.
//

#import "NFShowPictureView.h"
#import "NFShowImageView.h"
#import "HDPictureShowViewController.h"

//#define kSelfWidth      (SCREEN_WIDTH - 26.0f)
//#define kSelfHeight     kPLUS_SCALE_X(280.f)

//#define kSelfHeight     kPLUS_SCALE_X(197.f)

#define kSelfWidth      kPLUS_SCALE_X(210.f)
#define kSelfHeight     kPLUS_SCALE_X(200.f)

#define kSpace          3.0f

@implementation NFShowPictureView
{
    NFShowImageView *imageFirst_;
    NFShowImageView *imageSecond_;
    NFShowImageView *imageThree_;
    NFShowImageView *imageFourth_;
    NFShowImageView *imageFive_;
    NFShowImageView *imageSix_;
    NFShowImageView *imageseven_;
    NFShowImageView *imageEight_;
    NFShowImageView *imageNight_;
    
    NSArray *pictureArr_;
}

//给照片墙上的照片传递值
- (void)setPictureArr:(NSArray *)pictureArr isFromLocal:(BOOL)local
{
    pictureArr_ = pictureArr;
    if (!imageFirst_)
    {
        imageFirst_ = [[NFShowImageView alloc] init];
        imageSecond_ = [[NFShowImageView alloc] init];
        imageThree_ = [[NFShowImageView alloc] init];
        imageFourth_ = [[NFShowImageView alloc] init];
        imageFive_ = [[NFShowImageView alloc] init];
        imageSix_ = [[NFShowImageView alloc] init];
        imageseven_ = [[NFShowImageView alloc] init];
        imageEight_ = [[NFShowImageView alloc] init];
        imageNight_ = [[NFShowImageView alloc] init];
        [self addSubview:imageFirst_];
        [self addSubview:imageSecond_];
        [self addSubview:imageThree_];
        [self addSubview:imageFourth_];
        [self addSubview:imageFive_];
        [self addSubview:imageSix_];
        [self addSubview:imageseven_];
        [self addSubview:imageEight_];
        [self addSubview:imageNight_];
    }
    //控件的尺寸初始化
    imageFirst_.hidden = YES;
    imageSecond_.hidden = YES;
    imageThree_.hidden = YES;
    imageFourth_.hidden = YES;
    imageFive_.hidden = YES;
    imageSix_.hidden = YES;
    imageseven_.hidden = YES;
    imageEight_.hidden = YES;
    imageNight_.hidden = YES;
    imageFirst_.userInteractionEnabled = !local;
    imageSecond_.userInteractionEnabled = !local;
    imageThree_.userInteractionEnabled = !local;
    imageFourth_.userInteractionEnabled = !local;
    imageFive_.userInteractionEnabled = !local;
    imageSix_.userInteractionEnabled = !local;
    imageseven_.userInteractionEnabled = !local;
    imageEight_.userInteractionEnabled = !local;
    imageNight_.userInteractionEnabled = !local;
    
    UITapGestureRecognizer *tap_1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showphoto:)];
    imageFirst_.tag = 0;
    [imageFirst_ addGestureRecognizer:tap_1];
    
    UITapGestureRecognizer *tap_2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showphoto:)];
    imageSecond_.tag = 1;
    [imageSecond_ addGestureRecognizer:tap_2];
    
    UITapGestureRecognizer *tap_3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showphoto:)];
    imageThree_.tag = 2;
    [imageThree_ addGestureRecognizer:tap_3];
    
    UITapGestureRecognizer *tap_4 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showphoto:)];
    imageFourth_.tag = 3;
    [imageFourth_ addGestureRecognizer:tap_4];
    
    UITapGestureRecognizer *tap_5 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showphoto:)];
    imageFive_.tag = 4;
    [imageFive_ addGestureRecognizer:tap_5];
    
    UITapGestureRecognizer *tap_6 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showphoto:)];
    imageSix_.tag = 5;
    [imageSix_ addGestureRecognizer:tap_6];
    
    UITapGestureRecognizer *tap_7 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showphoto:)];
    imageseven_.tag = 6;
    [imageseven_ addGestureRecognizer:tap_7];
    
    UITapGestureRecognizer *tap_8 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showphoto:)];
    imageEight_.tag = 7;
    [imageEight_ addGestureRecognizer:tap_8];
    
    UITapGestureRecognizer *tap_9 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showphoto:)];
    imageNight_.tag = 8;
    [imageNight_ addGestureRecognizer:tap_9];

    if (1 == pictureArr.count)
    {
        imageFirst_.frame = CGRectMake(0, 0, kSelfWidth, kSelfHeight);
    }
    else if (2 == pictureArr.count)
    {
        imageFirst_.frame = CGRectMake(0, 0, (kSelfWidth - kSpace) / 2 , kSelfHeight);
        imageSecond_.frame = CGRectMake((kSelfWidth - kSpace) / 2 + kSpace, 0, (kSelfWidth - kSpace) / 2, kSelfHeight);
    }
    else if (3 == pictureArr.count)
    {
        imageFirst_.frame = CGRectMake(0, 0, (kSelfWidth - kSpace) / 2 ,(kSelfHeight - kSpace) / 2);
        imageSecond_.frame = CGRectMake((kSelfWidth - kSpace) / 2 + kSpace, 0, (kSelfWidth - kSpace) / 2, kSelfHeight);
        imageThree_.frame = CGRectMake(0, (kSelfHeight - kSpace) / 2 + kSpace, (kSelfWidth - kSpace) / 2, (kSelfHeight - kSpace) / 2);
    }
    else if (4 == pictureArr.count)
    {
        imageFirst_.frame = CGRectMake(0, 0, (kSelfWidth - kSpace) / 2 ,(kSelfHeight - kSpace) / 2);
        imageSecond_.frame = CGRectMake((kSelfWidth - kSpace) / 2 + kSpace, 0, (kSelfWidth - kSpace) / 2 ,(kSelfHeight - kSpace) / 2);
        imageThree_.frame = CGRectMake((kSelfWidth - kSpace) / 2 + kSpace, (kSelfHeight - kSpace) / 2 + kSpace, (kSelfWidth - kSpace) / 2, (kSelfHeight - kSpace) / 2);
        imageFourth_.frame = CGRectMake(0, (kSelfHeight - kSpace) / 2 + kSpace, (kSelfWidth - kSpace) / 2, (kSelfHeight - kSpace) / 2);
    }
    else if (5 == pictureArr.count)
    {
        imageFirst_.frame = CGRectMake(0, 0, (kSelfWidth - kSpace) / 2 ,(kSelfHeight - kSpace) / 2);
        imageSecond_.frame = CGRectMake((kSelfWidth - kSpace) / 2 + kSpace, 0, (kSelfWidth - kSpace) / 2 ,(kSelfHeight - 2 * kSpace) / 3);
        imageThree_.frame = CGRectMake((kSelfWidth - kSpace) / 2 + kSpace, (kSelfHeight - 2 * kSpace) / 3 + kSpace, (kSelfWidth - kSpace) / 2 ,(kSelfHeight - 2 * kSpace) / 3);
        imageFourth_.frame = CGRectMake((kSelfWidth - kSpace) / 2 + kSpace, (kSelfHeight - 2 * kSpace) / 3 * 2 + 2 * kSpace, (kSelfWidth - kSpace) / 2, (kSelfHeight - 2 * kSpace) / 3);
        imageFive_.frame = CGRectMake(0, (kSelfHeight - kSpace) / 2 + kSpace, (kSelfWidth - kSpace) / 2, (kSelfHeight - kSpace) / 2);
    }
    else if (6 == pictureArr.count)
    {
        imageFirst_.frame = CGRectMake(0, 0, (kSelfWidth - kSpace) / 2 ,(kSelfHeight - 2 * kSpace) / 3 * 2 + kSpace);
        imageSecond_.frame = CGRectMake((kSelfWidth - kSpace) / 2 + kSpace, 0, (kSelfWidth - kSpace) / 2 ,(kSelfHeight - 2 * kSpace) / 3);
        imageThree_.frame = CGRectMake((kSelfWidth - kSpace) / 2 + kSpace, (kSelfHeight - 2 * kSpace) / 3 + kSpace, (kSelfWidth - kSpace) / 2 ,(kSelfHeight - 2 * kSpace) / 3);
        imageFourth_.frame = CGRectMake((kSelfWidth - 2 * kSpace) / 3 * 2 + 2 * kSpace, (kSelfHeight - 2 * kSpace) / 3 * 2 + 2 * kSpace, (kSelfWidth - 2 * kSpace) / 3, (kSelfHeight - 2 * kSpace) / 3);
        imageFive_.frame = CGRectMake((kSelfWidth - 2 * kSpace) / 3 + kSpace, (kSelfHeight - 2 * kSpace) / 3 * 2 + 2 * kSpace, (kSelfWidth - 2 * kSpace) / 3, (kSelfHeight - 2 * kSpace) / 3);
        imageSix_.frame = CGRectMake(0, (kSelfHeight - 2 * kSpace) / 3 * 2 + 2 * kSpace, (kSelfWidth - 2 * kSpace) / 3, (kSelfHeight - 2 * kSpace) / 3);
    }
    else if (7 == pictureArr.count)
    {
        imageFirst_.frame = CGRectMake(0, 0, (kSelfWidth - kSpace) / 2 ,(kSelfHeight - 2 * kSpace) / 3 * 2 + kSpace);
        imageSecond_.frame = CGRectMake((kSelfWidth - kSpace) / 2 + kSpace, 0, (kSelfWidth - kSpace) / 2 ,(kSelfHeight - 2 * kSpace) / 3);
        imageThree_.frame = CGRectMake((kSelfWidth - kSpace) / 2 + kSpace, (kSelfHeight - 2 * kSpace) / 3 + kSpace, (kSelfWidth - kSpace) / 2 ,(kSelfHeight - 2 * kSpace) / 3);
        imageFourth_.frame = CGRectMake((kSelfWidth - 3 * kSpace) / 4 * 3 + 3 * kSpace, (kSelfHeight - 2 * kSpace) / 3 * 2 + 2 * kSpace, (kSelfWidth - 3 * kSpace) / 4, (kSelfHeight - 2 * kSpace) / 3);
        imageFive_.frame = CGRectMake((kSelfWidth - 3 * kSpace) / 4 * 2 + 2 * kSpace, (kSelfHeight - 2 * kSpace) / 3 * 2 + 2 * kSpace, (kSelfWidth - 3 * kSpace) / 4, (kSelfHeight - 2 * kSpace) / 3);
        imageSix_.frame = CGRectMake((kSelfWidth - 3 * kSpace) / 4 + kSpace, (kSelfHeight - 2 * kSpace) / 3 * 2 + 2 * kSpace, (kSelfWidth - 3 * kSpace) / 4, (kSelfHeight - 2 * kSpace) / 3);
        imageseven_.frame = CGRectMake(0, (kSelfHeight - 2 * kSpace) / 3 * 2 + 2 * kSpace, (kSelfWidth - 3 * kSpace) / 4, (kSelfHeight - 2 * kSpace) / 3);
    }
    else if (8 == pictureArr.count)
    {
        imageFirst_.frame = CGRectMake(0, 0, (kSelfWidth - kSpace) / 2 ,(kSelfHeight - 2 * kSpace) / 3);
        imageSecond_.frame = CGRectMake((kSelfWidth - kSpace) / 2 + kSpace, 0, (kSelfWidth - kSpace) / 2 ,(kSelfHeight - 2 * kSpace) / 3);
        imageThree_.frame = CGRectMake((kSelfWidth - 2 * kSpace) / 3 * 2 + 2 * kSpace, (kSelfHeight - 2 * kSpace) / 3  + kSpace, (kSelfWidth - 2 * kSpace) / 3, (kSelfHeight - 2 * kSpace) / 3);
        imageFourth_.frame = CGRectMake((kSelfWidth - 2 * kSpace) / 3 + kSpace, (kSelfHeight - 2 * kSpace) / 3 + kSpace, (kSelfWidth - 2 * kSpace) / 3, (kSelfHeight - 2 * kSpace) / 3);
        imageFive_.frame = CGRectMake(0, (kSelfHeight - 2 * kSpace) / 3 + kSpace, (kSelfWidth - 2 * kSpace) / 3, (kSelfHeight - 2 * kSpace) / 3);
        imageSix_.frame = CGRectMake((kSelfWidth - 2 * kSpace) / 3 * 2 + 2 * kSpace, (kSelfHeight - 2 * kSpace) / 3 * 2 + 2 * kSpace, (kSelfWidth - 2 * kSpace) / 3, (kSelfHeight - 2 * kSpace) / 3);
        imageseven_.frame = CGRectMake((kSelfWidth - 2 * kSpace) / 3 + kSpace, (kSelfHeight - 2 * kSpace) / 3 * 2 + 2 * kSpace, (kSelfWidth - 2 * kSpace) / 3, (kSelfHeight - 2 * kSpace) / 3);
        imageEight_.frame = CGRectMake(0, (kSelfHeight - 2 * kSpace) / 3 * 2 + 2 * kSpace, (kSelfWidth - 2 * kSpace) / 3, (kSelfHeight - 2 * kSpace) / 3);

    }
    else if (9 == pictureArr.count)
    {
        imageFirst_.frame = CGRectMake(0, 0, (kSelfWidth - kSpace) / 2 ,(kSelfHeight - 2 * kSpace) / 3);
        imageSecond_.frame = CGRectMake((kSelfWidth - kSpace) / 2 + kSpace, 0, (kSelfWidth - kSpace) / 2 ,(kSelfHeight - 2 * kSpace) / 3);
        imageThree_.frame = CGRectMake((kSelfWidth - 2 * kSpace) / 3 * 2 + 2 * kSpace, (kSelfHeight - 2 * kSpace) / 3  + kSpace, (kSelfWidth - 2 * kSpace) / 3, (kSelfHeight - 2 * kSpace) / 3);
        imageFourth_.frame = CGRectMake((kSelfWidth - 2 * kSpace) / 3 + kSpace, (kSelfHeight - 2 * kSpace) / 3 + kSpace, (kSelfWidth - 2 * kSpace) / 3, (kSelfHeight - 2 * kSpace) / 3);
        imageFive_.frame = CGRectMake(0, (kSelfHeight - 2 * kSpace) / 3 + kSpace, (kSelfWidth - 2 * kSpace) / 3, (kSelfHeight - 2 * kSpace) / 3);
        
        imageSix_.frame = CGRectMake((kSelfWidth - 3 * kSpace) / 4 * 3 + 3 * kSpace, (kSelfHeight - 2 * kSpace) / 3 * 2 + 2 * kSpace, (kSelfWidth - 3 * kSpace) / 4, (kSelfHeight - 2 * kSpace) / 3);
        imageseven_.frame = CGRectMake((kSelfWidth - 3 * kSpace) / 4 * 2 + 2 * kSpace, (kSelfHeight - 2 * kSpace) / 3 * 2 + 2 * kSpace, (kSelfWidth - 3 * kSpace) / 4, (kSelfHeight - 2 * kSpace) / 3);
        imageEight_.frame = CGRectMake((kSelfWidth - 3 * kSpace) / 4 + kSpace, (kSelfHeight - 2 * kSpace) / 3 * 2 + 2 * kSpace, (kSelfWidth - 3 * kSpace) / 4, (kSelfHeight - 2 * kSpace) / 3);
        imageNight_.frame = CGRectMake(0, (kSelfHeight - 2 * kSpace) / 3 * 2 + 2 * kSpace, (kSelfWidth - 3 * kSpace) / 4, (kSelfHeight - 2 * kSpace) / 3);
    }
    if (local)
    {
        [self showPictureFromLocal:pictureArr];
    }else
    {
        [self showPicture:pictureArr];
    }
}

- (void)showPictureFromLocal:(NSArray *)pictureArr
{
    if (1 <= pictureArr.count)
    {
        imageFirst_.image = [pictureArr objectAtIndex:0];
        imageFirst_.hidden = NO;
    }
    if (2 <= pictureArr.count)
    {
        imageSecond_.image = [pictureArr objectAtIndex:1];
        imageSecond_.hidden = NO;
    }
    if (3 <= pictureArr.count)
    {
        imageThree_.image = [pictureArr objectAtIndex:2];
        imageThree_.hidden = NO;
    }
    if (4 <= pictureArr.count)
    {
        imageFourth_.image = [pictureArr objectAtIndex:3];
        imageFourth_.hidden = NO;
    }
    if (5 <= pictureArr.count)
    {
        imageFive_.image = [pictureArr objectAtIndex:4];
        imageFive_.hidden = NO;
    }
    if (6 <= pictureArr.count)
    {
        imageSix_.image = [pictureArr objectAtIndex:5];
        imageSix_.hidden = NO;
    }
    if (7 <= pictureArr.count)
    {
        imageseven_.image = [pictureArr objectAtIndex:6];
        imageseven_.hidden = NO;
    }
    if (8 <= pictureArr.count)
    {
        imageEight_.image = [pictureArr objectAtIndex:7];
        imageEight_.hidden = NO;
    }
    if (9 <= pictureArr.count)
    {
        imageNight_.image = [pictureArr objectAtIndex:8];
        imageNight_.hidden = NO;
    }

}

//显示图片
- (void)showPicture:(NSArray *)pictureArr
{
    if (1 <= pictureArr.count)
    {
        [imageFirst_ ShowImageWithUrlStr:[pictureArr objectAtIndex:0]  completion:nil];
        
        imageFirst_.hidden = NO;
    }
    if (2 <= pictureArr.count)
    {
        [imageSecond_ ShowImageWithUrlStr:[pictureArr objectAtIndex:1]  completion:nil];
        imageSecond_.hidden = NO;
    }
    if (3 <= pictureArr.count)
    {
        [imageThree_ ShowImageWithUrlStr:[pictureArr objectAtIndex:2]  completion:nil];
        imageThree_.hidden = NO;
    }
    if (4 <= pictureArr.count)
    {
        [imageFourth_ ShowImageWithUrlStr:[pictureArr objectAtIndex:3]  completion:nil];
        imageFourth_.hidden = NO;
    }
    if (5 <= pictureArr.count)
    {
        [imageFive_ ShowImageWithUrlStr:[pictureArr objectAtIndex:4]  completion:nil];
        imageFive_.hidden = NO;
    }
    if (6 <= pictureArr.count)
    {
        [imageSix_ ShowImageWithUrlStr:[pictureArr objectAtIndex:5]  completion:nil];
        imageSix_.hidden = NO;
    }
    if (7 <= pictureArr.count)
    {
        [imageseven_ ShowImageWithUrlStr:[pictureArr objectAtIndex:6]  completion:nil];
        imageseven_.hidden = NO;
    }
    if (8 <= pictureArr.count)
    {
        [imageEight_ ShowImageWithUrlStr:[pictureArr objectAtIndex:7]  completion:nil];
        imageEight_.hidden = NO;
    }
    if (9 <= pictureArr.count)
    {
        [imageNight_ ShowImageWithUrlStr:[pictureArr objectAtIndex:8]  completion:nil];
        imageNight_.hidden = NO;
    }
}

- (void)showphoto:(UITapGestureRecognizer *)tap
{
    HDPictureShowViewController *showImageViewCtrol = [[HDPictureShowViewController alloc] init];
    showImageViewCtrol.imageUrlList = pictureArr_;
    showImageViewCtrol.mainImageIndex = tap.view.tag;
    showImageViewCtrol.isLuoYang = YES;
    showImageViewCtrol.isNeedNavigation = YES;
    [[KeepAppBox viewController:self].navigationController pushViewController:showImageViewCtrol animated:YES];

}

@end
