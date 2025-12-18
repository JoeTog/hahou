//
//  RecommendFriendTableViewCell.h
//  nationalFitness
//
//  Created by joe on 2019/12/30.
//  Copyright © 2019年 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NFHeadImageView.h"



NS_ASSUME_NONNULL_BEGIN

@interface RecommendFriendTableViewCell : UITableViewCell



@property (weak, nonatomic) IBOutlet NFHeadImageView *recommendheadV;


@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;



@property (weak, nonatomic) IBOutlet UIImageView *backimageV;


@property (weak, nonatomic) IBOutlet UIButton *clickBtn;


@property (weak, nonatomic) IBOutlet UILabel *titileNameLabel;



@end

NS_ASSUME_NONNULL_END
