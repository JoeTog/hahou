//
//  GroupAddMemberTableViewCell.m
//  nationalFitness
//
//  Created by Joe on 2017/7/13.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "GroupAddMemberTableViewCell.h"
#import "UIColor+RYChat.h"

@implementation GroupAddMemberTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self.selectBtn setImage:[UIImage imageNamed:@"添加群聊未选中"] forState:(UIControlStateNormal)];
    [self.selectBtn setImage:[UIImage imageNamed:@"添加群聊选中"] forState:(UIControlStateSelected)];
    [self.selectBtn setImage:[UIImage imageNamed:@"授权管理选中"] forState:(UIControlStateDisabled)];
    //点击cell便改变状态cell.selectBtn.enabled
    self.selectBtn.userInteractionEnabled = NO;
    self.nickNameLabel.textColor = [UIColor colorMainTextColor];
    ViewRadius(self.headImageView, self.headImageView.frame.size.width/2);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (self.selectBtn.enabled) {
        [super setSelected:selected animated:animated];
    }
    
    // Configure the view for the selected state
}

@end
