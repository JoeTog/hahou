//
//  BillListTableViewCell.h
//  nationalFitness
//
//  Created by joe on 2020/1/19.
//  Copyright © 2020年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NFShowImageView.h"
#import "UIImage+Addtions.h"

#import "EaseImageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface BillListTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet NFShowImageView *headImageV;



@property (weak, nonatomic) IBOutlet UILabel *titleDetailLabel;


@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *amountLabel;


@property (weak, nonatomic) IBOutlet EaseImageView *badgeView;




@end

NS_ASSUME_NONNULL_END
