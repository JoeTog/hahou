//
//  CardTableViewCell.h
//  nationalFitness
//
//  Created by joe on 2020/1/11.
//  Copyright © 2020年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NFHeadImageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CardTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet NFHeadImageView *imageV;

@property (weak, nonatomic) IBOutlet UILabel *cardTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *cardTypeLabel;

@property (weak, nonatomic) IBOutlet UILabel *cardTailLabel;



@property (weak, nonatomic) IBOutlet UIView *backView;






@end

NS_ASSUME_NONNULL_END
