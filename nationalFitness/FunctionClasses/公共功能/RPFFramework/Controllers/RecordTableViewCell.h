//
//  RecordTableViewCell.h
//  nationalFitness
//
//  Created by joe on 2019/12/10.
//  Copyright © 2019年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NFShowImageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface RecordTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet NFShowImageView *headV;



@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;




@end

NS_ASSUME_NONNULL_END
