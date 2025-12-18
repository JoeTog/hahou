//
//  QRGroupCodeViewController.h
//  nationalFitness
//
//  Created by joe on 2018/1/8.
//  Copyright © 2018年 chenglong. All rights reserved.
//

#import "NFbaseViewController.h"
#import "JsonModel.h"
#import "LogoQR.h"

#import "PublicDefine.h"
#import "NFShowImageView.h"
#import <CoreImage/CoreImage.h>

#import "PHProgressHUD.h"
#import "MBProgressHUD.h"
#import "MBProgressHUD+NHAdd.h"

//微信SDK头文件
#import "WXApi.h"

#import "LWWeChatActionSheet.h"
#import "SocketModel.h"


typedef void (^ReturnRefreshBlock)(BOOL refresh);


@interface QRGroupCodeViewController : NFbaseViewController

@property(nonatomic,copy)ReturnRefreshBlock returnRefreshBlock;

-(void)returnRefreshBlockk:(ReturnRefreshBlock)block;



//群租id
@property (strong, nonatomic) NSString *groupId;

//群聊名称
@property (strong, nonatomic) NSString *groupName;
//群聊头像
@property (strong, nonatomic) NSString *groupIconUrl;

//我的nickname
@property (strong, nonatomic) NSString *nickname;


//群头像
@property (weak, nonatomic) IBOutlet NFShowImageView *groupHeadPicImageV;


//群昵称
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;



//群二维码
@property (weak, nonatomic) IBOutlet NFShowImageView *groupQRCodeImageV;


//背景view
@property (weak, nonatomic) IBOutlet UIView *backView;










@end
