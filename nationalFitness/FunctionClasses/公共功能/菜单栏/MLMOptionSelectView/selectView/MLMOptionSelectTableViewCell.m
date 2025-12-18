//
//  MLMOptionSelectTableViewCell.m
//  nationalFitness
//
//  Created by Joe on 2017/8/8.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "MLMOptionSelectTableViewCell.h"


@implementation MLMOptionSelectTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    ViewRadius(self.imageV, self.imageV.frame.size.width/2);
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
