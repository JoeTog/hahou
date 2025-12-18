//
//  RPFOpenPacketViewController.h
//  NIM
//
//  Created by King on 2019/2/18.
//  Copyright © 2019年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseRPFViewController.h"


#import "SocketModel.h"
#import "SocketRequest.h"


#import "RPFNoneViewController.h"



NS_ASSUME_NONNULL_BEGIN

typedef void(^OpenRedPacketFinishBlock)(BOOL isDone);


@interface RPFOpenPacketViewController : UIViewController

@property(nonatomic, copy)NSString * userId;
@property(nonatomic, copy)NSString * sendUserId;

@property(nonatomic, copy)NSString * userName;
@property(nonatomic, copy)NSString * userHeadUrl;
@property(nonatomic, copy)NSString * wishContent;
@property(nonatomic, copy)NSString * redpacketId;
@property(nonatomic, copy)NSString * thirdToken;
@property(nonatomic, assign)BOOL isGroup;
@property(nonatomic, copy)NSString * appkey;
@property(nonatomic, copy)NSString * groupId;


@property (weak, nonatomic) IBOutlet UIImageView *headImgView;//拆包时候的头像 ，抢完t时隐藏
@property (weak, nonatomic) IBOutlet UIButton *nameBtn;//拆包时候的名字 抢完提示的红包祝福语
@property (weak, nonatomic) IBOutlet UILabel *wishContentLabel;//拆包时候的祝福语mq，抢完提示的来晚一步
@property (weak, nonatomic) IBOutlet UIButton *openBtn;//拆包时候的按钮，抢完提示时候隐藏
@property (weak, nonatomic) IBOutlet UIButton *checkResultBtn;//查看详情
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;//关闭
@property (weak, nonatomic) IBOutlet UIImageView *bgImgView;


@property (weak, nonatomic) IBOutlet UIButton *nameBtnNone;//拆包时候隐藏 抢完试后的名字【xxx的红包】

@property (weak, nonatomic) IBOutlet UILabel *faleyigehongbaoLabel;


@property(nonatomic,copy)OpenRedPacketFinishBlock openRPFinishBlock;

@end

NS_ASSUME_NONNULL_END
