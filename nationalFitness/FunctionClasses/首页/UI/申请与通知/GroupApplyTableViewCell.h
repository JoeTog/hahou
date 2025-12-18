//
//  GroupApplyTableViewCell.h
//  nationalFitness
//
//  Created by joe on 2019/8/12.
//  Copyright © 2019年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EaseImageView.h"
#import "UIImage+Addtions.h"

#import "NFShowImageView.h"



NS_ASSUME_NONNULL_BEGIN


@interface GroupApplyTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet NFShowImageView *headImageV;


@property (weak, nonatomic) IBOutlet UILabel *applyDetailLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;


@property (weak, nonatomic) IBOutlet UIButton *agreeBtn;

@property (weak, nonatomic) IBOutlet EaseImageView *badgeImageV;


@property (weak, nonatomic) IBOutlet UILabel *stateLabel;



@end

NS_ASSUME_NONNULL_END
