//
//  PointListTableViewCell.h
//  nationalFitness
//
//  Created by joe on 2021/1/8.
//  Copyright © 2021 chenglong. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "NFHeadImageView.h"


NS_ASSUME_NONNULL_BEGIN

@interface PointListTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet NFHeadImageView *headImageV;


@property (weak, nonatomic) IBOutlet UILabel *nickNameL;


@property (weak, nonatomic) IBOutlet UILabel *commentLabel;



@property (weak, nonatomic) IBOutlet UILabel *timeL;


//图片和文字只能留一个
@property (weak, nonatomic) IBOutlet NFHeadImageView *contentImageV;


@property (weak, nonatomic) IBOutlet UILabel *dymicContentL;





@end

NS_ASSUME_NONNULL_END
