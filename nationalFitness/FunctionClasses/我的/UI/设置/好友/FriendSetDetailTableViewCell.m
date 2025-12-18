//
//  FriendSetDetailTableViewCell.m
//  nationalFitness
//
//  Created by Joe on 2017/8/9.
//  Copyright © 2017年 chenglong. All rights reserved.
//

#import "FriendSetDetailTableViewCell.h"
#import "UIFont+RYChat.h"

@implementation FriendSetDetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    ViewRadius(self.imagView, self.imagView.frame.size.width/2);
    
    self.nameLabel.font = [UIFont fontMainText];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
