//
//  BellSetTableViewCell.m
//  nationalFitness
//
//  Created by Joe on 2017/8/8.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "BellSetTableViewCell.h"
#import "UIFont+RYChat.h"

@implementation BellSetTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    
    [self.selectBtn setImage:[UIImage imageNamed:@"授权管理未选中"] forState:(UIControlStateNormal)];
    [self.selectBtn setImage:[UIImage imageNamed:@"添加群聊选中"] forState:(UIControlStateSelected)];
    
    self.titleLabel.font = [UIFont fontMainText];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
