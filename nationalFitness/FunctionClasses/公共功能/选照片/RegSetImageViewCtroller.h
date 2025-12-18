//
//  RegSetImageViewCtroller.h
//  nationalFitness
//  编辑图片 上传图片
//  Created by Joe on 2017/9/12.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NFbaseViewController.h"
#import "NFShowImageView.h"
#import "MineTableViewController.h"
#import "LoginManager.h"


/**
 *  剪切类型
 */
typedef NS_ENUM(NSInteger, NFCutImageType)
{
    /*
     *  用户头像
     */
    CutUserHeadImage = 0,
    /*
     *  只裁剪， 不操作
     */
    CutOnlyCutImage = 1,
    /*
     *  发起活动的焦点图
     */
    CutActivityHeadImag = 2,
    /*
     *  发起主题秀
     */
    CutThemeShowImag = 5,
    /*
     *  徽章
     */
    CutClubBadgeImage = 6,
    /*
     *  俱乐部
     */
    CutClubHeadImage = 7,
    /*
     *  举报
     */
    CutReportImage = 8
    
};

typedef void (^ReturnPicPath)(NSString *pic);

@interface RegSetImageViewCtroller : NFbaseViewController

@property (nonatomic,weak) id backToVC;

@property (nonatomic, strong) UIImage *originalImage;

@property (nonatomic, assign) NFCutImageType cutType;

@property(nonatomic,copy)ReturnPicPath ReturnPictureBlock;

-(void)ReturnPicPathManager:(ReturnPicPath)block;





@end
