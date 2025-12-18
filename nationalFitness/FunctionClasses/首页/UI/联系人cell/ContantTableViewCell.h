//
//  ContantTableViewCell.h
//  nationalFitness
//
//  Created by Joe on 2017/6/30.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseImageView.h"
#import "UIImage+Addtions.h"

#import "NFShowImageView.h"

@interface ContantTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet NFShowImageView *headImageView;


@property (weak, nonatomic) IBOutlet UILabel *nameLabel;


@property (weak, nonatomic) IBOutlet UILabel *badgeCountLabel;

//默认隐藏
@property (weak, nonatomic) IBOutlet EaseImageView *badgeCountView;


//标记 申请、拒绝、拉黑 //默认是hidden 申请与通知里面用到了 就显示
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

//时间 【操作时间】
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;


@property (weak, nonatomic) IBOutlet UIButton *agreeBtn;




@end
