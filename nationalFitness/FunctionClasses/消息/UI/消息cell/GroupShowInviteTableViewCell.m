//
//  GroupShowInviteTableViewCell.m
//  nationalFitness
//
//  Created by Joe on 2017/9/14.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "GroupShowInviteTableViewCell.h"

@implementation GroupShowInviteTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    
    ViewRadius(self.GroupShowMessageLabel, 3);
    
    
    
    
}







- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
