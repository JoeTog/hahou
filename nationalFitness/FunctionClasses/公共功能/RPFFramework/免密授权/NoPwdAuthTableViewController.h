//
//  NoPwdAuthTableViewController.h
//  nationalFitness
//
//  Created by joe on 2020/1/6.
//  Copyright © 2020年 chenglong. All rights reserved.
//

#import "NFTableViewController.h"

#import "HCDTimer.h"

#import "SocketModel.h"
#import "SocketRequest.h"



NS_ASSUME_NONNULL_BEGIN

@interface NoPwdAuthTableViewController : NFTableViewController

@property (weak, nonatomic) IBOutlet UILabel *firstlabel;

@property (weak, nonatomic) IBOutlet UILabel *secondLabel;

//忘记支付密码需要短信确认，验证码已发送至手机，请按提示操作。
@property (weak, nonatomic) IBOutlet UILabel *codeNoticeLabel;


@property(nonatomic, assign)BOOL isChange;//是否是修改密码

@property(nonatomic, copy)NSString * phoneNumString;//




@end

NS_ASSUME_NONNULL_END
