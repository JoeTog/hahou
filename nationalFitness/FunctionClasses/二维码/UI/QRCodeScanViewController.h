//
//  QRCodeScanViewController.h
//  nationalFitness
//
//  Created by Joe on 2017/7/12.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "NFbaseViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AddFriendOrGroupdetailViewController.h"

//扫描群二维码需要用到
#import "SocketModel.h"
#import "SocketRequest.h"



//#import "LBXZBarWrapper.h"
//#import "ZBarSDK.h"

@interface QRCodeScanViewController : NFbaseViewController

//懒加载
@property (copy, nonatomic) NSMutableDictionary *parms;    //懒加载


//我的nickname
@property (strong, nonatomic) NSString *nickname;


@property (weak, nonatomic) IBOutlet UIImageView *lineImageView;


@property (weak, nonatomic) IBOutlet UIImageView *backimage;


@property (weak, nonatomic) IBOutlet UIButton *showMyQRCodeClick;



@end
