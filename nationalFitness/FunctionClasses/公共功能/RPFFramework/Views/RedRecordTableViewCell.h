//
//  RedRecordTableViewCell.h
//  nationalFitness
//
//  Created by joe on 2020/1/11.
//  Copyright © 2020年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RedRecordTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *amountlabel;


@property (weak, nonatomic) IBOutlet UIImageView *imageV;


@property (weak, nonatomic) IBOutlet UILabel *detailLabelll;





@end

NS_ASSUME_NONNULL_END
