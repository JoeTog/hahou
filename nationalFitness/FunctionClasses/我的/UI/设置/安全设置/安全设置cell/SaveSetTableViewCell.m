//
//  SaveSetTableViewCell.m
//  nationalFitness
//
//  Created by Joe on 2017/7/24.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "SaveSetTableViewCell.h"
#import "UIColor+RYChat.h"
#import "UIFont+RYChat.h"

@implementation SaveSetTableViewCell{
    
    
    
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self.seclectButton setImage:[UIImage imageNamed:@"授权管理未选中"] forState:(UIControlStateNormal)];
    [self.seclectButton setImage:[UIImage imageNamed:@"添加群聊选中"] forState:(UIControlStateSelected)];
    
    self.titleLabell.textColor = [UIColor colorMainTextColor];
    
    self.titleLabell.font = [UIFont fontMainText];
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
